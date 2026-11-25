import 'dart:math' as math;
import 'package:venera_next/components/workspace_navigation_scope.dart';
import 'package:venera_next/foundation/workspace_record.dart';
import 'package:venera_next/design_system/tokens.dart';
import 'package:venera_next/foundation/application_preferences.dart';
import 'package:venera_next/foundation/global_preference_store.dart';
import 'package:venera_next/foundation/keyword_settings_store.dart';
import 'package:venera_next/foundation/navigation_admission.dart';
import 'package:venera_next/components/settings_save_state.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:venera_next/components/gesture.dart';
import 'package:venera_next/components/image.dart';
import 'package:venera_next/components/menu.dart';
import 'package:venera_next/components/message.dart';
import 'package:venera_next/components/select.dart';
import 'package:venera_next/features/comic_source/comic_source_api.dart';
import 'package:venera_next/routing/app_navigation.dart';
import 'package:venera_next/foundation/app_locale.dart';
import 'package:venera_next/foundation/app.dart';
import 'package:venera_next/foundation/appdata.dart';
import 'package:venera_next/foundation/context.dart';
import 'package:venera_next/foundation/extensions.dart';
import 'package:venera_next/foundation/translations.dart';
import 'package:venera_next/foundation/widget_utils.dart';

import 'rating.dart';
import 'comic_preview.dart';
import 'comic_selection_drag.dart';

typedef ComicPageBuilder =
    Widget Function({
      required String id,
      required String sourceKey,
      String? cover,
      String? title,
      int? heroID,
    });

typedef ComicReaderBuilder =
    Widget Function({
      required String id,
      required String sourceKey,
      String? title,
    });

typedef AddComicFavoriteHandler =
    Future<void> Function(BuildContext context, List<Comic> comics);
typedef ComicTileStateResolver = ComicTileState Function(Comic comic);
typedef ComicTileImageProviderResolver = ImageProvider? Function(Comic comic);
typedef ComicWidgetListenerRegistrar = void Function(VoidCallback listener);
typedef ComicFavoriteDisplayStateResolver =
    ComicFavoriteDisplayState Function();

class ComicTileState {
  const ComicTileState({
    this.isFavorite = false,
    this.historyPage,
    this.historyMaxPage,
    this.historyDescription,
    this.historyTooltipDescription,
    this.historyCompactDescription,
    this.descriptionOverride,
    this.hasNewUpdate = false,
  });

  final bool isFavorite;
  final int? historyPage;
  final int? historyMaxPage;
  final String? historyDescription;
  final String? historyTooltipDescription;
  final String? historyCompactDescription;
  final String? descriptionOverride;
  final bool hasNewUpdate;
}

class ComicFavoriteDisplayState {
  const ComicFavoriteDisplayState({
    this.isGallery = false,
    this.galleryColumns,
  });

  final bool isGallery;
  final int? galleryColumns;
}

ComicPageBuilder? _comicPageBuilder;
ComicReaderBuilder? _comicReaderBuilder;

AddComicFavoriteHandler? _addComicFavoriteHandler;
ComicTileStateResolver? _comicTileStateResolver;
ComicTileImageProviderResolver? _comicTileImageProviderResolver;
ComicWidgetListenerRegistrar? _addComicWidgetStateListener;
ComicWidgetListenerRegistrar? _removeComicWidgetStateListener;
ComicFavoriteDisplayStateResolver? _comicFavoriteDisplayStateResolver;

void configureComicWidgets({
  ComicPageBuilder? comicPageBuilder,
  ComicReaderBuilder? comicReaderBuilder,
  AddComicFavoriteHandler? addFavorite,
  ComicTileStateResolver? tileStateResolver,
  ComicTileImageProviderResolver? tileImageProviderResolver,
  ComicWidgetListenerRegistrar? addStateListener,
  ComicWidgetListenerRegistrar? removeStateListener,
  ComicFavoriteDisplayStateResolver? favoriteDisplayStateResolver,
}) {
  _comicPageBuilder = comicPageBuilder;
  _comicReaderBuilder = comicReaderBuilder;
  _addComicFavoriteHandler = addFavorite;
  _comicTileStateResolver = tileStateResolver;
  _comicTileImageProviderResolver = tileImageProviderResolver;
  _addComicWidgetStateListener = addStateListener;
  _removeComicWidgetStateListener = removeStateListener;
  _comicFavoriteDisplayStateResolver = favoriteDisplayStateResolver;
}

void addComicWidgetStateListener(VoidCallback listener) {
  _addComicWidgetStateListener?.call(listener);
}

void removeComicWidgetStateListener(VoidCallback listener) {
  _removeComicWidgetStateListener?.call(listener);
}

