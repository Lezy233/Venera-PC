import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venera_next/components/image.dart';
import 'package:venera_next/features/comic_source/comic_source.dart';
import 'package:venera_next/features/comic_widgets/comic_widgets.dart';
import 'package:venera_next/features/search/search_result_page.dart';
import 'package:venera_next/features/search/aggregated_search_page.dart';
import 'package:venera_next/foundation/app.dart';
import 'package:venera_next/foundation/appdata.dart';
import 'package:venera_next/foundation/app_data_operations.dart';
import 'package:venera_next/foundation/application_preferences.dart';
import 'package:venera_next/foundation/global_preference_store.dart';
import 'package:venera_next/foundation/res.dart';
import '../../support/comic_source_fixture.dart';

class _Source extends ComicSourceFixture {
  _Source() : super(key: 'gallery-geometry');
  final comics = List.generate(
    30,
    (i) => Comic(
      'Geometry book $i',
      '',
      'book-$i',
      null,
      const [],
      '',
      'gallery-geometry',
      null,
      null,
    ),
  );
  @override
  SearchPageData get searchPageData =>
      SearchPageData(null, (_, _, _) async => Res(comics, subData: 1), null);
}

Map<String, Object> _geometry(WidgetTester tester) {
  final grid = find.byType(SliverGrid).first;
  final render = tester.renderObject<RenderSliverGrid>(grid);
  final layout =
      tester.widget<SliverGrid>(grid).gridDelegate.getLayout(render.constraints)
          as SliverGridRegularTileLayout;
  final tile = find.byType(ComicTile).first;
  final card = tester.getRect(tile);
  final image = tester.getRect(
    find.descendant(of: tile, matching: find.byType(AnimatedImage)).first,
  );
  final title = find
      .descendant(of: tile, matching: find.text('Geometry book 0'))
      .first;
  Rect? titleSlot;
  tester.element(title).visitAncestorElements((element) {
    if (element.widget is SizedBox &&
        (element.widget as SizedBox).height != null) {
      final box = element.renderObject! as RenderBox;
      titleSlot = box.localToGlobal(Offset.zero) & box.size;
      return false;
    }
    return true;
  });
  List<double> rect(Rect value) => [
    value.left - card.left,
    value.top - card.top,
    value.width,
    value.height,
  ];
  return {
    'columns': layout.crossAxisCount,
    'card': [card.width, card.height],
    'cover': rect(image),
    'title': rect(titleSlot!),
    'columnStride': layout.crossAxisStride,
    'rowStride': layout.mainAxisStride,
    'outerLeft': card.left,
    'innerRight': card.right - image.right,
    'coverToTitleGap': titleSlot!.top - image.bottom,
  };
}

