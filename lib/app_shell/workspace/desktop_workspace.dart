import 'dart:async';
import 'package:flutter/material.dart';
import 'package:venera_next/app_shell/desktop_chrome.dart';
import 'package:venera_next/components/navigation_bar.dart';
import 'package:venera_next/components/settings_save_state.dart';
import 'package:venera_next/components/window_frame.dart';
import 'package:venera_next/components/window_selection_task.dart';
import 'package:venera_next/foundation/app.dart';
import 'package:venera_next/foundation/appdata.dart';
import 'package:venera_next/foundation/application_preferences.dart';
import 'package:venera_next/foundation/global_preference_store.dart';
import 'package:venera_next/foundation/app_page_route.dart';
import 'package:venera_next/foundation/navigation_admission.dart';
import 'package:venera_next/foundation/selection_operation.dart';
import 'package:venera_next/foundation/translations.dart';
import 'package:venera_next/routing/app_navigation.dart';
import 'package:venera_next/design_system/tokens.dart';
import 'workspace_record.dart';
import 'workspace_store.dart';
import 'workspace_page_scope.dart';
import 'workspace_pages.dart';
import 'workspace_tab_strip.dart';
import 'workspace_navigation_scope.dart';

/// The desktop shell has one visible content stack, with retained siblings.
class DesktopWorkspace extends StatefulWidget {
  const DesktopWorkspace({super.key});
  @override
  State<DesktopWorkspace> createState() => DesktopWorkspaceState();
  static DesktopWorkspaceState? of(BuildContext context) =>
      context.findAncestorStateOfType<DesktopWorkspaceState>();
}

class DesktopWorkspaceState extends SettingsSaveState<DesktopWorkspace> {
  late final WorkspaceStore store;
  late final WorkspaceRecord record;
  final _tabs = <String, _RuntimeTab>{};
  final _shellKey = GlobalKey<NaviPaneState>();
  final _unusedNavigator = GlobalKey<NavigatorState>();
  final _unusedObserver = NaviObserver();
  DesktopChromeController? _chrome;
  DesktopChromeController? _boundChrome;
  late final ValueChanged<int> _navigateCallback = _navigateRoot;
  late final VoidCallback _backCallback = back;
  late final VoidCallback _openSettings = _showSettings;
  late final VoidCallback _openSearch = _showSearch;
  void _showSettings() =>
      openCurrent(WorkspaceRouteRecord(kind: WorkspacePageKind.settings));
  void _showSearch() =>
      openCurrent(WorkspaceRouteRecord(kind: WorkspacePageKind.search));
  late final DesktopWorkspaceActions _workspaceActions =
      DesktopWorkspaceActions(
        newTab: newTab,
        closeTab: () =>
            record.activeId == null ? null : close(record.activeId!),
        nextTab: () => _cycle(1),
        previousTab: () => _cycle(-1),
        back: back,
      );
  void _cycle(int direction) {
    if (record.tabs.isEmpty) return;
    final index = record.tabs.indexWhere((tab) => tab.id == record.activeId);
    activateTab(record.tabs[(index + direction) % record.tabs.length].id);
  }

  void _queryCurrent(String query) {
    final local = _tabs[record.activeId]?.chrome;
    local?.searchController.text = query;
    local?.updateSearchQuery(query);
  }

  WindowFrameController? _frame;
  Timer? _saveTimer;
  int _saveRevision = 0;
  bool _syncScheduled = false;
  String? recoveryMessage;
  Object? closeError;
  String? _failedClose;

