import 'dart:convert';

/// Serializable navigation/view state. Business records remain in their stores.
enum WorkspacePageKind {
  home,
  favorites,
  explore,
  categories,
  search,
  searchResults,
  aggregatedSearch,
  comic,
  reader,
  settings,
}

String workspaceIdentity() =>
    '${DateTime.now().microsecondsSinceEpoch}-${_identitySequence++}';
int _identitySequence = 0;

class WorkspaceRouteRecord {
  WorkspaceRouteRecord({
    String? id,
    required this.kind,
    Map<String, dynamic>? arguments,
    Map<String, dynamic>? view,
  }) : id = id ?? workspaceIdentity(),
       arguments = arguments ?? {},
       view = view ?? {};

  final String id;
  final WorkspacePageKind kind;
  final Map<String, dynamic> arguments;
  final Map<String, dynamic> view;

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind.name,
    'arguments': arguments,
    'view': view,
  };

  factory WorkspaceRouteRecord.fromJson(Object? value) {
    final json = _map(value);
    final name = _string(json['kind']);
    final kind = WorkspacePageKind.values
        .where((k) => k.name == name)
        .firstOrNull;
    if (kind == null) throw const FormatException('Unknown workspace page');
    final args = _map(json['arguments']);
    if ([WorkspacePageKind.comic, WorkspacePageKind.reader].contains(kind)) {
      _string(args['id']);
      _string(args['sourceKey']);
    }
    if (kind == WorkspacePageKind.searchResults) {
      _string(args['sourceKey']);
      if (args['keyword'] is! String) {
        throw const FormatException('Invalid search');
      }
    }
    if (kind == WorkspacePageKind.aggregatedSearch &&
        args['keyword'] is! String) {
      throw const FormatException('Invalid search');
    }
    for (final key in ['cover', 'title', 'profileId']) {
      _optional<String>(args, key);
    }
    _stringList(args, 'options');
    for (final key in ['chapter', 'page']) {
      _optional<int>(args, key);
      if (args[key] != null && (args[key] as int) < 0) {
        throw const FormatException('Invalid reading position');
      }
    }
    final view = _map(json['view']);
    _validateView(view);
    return WorkspaceRouteRecord(
      id: _string(json['id']),
      kind: kind,
      arguments: args,
      view: view,
    );
  }
}

class WorkspaceTabRecord {
  WorkspaceTabRecord({
    String? id,
    required this.routes,
    this.restoreParent = false,
  }) : id = id ?? workspaceIdentity();
  final String id;
  final List<WorkspaceRouteRecord> routes;
  bool restoreParent;
  WorkspaceRouteRecord get current => routes.last;
  Map<String, dynamic> toJson() => {
    'id': id,
    'routes': routes.map((r) => r.toJson()).toList(),
    'restoreParent': restoreParent,
  };
  factory WorkspaceTabRecord.fromJson(Object? value) {
    final json = _map(value);
    final routes = _list(
      json['routes'],
    ).map(WorkspaceRouteRecord.fromJson).toList();
    if (routes.isEmpty ||
        routes.map((r) => r.id).toSet().length != routes.length) {
      throw const FormatException('Invalid workspace stack');
    }
    _optional<bool>(json, 'restoreParent');
    return WorkspaceTabRecord(
      id: _string(json['id']),
      routes: routes,
      restoreParent: json['restoreParent'] as bool? ?? false,
    );
  }
}

class WorkspaceRecord {
  WorkspaceRecord({
    required this.directory,
    required this.tabs,
    required this.activeId,
    required this.recent,
  });
  static const version = 1;
  final String directory;
  final List<WorkspaceTabRecord> tabs;
  String? activeId;
  final List<String> recent;

  WorkspaceTabRecord? get active =>
      tabs.where((t) => t.id == activeId).firstOrNull;

  void activate(String id) {
    if (!tabs.any((t) => t.id == id)) return;
    activeId = id;
    recent.remove(id);
    recent.add(id);
  }

  void add(WorkspaceTabRecord tab, {required bool background}) {
    tabs.add(tab);
    if (!background) activate(tab.id);
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= tabs.length) return;
    if (newIndex < 0 || newIndex > tabs.length) return;
    if (oldIndex < newIndex) newIndex -= 1;
    if (oldIndex == newIndex) return;
    final tab = tabs.removeAt(oldIndex);
    tabs.insert(newIndex.clamp(0, tabs.length), tab);
  }

  void close(String id, {String target = 'recent'}) {
    final index = tabs.indexWhere((t) => t.id == id);
    if (index < 0) return;
    final wasActive = id == activeId;
    tabs.removeAt(index);
    recent.remove(id);
    if (!wasActive) return;
    if (tabs.isEmpty) {
      activeId = null;
      return;
    }
    if (target == 'right') {
      activate(tabs[index.clamp(0, tabs.length - 1)].id);
    } else if (target == 'left') {
      activate(tabs[(index - 1).clamp(0, tabs.length - 1)].id);
    } else if (recent.isNotEmpty) {
      activate(recent.last);
    } else {
      // No visited target: leave an actionable empty workspace. Unseen
      // background tabs remain available in the tab strip, outside the MRU.
      activeId = null;
    }
  }

  Map<String, dynamic> toJson() => {
    'version': version,
    'directory': directory,
    'tabs': tabs.map((t) => t.toJson()).toList(),
    'active': activeId,
    'recent': recent,
  };

  /// Freeze before submitting to the existing application write queue.
  Map<String, dynamic> freeze() => _map(jsonDecode(jsonEncode(toJson())));

  factory WorkspaceRecord.fromJson(Object? value, {required String directory}) {
    final json = _map(value);
    if (json['version'] != version || json['directory'] != directory) {
      throw const FormatException('Incompatible workspace');
    }
    final tabs = _list(json['tabs']).map(WorkspaceTabRecord.fromJson).toList();
    final ids = tabs.map((t) => t.id).toSet();
    final routeIds = tabs.expand((t) => t.routes).map((r) => r.id).toList();
    final recent = _list(json['recent']).map(_string).toList();
    if (ids.length != tabs.length ||
        routeIds.toSet().length != routeIds.length ||
        recent.toSet().length != recent.length ||
        recent.any((id) => !ids.contains(id)) ||
        (json['active'] != null && !ids.contains(json['active']))) {
      throw const FormatException('Invalid workspace identities');
    }
    return WorkspaceRecord(
      directory: directory,
      tabs: tabs,
      activeId: json['active'] as String?,
      recent: recent,
    );
  }
}