void _sameGeometry(Map<String, Object> actual, Map<String, Object> expected) {
  for (final key in expected.keys) {
    final target = expected[key]!;
    if (target is List) {
      final measured = actual[key]! as List;
      expect(measured, hasLength(target.length));
      for (var i = 0; i < target.length; i++) {
        expect(
          measured[i],
          closeTo(target[i] as num, 0.000001),
          reason: '$key[$i]',
        );
      }
    } else {
      expect(actual[key], closeTo(target as num, 0.000001), reason: key);
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  App.dataPath = App.cachePath = Directory.systemTemp.path;
  final source = _Source();
  late Map<String, dynamic> previous;
  late Directory root;
  late String oldPath, oldCache;
  late MemoryImage portrait, wide;
  setUpAll(() async {
    Future<MemoryImage> cover(int width, int height) async {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawColor(Colors.white, BlendMode.src);
      canvas.drawRect(
        Rect.fromLTWH(0, 0, width * .1, height.toDouble()),
        Paint()..color = Colors.red,
      );
      canvas.drawRect(
        Rect.fromLTWH(width * .9, 0, width * .1, height.toDouble()),
        Paint()..color = Colors.green,
      );
      canvas.drawRect(
        Rect.fromLTWH(0, 0, width.toDouble(), height * .1),
        Paint()..color = Colors.blue,
      );
      canvas.drawRect(
        Rect.fromLTWH(0, height * .9, width.toDouble(), height * .1),
        Paint()..color = Colors.yellow,
      );
      final picture = recorder.endRecording();
      final image = await picture.toImage(width, height);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      picture.dispose();
      return MemoryImage(bytes!.buffer.asUint8List());
    }

    portrait = await cover(68, 100);
    wide = await cover(160, 60);
  });
  setUp(() {
    oldPath = App.dataPath;
    oldCache = App.cachePath;
    root = Directory.systemTemp.createTempSync('search-gallery-geometry-');
    App.dataPath = App.cachePath = root.path;
    previous = Map<String, dynamic>.from(appdata.toJson()['settings'] as Map);
    appdata.settings[FavoritePreferences.displayMode.key] = 'gallery';
    appdata.settings[FavoritePreferences.galleryColumns.key] = 0;
    appdata.settings[DiscoveryPreferences.searchDisplayMode.key] = 'gallery';
    appdata.settings[DiscoveryPreferences.comicDisplayMode.key] = 'detailed';
    appdata.settings[DiscoveryPreferences.searchSources.key] = [source.key];
    configureComicWidgets(
      favoriteDisplayStateResolver: () => ComicFavoriteDisplayState(
        isGallery:
            GlobalPreferenceStore(
              appdata.settings,
            ).read(FavoritePreferences.displayMode) ==
            'gallery',
        galleryColumns: GlobalPreferenceStore(
          appdata.settings,
        ).read(FavoritePreferences.galleryColumns),
      ),
      tileImageProviderResolver: (comic) =>
          comic.id == 'book-1' ? wide : portrait,
    );
    configureComicSourceRegistry(
      all: () => [source],
      find: (key) => key == source.key ? source : null,
      fromIntKey: (_) => source,
      isEmpty: () => false,
    );
  });
  tearDown(() {
    configureComicWidgets();
    configureComicSourceRegistry(
      all: () => [],
      find: (_) => null,
      fromIntKey: (_) => null,
      isEmpty: () => true,
    );
    previous.forEach((k, v) => appdata.settings[k] = v);
    App.dataPath = oldPath;
    App.cachePath = oldCache;
    root.deleteSync(recursive: true);
  });
  // Same usable content width, without sidebars or independently guessed sizes.
  for (final width in [600.0, 1000.0, 1400.0]) {
    for (final scale in [1.0, 1.5]) {
      for (final density in ['comfortable', 'compact']) {
        testWidgets('production gallery geometry $width $scale $density', (
          tester,
        ) async {
          tester.view.physicalSize = Size(width, 1000);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(() async {
            await tester.pumpWidget(const SizedBox());
            var done = false;
            AppDataOperations.instance
                .run<void>(() {})
                .then((_) => done = true);
            for (var i = 0; i < 100 && !done; i++) {
              await tester.runAsync(
                () => Future<void>.delayed(const Duration(milliseconds: 10)),
              );
              await tester.pump();
            }
            expect(
              done,
              isTrue,
              reason: 'drain original search-history IO before fixture cleanup',
            );
          });
          appdata.settings[FavoritePreferences.density.key] = density;
          Widget shell(Widget child) => MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: Scaffold(body: child),
          );
          await tester.pumpWidget(
            shell(
              CustomScrollView(
                slivers: [
                  SliverGridComics(
                    comics: source.comics,
                    useFavoriteDisplaySettings: true,
                  ),
                ],
              ),
            ),
          );
          await tester.pumpAndSettle();
          final favorite = _geometry(tester);
          await tester.pumpWidget(const SizedBox());
          await tester.pumpWidget(
            shell(SearchResultPage(text: 'geometry', sourceKey: source.key)),
          );
          await tester.pumpAndSettle();
          final search = _geometry(tester);
          // Structured actual measurements survive in the raw test log.
          // ignore: avoid_print
          print(
            'UX1_GEOMETRY ${jsonEncode({'width': width, 'scale': scale, 'density': density, 'favorite': favorite, 'search': search})}',
          );
          _sameGeometry(search, favorite);
          await tester.pumpWidget(const SizedBox());
          await tester.pumpWidget(
            shell(const AggregatedSearchPage(keyword: 'geometry')),
          );
          await tester.pumpAndSettle();
          expect(
            find.byType(SliverGrid),
            findsOneWidget,
            reason: 'aggregate groups must also use the favorite grid',
          );
          final aggregate = _geometry(tester);
          // ignore: avoid_print
          print(
            'UX1_AGGREGATE_GEOMETRY ${jsonEncode({'width': width, 'scale': scale, 'density': density, 'aggregate': aggregate})}',
          );
          _sameGeometry(aggregate, favorite);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
        });
      }
    }
  }
  testWidgets(
    'production search preserves all four colored cover edges in portrait and wide images',
    (tester) async {
      tester.view.physicalSize = const Size(1000, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RepaintBoundary(
              key: boundaryKey,
              child: SearchResultPage(text: 'pixels', sourceKey: source.key),
            ),
          ),
        ),
      );
      for (var i = 0; i < 50; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
        await tester.pump();
        if (find.byType(RawImage).evaluate().length >= 2) break;
      }
      await tester.pumpAndSettle();
      final boundary =
          boundaryKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      final pixels = await tester.runAsync(() async {
        final frame = await boundary.toImage(pixelRatio: 1);
        final bytes = await frame.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        final result = (frame.width, bytes!.buffer.asUint8List());
        frame.dispose();
        return result;
      });
      expect(find.byType(RawImage), findsWidgets);
      for (final index in [0, 1]) {
        final card = find.byWidgetPredicate(
          (w) => w is ComicTile && w.comic.id == 'book-$index',
        );
        final raw = find.descendant(of: card, matching: find.byType(RawImage));
        final image = tester.widget<RawImage>(raw).image!;
        expect((image.width, image.height), index == 0 ? (68, 100) : (160, 60));
        final slot = tester
            .getRect(raw)
            .shift(-boundary.localToGlobal(Offset.zero));
        final ratio = index == 0 ? 68 / 100 : 160 / 60;
        final width = math.min(slot.width, slot.height * ratio);
        final height = width / ratio;
        final painted = Rect.fromCenter(
          center: slot.center,
          width: width,
          height: height,
        );
        final samples = [
          (Offset(painted.left + width * .04, painted.center.dy), Colors.red),
          (
            Offset(painted.right - width * .04, painted.center.dy),
            Colors.green,
          ),
          (Offset(painted.center.dx, painted.top + height * .04), Colors.blue),
          (
            Offset(painted.center.dx, painted.bottom - height * .04),
            Colors.yellow,
          ),
        ];
        for (final sample in samples) {
          final offset =
              (sample.$1.dy.round() * pixels!.$1 + sample.$1.dx.round()) * 4;
          final actual = pixels.$2.sublist(offset, offset + 3);
          final color = sample.$2.toARGB32();
          expect(
            actual,
            [(color >> 16) & 255, (color >> 8) & 255, color & 255],
            reason:
                'book-$index original edge ${sample.$1} must remain visible',
          );
        }
        // ignore: avoid_print
        print(
          'UX1_COVER_PIXELS book-$index decoded=${image.width}x${image.height} slot=$slot painted=$painted all_four_edges_visible',
        );
      }
      await tester.pumpWidget(const SizedBox());
      var done = false;
      AppDataOperations.instance.run<void>(() {}).then((_) => done = true);
      for (var i = 0; i < 100 && !done; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
        await tester.pump();
      }
      expect(done, isTrue);
    },
  );
}
