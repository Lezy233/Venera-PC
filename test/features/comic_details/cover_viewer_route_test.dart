import 'package:venera_next/foundation/app_page_route.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:venera_next/components/image.dart';
import 'package:venera_next/features/comic_details/cover_viewer.dart';
import 'package:venera_next/foundation/image_provider/cached_image.dart';

void main() {
  for (final matchingHero in [false, true]) {
    testWidgets('cover real route hero=$matchingHero without workspace', (
      tester,
    ) async {
      final root = Directory.systemTemp.createTempSync(
        'ux1-cover-route-probe-',
      );
      final file = File('${root.path}/cover.png')
        ..writeAsBytesSync(img.encodePng(img.Image(width: 100, height: 150)));
      final provider = CachedImageProvider('file://${file.path}');
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox());
        await tester.runAsync(() async => root.deleteSync(recursive: true));
      });
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => GestureDetector(
              onTap: () => Navigator.of(context).push(
                AppPageRoute(
                  builder: (_) => ComicCoverViewer(
                    imageProvider: provider,
                    title: 'Fixture',
                    heroTag: 'probe',
                  ),
                ),
              ),
              child: Hero(
                tag: matchingHero ? 'probe' : 'different',
                child: AnimatedImage(image: provider, width: 100, height: 150),
              ),
            ),
          ),
        ),
      );
      for (var i = 0; i < 10; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
        await tester.pump();
      }
      await tester.tap(find.byType(AnimatedImage));
      for (var i = 0; i < 20; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
        await tester.pump(const Duration(milliseconds: 30));
      }
      expect(find.byType(ComicCoverViewer), findsOneWidget);
      final canvas = tester.getRect(find.byType(PhotoView));
      final painted = find.descendant(
        of: find.byType(ComicCoverViewer),
        matching: find.byType(RawImage),
      );
      expect(painted, findsOneWidget);
      final image = tester.widget<RawImage>(painted).image!;
      expect((image.width, image.height), (100, 150));
      final rect = tester.getRect(painted);
      expect(rect.width / rect.height, closeTo(100 / 150, .01));
      expect(rect.height, closeTo(canvas.height, 1.5));
      expect(rect.center.dx, closeTo(canvas.center.dx, 1.5));
      expect(rect.center.dy, closeTo(canvas.center.dy, 1.5));
      final hero = tester
          .widget<PhotoView>(find.byType(PhotoView))
          .heroAttributes!;
      expect(hero.tag, 'probe');
      await tester.tap(
        find.descendant(
          of: find.byType(ComicCoverViewer),
          matching: find.widgetWithIcon(IconButton, Icons.close),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ComicCoverViewer), findsNothing);
      expect(find.byType(AnimatedImage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  for (final warm in [false, true]) {
    testWidgets('unchanged cover viewer without workspace warm=$warm', (
      tester,
    ) async {
      final root = Directory.systemTemp.createTempSync('ux1-cover-probe-');
      final file = File('${root.path}/cover.png')
        ..writeAsBytesSync(img.encodePng(img.Image(width: 100, height: 150)));
      final provider = CachedImageProvider('file://${file.path}');
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox());
        await tester.runAsync(() async => root.deleteSync(recursive: true));
      });
      await tester.pumpWidget(
        MaterialApp(
          home: Stack(
            children: [
              if (warm) Offstage(child: AnimatedImage(image: provider)),
              ComicCoverViewer(
                imageProvider: provider,
                title: 'Fixture',
                heroTag: 'probe',
              ),
            ],
          ),
        ),
      );
      for (var i = 0; i < 20; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
        await tester.pump();
      }
      expect(tester.takeException(), isNull);
    });
  }
}
