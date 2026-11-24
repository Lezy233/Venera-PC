import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:venera_next/components/workspace_comic_drag.dart';
import 'package:venera_next/foundation/workspace_record.dart';
import 'package:venera_next/design_system/tokens.dart';
import 'package:venera_next/foundation/translations.dart';

class ComicSelectionDrag extends StatefulWidget {
  const ComicSelectionDrag({
    super.key,
    required this.routes,
    required this.child,
  });
  final List<WorkspaceRouteRecord> routes;
  final Widget child;
  @override
  State<ComicSelectionDrag> createState() => _ComicSelectionDragState();
}

class _ComicSelectionDragState extends State<ComicSelectionDrag> {
  final focus = FocusNode(debugLabel: 'comic-selection-drag');
  WorkspaceComicDrag? active;
  FocusNode? origin;
  int? pointer;
  @override
  void dispose() {
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final payload = WorkspaceComicDrag(widget.routes);
    return Focus(
      focusNode: focus,
      skipTraversal: true,
      onKeyEvent: (_, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape &&
            active != null) {
          active!.cancelled = true;
          if (pointer != null) GestureBinding.instance.cancelPointer(pointer!);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Listener(
        onPointerDown: (event) {
          if (event.buttons == kPrimaryButton) pointer = event.pointer;
        },
        child: Draggable<WorkspaceComicDrag>(
          data: payload,
          maxSimultaneousDrags: widget.routes.isEmpty ? 0 : 1,
          allowedButtonsFilter: (buttons) => buttons == kPrimaryButton,
          dragAnchorStrategy: pointerDragAnchorStrategy,
          onDragStarted: () {
            active = payload;
            origin = FocusManager.instance.primaryFocus;
            focus.requestFocus();
          },
          onDragEnd: (_) {
            active = null;
            pointer = null;
            if (origin?.context?.mounted == true) origin!.requestFocus();
            if (mounted) setState(() {});
          },
          feedback: Material(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                'Open @count in background tabs'.tlParams({
                  'count': payload.routes.length,
                }),
              ),
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
