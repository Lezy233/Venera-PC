import 'dart:io';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venera_next/features/comic_source/comic_source.dart';
import 'package:venera_next/features/comic_widgets/comic_widgets.dart';
import 'package:venera_next/features/favorites/favorites_display.dart';
import 'package:venera_next/features/search/search_result_page.dart';
import 'package:venera_next/foundation/app.dart';
import 'package:venera_next/foundation/appdata.dart';
import 'package:venera_next/foundation/app_data_operations.dart';
import 'package:venera_next/foundation/application_preferences.dart';
import 'package:venera_next/foundation/global_preference_store.dart';
import 'package:venera_next/foundation/res.dart';
import 'package:venera_next/foundation/workspace_record.dart';
import 'package:venera_next/components/workspace_page_scope.dart';
import 'package:venera_next/features/search/aggregated_search_page.dart';
import 'package:venera_next/routing/app_navigation.dart';
import '../../support/comic_card_actions.dart';
import '../../support/comic_source_fixture.dart';

class _SearchSource extends ComicSourceFixture {
  _SearchSource([String key = 'search-display-mode']) : super(key: key);
  final calls = <List<Object>>[];

  @override
  SearchPageData get searchPageData =>
      SearchPageData(null, (keyword, page, options) async {
        calls.add([keyword, page, List<String>.of(options)]);
        return Res(
          List.generate(
            40,
            (index) => Comic(
              'search mode card $index',
              '',
              'search-mode-book-$index',
              null,
              null,
              '',
              key,
              null,
              null,
            ),
          ),
          subData: 1,
        );
      }, null);
}

