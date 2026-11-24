import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venera_next/components/workspace_navigation_scope.dart';
import 'package:venera_next/foundation/workspace_record.dart';
import 'package:venera_next/app_shell/workspace/workspace_tab_strip.dart';
import 'package:venera_next/features/comic_source/comic_source.dart';
import 'package:venera_next/features/comic_widgets/comic_widgets.dart';

Comic _favorite(String id, String sourceKey) => Comic(
  'Favorite $id',
  'cover://$id',
  id,
  null,
  const [],
  '',
  sourceKey,
  null,
  null,
);

void main() {
  testWidgets(
    'production favorites grid drags one unselected comic to tabs once',
    (tester) async {
      final opened = <WorkspaceRouteRecord>[];
      final tab = WorkspaceTabRecord(
        routes: [
          WorkspaceRouteRecord(
            kind: WorkspacePageKind.favorites,
            arguments: const {'title': 'Favorites'},
          ),
        ],
      );
      final record = WorkspaceRecord(
        directory: '/tmp/ux1-5-8-favorites',
        tabs: [tab],
        activeId: tab.id,
        recent: [tab.id],
      );
      final comics = [
        _favorite('favorite-1', 'network-a'),
        _favorite('favorite-2', 'network-b'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: WorkspaceNavigationScope(
              openBackground: opened.add,
              child: Column(
                children: [
                  WorkspaceTabStrip(
                    record: record,
                    activate: (_) {},
                    close: (_) {},
                    newTab: () {},
                    visited: {tab.id},
                    reorder: (_, _) {},
                    openBackground: opened.add,
                  ),
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverGridComics(
                          comics: comics,
                          displayMode: ComicTileDisplayMode.gallery,
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
      await tester.pumpAndSettle();
      final cards = find.byType(ComicTile);
      expect(cards, findsNWidgets(2));
      final first = tester.widget<ComicTile>(cards.first);
      expect(first.selected, isFalse);
      final gesture = await tester.startGesture(
        tester.getCenter(cards.first),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.moveTo(tester.getCenter(find.byType(WorkspaceTabStrip)));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(opened, hasLength(1));
      expect(opened.single.kind, WorkspacePageKind.comic);
      expect(opened.single.arguments, {
        'id': 'favorite-1',
        'sourceKey': 'network-a',
        'cover': 'cover://favorite-1',
        'title': 'Favorite favorite-1',
      });
      expect(tester.widget<ComicTile>(cards.first).selected, isFalse);
      expect(tester.takeException(), isNull);
    },
  );
}
