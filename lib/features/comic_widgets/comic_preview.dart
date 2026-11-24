import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:venera_next/design_system/tokens.dart';
import 'package:venera_next/features/comic_source/comic_source_api.dart';
import 'package:venera_next/foundation/res.dart';
import 'package:venera_next/foundation/translations.dart';
import 'package:venera_next/foundation/appdata.dart';
import 'package:venera_next/foundation/application_preferences.dart';
import 'package:venera_next/foundation/global_preference_store.dart';

/// A temporary view of one list, without a durable workspace destination.
Future<void> showComicPreview({
  required BuildContext context,
  required Comic comic,
  required List<Comic> group,
  required ValueChanged<Comic> openCurrent,
  required ValueChanged<Comic>? openBackground,
  required ImageProvider? Function(Comic) imageProvider,
}) async {
  final origin = FocusManager.instance.primaryFocus;
  await showDialog<void>(
    context: context,
    builder: (context) => _ComicPreview(
      comic: comic,
      group: List.unmodifiable(group),
      openCurrent: openCurrent,
      openBackground: openBackground,
      imageProvider: imageProvider,
    ),
    animationStyle:
        (MediaQuery.disableAnimationsOf(context) ||
            GlobalPreferenceStore(
              appdata.settings,
            ).read(AppearancePreferences.reduceMotion))
        ? AnimationStyle.noAnimation
        : const AnimationStyle(duration: AppMotion.fast),
  );
  if (origin?.context?.mounted == true) origin!.requestFocus();
}

class _ComicPreview extends StatefulWidget {
  const _ComicPreview({
    required this.comic,
    required this.group,
    required this.openCurrent,
    required this.openBackground,
    required this.imageProvider,
  });
  final Comic comic;
  final List<Comic> group;
  final ValueChanged<Comic> openCurrent;
  final ValueChanged<Comic>? openBackground;
  final ImageProvider? Function(Comic) imageProvider;
  @override
  State<_ComicPreview> createState() => _ComicPreviewState();
}

class _ComicPreviewState extends State<_ComicPreview> {
  late int index = widget.group.indexWhere(
    (c) => c.id == widget.comic.id && c.sourceKey == widget.comic.sourceKey,
  );
  final requests = <(String, String), Future<Res<ComicDetails>>>{};
  bool _hasFocus = false;
  Comic get comic => index < 0 ? widget.comic : widget.group[index];
  Future<Res<ComicDetails>> details(Comic target) =>
      requests.putIfAbsent((target.sourceKey, target.id), () async {
        final loader = ComicSource.find(target.sourceKey)?.loadComicInfo;
        if (loader == null) return const Res.error('Comic source not found');
        try {
          return await loader(target.id);
        } catch (error, stack) {
          return Res.fromException(error, stack);
        }
      });
  void move(int delta) {
    final next = index + delta;
    if (next >= 0 && next < widget.group.length) setState(() => index = next);
  }

  void open(bool background) {
    final target = comic;
    final action = background ? widget.openBackground : widget.openCurrent;
    if (action == null) return;
    Navigator.of(context).pop();
    action(target);
  }

  @override
  Widget build(BuildContext context) {
    final target = comic;
    final image = widget.imageProvider(target);
    return Focus(
      autofocus: true,
      onFocusChange: (value) {
        if (value != _hasFocus && mounted) setState(() => _hasFocus = value);
      },
      onKeyEvent: (_, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        final key = event.logicalKey;
        if (key == LogicalKeyboardKey.escape ||
            key == LogicalKeyboardKey.space) {
          Navigator.of(context).pop();
        } else if (key == LogicalKeyboardKey.arrowLeft) {
          move(-1);
        } else if (key == LogicalKeyboardKey.arrowRight) {
          move(1);
        } else if (key == LogicalKeyboardKey.enter) {
          open(
            HardwareKeyboard.instance.isControlPressed ||
                HardwareKeyboard.instance.isMetaPressed,
          );
        } else {
          return KeyEventResult.ignored;
        }
        return KeyEventResult.handled;
      },
      child: Dialog(
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(
            color: _hasFocus
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: _hasFocus ? 2 : 0,
          ),
        ),
        child: Semantics(
          label: 'Comic preview'.tl,
          explicitChildNodes: true,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppSizes.comicPreviewWidth,
              maxHeight: MediaQuery.sizeOf(context).height - AppSpacing.xl * 2,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          target.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close'.tl,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: AppSizes.hairline),
                Flexible(
                  child: SingleChildScrollView(
                    key: ValueKey((target.sourceKey, target.id)),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (image != null)
                          Center(
                            child: SizedBox(
                              height: AppSizes.comicPreviewCoverHeight,
                              child: Image(image: image, fit: BoxFit.contain),
                            ),
                          ),
                        Text(
                          ComicSource.find(target.sourceKey)?.name ??
                              target.sourceKey,
                        ),
                        FutureBuilder<Res<ComicDetails>>(
                          key: ValueKey((target.sourceKey, target.id)),
                          future: details(target),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const LinearProgressIndicator();
                            }
                            final result = snapshot.data!;
                            if (result.error) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(target.description),
                                  Text(result.errorMessage!.tl),
                                  TextButton(
                                    onPressed: () => setState(
                                      () => requests.remove((
                                        target.sourceKey,
                                        target.id,
                                      )),
                                    ),
                                    child: Text('Retry'.tl),
                                  ),
                                ],
                              );
                            }
                            final data = result.data;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data.title,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                if (data.subTitle != null) Text(data.subTitle!),
                                const SizedBox(height: AppSpacing.md),
                                Text(data.description ?? target.description),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  'Chapters'.tl,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                for (final chapter
                                    in data.chapters?.titles ??
                                        const <String>[])
                                  Text(chapter),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: AppSizes.hairline),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    children: [
                      IconButton(
                        tooltip: 'Previous'.tl,
                        onPressed: index > 0 ? () => move(-1) : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      IconButton(
                        tooltip: 'Next'.tl,
                        onPressed: index + 1 < widget.group.length
                            ? () => move(1)
                            : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                      TextButton(
                        onPressed: () => open(false),
                        child: Text('Details'.tl),
                      ),
                      if (widget.openBackground != null)
                        TextButton(
                          onPressed: () => open(true),
                          child: Text('Open in background tab'.tl),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
