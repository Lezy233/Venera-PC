import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venera_next/features/comic_source/comic_source.dart';
import 'package:venera_next/features/comic_widgets/comic_widgets.dart';

Comic _comic(String id) => Comic(
  id,
  '',
  id,
  null,
  const [],
  '',
  'favorite-long-press-fixture',
  null,
  null,
);

void main() {
  testWidgets(
    'production favorite grid long press does not select; checkbox still selects',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverGridComics(
                  comics: [_comic('favorite-a'), _comic('favorite-b')],
                  displayMode: ComicTileDisplayMode.gallery,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final card = find.byType(ComicTile).first;
      await tester.longPress(card);
      await tester.pumpAndSettle();
      expect(find.text('Details'), findsNothing);
      expect(
        tester
            .widgetList<ComicTile>(find.byType(ComicTile))
            .every((tile) => !tile.selected),
        isTrue,
      );
      final secondary = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryMouseButton,
      );
      await secondary.addPointer(location: tester.getCenter(card));
      await secondary.down(tester.getCenter(card));
      await secondary.up();
      await tester.pumpAndSettle();
      expect(find.text('Details'), findsOneWidget);
      // Checkbox selection remains covered by the existing B4 hit-target
      // regression; this production-grid test isolates long-press semantics.
    },
  );
}
