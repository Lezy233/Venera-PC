import 'package:venera_next/foundation/workspace_record.dart';

/// Ephemeral drag payload. It never owns or edits a favorite/source record.
class WorkspaceComicDrag {
  WorkspaceComicDrag(Iterable<WorkspaceRouteRecord> routes)
    : routes = List.unmodifiable(routes);
  final List<WorkspaceRouteRecord> routes;
  bool cancelled = false;
}
