import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venera_next/foundation/res.dart';
import 'package:venera_next/features/comic_source/comic_source.dart';
import 'package:venera_next/features/comic_widgets/comic_widgets.dart';
import 'package:venera_next/features/favorites/comic_reorder_page.dart';
import 'package:venera_next/features/favorites/favorites.dart';
import 'package:venera_next/features/favorites/favorites_scope.dart';
import 'package:venera_next/foundation/app.dart';
import 'package:venera_next/foundation/appdata.dart';
import 'package:venera_next/foundation/comic_type.dart';
import '../components/sidebar_presentation_test.dart' show settleSidebarWork;

void main() {
  App.dataPath = App.cachePath = Directory.systemTemp.path;
  for (final reorder in [false, true]) {
    testWidgets(
      'favorite density does not resize ${reorder ? 'production reorder editor' : 'ordinary ComicList'}',
      (tester) async {
        final root = Directory.systemTemp.createTempSync('ux1-isolation-');
        final oldPath = App.dataPath, oldCache = App.cachePath;
        final oldSettings = Map<String, dynamic>.from(
          appdata.toJson()['settings'] as Map,
        );
        App.dataPath = App.cachePath = root.path;
        appdata.settings['language'] = 'en-US';
        appdata.settings['blockedWords'] = <String>[];
        appdata.settings['favoritesDisplayMode'] = 'gallery';
        appdata.settings['favoritesGalleryColumns'] = 0;
        appdata.settings['favoritesDensity'] = 'comfortable';
        final manager = LocalFavoritesManager.independent();
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(1000, 900);
        addTearDown(() async {
          await tester.pumpWidget(const SizedBox());
          await settleSidebarWork(tester, () => appdata.writeImplicitData());
          await tester.runAsync(() async {
            await manager.debugWaitForHashedIdsRefresh();
            manager.close();
          });
          oldSettings.forEach((k, v) => appdata.settings[k] = v);
          App.dataPath = oldPath;
          App.cachePath = oldCache;
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
          root.deleteSync(recursive: true);
        });
        await tester.runAsync(() async {
          await manager.init();
          await manager.createFolder('Order');
          for (var i = 0; i < 12; i++) {
            await manager.addComic(
              'Order',
              FavoriteItem(
                id: 'b$i',
                name: 'Book $i',
                coverPath: '',
                author: 'Author',
                type: ComicType.local,
                tags: const [],
              ),
            );
          }
          await manager.debugWaitForHashedIdsRefresh();
        });
        Widget tree() => FavoritesScope(
          manager: manager,
          child: MaterialApp(
            home: Scaffold(
              body: reorder
                  ? Builder(
                      builder: (context) => TextButton(
                        onPressed: () => reorderFavoriteComics(
                          context,
                          manager: manager,
                          folder: 'Order',
                          isCurrent: () => true,
                        ),
                        child: const Text('Open editor'),
                      ),
                    )
                  : ComicList(
                      loadPage: (page) async => Res(
                        List.generate(
                          12,
                          (i) => Comic(
                            'Book $i',
                            '',
                            'b$i',
                            'Author',
                            const [],
                            '',
                            'local',
                            null,
                            null,
                          ),
                        ),
                        subData: 1,
                      ),
                    ),
            ),
          ),
        );
        await tester.pumpWidget(tree());
        await tester.pumpAndSettle();
        if (reorder) {
          await tester.tap(find.text('Open editor'));
          await tester.pumpAndSettle();
        }
        expect(find.byType(ComicTile), findsWidgets);
        final before = tester.getSize(find.byType(ComicTile).first);
        // The reorder editor now shares the collection bookshelf card layout
        // (UX1 D4); its density stays pinned to comfortable below.
        expect(
          tester.widget<ComicTile>(find.byType(ComicTile).first).bookshelf,
          reorder,
        );
        // Actual production settings listener/rebuild, no delegate-only substitute.
        appdata.settings['favoritesDensity'] = 'compact';
        await tester.pumpWidget(tree());
        await tester.pumpAndSettle();
        expect(tester.getSize(find.byType(ComicTile).first), before);
        appdata.settings['favoritesDensity'] = 'comfortable';
        await tester.pumpWidget(tree());
        await tester.pumpAndSettle();
        expect(tester.getSize(find.byType(ComicTile).first), before);
        if (reorder) {
          // Geometry identity with the collection grid at comfortable density
          // is owned by favorites_reorder_test; this protection only pins the
          // density isolation above.
          expect(before.width, greaterThan(0));
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
}
