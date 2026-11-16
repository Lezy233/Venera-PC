import 'package:venera_next/foundation/app.dart';
import 'package:venera_next/foundation/appdata.dart';
import 'workspace_record.dart';

/// Per-window ownership of the existing appdata transaction, not a second store.
class WorkspaceStore {
  WorkspaceStore(this.directory) {
    _owners[directory] = _owner;
  }
  static const key = 'workspaceSnapshot';
  static final _owners = <String, Object>{};
  final String directory;
  final Object _owner = Object();
  int _revision = 0;

  bool get isCurrent =>
      App.dataPath == directory && identical(_owners[directory], _owner);

  WorkspaceRecord? read() {
    final value = appdata.implicitData[key];
    if (value == null) return null;
    return WorkspaceRecord.fromJson(value, directory: directory);
  }

  /// Returns an idempotent assignment for SettingsSaveState (including Retry).
  Future<void> Function() assignment(WorkspaceRecord record) {
    final revision = ++_revision;
    final frozen = record.freeze();
    return () async {
      if (!isCurrent || revision != _revision) return;
      try {
        await appdata.updateImplicit((draft) {
          // Recheck after admission and queueing. A retry of an obsolete intent
          // must not write a later view from memory, or replace a newer snapshot.
          if (!isCurrent || revision != _revision) {
            throw const _ObsoleteWorkspaceWrite();
          }
          draft[key] = frozen;
        });
      } on _ObsoleteWorkspaceWrite {
        // No draft was applied and no file was written by the retired owner.
      }
    };
  }
}

class _ObsoleteWorkspaceWrite implements Exception {
  const _ObsoleteWorkspaceWrite();
}