ComicFavoriteDisplayState comicFavoriteDisplayState() {
  return _comicFavoriteDisplayStateResolver?.call() ??
      const ComicFavoriteDisplayState();
}

Widget _buildComicPage({
  required String id,
  required String sourceKey,
  String? cover,
  String? title,
  int? heroID,
}) {
  final builder =
      _comicPageBuilder ??
      (throw StateError("Comic page builder is not configured."));
  return builder(
    id: id,
    sourceKey: sourceKey,
    cover: cover,
    title: title,
    heroID: heroID,
  );
}

void _openComicPage({
  BuildContext? context,
  required String id,
  required String sourceKey,
  String? cover,
  String? title,
  int? heroID,
}) {
  final targetContext =
      context ?? appNavigation.mainNavigatorKey?.currentContext;
  targetContext?.to(
    () => _buildComicPage(
      id: id,
      sourceKey: sourceKey,
      cover: cover,
      title: title,
      heroID: heroID,
    ),
  );
}

void _openComicBody(Comic comic, {BuildContext? context, int? heroID}) {
  if (GlobalPreferenceStore(
        appdata.settings,
      ).read(FavoritePreferences.onClickFavorite) ==
      'read') {
    final builder =
        _comicReaderBuilder ??
        (throw StateError('Comic reader builder is not configured.'));
    final targetContext =
        context ?? appNavigation.mainNavigatorKey?.currentContext;
    targetContext?.to(
      () =>
          builder(id: comic.id, sourceKey: comic.sourceKey, title: comic.title),
    );
    return;
  }
  _openComicPage(
    context: context,
    id: comic.id,
    sourceKey: comic.sourceKey,
    cover: comic.cover,
    title: comic.title,
    heroID: heroID,
  );
}

Future<void> _addComicToFavorites(BuildContext context, List<Comic> comics) {
  final handler =
      _addComicFavoriteHandler ??
      (throw StateError("Add comic favorite handler is not configured."));
  return handler(context, comics);
}

ImageProvider? _findImageProvider(Comic comic) {
  return _comicTileImageProviderResolver?.call(comic);
}

ComicTileState _tileState(Comic comic) {
  return _comicTileStateResolver?.call(comic) ?? const ComicTileState();
}

Widget _buildUpdateBadge(BuildContext context, {double size = 24}) {
  return Container(
    height: size,
    width: size,
    color: Colors.deepOrange.shade700,
    child: Icon(Icons.update, size: size * 2 / 3, color: Colors.white),
  );
}

enum ComicTileDisplayMode { detailed, gallery }

class ComicTile extends StatelessWidget {
  const ComicTile({
    super.key,
    required this.comic,
    this.enableLongPressed = true,
    this.badge,
    this.menuOptions,
    this.onTap,
    this.onLongPressed,
    this.onBlocked,
    this.heroID,
    this.displayMode,
    this.hoverColor,
    this.bookshelf = false,
    this.compactDensityOverride,
    this.previewGroup,
    this.selected = false,
    this.onSelectionChanged,
    this.clearSelection,
    this.selectedGroup = const [],
    this.enableSelectionDrag = true,
    this.compactContent,
  });

  final bool bookshelf;

  /// Pins the bookshelf card density for hosts that must not follow the
  /// favorite-density preference (for example the reorder editor keeps a
  /// fixed layout while the collection grid switches density).
  final bool? compactDensityOverride;

  final List<Comic>? previewGroup;
  final bool selected;
  final ValueChanged<bool>? onSelectionChanged;
  final VoidCallback? clearSelection;
  final List<Comic> selectedGroup;
  final bool enableSelectionDrag;

  /// Keeps an existing compact surface while sharing card input behavior.
  final Widget? compactContent;

  WorkspaceRouteRecord _backgroundRoute(Comic target) => WorkspaceRouteRecord(
    kind: WorkspacePageKind.comic,
    arguments: {
      'id': target.id,
      'sourceKey': target.sourceKey,
      'cover': target.cover,
      'title': target.title,
    },
  );

  final Comic comic;

  final bool enableLongPressed;

  final String? badge;

  final List<MenuEntry>? menuOptions;

  final VoidCallback? onTap;

  final VoidCallback? onLongPressed;

  final VoidCallback? onBlocked;

  final int? heroID;

  final ComicTileDisplayMode? displayMode;

  /// Optional paint override for the primary ink response, without changing
  /// the inherited theme used by independent controls or context menus.
  final Color? hoverColor;

  void _onTap() {
    if (onTap != null) {
      onTap!();
      return;
    }
    _openComicBody(comic, heroID: heroID);
  }

  void _onLongPressed(BuildContext context) {
    if (onLongPressed != null) {
      onLongPressed!();
      return;
    }
    // Desktop cards use the secondary pointer for their context menu. Keep
    // the mobile long-press affordance, while avoiding the legacy mobile menu
    // on a desktop primary-pointer hold.
    if (App.isDesktop) return;
    onLongPress(context);
  }