void main() {
  App.dataPath = App.cachePath = Directory.systemTemp.path;

  Future<void> drain(WidgetTester tester, Future<void> operation) async {
    var done = false;
    Object? error;
    operation.then(
      (_) => done = true,
      onError: (Object value) {
        error = value;
        done = true;
      },
    );
    for (var i = 0; i < 100; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
      if (done) break;
    }
    expect(done, isTrue, reason: 'bounded real IO must finish');
    expect(error, isNull);
  }

  Future<void> flush(WidgetTester tester) async {
    await tester.pump();
    await drain(tester, AppDataOperations.instance.run<void>(() {}));
    expect(
      find.byType(CircularProgressIndicator),
      findsNothing,
      reason: 'bounded real IO must finish',
    );
    await tester.pumpAndSettle();
  }

  testWidgets('search display mode is a real persisted gallery/list control', (
    tester,
  ) async {
    final source = _SearchSource();
    final other = _SearchSource('other-display-source');
    final root = Directory.systemTemp.createTempSync('search-display-mode-');
    final oldPath = App.dataPath, oldCache = App.cachePath;
    final checkpoint = appdata.captureImportCheckpoint();
    App.dataPath = App.cachePath = root.path;
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final previous = Map<String, dynamic>.from(
      appdata.toJson()['settings'] as Map,
    );
    configureComicSourceRegistry(
      all: () => [source, other],
      find: (key) => key == source.key
          ? source
          : key == other.key
          ? other
          : null,
      fromIntKey: (_) => source,
      isEmpty: () => false,
    );
    appdata.settings['language'] = 'en-US';
    appdata.settings[DiscoveryPreferences.searchDisplayMode.key] = null;
    appdata.settings[FavoritePreferences.displayMode.key] = 'list';
    appdata.settings['searchSources'] = [source.key, other.key];
    final record = WorkspaceRouteRecord(
      kind: WorkspacePageKind.searchResults,
      arguments: {'sourceKey': source.key, 'keyword': 'keyword'},
    );
    final binding = WorkspacePageBinding(record, () {});
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      await drain(
        tester,
        appdata.restoreImportCheckpoint(checkpoint, persist: false),
      );
      binding.dispose();
      App.dataPath = oldPath;
      App.cachePath = oldCache;
      root.deleteSync(recursive: true);
      configureComicSourceRegistry(
        all: () => [],
        find: (_) => null,
        fromIntKey: (_) => null,
        isEmpty: () => true,
      );
      previous.forEach((key, value) => appdata.settings[key] = value);
    });

    Widget page() => MaterialApp(
      navigatorKey: appNavigation.rootNavigatorKey,
      home: Scaffold(
        body: WorkspacePageScope(
          binding: binding,
          child: SearchResultPage(
            text: 'keyword',
            sourceKey: source.key,
            options: const ['original-filter'],
          ),
        ),
      ),
    );
    await tester.pumpWidget(page());
    await flush(tester);

    expect(find.text('search mode card 0'), findsOneWidget);
    expect(find.byType(FavoriteDisplayButton), findsOneWidget);
    expect(
      GlobalPreferenceStore(
        appdata.settings,
      ).read(DiscoveryPreferences.searchDisplayMode),
      'gallery',
    );
    expect(
      tester.widget<ComicTile>(find.byType(ComicTile).first).displayMode,
      ComicTileDisplayMode.gallery,
    );
    final originalState = tester.state(find.byType(SearchResultPage));
    final gridState = tester.state(find.byType(SliverGridComics));
    final list = tester.widget<ComicList>(find.byType(ComicList));
    final scroll = list.controller!;
    final originalId = record.id;
    await toggleComicCheckbox(tester, find.byType(ComicTile).first);
    await tester.sendEventToBinding(
      PointerScrollEvent(
        position: tester.getCenter(find.byType(ComicTile).first),
        scrollDelta: const Offset(0, 120),
        kind: PointerDeviceKind.mouse,
      ),
    );
    await tester.pumpAndSettle();
    expect(scroll.offset, closeTo(120, .01));

    await tester.tap(find.byTooltip('Search display mode'));
    await flush(tester);
    expect(find.text('List'), findsOneWidget);
    await tester.tap(find.text('List'));
    await flush(tester);
    expect(
      tester.widget<ComicTile>(find.byType(ComicTile).first).displayMode,
      ComicTileDisplayMode.detailed,
    );
    expect(tester.state(find.byType(SearchResultPage)), same(originalState));
    expect(tester.state(find.byType(SliverGridComics)), same(gridState));
    expect(
      tester.widget<ComicList>(find.byType(ComicList)).controller,
      same(scroll),
    );
    expect(scroll.offset, closeTo(120, .01));
    expect(record.id, originalId);
    binding.capture();
    expect(record.view['search-result']['keyword'], 'keyword');
    expect(record.view['search-result']['sourceKey'], source.key);
    expect(record.view['search-result']['options'], ['original-filter']);
    expect(source.calls, [
      [
        'keyword',
        1,
        ['original-filter'],
      ],
    ]);
    expect(other.calls, isEmpty);
    expect(appdata.settings[FavoritePreferences.displayMode.key], 'list');
    expect(
      GlobalPreferenceStore(
        appdata.settings,
      ).read(DiscoveryPreferences.searchDisplayMode),
      'list',
    );

    await tester.tap(find.byTooltip('Search display mode'));
    await flush(tester);
    await tester.tap(find.text('Gallery'));
    await flush(tester);
    expect(
      tester.widget<ComicTile>(find.byType(ComicTile).first).displayMode,
      ComicTileDisplayMode.gallery,
    );
    expect(tester.state(find.byType(SliverGridComics)), same(gridState));
    await tester.sendEventToBinding(
      PointerScrollEvent(
        position: tester.getCenter(find.byType(ComicTile).hitTestable().first),
        scrollDelta: const Offset(0, -120),
        kind: PointerDeviceKind.mouse,
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<ComicTile>(find.byType(ComicTile).first).selected,
      isTrue,
    );
    final disk =
        jsonDecode(File('${root.path}/appdata.json').readAsStringSync()) as Map;
    expect(disk['settings']['searchDisplayMode'], 'gallery');
    expect(disk['settings'][FavoritePreferences.displayMode.key], 'list');
    await tester.tap(find.byTooltip('Search display mode'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('List'));
    await flush(tester);
    await tester.pumpWidget(const SizedBox());
    await drain(tester, appdata.loadDataForTesting(root.path));
    await tester.pumpWidget(page());
    await flush(tester);
    expect(
      tester.widget<ComicTile>(find.byType(ComicTile).first).displayMode,
      ComicTileDisplayMode.detailed,
    );
    expect(appdata.settings[FavoritePreferences.displayMode.key], 'list');
    // Both source groups share the search mode and retain their own selection.
    // Their source header still opens the full results page.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: appNavigation.rootNavigatorKey,
        home: const Scaffold(
          body: AggregatedSearchPage(keyword: 'aggregate keyword'),
        ),
      ),
    );
    await flush(tester);
    expect(find.byTooltip('Search display mode'), findsOneWidget);
    expect(
      tester.widget<ComicTile>(find.byType(ComicTile).first).displayMode,
      ComicTileDisplayMode.detailed,
    );
    await toggleComicCheckbox(tester, find.byType(ComicTile).first);
    final aggregateState = tester.state(find.byType(AggregatedSearchPage));
    final aggregateCalls = source.calls.length;
    await tester.tap(find.byTooltip('Search display mode'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gallery'));
    await flush(tester);
    expect(
      tester.state(find.byType(AggregatedSearchPage)),
      same(aggregateState),
    );
    expect(source.calls.length, aggregateCalls);
    expect(find.byType(SliverGridComics), findsWidgets);
    expect(
      tester.widget<ComicTile>(find.byType(ComicTile).first).displayMode,
      ComicTileDisplayMode.gallery,
    );
    expect(
      tester.widget<ComicTile>(find.byType(ComicTile).first).selected,
      isTrue,
    );
    await tester.tap(find.byTooltip('Search display mode'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('List'));
    await flush(tester);
    expect(
      tester.widget<ComicTile>(find.byType(ComicTile).first).selected,
      isTrue,
    );
    // The source groups are now full grids rather than short horizontal rows.
    // Reach the next real group with pointer scrolling before checking its request.
    await tester.drag(
      find.byType(AggregatedSearchPage),
      const Offset(0, -10000),
    );
    await flush(tester);
    await tester.drag(
      find.byType(AggregatedSearchPage),
      const Offset(0, 10000),
    );
    await flush(tester);
    expect(other.calls, [
      ['aggregate keyword', 1, []],
    ]);
    await tester.tap(find.text(source.name).first);
    await flush(tester);
    expect(find.byType(SearchResultPage), findsOneWidget);
    expect(find.byTooltip('Search display mode'), findsOneWidget);
    expect(
      tester.widget<ComicTile>(find.byType(ComicTile).first).displayMode,
      ComicTileDisplayMode.detailed,
    );
    expect(source.calls.last[0], 'aggregate keyword');
  });
}
