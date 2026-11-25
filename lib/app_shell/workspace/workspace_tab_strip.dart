import 'package:flutter/material.dart';
import 'package:venera_next/design_system/breakpoints.dart';
import 'package:venera_next/design_system/tokens.dart';
import 'package:venera_next/foundation/translations.dart';
import 'package:venera_next/foundation/workspace_record.dart';
import 'package:venera_next/routing/app_navigation.dart';
import 'package:venera_next/components/workspace_comic_drag.dart';
import 'package:window_manager/window_manager.dart';

final workspaceTabDragActive = ValueNotifier<bool>(false);
final workspaceTabPointerOver = ValueNotifier<bool>(false);

class WorkspaceWindowDragArea extends StatelessWidget {
  const WorkspaceWindowDragArea({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([
      workspaceTabDragActive,
      workspaceTabPointerOver,
    ]),
    builder: (context, child) {
      final blocked =
          workspaceTabDragActive.value || workspaceTabPointerOver.value;
      return blocked
          ? IgnorePointer(child: child)
          : DragToMoveArea(child: child!);
    },
    child: child,
  );
}

String workspaceTitle(WorkspaceRouteRecord record) =>
    (record.arguments['title'] ??
            record.arguments['keyword'] ??
            switch (record.kind) {
              WorkspacePageKind.home => 'Home'.tl,
              WorkspacePageKind.favorites => 'Favorites'.tl,
              WorkspacePageKind.explore => 'Explore'.tl,
              WorkspacePageKind.categories => 'Categories'.tl,
              WorkspacePageKind.search => 'Search'.tl,
              WorkspacePageKind.searchResults => 'Search'.tl,
              WorkspacePageKind.aggregatedSearch => 'Search'.tl,
              WorkspacePageKind.comic => record.arguments['id'],
              WorkspacePageKind.reader => record.arguments['id'] ?? 'Reader'.tl,
              WorkspacePageKind.settings => 'Settings'.tl,
            })
        .toString();

class WorkspaceTabStrip extends StatelessWidget {
  const WorkspaceTabStrip({
    super.key,
    required this.record,
    required this.activate,
    required this.close,
    required this.newTab,
    required this.visited,
    required this.reorder,
    this.openBackground,
    this.openBackgroundAt,
    this.inline = false,
  });
  final WorkspaceRecord record;
  final ValueChanged<String> activate, close;
  final VoidCallback newTab;
  final Set<String> visited;
  final void Function(int oldIndex, int newIndex) reorder;
  final ValueChanged<WorkspaceRouteRecord>? openBackground;
  final void Function(int index, WorkspaceRouteRecord route)? openBackgroundAt;
  final bool inline;
  @override
  Widget build(BuildContext context) {
    final scale =
        MediaQuery.textScalerOf(context).scale(AppFontSize.body) /
        AppFontSize.body;
    return DragTarget<WorkspaceComicDrag>(
      onWillAcceptWithDetails: (details) =>
          openBackground != null && !details.data.cancelled,
      onAcceptWithDetails: (details) {
        if (details.data.cancelled) return;
        for (final route in details.data.routes) {
          openBackground?.call(route);
        }
      },
      builder: (context, candidates, rejected) => FocusTraversalGroup(
        // Tab order must follow the visual tab order even while the strip is
        // scrolled; reading-order sorting over clipped tabs is unstable.
        policy: WidgetOrderTraversalPolicy(),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              width: AppSizes.hairline,
              color: candidates.isNotEmpty
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0),
            ),
          ),
          child: Material(
            color: Theme.of(context).colorScheme.shellSurface,
            child: Container(
              height: inline
                  ? AppSizes.titleBarHeight
                  : AppSizes.workspaceTabHeight * scale,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.shellBorder,
                    width: inline ? 0 : AppSizes.hairline,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: MouseRegion(
                      onEnter: (_) => workspaceTabPointerOver.value = true,
                      onExit: (_) => workspaceTabPointerOver.value = false,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (
                              var index = 0;
                              index < record.tabs.length;
                              index++
                            )
                              _ComicDropTarget(
                                index: index,
                                openBackgroundAt: openBackgroundAt,
                                child: _ReorderableTab(
                                  key: ValueKey(record.tabs[index].id),
                                  index: index,
                                  maxIndex: record.tabs.length - 1,
                                  reorder: reorder,
                                  child: _Tab(
                                    title: workspaceTitle(
                                      record.tabs[index].current,
                                    ),
                                    active:
                                        record.activeId ==
                                        record.tabs[index].id,
                                    activate: () =>
                                        activate(record.tabs[index].id),
                                    close: () => close(record.tabs[index].id),
                                    scale: scale,
                                    inline: inline,
                                  ),
                                ),
                              ),
                            _ComicDropTarget(
                              index: record.tabs.length,
                              openBackgroundAt: openBackgroundAt,
                              child: const SizedBox(width: 8),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _AllTabsButton(
                    record: record,
                    activate: activate,
                    visited: visited,
                  ),
                  IconButton(
                    tooltip: 'New tab'.tl,
                    onPressed: newTab,
                    icon: const Icon(Icons.add),
                  ),
                  // Keep the trailing window-drag blank only when the row has
                  // room for it; compact/150% text must not overflow.
                  if (!Breakpoints.isCompact(context))
                    const SizedBox(width: 96),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens the "All N" tab list from the merged title bar.
///
/// [PopupMenuButton] resolves [Navigator] from its own context, but the title
/// bar lives above the app's Navigator. The menu is therefore shown through
/// the root navigator context while keeping the standard popup route, items
/// and keyboard semantics.
class _AllTabsButton extends StatelessWidget {
  const _AllTabsButton({
    required this.record,
    required this.activate,
    required this.visited,
  });

  final WorkspaceRecord record;
  final ValueChanged<String> activate;
  final Set<String> visited;

  List<PopupMenuEntry<String>> _items() => [
    for (final tab in record.tabs)
      PopupMenuItem<String>(
        value: tab.id,
        child: ListTile(
          dense: true,
          selected: tab.id == record.activeId,
          leading: Icon(
            visited.contains(tab.id) ? Icons.tab : Icons.pending_outlined,
          ),
          title: Text(workspaceTitle(tab.current)),
        ),
      ),
  ];

  Future<void> _showMenu(BuildContext buttonContext) async {
    final navigator = appNavigation.rootNavigatorKey.currentState;
    final rootContext = navigator?.context;
    final box = buttonContext.findRenderObject() as RenderBox?;
    final overlayEntry = navigator?.overlay?.context;
    if (rootContext == null || box == null || !box.hasSize) return;
    final overlay = overlayEntry?.findRenderObject() as RenderBox?;
    if (overlay == null) return;
    final selected = await showMenu<String>(
      context: rootContext,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          box.localToGlobal(Offset.zero, ancestor: overlay),
          box.localToGlobal(
            box.size.bottomRight(Offset.zero),
            ancestor: overlay,
          ),
        ),
        Offset.zero & overlay.size,
      ),
      items: _items(),
    );
    if (selected != null) activate(selected);
  }

  @override
  Widget build(BuildContext context) => Tooltip(
    message: 'All tabs'.tl,
    child: Builder(
      builder: (buttonContext) => InkWell(
        onTap: () => _showMenu(buttonContext),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text('All @count'.tlParams({'count': record.tabs.length})),
        ),
      ),
    ),
  );
}

class _ComicDropTarget extends StatelessWidget {
  const _ComicDropTarget({
    required this.index,
    this.openBackgroundAt,
    required this.child,
  });
  final int index;
  final void Function(int, WorkspaceRouteRecord)? openBackgroundAt;
  final Widget child;
  @override
  Widget build(BuildContext context) => DragTarget<WorkspaceComicDrag>(
    onWillAcceptWithDetails: (details) =>
        openBackgroundAt != null && !details.data.cancelled,
    onAcceptWithDetails: (details) {
      if (details.data.cancelled) return;
      for (final route in details.data.routes) {
        openBackgroundAt?.call(index, route);
      }
    },
    builder: (context, candidates, rejected) => Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (candidates.isNotEmpty)
          Positioned(
            left: 0,
            top: 2,
            bottom: 2,
            child: Container(
              width: 3,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
      ],
    ),
  );
}

class _ReorderableTab extends StatefulWidget {
  const _ReorderableTab({
    super.key,
    required this.index,
    required this.maxIndex,
    required this.reorder,
    required this.child,
  });
  final int index;
  final int maxIndex;
  final void Function(int, int) reorder;
  final Widget child;
  @override
  State<_ReorderableTab> createState() => _ReorderableTabState();
}

class _ReorderableTabState extends State<_ReorderableTab> {
  bool dragging = false;
  double lastX = 0;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onLongPressStart: (details) {
      dragging = true;
      lastX = details.globalPosition.dx;
      workspaceTabDragActive.value = true;
      setState(() {});
    },
    onLongPressMoveUpdate: (details) {
      final delta = details.globalPosition.dx - lastX;
      if (delta > 72 && widget.index < widget.maxIndex) {
        widget.reorder(widget.index, widget.index + 1);
        lastX = details.globalPosition.dx;
      } else if (delta < -72 && widget.index > 0) {
        widget.reorder(widget.index, widget.index - 1);
        lastX = details.globalPosition.dx;
      }
    },
    onLongPressEnd: (_) {
      dragging = false;
      workspaceTabDragActive.value = false;
      setState(() {});
    },
    child: AnimatedOpacity(
      opacity: dragging ? .55 : 1,
      duration: AppMotion.fast,
      child: widget.child,
    ),
  );
}

class _Tab extends StatefulWidget {
  const _Tab({
    required this.title,
    required this.active,
    required this.activate,
    required this.close,
    required this.scale,
    required this.inline,
  });
  final String title;
  final bool active;
  final VoidCallback activate, close;
  final double scale;
  final bool inline;
  @override
  State<_Tab> createState() => _TabState();
}

class _TabState extends State<_Tab> {
  bool hover = false, focus = false;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final showClose = widget.active || hover || focus;
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: Focus(
        onFocusChange: (value) => setState(() => focus = value),
        child: Semantics(
          selected: widget.active,
          button: true,
          label: widget.title,
          child: Tooltip(
            message: widget.title,
            waitDuration: AppMotion.tooltipWait,
            child: Material(
              color: widget.active
                  ? scheme.accentContainer.withValues(alpha: .55)
                  : scheme.shellSurface,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: scheme.outlineVariant.withValues(alpha: .45),
                      width: AppSizes.hairline,
                    ),
                  ),
                ),
                child: InkWell(
                  onTap: widget.activate,
                  child: SizedBox(
                    width: AppSizes.workspaceTabWidth * widget.scale,
                    child: Row(
                      children: [
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ExcludeSemantics(
                          excluding: !showClose,
                          child: IgnorePointer(
                            ignoring: !showClose,
                            child: Opacity(
                              opacity: showClose ? 1 : 0,
                              child: SizedBox.square(
                                dimension: widget.inline
                                    ? AppSizes.titleBarHeight
                                    : AppSizes.workspaceTabHeight,
                                child: IconButton(
                                  tooltip: 'Close tab'.tl,
                                  onPressed: showClose ? widget.close : null,
                                  icon: const Icon(
                                    Icons.close,
                                    size: AppSizes.shellIconSize,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