  @override
  void initState() {
    super.initState();
    store = WorkspaceStore(App.dataPath);
    WorkspaceRecord? restored;
    if (GlobalPreferenceStore(
          appdata.settings,
        ).read(WorkspacePreferences.startup) !=
        'fresh') {
      try {
        restored = store.read();
        if (restored == null) {
          recoveryMessage = 'No saved workspace. Opened favorites.'.tl;
        }
      } on FormatException {
        recoveryMessage =
            'The saved workspace could not be restored. Opened favorites.'.tl;
      }
    }
    if (restored == null) {
      final first = WorkspaceTabRecord(
        routes: [WorkspaceRouteRecord(kind: WorkspacePageKind.favorites)],
      );
      restored = WorkspaceRecord(
        directory: store.directory,
        tabs: [first],
        activeId: first.id,
        recent: [first.id],
      );
    }
    record = restored;
    if (record.tabs.any((tab) => tab.restoreParent)) {
      recoveryMessage =
          'Temporary pages were not restored. Returned to their previous pages.'
              .tl;
      for (final tab in record.tabs) {
        tab.restoreParent = false;
      }
      // Consume the marker reliably, even if the user does not navigate.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _changed();
      });
    }
    for (final tab in record.tabs) {
      _tabs[tab.id] = _RuntimeTab(tab, this);
    }
    final active = _tabs[record.activeId];
    if (active != null) {
      active.mountedOnce = true;
      appNavigation.mainNavigatorKey = active.navigator;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = DesktopChromeScope.maybeOf(context);
    if (!identical(next, _chrome)) {
      _chrome = next;
      _scheduleSync();
    }
    final frame = context
        .getInheritedWidgetOfExactType<WindowFrameController>();
    if (_frame?.addExitTask != frame?.addExitTask) {
      _frame?.removeExitTask(_flush);
      _frame = frame;
      frame?.addExitTask(_flush);
    }
  }

  void _scheduleSync() {
    if (_syncScheduled) return;
    _syncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (!mounted) return;
      _syncChrome();
      setState(() {});
    });
  }

  void _syncChrome() {
    final chrome = _chrome;
    if (chrome == null) return;
    final tab = _tabs[record.activeId];
    final local = tab?.chrome;
    final favorites = tab?.record.current.kind == WorkspacePageKind.favorites;
    local?.setFavoritesActive(favorites);
    if (!identical(_boundChrome, chrome)) {
      _boundChrome?.setWorkspaceActions(null);
      _boundChrome?.clearGlobalActions();
      _boundChrome = chrome;
      chrome.bindGlobalActions(
        openSettings: _openSettings,
        openSearch: _openSearch,
        navigate: _navigateCallback,
        back: _backCallback,
      );
      chrome.setWorkspaceActions(_workspaceActions);
    }
    final navigationKinds = [
      WorkspacePageKind.home,
      WorkspacePageKind.favorites,
      WorkspacePageKind.explore,
      WorkspacePageKind.categories,
    ];
    final root = tab?.record.routes
        .where((route) => navigationKinds.contains(route.kind))
        .lastOrNull;
    final shell = _shellKey.currentState;
    if (root != null && shell != null) {
      shell.currentPage = navigationKinds.indexOf(root.kind);
    }
    chrome.setFavoritesActive(favorites);
    chrome.setLeftSidebar(
      available: local?.leftAvailable ?? false,
      expanded: local?.leftExpanded ?? true,
      toggle: local?.toggleLeftSidebar,
    );
    chrome.setRightSidebar(
      available: local?.rightAvailable ?? false,
      expanded: local?.rightExpanded ?? false,
      toggle: local?.toggleRightSidebar,
    );
    chrome.setFavoritesSearchQuery(tab == null ? null : _queryCurrent);
    DesktopChromeScope.setReaderActions(
      chrome,
      tab?.activeRouteRecord == null ? null : local?.readerActions,
    );
    if (tab != null) appNavigation.mainNavigatorKey = tab.navigator;
  }

  void _navigateRoot(int index) {
    final kind = [
      WorkspacePageKind.home,
      WorkspacePageKind.favorites,
      WorkspacePageKind.explore,
      WorkspacePageKind.categories,
    ][index];
    openCurrent(WorkspaceRouteRecord(kind: kind));
  }

  void _capture() {
    for (final tab in _tabs.values) {
      for (final binding in tab.bindings.values) {
        binding.capture();
      }
    }
  }

  void _changed() {
    if (!mounted) return;
    _scheduleSync();
    _saveTimer?.cancel();
    final revision = ++_saveRevision;
    _saveTimer = Timer(AppMotion.normal, () async {
      // A newly activated route registers its view during the next frame.
      // Freeze after that frame, including when a busy frame outlasts debounce.
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted ||
          revision != _saveRevision ||
          !acceptsSettingsChanges ||
          !store.isCurrent) {
        return;
      }
      _capture();
      unawaited(
        saveSetting(
          WorkspaceStore.key,
          store.assignment(record),
          showSavedFeedback: false,
          isCurrent: () => store.isCurrent,
        ),
      );
    });
  }

  Future<void> _flush() async {
    _saveTimer?.cancel();
    _saveRevision++;
    _capture();
    await store.assignment(record)();
  }

  void activateTab(String id, {bool rememberPrevious = true}) {
    if (!acceptsSettingsChanges || !_tabs.containsKey(id)) return;
    final previous = _tabs[record.activeId];
    if (rememberPrevious) {
      previous?.bindings[previous.record.current.id]?.rememberFocus();
    }
    _capture();
    record.activate(id);
    final tab = _tabs[id]!;
    tab.mountedOnce = true;
    appNavigation.mainNavigatorKey = tab.navigator;
    for (final item in _tabs.values) {
      item.updateActivity(item == tab);
    }
    final chrome = _chrome;
    if (chrome != null &&
        chrome.searchController.text != tab.chrome.searchController.text) {
      chrome.searchController.text = tab.chrome.searchController.text;
    }
    // Activate the subtree in this frame before the post-frame focus return.
    // Chrome synchronization itself runs after layout and cannot do this work.
    setState(() {});
    _changed();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && record.activeId == id) {
        tab.bindings[tab.activeRouteRecord?.id]?.restoreFocus();
      }
    });
  }

  void newTab() => openBackground(
    WorkspaceRouteRecord(kind: WorkspacePageKind.favorites),
    activateNow: true,
  );
  void openBackground(WorkspaceRouteRecord page, {bool activateNow = false}) {
    if (!acceptsSettingsChanges) return;
    final tab = WorkspaceTabRecord(routes: [page]);
    record.add(tab, background: true);
    _tabs[tab.id] = _RuntimeTab(tab, this);
    if (activateNow) {
      activateTab(tab.id);
    } else {
      _changed();
    }
  }

  void openCurrent(WorkspaceRouteRecord page) {
    final tab = _tabs[record.activeId];
    if (tab == null) {
      openBackground(page, activateNow: true);
      return;
    }
    final navigator = tab.navigator.currentState;
    if (navigator == null || !NavigationAdmission.allows(navigator.context)) {
      return;
    }
    navigator.push(tab.route(page));
  }

  void back() {
    final navigator = _tabs[record.activeId]?.navigator.currentState;
    if (navigator != null &&
        NavigationAdmission.allows(navigator.context) &&
        navigator.canPop()) {
      navigator.maybePop();
    }
  }

  Future<void> close(String id) async {
    final tab = _tabs[id];
    if (tab == null || !acceptsSettingsChanges || tab.closing) return;
    tab.closing = true;
    try {
      await tab.tasks.closeAndWait();
      if (!mounted) return;
      _capture();
      final wasActive = record.activeId == id;
      record.close(
        id,
        target: GlobalPreferenceStore(
          appdata.settings,
        ).read(WorkspacePreferences.closeTarget),
      );
      _tabs.remove(id);
      // Unmount the removed subtree in the next frame before its owned
      // chrome/bindings are released by the post-frame callback below.
      setState(() {});
      if (_failedClose == id) {
        _failedClose = null;
        closeError = null;
      }
      if (wasActive && record.activeId != null) {
        // The model already chose the destination. Its stored focus belongs
        // to that stack; the current native focus still belongs to the tab
        // being removed and must not overwrite it.
        activateTab(record.activeId!, rememberPrevious: false);
      }
      _changed();
      WidgetsBinding.instance.addPostFrameCallback((_) => tab.dispose());
    } catch (error) {
      if (mounted) {
        setState(() {
          closeError = error;
          _failedClose = id;
        });
      }
    } finally {
      tab.closing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Workspace feedback/empty states sit outside the individual page routes.
    // Give them the same Material typography as the surrounding shell.
    final content = Material(
      color: Theme.of(context).colorScheme.shellSurface,
      child: Column(
        children: [
          WorkspaceTabStrip(
            record: record,
            openBackground: openBackground,
            activate: activateTab,
            close: close,
            newTab: newTab,
            visited: {
              for (final tab in _tabs.values)
                if (tab.mountedOnce) tab.record.id,
            },
          ),
          if (recoveryMessage != null)
            Row(
              children: [
                Expanded(child: Text(recoveryMessage!)),
                IconButton(
                  tooltip: 'Dismiss'.tl,
                  onPressed: () => setState(() => recoveryMessage = null),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          if (closeError != null)
            Row(
              children: [
                Expanded(child: Text('Could not close tab. Try again.'.tl)),
                TextButton(
                  onPressed: () => close(_failedClose!),
                  child: Text('Retry'.tl),
                ),
              ],
            ),
          Expanded(
            child: Stack(
              children: [
                for (final tab in _tabs.values)
                  if (tab.mountedOnce)
                    Positioned.fill(
                      key: ValueKey(tab.record.id),
                      child: Offstage(
                        offstage: tab.record.id != record.activeId,
                        child: TickerMode(
                          enabled: tab.record.id == record.activeId,
                          child: ExcludeFocus(
                            excluding: tab.record.id != record.activeId,
                            child: SelectionTasksScope(
                              registry: tab.tasks,
                              child: DesktopChromeScope(
                                controller: tab.chrome,
                                child: HeroControllerScope(
                                  controller: tab.heroes,
                                  child: Navigator(
                                    key: tab.navigator,
                                    observers: [tab.observer],
                                    routeTraversalEdgeBehavior:
                                        TraversalEdgeBehavior.parentScope,
                                    onGenerateInitialRoutes: (_, _) => [
                                      for (final route
                                          in List<WorkspaceRouteRecord>.of(
                                            tab.record.routes,
                                          ))
                                        tab.route(route),
                                    ],
                                    onGenerateRoute: (_) => null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                if (record.activeId == null)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('No tabs open'.tl),
                        TextButton(
                          onPressed: newTab,
                          child: Text('Open favorites'.tl),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    return WorkspaceNavigationScope(
      openBackground: openBackground,
      child: NaviPane(
        bookshelf: true,
        key: _shellKey,
        initialPage: 1,
        observer: _unusedObserver,
        navigatorKey: _unusedNavigator,
        onWorkspaceNavigate: _navigateRoot,
        paneItems: [
          for (final pair in [
            ('Home', Icons.home_outlined),
            ('Favorites', Icons.local_activity_outlined),
            ('Explore', Icons.explore_outlined),
            ('Categories', Icons.category_outlined),
          ])
            PaneItemEntry(
              label: pair.$1.tl,
              icon: pair.$2,
              activeIcon: pair.$2,
            ),
        ],
        paneActions: [
          PaneActionEntry(
            label: 'Settings'.tl,
            icon: Icons.settings_outlined,
            onTap: () => openCurrent(
              WorkspaceRouteRecord(kind: WorkspacePageKind.settings),
            ),
          ),
        ],
        pageBuilder: (_) => const SizedBox(),
        workspace: withSettingsSaveFailureFeedback(content),
      ),
    );
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _frame?.removeExitTask(_flush);
    for (final tab in _tabs.values) {
      tab.chrome.removeListener(_scheduleSync);
    }
    final detached = List<_RuntimeTab>.of(_tabs.values);
    _chrome?.setFavoritesActive(false);
    _chrome?.setLeftSidebar(available: false, expanded: true);
    _chrome?.setRightSidebar(available: false, expanded: false);
    _chrome?.setFavoritesSearchQuery(null);
    DesktopChromeScope.setReaderActions(_chrome, null);
    _chrome?.setWorkspaceActions(null);
    _chrome?.clearGlobalActions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final tab in detached) {
        tab.dispose();
      }
    });
    super.dispose();
  }
}

class _RuntimeTab {
  _RuntimeTab(this.record, this.owner) {
    observer = _WorkspaceObserver(this);
    chrome.addListener(owner._scheduleSync);
  }
  final WorkspaceTabRecord record;
  final DesktopWorkspaceState owner;
  final navigator = GlobalKey<NavigatorState>();
  final chrome = DesktopChromeController();
  final tasks = SelectionTaskRegistry();
  final heroes = MaterialApp.createMaterialHeroController();
  final bindings = <String, WorkspacePageBinding>{};
  final tracked = <Route<dynamic>, WorkspaceRouteRecord>{};
  final liveRoutes = <Route<dynamic>>[];
  final auxiliaryRoutes = <Route<dynamic>>{};
  WorkspaceRouteRecord? get activeRouteRecord =>
      liveRoutes.isEmpty ? null : tracked[liveRoutes.last];
  late final _WorkspaceObserver observer;
  bool mountedOnce = false, closing = false;
  WorkspacePageBinding binding(WorkspaceRouteRecord record) =>
      bindings.putIfAbsent(
        record.id,
        () => WorkspacePageBinding(record, owner._changed),
      );
  Route<dynamic> route(WorkspaceRouteRecord record) => AppPageRoute(
    settings: RouteSettings(arguments: record),
    builder: (_) => buildWorkspacePage(record),
  );
  void updateActivity(bool active) {
    final current = activeRouteRecord;
    record.restoreParent =
        liveRoutes.isNotEmpty && auxiliaryRoutes.contains(liveRoutes.last);
    for (final entry in bindings.entries) {
      entry.value.setActive(active && entry.key == current?.id);
    }
  }

  void dispose() {
    chrome.removeListener(owner._scheduleSync);
    for (final binding in bindings.values) {
      binding.dispose();
    }
    chrome.dispose();
    heroes.dispose();
  }
}

class _WorkspaceObserver extends NavigatorObserver {
  _WorkspaceObserver(this.tab);
  final _RuntimeTab tab;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    tab.bindings[tab.activeRouteRecord?.id]?.rememberFocus();
    tab.liveRoutes.add(route);
    _observe(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    tab.bindings[tab.activeRouteRecord?.id]?.rememberFocus();
    final index = tab.liveRoutes.indexOf(oldRoute!);
    if (index < 0 || newRoute == null) return;
    tab.liveRoutes[index] = newRoute;
    tab.auxiliaryRoutes.remove(oldRoute);
    final previous = tab.tracked.remove(oldRoute);
    if (previous != null) {
      tab.bindings[previous.id]?.setActive(false);
      tab.record.routes.removeWhere((r) => r.id == previous.id);
    }
    _observe(newRoute);
  }

  void _observe(Route<dynamic> route) {
    if (route is! AppPageRoute) {
      tab.updateActivity(tab.owner.record.activeId == tab.record.id);
      return;
    }
    // Suspend before building the incoming route; its builder must run only
    // in the real route context, never speculatively from this observer.
    if (identical(tab.liveRoutes.last, route)) {
      for (final binding in tab.bindings.values) {
        binding.setActive(false);
      }
    }
    final args = route.settings.arguments;
    if (args is WorkspaceRouteRecord) {
      _track(route, args);
    } else {
      route.workspaceWrapper = (child) {
        final record = describeWorkspacePage(child);
        if (record == null) {
          if (isWorkspaceAuxiliaryPage(child)) tab.auxiliaryRoutes.add(route);
          tab.updateActivity(tab.owner.record.activeId == tab.record.id);
          tab.owner._changed();
          return child;
        }
        _track(route, record);
        return route.workspaceWrapper!(child);
      };
    }
  }

  void _track(AppPageRoute route, WorkspaceRouteRecord record) {
    final added = !tab.record.routes.any((r) => r.id == record.id);
    if (added) {
      // Replacement can occur below the visible route. Keep its exact stack
      // position rather than appending it as a new current page.
      final index = tab.liveRoutes.indexOf(route);
      final before = tab.liveRoutes
          .take(index)
          .where(tab.tracked.containsKey)
          .length;
      tab.record.routes.insert(before, record);
    }
    tab.tracked[route] = record;
    final binding = tab.binding(record);
    route.workspaceWrapper = (child) =>
        _DeferredPage(binding: binding, child: child);
    tab.updateActivity(tab.owner.record.activeId == tab.record.id);
    if (added) {
      tab.owner._changed();
    } else {
      tab.owner._scheduleSync();
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _remove(route);
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _remove(route);
  void _remove(Route<dynamic> route) {
    tab.liveRoutes.remove(route);
    tab.auxiliaryRoutes.remove(route);
    final record = tab.tracked.remove(route);
    if (record != null) {
      tab.record.routes.removeWhere((r) => r.id == record.id);
    }
    if (tab.record.routes.isEmpty) return;
    tab.updateActivity(tab.owner.record.activeId == tab.record.id);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (tab.owner.mounted) {
        tab.bindings[tab.activeRouteRecord?.id]?.restoreFocus();
      }
    });
    tab.owner._changed();
  }
}

class _DeferredPage extends StatefulWidget {
  const _DeferredPage({required this.binding, required this.child});
  final WorkspacePageBinding binding;
  final Widget child;
  @override
  State<_DeferredPage> createState() => _DeferredPageState();
}

class _DeferredPageState extends State<_DeferredPage> {
  bool built = false;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.binding,
    builder: (context, _) {
      built = built || widget.binding.active;
      return WorkspacePageScope(
        binding: widget.binding,
        child: built ? widget.child : const SizedBox(),
      );
    },
  );
}
