import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:venera_next/app_shell/workspace/workspace_record.dart';
import 'package:venera_next/app_shell/workspace/workspace_store.dart';
import 'package:venera_next/foundation/app.dart';
import 'package:venera_next/foundation/appdata.dart';

WorkspaceTabRecord tab(String entity) => WorkspaceTabRecord(
  routes: [
    WorkspaceRouteRecord(
      kind: WorkspacePageKind.comic,
      arguments: {'id': entity, 'sourceKey': 'same-source'},
      view: {
        'scroll': 420.0,
        'selected': [
          {'sourceKey': 'same-source', 'id': 'a'},
        ],
        'focus': 'comic:a',
        'expanded': true,
      },
    ),
  ],
);

void main() {
  test(
    'snapshot preserves stable stack and entity identity; MRU excludes unseen tabs',
    () {
      final a = tab('same-title-A'), b = tab('same-title-B'), c = tab('C');
      final record = WorkspaceRecord(
        directory: '/isolated',
        tabs: [],
        activeId: null,
        recent: [],
      );
      record.add(a, background: false);
      record.add(b, background: true);
      record.add(c, background: false);
      expect(record.recent, [a.id, c.id]);
      record.close(c.id);
      expect(record.activeId, a.id);
      final copy = WorkspaceRecord.fromJson(
        jsonDecode(jsonEncode(record.toJson())),
        directory: '/isolated',
      );
      expect(copy.toJson(), record.toJson());
      expect(copy.tabs[1].current.arguments['id'], 'same-title-B');
      expect(copy.tabs[0].current.view['scroll'], 420.0);
      copy.close(a.id);
      expect(copy.activeId, isNull);
      expect(copy.tabs.single.id, b.id);
    },
  );
  test(
    'unknown version, foreign directory, malformed and duplicate identities reject safely',
    () {
      final a = tab('a');
      final good = WorkspaceRecord(
        directory: '/data',
        tabs: [a],
        activeId: a.id,
        recent: [a.id],
      );
      for (final bad in [
        null,
        {},
        {...good.freeze(), 'version': 2},
        {...good.freeze(), 'directory': '/other'},
        {
          ...good.freeze(),
          'tabs': [a.toJson(), a.toJson()],
        },
        {
          ...good.freeze(),
          'tabs': [
            {...a.toJson(), 'restoreParent': 'yes'},
          ],
        },
        {...good.freeze(), 'active': 'missing'},
        {
          ...good.freeze(),
          'recent': ['missing'],
        },
      ]) {
        expect(
          () => WorkspaceRecord.fromJson(bad, directory: '/data'),
          throwsFormatException,
        );
      }
    },
  );
  test(
    'known route arguments and view fields reject malformed data before mounting',
    () {
      final cases = <WorkspaceRouteRecord>[
        WorkspaceRouteRecord(
          kind: WorkspacePageKind.comic,
          arguments: {'id': 'a', 'sourceKey': 's', 'title': 12},
        ),
        WorkspaceRouteRecord(
          kind: WorkspacePageKind.reader,
          arguments: {'id': 'a', 'sourceKey': 's', 'page': '2'},
        ),
        WorkspaceRouteRecord(
          kind: WorkspacePageKind.searchResults,
          arguments: {
            'keyword': 'x',
            'sourceKey': 's',
            'options': [null],
          },
        ),
        WorkspaceRouteRecord(
          kind: WorkspacePageKind.aggregatedSearch,
          arguments: {'keyword': 7},
        ),
        WorkspaceRouteRecord(
          kind: WorkspacePageKind.favorites,
          view: {'focus': false},
        ),
        WorkspaceRouteRecord(
          kind: WorkspacePageKind.favorites,
          view: {
            'local-favorites': {'scroll': '420'},
          },
        ),
        WorkspaceRouteRecord(
          kind: WorkspacePageKind.favorites,
          view: {
            'local-favorites': {
              'selection': [
                {'id': 'a', 'sourceKey': 's', 'type': 'wrong'},
              ],
            },
          },
        ),
      ];
      for (final route in cases) {
        expect(
          () => WorkspaceRouteRecord.fromJson(
            jsonDecode(jsonEncode(route.toJson())),
          ),
          throwsFormatException,
          reason: 'malformed ${route.kind}: ${route.toJson()}',
        );
      }
    },
  );
  test(
    'real disk fault, latest assignment retry, directory/session ownership and disk decode',
    () async {
      final root = Directory.systemTemp.createTempSync('ux1-workspace-store-');
      final before = Map<String, dynamic>.of(appdata.implicitData);
      App.dataPath = root.path;
      final owner = WorkspaceStore(root.path);
      final a = tab('a'), b = tab('b');
      final record = WorkspaceRecord(
        directory: root.path,
        tabs: [a],
        activeId: a.id,
        recent: [a.id],
      );
      try {
        appdata.implicitData['unrelated'] = 42;
        final obstacle = Directory('${root.path}/implicitData.json.tmp')
          ..createSync();
        final old = owner.assignment(record);
        await expectLater(old(), throwsA(isA<FileSystemException>()));
        record.add(b, background: true);
        final latest = owner.assignment(record);
        obstacle.deleteSync();
        await latest();
        await old();
        final disk =
            jsonDecode(
                  File('${root.path}/implicitData.json').readAsStringSync(),
                )
                as Map;
        expect(disk['unrelated'], 42);
        expect(
          WorkspaceRecord.fromJson(
            disk[WorkspaceStore.key],
            directory: root.path,
          ).tabs.map((t) => t.id),
          [a.id, b.id],
        );
        final queued = owner.assignment(record);
        App.dataPath = '${root.path}/other';
        await queued();
        expect(
          File('${root.path}/other/implicitData.json').existsSync(),
          isFalse,
          reason:
              'an obsolete directory callback must not write even an unchanged draft into the new directory',
        );
        App.dataPath = root.path;
        WorkspaceStore(
          root.path,
        ); // a new directory/session owner retires this writer
        record.close(b.id);
        await owner.assignment(record)();
        final after =
            jsonDecode(
                  File('${root.path}/implicitData.json').readAsStringSync(),
                )
                as Map;
        expect(after[WorkspaceStore.key], disk[WorkspaceStore.key]);
      } finally {
        appdata.implicitData = before;
        root.deleteSync(recursive: true);
      }
    },
  );
}
