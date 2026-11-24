import 'package:flutter/widgets.dart';
import 'package:venera_next/foundation/workspace_record.dart';

/// Content submits a durable destination without depending on the shell State.
class WorkspaceNavigationScope extends InheritedWidget {
  const WorkspaceNavigationScope({
    super.key,
    required this.openBackground,
    required super.child,
  });

  final ValueChanged<WorkspaceRouteRecord> openBackground;

  static WorkspaceNavigationScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<WorkspaceNavigationScope>();

  @override
  bool updateShouldNotify(WorkspaceNavigationScope oldWidget) =>
      openBackground != oldWidget.openBackground;
}
