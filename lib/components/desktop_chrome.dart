import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:venera_next/foundation/app.dart';

/// Reader actions exposed to the desktop menus and shortcuts.
class DesktopReaderActions {
  const DesktopReaderActions({
    required this.openSettings,
    required this.openChapters,
    required this.toggleThumbnails,
    this.filterChapters,
    this.submitChapterSearch,
    this.toggleFullscreen,
    this.immersive = false,
  });

  final VoidCallback openSettings;
  final VoidCallback openChapters;
  final VoidCallback toggleThumbnails;
  final ValueChanged<String>? filterChapters;
  final ValueChanged<String>? submitChapterSearch;
  final VoidCallback? toggleFullscreen;
  final bool immersive;
}

class DesktopWorkspaceActions {
  const DesktopWorkspaceActions({
    required this.newTab,
    required this.closeTab,
    required this.nextTab,
    required this.previousTab,
    required this.back,
  });
  final VoidCallback newTab, closeTab, nextTab, previousTab, back;
}

/// Shell-level state shared by the custom title bar, menus and shortcuts.
/// Pages register their available sidebars/actions while they are mounted.
class DesktopChromeController extends ChangeNotifier {
  bool _disposed = false;
  DesktopWorkspaceActions? _workspaceActions;
  WidgetBuilder? _workspaceTabsBuilder;
  bool _workspaceTabsVisible = true;
  WidgetBuilder? get workspaceTabsBuilder =>
      _workspaceTabsVisible ? _workspaceTabsBuilder : null;
  void setWorkspaceTabs({WidgetBuilder? builder, bool visible = true}) {
    if (identical(_workspaceTabsBuilder, builder) &&
        _workspaceTabsVisible == visible) {
      return;
    }
    _workspaceTabsBuilder = builder;
    _workspaceTabsVisible = visible;
    notifyListeners();
  }

