import 'package:flutter/material.dart';
import 'package:venera_next/design_system/tokens.dart';
import 'package:venera_next/foundation/translations.dart';
import 'workspace_record.dart';

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
  });
  final WorkspaceRecord record;
  final ValueChanged<String> activate, close;
  final VoidCallback newTab;
  final Set<String> visited;
  @override
  Widget build(BuildContext context) {
    final scale =
        MediaQuery.textScalerOf(context).scale(AppFontSize.body) /
        AppFontSize.body;
    return Material(
      color: Theme.of(context).colorScheme.shellSurface,
      child: Container(
        height: AppSizes.workspaceTabHeight * scale,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.shellBorder,
              width: AppSizes.hairline,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final tab in record.tabs)
                      _Tab(
                        key: ValueKey(tab.id),
                        title: workspaceTitle(tab.current),
                        active: record.activeId == tab.id,
                        activate: () => activate(tab.id),
                        close: () => close(tab.id),
                        scale: scale,
                      ),
                  ],
                ),
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'All tabs'.tl,
              onSelected: activate,
              itemBuilder: (context) => [
                for (final tab in record.tabs)
                  PopupMenuItem(
                    value: tab.id,
                    child: ListTile(
                      dense: true,
                      selected: tab.id == record.activeId,
                      leading: Icon(
                        visited.contains(tab.id)
                            ? Icons.tab
                            : Icons.pending_outlined,
                      ),
                      title: Text(workspaceTitle(tab.current)),
                    ),
                  ),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text(
                  'All @count'.tlParams({'count': record.tabs.length}),
                ),
              ),
            ),
            IconButton(
              tooltip: 'New tab'.tl,
              onPressed: newTab,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatefulWidget {
  const _Tab({
    super.key,
    required this.title,
    required this.active,
    required this.activate,
    required this.close,
    required this.scale,
  });
  final String title;
  final bool active;
  final VoidCallback activate, close;
  final double scale;
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
                  ? scheme.accentContainer
                  : scheme.shellSurface,
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
                              dimension: AppSizes.workspaceTabHeight,
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
    );
  }
}
