import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:venera_next/components/settings_save_state.dart';
import 'package:venera_next/design_system/breakpoints.dart';
import 'package:venera_next/design_system/tokens.dart';
import 'package:venera_next/foundation/app.dart';
import 'package:venera_next/foundation/appdata.dart';
import 'package:venera_next/foundation/translations.dart';
import 'desktop_chrome.dart';
import 'desktop_top_bar.dart';

/// Keeps the navigator at a fixed position in the tree across width changes.
/// Compact overlay state never becomes the user's wide-window preference.
class BookshelfWorkspace extends StatefulWidget {
  const BookshelfWorkspace({
    super.key,
    required this.navigation,
    required this.child,
    this.showToolbar = true,
  });
  final Widget navigation;
  final Widget child;

  /// Standalone bookshelf tests and non-window hosts keep the legacy local
  /// toolbar. The desktop production shell renders these controls in the
  /// merged WindowFrame row instead.
  final bool showToolbar;
  @override
  State<BookshelfWorkspace> createState() => _BookshelfWorkspaceState();
}

class _BookshelfWorkspaceState extends SettingsSaveState<BookshelfWorkspace> {
  static const preferenceKey = 'bookshelfExpanded';
  late bool expanded;
  bool overlay = false;
  bool compact = false;
  DesktopChromeController? chrome;
  final overlayFocus = FocusScopeNode(debugLabel: 'bookshelf overlay');
  FocusNode? returnFocus;
  late final VoidCallback toggle = _toggle;

  @override
  void initState() {
    super.initState();
    expanded = appdata.implicitData[preferenceKey] != false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextCompact = Breakpoints.isCompact(context);
    if (compact != nextCompact) {
      overlay = false;
      if (overlayFocus.hasFocus) returnFocus?.requestFocus();
    }
    compact = nextCompact;
    final next = DesktopChromeScope.maybeOf(context);
    if (chrome != next) {
      chrome?.setBookshelf();
      chrome = next;
    }
    _scheduleSync();
  }

  void _scheduleSync() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      chrome?.setBookshelf(
        toggle: toggle,
        expanded: compact ? overlay : expanded,
      );
    }
  });

  void _closeOverlay() {
    if (!overlay) return;
    setState(() => overlay = false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && returnFocus?.context != null) returnFocus?.requestFocus();
    });
    _scheduleSync();
  }

  void _toggle() {
    if (!acceptsSettingsChanges) return;
    if (compact) {
      if (overlay) {
        _closeOverlay();
        return;
      }
      returnFocus = FocusManager.instance.primaryFocus;
      setState(() => overlay = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && overlay) overlayFocus.requestFocus();
      });
    } else {
      setState(() => expanded = !expanded);
      final value = expanded;
      final path = App.dataPath;
      unawaited(
        saveSetting(
          preferenceKey,
          () {
            if (App.dataPath != path) {
              throw StateError('Settings directory changed'.tl);
            }
            return appdata.updateImplicit(
              (draft) => draft[preferenceKey] = value,
            );
          },
          showSavedFeedback: false,
          isCurrent: () => App.dataPath == path,
        ),
      );
    }
    _scheduleSync();
  }

  @override
  void dispose() {
    chrome?.setBookshelf();
    overlayFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    overlayFocus.traversalEdgeBehavior = compact
        ? TraversalEdgeBehavior.closedLoop
        : TraversalEdgeBehavior.parentScope;
    final scheme = Theme.of(context).colorScheme;
    final immersive = chrome?.readerActions?.immersive == true;
    final scale =
        MediaQuery.textScalerOf(context).scale(AppFontSize.body) /
        AppFontSize.body;
    final width = math.min(
      AppSizes.bookshelfWidth,
      MediaQuery.sizeOf(context).width - AppSizes.navItemSize,
    );
    return Focus(
      canRequestFocus: false,
      onKeyEvent: (_, event) {
        if (compact &&
            overlay &&
            event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          _closeOverlay();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: withSettingsSaveFailureFeedback(
        Stack(
          children: [
            Positioned.fill(
              left: !immersive && !compact && expanded ? width : 0,
              child: ExcludeFocus(
                excluding: compact && overlay,
                child: Column(
                  children: [
                    Visibility(
                      visible: widget.showToolbar && !immersive,
                      maintainState: true,
                      child: Material(
                        color: scheme.shellSurface,
                        child: Container(
                          constraints: BoxConstraints(
                            minHeight: AppSizes.workspaceToolbarHeight * scale,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: scheme.shellBorder,
                                width: AppSizes.hairline,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Semantics(
                                toggled: compact ? overlay : expanded,
                                child: IconButton(
                                  tooltip: 'Toggle bookshelf'.tl,
                                  onPressed: _toggle,
                                  icon: const Icon(Icons.view_sidebar_outlined),
                                ),
                              ),
                              if (chrome != null)
                                IconButton(
                                  tooltip: 'Back'.tl,
                                  onPressed: chrome!.goBack,
                                  icon: const Icon(Icons.arrow_back),
                                ),
                              const Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: DesktopSearchBox(),
                                ),
                              ),
                              if (chrome?.favoritesActive == true)
                                const DesktopLayoutControls(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: widget.child),
                  ],
                ),
              ),
            ),
            if (!immersive && compact && overlay)
              Positioned.fill(
                child: ModalBarrier(
                  key: const ValueKey('bookshelf-scrim'),
                  dismissible: true,
                  onDismiss: _closeOverlay,
                  color: scheme.scrim.withValues(
                    alpha: AppOpacity.selectedContainer,
                  ),
                  semanticsLabel: 'Close bookshelf'.tl,
                ),
              ),
            if (!immersive && ((!compact && expanded) || (compact && overlay)))
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: width,
                child: FocusScope(
                  node: overlayFocus,
                  onKeyEvent: (_, event) {
                    if (compact &&
                        overlay &&
                        event is KeyDownEvent &&
                        event.logicalKey == LogicalKeyboardKey.escape) {
                      _closeOverlay();
                      return KeyEventResult.handled;
                    }
                    return KeyEventResult.ignored;
                  },
                  child: Material(
                    color: scheme.shellSurface,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: scheme.shellBorder,
                            width: AppSizes.hairline,
                          ),
                        ),
                      ),
                      child: widget.navigation,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