  void refreshWorkspaceTabs() {
    // Workspace observers track routes while the incoming route builds, so the
    // refresh must not mark this scope dirty during the build phase.
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_disposed) notifyListeners();
      });
      return;
    }
    notifyListeners();
  }

  DesktopWorkspaceActions? get workspaceActions => _workspaceActions;
  void setWorkspaceActions(DesktopWorkspaceActions? actions) {
    if (identical(_workspaceActions, actions)) return;
    _workspaceActions = actions;
    notifyListeners();
  }

  VoidCallback? _toggleBookshelf;
  bool _bookshelfExpanded = true;
  bool get bookshelfAvailable => _toggleBookshelf != null;
  bool get bookshelfExpanded => _bookshelfExpanded;
  void toggleBookshelf() => _toggleBookshelf?.call();
  void setBookshelf({VoidCallback? toggle, bool expanded = true}) {
    if (_toggleBookshelf == toggle && _bookshelfExpanded == expanded) return;
    _toggleBookshelf = toggle;
    _bookshelfExpanded = expanded;
    notifyListeners();
  }

  bool _favoritesActive = false;
  bool _leftAvailable = false;
  bool _leftExpanded = true;
  VoidCallback? _toggleLeft;
  bool _rightAvailable = false;
  bool _rightExpanded = false;
  VoidCallback? _toggleRight;
  ValueChanged<String>? _favoritesSearchQuery;
  DesktopReaderActions? _readerActions;

  VoidCallback? _openSettings;
  VoidCallback? _openSearch;
  void Function(int index)? _navigate;
  VoidCallback? _back;

  bool get favoritesActive => _favoritesActive;
  bool get leftAvailable => _leftAvailable;
  bool get leftExpanded => _leftExpanded;
  bool get rightAvailable => _rightAvailable;
  bool get rightExpanded => _rightExpanded;
  DesktopReaderActions? get readerActions => _readerActions;

  void setFavoritesActive(bool value) {
    if (value == _favoritesActive) return;
    _favoritesActive = value;
    notifyListeners();
  }

  void setLeftSidebar({
    required bool available,
    required bool expanded,
    VoidCallback? toggle,
  }) {
    if (available == _leftAvailable &&
        expanded == _leftExpanded &&
        toggle == _toggleLeft) {
      return;
    }
    _leftAvailable = available;
    _leftExpanded = expanded;
    _toggleLeft = toggle;
    notifyListeners();
  }

  void setRightSidebar({
    required bool available,
    required bool expanded,
    VoidCallback? toggle,
  }) {
    if (available == _rightAvailable &&
        expanded == _rightExpanded &&
        toggle == _toggleRight) {
      return;
    }
    _rightAvailable = available;
    _rightExpanded = expanded;
    _toggleRight = toggle;
    notifyListeners();
  }

  void setFavoritesSearchQuery(ValueChanged<String>? search) {
    if (search == _favoritesSearchQuery) return;
    _favoritesSearchQuery = search;
    notifyListeners();
  }

  void setReaderActions(
    DesktopReaderActions? actions, {
    void Function(VoidCallback notification)? dispatch,
  }) {
    if (identical(actions, _readerActions)) return;
    _readerActions = actions;
    void notify() {
      if (!_disposed) notifyListeners();
    }

    if (dispatch == null) {
      notify();
    } else {
      dispatch(notify);
    }
  }

  void bindGlobalActions({
    required VoidCallback openSettings,
    required VoidCallback openSearch,
    required void Function(int index) navigate,
    required VoidCallback back,
  }) {
    final changed =
        openSettings != _openSettings ||
        openSearch != _openSearch ||
        navigate != _navigate ||
        back != _back;
    _openSettings = openSettings;
    _openSearch = openSearch;
    _navigate = navigate;
    _back = back;
    if (changed) notifyListeners();
  }

  void clearGlobalActions() {
    _openSettings = null;
    _openSearch = null;
    _navigate = null;
    _back = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  void toggleLeftSidebar() => _toggleLeft?.call();

  void toggleRightSidebar() => _toggleRight?.call();

  /// Cmd+, opens reader settings while reading, otherwise general settings.
  void openSettingsAction() =>
      (_readerActions?.openSettings ?? _openSettings)?.call();

  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode(debugLabel: 'desktop search');

  /// Cmd+F / clicking the search box: focus the top bar search field. In the
  /// reader the search target is the chapter list.
  void focusSearch() {
    final reader = _readerActions;
    if (reader != null) {
      reader.openChapters();
      reader.filterChapters?.call(searchController.text);
    }
    searchFocusNode.requestFocus();
    searchController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: searchController.text.length,
    );
  }

  void openSearchAction() => focusSearch();

  void openGlobalSearch() => _openSearch?.call();

  /// Reader actions take precedence over a still-mounted favorites page.
  void updateSearchQuery(String value) {
    final reader = _readerActions;
    if (reader != null) {
      reader.filterChapters?.call(value);
    } else if (_favoritesActive) {
      _favoritesSearchQuery?.call(value);
    }
  }

  /// Enter selects a matching chapter, filters favorites, or opens global search.
  void submitSearch(String value) {
    final reader = _readerActions;
    if (reader != null) {
      reader.filterChapters?.call(value);
      reader.submitChapterSearch?.call(value);
      return;
    }
    final favorites = _favoritesSearchQuery;
    if (_favoritesActive && favorites != null) {
      favorites(value);
      return;
    }
    _openSearch?.call();
  }

  void navigateTo(int index) => _navigate?.call(index);

  void goBack() => _back?.call();

  bool get canNavigate => _navigate != null;
}

class DesktopChromeScope extends InheritedNotifier<DesktopChromeController> {
  const DesktopChromeScope({
    super.key,
    required DesktopChromeController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Route owners revoke immediately, but widget listeners cannot rebuild
  /// during a locked frame. Pure controllers retain synchronous notification.
  static void setReaderActions(
    DesktopChromeController? controller,
    DesktopReaderActions? actions,
  ) => controller?.setReaderActions(
    actions,
    dispatch: (notify) {
      if (SchedulerBinding.instance.schedulerPhase ==
          SchedulerPhase.persistentCallbacks) {
        WidgetsBinding.instance.addPostFrameCallback((_) => notify());
      } else {
        notify();
      }
    },
  );

  static DesktopChromeController? maybeRead(BuildContext context) =>
      context.getInheritedWidgetOfExactType<DesktopChromeScope>()?.notifier;

  static DesktopChromeController? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<DesktopChromeScope>()
      ?.notifier;
}

/// Primary shortcut for the current desktop platform.
SingleActivator primaryShortcut(
  LogicalKeyboardKey key, {
  bool alt = false,
  bool shift = false,
}) => SingleActivator(
  key,
  meta: App.isMacOS,
  control: !App.isMacOS,
  alt: alt,
  shift: shift,
);