Map<String, dynamic> _map(Object? value) {
  if (value is! Map || value.keys.any((key) => key is! String)) {
    throw const FormatException('Invalid workspace object');
  }
  return Map<String, dynamic>.from(value);
}

List<dynamic> _list(Object? value) {
  if (value is! List) throw const FormatException('Invalid workspace list');
  return value;
}

String _string(Object? value) {
  if (value is! String || value.isEmpty) {
    throw const FormatException('Invalid workspace identity');
  }
  return value;
}

void _optional<T>(Map<String, dynamic> data, String key) {
  if (data[key] != null && data[key] is! T) {
    throw FormatException('Invalid workspace field: $key');
  }
}

void _stringList(Map<String, dynamic> data, String key) {
  if (data[key] == null) return;
  if (_list(data[key]).any((item) => item is! String)) {
    throw FormatException('Invalid workspace string list: $key');
  }
}

void _offset(Map<String, dynamic> data, String key) {
  if (data[key] == null) return;
  final value = data[key];
  if (value is! num || !value.isFinite || value < 0) {
    throw FormatException('Invalid workspace offset: $key');
  }
}

/// Validate fields before factories or State restoration can cast them. Unknown
/// JSON fields remain inert, so a view may add fields without rewriting data.
void _validateView(Map<String, dynamic> view) {
  _optional<String>(view, 'focus');
  _optional<bool>(view, 'expanded');
  _offset(view, 'scroll');
  if (view.containsKey('reader')) {
    final saved = _map(view['reader']);
    _optional<String>(saved, 'chapterId');
    for (final key in ['chapter', 'page']) {
      _optional<int>(saved, key);
      if (saved[key] != null && (saved[key] as int) < 1) {
        throw const FormatException('Invalid reader position');
      }
    }
  }
  if (view.containsKey('comic-details')) {
    _offset(_map(view['comic-details']), 'scroll');
  }
  for (final key in ['comic-chapters', 'comic-chapter-group']) {
    if (view.containsKey(key)) {
      final saved = _map(view[key]);
      _optional<bool>(saved, 'expanded');
      _optional<String>(saved, 'group');
    }
  }
  if (view.containsKey('search')) {
    final saved = _map(view['search']);
    for (final key in ['keyword', 'sourceKey', 'profileId']) {
      _optional<String>(saved, key);
    }
    _optional<bool>(saved, 'aggregated');
    _stringList(saved, 'options');
    _offset(saved, 'scroll');
  }
  if (view.containsKey('search-result')) {
    final saved = _map(view['search-result']);
    for (final key in ['keyword', 'input', 'sourceKey']) {
      _optional<String>(saved, key);
    }
    _stringList(saved, 'options');
    _offset(saved, 'scroll');
    _optional<int>(saved, 'page');
    if (saved['page'] != null && (saved['page'] as int) < 1) {
      throw const FormatException('Invalid result page');
    }
  }
  if (view.containsKey('aggregate-search')) {
    final saved = _map(view['aggregate-search']);
    for (final key in ['keyword', 'input', 'profileId']) {
      _optional<String>(saved, key);
    }
    _offset(saved, 'scroll');
    if (saved['sources'] != null) {
      for (final value in _list(saved['sources'])) {
        final target = _map(value);
        _string(target['sourceKey']);
        _stringList(target, 'options');
      }
    }
  }
  if (view.containsKey('favorites')) {
    final saved = _map(view['favorites']);
    for (final key in ['folder', 'seriesId']) {
      _optional<String>(saved, key);
    }
    for (final key in ['network', 'sidebarCollapsed']) {
      _optional<bool>(saved, key);
    }
    _offset(saved, 'sidebarWidth');
  }
  if (view.containsKey('local-favorites')) {
    final saved = _map(view['local-favorites']);
    for (final key in ['keyword', 'readFilter', 'sort']) {
      _optional<String>(saved, key);
    }
    for (final key in [
      'search',
      'multiSelect',
      'filterPanelOpen',
      'authorSection',
      'tagSection',
    ]) {
      _optional<bool>(saved, key);
    }
    _optional<int>(saved, 'lastSelectedIndex');
    _offset(saved, 'scroll');
    _stringList(saved, 'authors');
    _stringList(saved, 'tags');
    if (saved['selection'] != null) {
      for (final value in _list(saved['selection'])) {
        final identity = _map(value);
        _string(identity['id']);
        _string(identity['sourceKey']);
        if (identity['type'] is! int) {
          throw const FormatException('Invalid favorite identity');
        }
      }
    }
  }
}