  void onLongPress(BuildContext context) {
    var renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var location = renderBox.localToGlobal(
      Offset((size.width - 242) / 2, size.height / 2),
    );
    showMenu(location, context);
  }

  void onSecondaryTap(TapDownDetails details, BuildContext context) {
    showMenu(details.globalPosition, context);
  }

  void showMenu(Offset location, BuildContext context) {
    final workspace = WorkspaceNavigationScope.maybeOf(context);
    ContextMenuRegion.of(context).show(context, location, [
      if (workspace != null && selectedGroup.isNotEmpty)
        MenuEntry(
          icon: Icons.tab_outlined,
          text: 'Open selected in background tabs'.tl,
          onClick: () {
            for (final target in selectedGroup) {
              workspace.openBackground(_backgroundRoute(target));
            }
          },
        ),
      MenuEntry(
        icon: Icons.chrome_reader_mode_outlined,
        text: 'Details'.tl,
        onClick: () {
          _openComicPage(
            id: comic.id,
            sourceKey: comic.sourceKey,
            cover: comic.cover,
            title: comic.title,
          );
        },
      ),
      if (workspace != null)
        MenuEntry(
          icon: Icons.tab_outlined,
          text: 'Open in background tab'.tl,
          onClick: () => workspace.openBackground(
            WorkspaceRouteRecord(
              kind: WorkspacePageKind.comic,
              arguments: {
                'id': comic.id,
                'sourceKey': comic.sourceKey,
                'cover': comic.cover,
                'title': comic.title,
              },
            ),
          ),
        ),
      MenuEntry(
        icon: Icons.copy,
        text: 'Copy Title'.tl,
        onClick: () {
          Clipboard.setData(ClipboardData(text: comic.title));
          appNavigation.rootContext.showMessage(message: 'Title copied'.tl);
        },
      ),
      MenuEntry(
        icon: Icons.stars_outlined,
        text: 'Add to favorites'.tl,
        onClick: () {
          _addComicToFavorites(context, [comic]);
        },
      ),
      MenuEntry(
        icon: Icons.block,
        text: 'Block'.tl,
        onClick: () => block(context),
      ),
      ...?menuOptions,
    ]);
  }

  @override
  Widget build(BuildContext context) => ComicSelectionDrag(
    routes:
        enableSelectionDrag && WorkspaceNavigationScope.maybeOf(context) != null
        ? (selectedGroup.isEmpty ? [comic] : selectedGroup)
              .map(_backgroundRoute)
              .toList()
        : const [],
    child: Focus(
      skipTraversal: compactContent == null,
      onKeyEvent: (_, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        final background = WorkspaceNavigationScope.maybeOf(
          context,
        )?.openBackground;
        if (event.logicalKey == LogicalKeyboardKey.enter &&
            (HardwareKeyboard.instance.isControlPressed ||
                HardwareKeyboard.instance.isMetaPressed) &&
            background != null) {
          for (final target
              in selectedGroup.isEmpty ? [comic] : selectedGroup) {
            background(_backgroundRoute(target));
          }
          return KeyEventResult.handled;
        }
        if (FocusManager.instance.primaryFocus?.context
                ?.findAncestorWidgetOfExactType<Checkbox>() !=
            null) {
          return KeyEventResult.ignored;
        }
        if (event.logicalKey == LogicalKeyboardKey.enter &&
            compactContent != null) {
          _onTap();
          return KeyEventResult.handled;
        }
        if (event.logicalKey != LogicalKeyboardKey.space) {
          return KeyEventResult.ignored;
        }
        showComicPreview(
          context: context,
          comic: comic,
          group: previewGroup ?? [comic],
          imageProvider: _findImageProvider,
          openCurrent: (target) => _openComicPage(
            context: context,
            id: target.id,
            sourceKey: target.sourceKey,
            cover: target.cover,
            title: target.title,
          ),
          openBackground: background == null
              ? null
              : (target) => background(
                  WorkspaceRouteRecord(
                    kind: WorkspacePageKind.comic,
                    arguments: {
                      'id': target.id,
                      'sourceKey': target.sourceKey,
                      'cover': target.cover,
                      'title': target.title,
                    },
                  ),
                ),
        );
        return KeyEventResult.handled;
      },
      child: _ComicSelectionControl(
        title: comic.title,
        selected: selected,
        onChanged: onSelectionChanged,
        clear: clearSelection,
        child: ContextMenuRegion(
          identity: comic,
          builder: (context, _) => _build(context),
        ),
      ),
    ),
  );

