import 'package:flutter/material.dart';
import 'workspace_record.dart';

/// One route's retained view state; never owns a business store or network cache.
class WorkspacePageBinding extends ChangeNotifier {
  WorkspacePageBinding(this.record, this.onChanged) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) _acceptsChanges = true;
    });
  }
  final WorkspaceRouteRecord record;
  final VoidCallback onChanged;
  final _captures = <String, Map<String, dynamic> Function()>{};
  final _focusTargets = <String, FocusNode>{};
  bool _active = false;
  bool _acceptsChanges = false;
  bool _disposed = false;
  bool get active => _active;
  FocusNode? returnFocus;

  void setActive(bool value) {
    if (_active == value) return;
    _active = value;
    notifyListeners();
  }

  Map<String, dynamic> attach(
    String key,
    Map<String, dynamic> Function() capture,
  ) {
    _captures[key] = capture;
    final saved = record.view[key];
    return saved is Map ? Map<String, dynamic>.from(saved) : {};
  }

  void detach(String key) {
    final capture = _captures.remove(key);
    if (capture != null) record.view[key] = capture();
  }

  void capture() {
    for (final entry in _captures.entries) {
      record.view[entry.key] = entry.value();
    }
  }

  void changed() {
    capture();
    if (_acceptsChanges) onChanged();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void registerFocus(String key, FocusNode node) => _focusTargets[key] = node;
  void unregisterFocus(String key, FocusNode node) {
    if (identical(_focusTargets[key], node)) _focusTargets.remove(key);
  }

  void rememberFocus() {
    final node = FocusManager.instance.primaryFocus;
    if (node == null) return;
    returnFocus = node;
    for (final entry in _focusTargets.entries) {
      if (entry.value.hasFocus) record.view['focus'] = entry.key;
    }
  }

  void restoreFocus() {
    final remembered = returnFocus;
    final node = remembered?.context != null
        ? remembered
        : _focusTargets[record.view['focus']];
    if (node?.context != null && node!.canRequestFocus) node.requestFocus();
  }
}

class WorkspacePageScope extends InheritedNotifier<WorkspacePageBinding> {
  const WorkspacePageScope({
    super.key,
    required WorkspacePageBinding binding,
    required super.child,
  }) : super(notifier: binding);
  static WorkspacePageBinding? read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<WorkspacePageScope>()?.notifier;
  static WorkspacePageBinding? watch(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<WorkspacePageScope>()
      ?.notifier;
}

/// Pages opt into explicit, semantic view fields instead of widget serialization.
mixin WorkspaceViewState<W extends StatefulWidget> on State<W> {
  WorkspacePageBinding? _workspaceBinding;
  @protected
  WorkspacePageBinding? get workspaceBinding => _workspaceBinding;
  String get workspaceViewKey;
  Map<String, dynamic> captureWorkspaceView();
  void restoreWorkspaceView(Map<String, dynamic> saved);

  @protected
  void bindWorkspaceView() {
    final next = WorkspacePageScope.read(context);
    if (identical(next, _workspaceBinding)) return;
    _workspaceBinding?.detach(workspaceViewKey);
    _workspaceBinding = next;
    if (next != null) {
      restoreWorkspaceView(next.attach(workspaceViewKey, captureWorkspaceView));
    }
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    _workspaceBinding?.changed();
  }

  @override
  void dispose() {
    _workspaceBinding?.detach(workspaceViewKey);
    super.dispose();
  }
}