  Widget _build(BuildContext context) {
    if (compactContent != null) {
      return GestureDetector(
        onSecondaryTapDown: (detail) => onSecondaryTap(detail, context),
        child: compactContent,
      );
    }
    final state = _tileState(comic);
    final type = switch (displayMode) {
      ComicTileDisplayMode.detailed => 'detailed',
      ComicTileDisplayMode.gallery => 'gallery',
      null => GlobalPreferenceStore(
        appdata.settings,
      ).read(DiscoveryPreferences.comicDisplayMode),
    };

    Widget child = switch (type) {
      'detailed' => _buildDetailedMode(context, state),
      'gallery' => _buildGalleryMode(context),
      _ => _buildBriefMode(context, state),
    };

    Widget interactive(Widget content) => ClickInkWell(
      hoverColor: hoverColor,
      borderRadius: BorderRadius.circular(type == 'detailed' ? 12 : 8),
      onTap: _onTap,
      onLongPress: enableLongPressed ? () => _onLongPressed(context) : null,
      onSecondaryTapDown: (detail) => onSecondaryTap(detail, context),
      child: content,
    );

    final isFavorite = state.isFavorite;
    final progressInDescription =
        type != 'gallery' && state.descriptionOverride != null;
    final historyPage = progressInDescription
        ? null
        : state.historyPage == 0
        ? 1
        : state.historyPage;
    final historyDescription = progressInDescription
        ? null
        : state.historyDescription;
    final hasUpdate = state.hasNewUpdate;

    if (!isFavorite && historyPage == null && !hasUpdate) {
      return interactive(child);
    }

    return interactive(
      LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              (type == 'gallery' || type == 'brief') &&
              constraints.maxWidth < 88;
          final badgeSize = compact ? 18.0 : 24.0;
          final compactGallery = type == 'gallery' && compact;
          final separateProgress =
              historyDescription != null &&
              state.historyCompactDescription != null;
          // Keep multi-line progress over the cover, not over the comic title.
          return Stack(
            children: [
              Positioned.fill(child: child),
              Positioned(
                left: type == 'detailed'
                    ? 16
                    : compactGallery
                    ? 4
                    : 6,
                top: compactGallery ? 6 : 8,
                right: type == 'detailed'
                    ? separateProgress
                          ? math.max(
                              16.0,
                              constraints.maxWidth -
                                  16 -
                                  (constraints.maxHeight - 16) * 0.68,
                            )
                          : 16
                    : compactGallery
                    ? 4
                    : 6,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isFavorite || hasUpdate || !separateProgress)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isFavorite)
                              Container(
                                height: badgeSize,
                                width: badgeSize,
                                color: Colors.green,
                                child: Icon(
                                  Icons.bookmark_rounded,
                                  size: badgeSize * 2 / 3,
                                  color: Colors.white,
                                ),
                              ),
                            if (!separateProgress && historyDescription != null)
                              Flexible(
                                child: _ReadingProgressBadge(
                                  historyDescription,
                                  tooltip: state.historyTooltipDescription,
                                ),
                              ),
                            if (historyPage != null &&
                                historyDescription == null)
                              Container(
                                height: badgeSize,
                                color: Colors.blue.toOpacity(0.9),
                                constraints: BoxConstraints(
                                  minWidth: badgeSize,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: compactGallery ? 2 : 4,
                                ),
                                child: CustomPaint(
                                  painter: _ReadingHistoryPainter(
                                    historyPage,
                                    state.historyMaxPage,
                                  ),
                                ),
                              ),
                            if (hasUpdate)
                              _buildUpdateBadge(context, size: badgeSize),
                          ],
                        ),
                      if (separateProgress)
                        _ReadingProgressBadge(
                          historyDescription,
                          tooltip: state.historyTooltipDescription,
                          compactDescription: state.historyCompactDescription,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildImage(BuildContext context) {
    var image = _findImageProvider(comic);
    if (image == null) {
      return const SizedBox();
    }
    return AnimatedImage(
      image: image,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
    );
  }

  Widget _buildDetailedMode(BuildContext context, ComicTileState state) {
    return LayoutBuilder(
      builder: (context, constrains) {
        final height = constrains.maxHeight - 16;

        Widget image = Container(
          width: height * 0.68,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: context.colorScheme.outlineVariant,
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: buildImage(context),
        );

        if (heroID != null) {
          image = Hero(tag: "cover$heroID", child: image);
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 24, 8),
          child: Row(
            children: [
              image,
              SizedBox.fromSize(size: const Size(16, 5)),
              Expanded(
                child: _ComicDescription(
                  title: comic.maxPage == null
                      ? comic.title.replaceAll("\n", "")
                      : "[${comic.maxPage}P]${comic.title.replaceAll("\n", "")}",
                  subtitle: comic.subtitle ?? '',
                  description: state.descriptionOverride ?? comic.description,
                  descriptionTooltip:
                      state.historyTooltipDescription ??
                      state.descriptionOverride,
                  badge: badge ?? comic.language,
                  tags: comic.tags,
                  maxLines: 2,
                  enableTranslate:
                      ComicSource.find(comic.sourceKey)?.enableTagsTranslate ??
                      false,
                  rating: comic.stars,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBriefMode(BuildContext context, ComicTileState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        Widget image = Container(
          decoration: BoxDecoration(
            color: context.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.toOpacity(0.2),
                blurRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: buildImage(context),
        );

        if (heroID != null) {
          image = Hero(tag: "cover$heroID", child: image);
        }

        return Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: image),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: (() {
                      final subtitle = comic.subtitle
                          ?.replaceAll('\n', '')
                          .trim();
                      final description = state.descriptionOverride == null
                          ? comic.description
                          : state.historyCompactDescription ??
                                state.descriptionOverride!;
                      final text = description.isNotEmpty
                          ? description.split('|').join('\n')
                          : (subtitle?.isNotEmpty == true ? subtitle : null);
                      final fortSize = constraints.maxWidth < 80
                          ? 8.0
                          : constraints.maxWidth < 150
                          ? 10.0
                          : 12.0;

                      if (text == null) {
                        return const SizedBox();
                      }

                      var children = <Widget>[];
                      var lines = text.split('\n');
                      lines.removeWhere((e) => e.trim().isEmpty);
                      if (lines.length > 3) {
                        lines = lines.sublist(0, 3);
                      }
                      for (var line in lines) {
                        children.add(
                          Container(
                            margin: const EdgeInsets.fromLTRB(2, 0, 2, 2),
                            padding: constraints.maxWidth < 80
                                ? const EdgeInsets.fromLTRB(3, 1, 3, 1)
                                : constraints.maxWidth < 150
                                ? const EdgeInsets.fromLTRB(4, 2, 4, 2)
                                : const EdgeInsets.fromLTRB(5, 2, 5, 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.black.toOpacity(0.5),
                            ),
                            constraints: BoxConstraints(
                              maxWidth: constraints.maxWidth,
                            ),
                            child: Text(
                              line,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: fortSize,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.right,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      }
                      final labels = Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: children,
                      );
                      if (state.descriptionOverride == null) return labels;
                      final tooltip =
                          state.historyTooltipDescription ??
                          state.descriptionOverride!;
                      return Tooltip(
                        message: tooltip,
                        child: Semantics(
                          label: tooltip,
                          excludeSemantics: true,
                          child: labels,
                        ),
                      );
                    })(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
              child: Text(
                comic.title.replaceAll('\n', ''),
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ).paddingHorizontal(6).paddingVertical(8);
      },
    );
  }

  Widget _buildGalleryMode(BuildContext context) {
    if (bookshelf) return _buildBookshelfMode(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 88;
        Widget image = Container(
          decoration: BoxDecoration(
            color: context.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.toOpacity(0.16),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: buildImage(context),
        );

        if (heroID != null) {
          image = Hero(tag: 'cover$heroID', child: image);
        }

        return Padding(
          padding: compact
              ? const EdgeInsets.fromLTRB(4, 5, 4, 4)
              : const EdgeInsets.fromLTRB(6, 8, 6, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: image),
              SizedBox(height: compact ? 3 : 5),
              SizedBox(
                height: compact ? 24 : 36,
                child: Text(
                  comic.title.replaceAll('\n', ''),
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 10 : 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookshelfMode(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const titleStyle = TextStyle(
          fontSize: AppFontSize.body,
          fontWeight: FontWeight.w500,
        );
        final painter = TextPainter(
          text: TextSpan(
            text: comic.title.replaceAll('\n', ''),
            style: titleStyle,
          ),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 1,
        )..layout();
        final truncated = painter.width > constraints.maxWidth - AppSpacing.lg;
        painter.dispose();
        final largeText =
            MediaQuery.textScalerOf(context).scale(AppFontSize.body) >
            AppFontSize.body;
        final compact =
            compactDensityOverride ??
            GlobalPreferenceStore(
                  appdata.settings,
                ).read(FavoritePreferences.density) ==
                'compact';
        Widget image = Container(
          decoration: BoxDecoration(
            color: context.colorScheme.contentSurfaceRaised,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          clipBehavior: Clip.antiAlias,
          child: buildImage(context),
        );

        if (heroID != null) {
          image = Hero(tag: 'cover$heroID', child: image);
        }

        return Padding(
          padding: compact
              ? const EdgeInsets.all(AppSpacing.xs)
              : const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: image),
              const SizedBox(height: AppSpacing.xs),
              SizedBox(
                height:
                    MediaQuery.textScalerOf(context).scale(AppFontSize.body) *
                    (largeText ? 2 : 1) *
                    1.3,
                child: Tooltip(
                  message: truncated ? comic.title : '',
                  triggerMode: TooltipTriggerMode.manual,
                  child: Text(
                    comic.title.replaceAll('\n', ''),
                    maxLines: largeText ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppFontSize.body,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Text(
                comic.subtitle ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppFontSize.bodySmall,
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<String> _splitText(String text) {
    // split text by comma, brackets
    var words = <String>[];
    var buffer = StringBuffer();
    var inBracket = false;
    String? prevBracket;
    for (var i = 0; i < text.length; i++) {
      var c = text[i];
      if (c == '[' || c == '(') {
        if (inBracket) {
          buffer.write(c);
        } else {
          if (buffer.isNotEmpty) {
            words.add(buffer.toString().trim());
            buffer.clear();
          }
          inBracket = true;
          prevBracket = c;
        }
      } else if (c == ']' || c == ')') {
        if (prevBracket == '[' && c == ']' || prevBracket == '(' && c == ')') {
          if (buffer.isNotEmpty) {
            words.add(buffer.toString().trim());
            buffer.clear();
          }
          inBracket = false;
        } else {
          buffer.write(c);
        }
      } else if (c == ',') {
        if (inBracket) {
          buffer.write(c);
        } else {
          words.add(buffer.toString().trim());
          buffer.clear();
        }
      } else {
        buffer.write(c);
      }
    }
    if (buffer.isNotEmpty) {
      words.add(buffer.toString().trim());
    }
    words.removeWhere((element) => element == "");
    words = words.toSet().toList();
    return words;
  }

  void block(BuildContext comicTileContext) {
    if (!NavigationAdmission.allows(comicTileContext)) return;
    final owner = comicTileContext.widget;
    final route = ModalRoute.of(comicTileContext);
    bool ownerCurrent() =>
        comicTileContext.mounted &&
        identical(comicTileContext.widget, owner) &&
        (route == null || route.isActive) &&
        NavigationAdmission.allows(comicTileContext);
    final tags = List<String>.of(comic.tags ?? const []);
    final words = [
      ..._splitText(comic.title),
      if (comic.subtitle != null && comic.subtitle != '') comic.subtitle!,
      ...tags,
    ];
    final work = comicTileContext
        .getInheritedWidgetOfExactType<SettingsSaveScope>()
        ?.work;
    showDialog<void>(
      context: comicTileContext,
      builder: (_) {
        final dialog = _BlockComicDialog(
          words: words,
          tags: tags,
          ownerCurrent: ownerCurrent,
          onBlocked: onBlocked,
        );
        return work == null
            ? dialog
            : SettingsSaveScope(work: work, child: dialog);
      },
    );
  }
}

class _ComicSelectionControl extends StatefulWidget {
  const _ComicSelectionControl({
    required this.title,
    required this.selected,
    required this.onChanged,
    required this.clear,
    required this.child,
  });
  final String title;
  final bool selected;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? clear;
  final Widget child;
  @override
  State<_ComicSelectionControl> createState() => _ComicSelectionControlState();
}

class _ComicSelectionControlState extends State<_ComicSelectionControl> {
  bool hovered = false, focused = false;
  final focus = FocusNode(debugLabel: 'comic-card-selection');
  @override
  void dispose() {
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onChanged == null) return widget.child;
    final visible = hovered || focused || widget.selected;
    return Focus(
      focusNode: focus,
      skipTraversal: true,
      onFocusChange: (value) {
        setState(() => focused = value);
      },
      onKeyEvent: (_, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape &&
            widget.clear != null) {
          widget.clear!();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => hovered = true),
        onExit: (_) => setState(() => hovered = false),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: widget.selected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0),
              width: AppSizes.hairline,
            ),
          ),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              widget.child,
              if (visible)
                Positioned(
                  top: AppSpacing.xs,
                  right: AppSpacing.xs,
                  child: Material(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Checkbox(
                      semanticLabel: 'Select @title'.tlParams({
                        'title': widget.title,
                      }),
                      value: widget.selected,
                      onChanged: (value) {
                        focus.requestFocus();
                        widget.onChanged!(value ?? false);
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlockComicDialog extends StatefulWidget {
  const _BlockComicDialog({
    required this.words,
    required this.tags,
    required this.ownerCurrent,
    this.onBlocked,
  });
  final List<String> words, tags;
  final bool Function() ownerCurrent;
  final VoidCallback? onBlocked;
  @override
  State<_BlockComicDialog> createState() => _BlockComicDialogState();
}

class _BlockComicDialogState extends SettingsSaveState<_BlockComicDialog> {
  final _words = <String>[];
  final _settings = KeywordSettingsStore(
    readSettings: () => appdata.settings,
    updateSettings: (change) => appdata.updateSettings(change),
  );

  void _block() {
    if (!acceptsSettingsChanges ||
        savingSettings ||
        hasSettingsSaveError ||
        !widget.ownerCurrent()) {
      return;
    }
    final words = List<String>.unmodifiable(_words);
    final callback = widget.onBlocked;
    saveSetting(
      BlockedKeywordList.comics,
      () => _settings.blockAll(BlockedKeywordList.comics, words),
      onSaved: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted ||
              !acceptsSettingsChanges ||
              !NavigationAdmission.allows(context) ||
              ModalRoute.of(context)?.isCurrent != true) {
            return;
          }
          if (widget.ownerCurrent()) {
            context.showMessage(message: 'Blocked'.tl);
            callback?.call();
          }
          if (mounted) leaveSettings();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) => protectSettings(
    ContentDialog(
      title: 'Block'.tl,
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: math.max(0, math.min(400, context.height - 136)),
        ),
        child: SingleChildScrollView(
          child: AbsorbPointer(
            absorbing: savingSettings || hasSettingsSaveError,
            child: ExcludeFocus(
              excluding: savingSettings || hasSettingsSaveError,
              child: Wrap(
                runSpacing: 8,
                spacing: 8,
                children: [
                  for (final word in widget.words)
                    OptionChip(
                      text: widget.tags.contains(word)
                          ? word.translateTagIfNeed
                          : word,
                      isSelected: _words.contains(word),
                      onTap: () {
                        if (savingSettings || hasSettingsSaveError) return;
                        setState(() {
                          if (!_words.remove(word)) _words.add(word);
                        });
                      },
                    ),
                ],
              ),
            ),
          ),
        ).paddingHorizontal(16),
      ),
      actions: [
        settingsSaveStatus,
        FilledButton(
          onPressed: savingSettings || hasSettingsSaveError ? null : _block,
          child: Text('Block'.tl),
        ),
      ],
    ),
  );
}

class _ComicDescription extends StatelessWidget {
  const _ComicDescription({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.enableTranslate,
    this.descriptionTooltip,
    this.badge,
    this.maxLines = 2,
    this.tags,
    this.rating,
  });

  final String title;
  final String subtitle;
  final String description;
  final String? descriptionTooltip;
  final String? badge;
  final List<String>? tags;
  final int maxLines;
  final bool enableTranslate;
  final double? rating;

  @override
  Widget build(BuildContext context) {
    final displayTags = [
      for (final tag in tags ?? const <String>[])
        if (tag.removeAllBlank.isNotEmpty) tag.replaceAll('\n', ' '),
    ];
    Widget descriptionText = Text(
      description,
      style: const TextStyle(fontSize: 12.0),
      maxLines: displayTags.isEmpty ? 3 : 2,
      overflow: TextOverflow.ellipsis,
    );
    if (descriptionTooltip != null) {
      descriptionText = Tooltip(
        message: descriptionTooltip!,
        excludeFromSemantics: true,
        child: Semantics(
          label: descriptionTooltip,
          excludeSemantics: true,
          child: descriptionText,
        ),
      );
    }
    var enableTranslate =
        appLocale.languageCode == 'zh' && this.enableTranslate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title.trim(),
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14.0),
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
        ),
        if (subtitle != "")
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10.0,
              color: context.colorScheme.onSurface.toOpacity(0.7),
            ),
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
        const SizedBox(height: 4),
        if (displayTags.isNotEmpty)
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxHeight < 22) {
                  return Container();
                }
                int cnt = (constraints.maxHeight - 22).toInt() ~/ 25;
                return Container(
                  clipBehavior: Clip.antiAlias,
                  height: 21 + cnt * 24,
                  width: double.infinity,
                  decoration: const BoxDecoration(),
                  child: Wrap(
                    runAlignment: WrapAlignment.start,
                    clipBehavior: Clip.antiAlias,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    spacing: 4,
                    runSpacing: 3,
                    children: [
                      for (var s in displayTags)
                        Container(
                          height: 21,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth * 0.45,
                          ),
                          decoration: BoxDecoration(
                            color: s == "Unavailable"
                                ? context.colorScheme.errorContainer
                                : context.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            widthFactor: 1,
                            child: Text(
                              enableTranslate
                                  ? TagsTranslation.translateTag(s)
                                  : s.split(':').last,
                              style: const TextStyle(fontSize: 12),
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                    ],
                  ),
                ).toAlign(Alignment.topCenter);
              },
            ),
          )
        else
          const Spacer(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (rating != null) StarRating(value: rating!, size: 18),
                  descriptionText,
                ],
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                child: Center(
                  child: Text(
                    "${badge![0].toUpperCase()}${badge!.substring(1).toLowerCase()}",
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ReadingHistoryPainter extends CustomPainter {
  final int page;
  final int? maxPage;

  const _ReadingHistoryPainter(this.page, this.maxPage);

  @override
  void paint(Canvas canvas, Size size) {
    if (maxPage == null) {
      // 在中央绘制page
      final textPainter = TextPainter(
        text: TextSpan(
          text: "$page",
          style: TextStyle(fontSize: size.width * 0.8, color: Colors.white),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size.width - textPainter.width) / 2,
          (size.height - textPainter.height) / 2,
        ),
      );
    } else if (page == maxPage) {
      // 在中央绘制勾
      final paint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(size.width * 0.2, size.height * 0.5),
        Offset(size.width * 0.45, size.height * 0.75),
        paint,
      );
      canvas.drawLine(
        Offset(size.width * 0.45, size.height * 0.75),
        Offset(size.width * 0.85, size.height * 0.3),
        paint,
      );
    } else {
      // 在左上角绘制page, 在右下角绘制maxPage
      final textPainter = TextPainter(
        text: TextSpan(
          text: "$page",
          style: TextStyle(fontSize: size.width * 0.8, color: Colors.white),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, const Offset(0, 0));
      final textPainter2 = TextPainter(
        text: TextSpan(
          text: "/$maxPage",
          style: TextStyle(fontSize: size.width * 0.5, color: Colors.white),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter2.layout();
      textPainter2.paint(
        canvas,
        Offset(
          size.width - textPainter2.width,
          size.height - textPainter2.height,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! _ReadingHistoryPainter ||
        oldDelegate.page != page ||
        oldDelegate.maxPage != maxPage;
  }
}

class _ReadingProgressBadge extends StatelessWidget {
  const _ReadingProgressBadge(
    this.description, {
    this.compactDescription,
    this.tooltip,
  });
  final String description;
  final String? compactDescription;
  final String? tooltip;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip ?? description,
    child: Semantics(
      // Keep progress independently readable when the card's InkWell includes
      // the overlay as well as the title.
      container: true,
      label: tooltip ?? description,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        color: context.colorScheme.primaryContainer,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final line
                in compactDescription?.split('\n') ??
                    [description.replaceAll('\n', ' ')])
              Text(
                line,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: context.colorScheme.onPrimaryContainer,
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class SimpleComicTile extends StatelessWidget {
  const SimpleComicTile({
    super.key,
    required this.comic,
    this.onTap,
    this.withTitle = false,
    this.heroID,
    this.gaplessPlayback = false,
    this.previewGroup,
    this.selected = false,
    this.onSelectionChanged,
    this.clearSelection,
    this.selectedGroup = const [],
  });

  final Comic comic;

  final void Function()? onTap;

  final bool withTitle;

  final int? heroID;

  final bool gaplessPlayback;
  final List<Comic>? previewGroup;
  final bool selected;
  final ValueChanged<bool>? onSelectionChanged;
  final VoidCallback? clearSelection;
  final List<Comic> selectedGroup;

  @override
  Widget build(BuildContext context) {
    var image = _findImageProvider(comic);

    Widget child = image == null
        ? const SizedBox()
        : AnimatedImage(
            image: image,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            gaplessPlayback: gaplessPlayback,
          );

    child = Container(
      width: 98,
      height: 136,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );

    final state = _tileState(comic);
    if (state.hasNewUpdate || state.historyDescription != null) {
      child = Stack(
        children: [
          child,
          if (state.hasNewUpdate)
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(4),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: _buildUpdateBadge(context),
              ),
            ),
          if (state.historyDescription case final description?)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _ReadingProgressBadge(
                description,
                compactDescription: state.historyCompactDescription,
                tooltip: state.historyTooltipDescription,
              ),
            ),
        ],
      );
    }

    if (heroID != null) {
      child = Hero(tag: "cover$heroID", child: child);
    }

    child = AnimatedTapRegion(
      borderRadius: 8,
      footer: withTitle
          ? Padding(
              padding: const EdgeInsets.only(top: 4),
              child: SizedBox(
                width: 92,
                child: Center(
                  child: Text(
                    comic.title.replaceAll('\n', ''),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            )
          : null,
      onTap:
          onTap ??
          () {
            _openComicBody(comic, context: context, heroID: heroID);
          },
      child: child,
    );

    return ComicTile(
      comic: comic,
      onTap: onTap,
      heroID: heroID,
      enableLongPressed: false,
      compactContent: child,
      previewGroup: previewGroup,
      selected: selected,
      onSelectionChanged: onSelectionChanged,
      clearSelection: clearSelection,
      selectedGroup: selectedGroup,
    );
  }
}
