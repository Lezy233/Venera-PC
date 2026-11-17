import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venera_next/features/comic_details/comic_details.dart';
import 'package:venera_next/features/comic_widgets/comic_widgets.dart';
import 'package:venera_next/features/comic_source/comic_source.dart';
import 'package:venera_next/features/search/search_result_page.dart';
import 'package:venera_next/features/search/aggregated_search_page.dart';
import 'package:venera_next/foundation/app.dart';
import 'package:venera_next/foundation/appdata.dart';
import 'package:venera_next/foundation/app_page_route.dart';
import 'package:venera_next/foundation/res.dart';
import 'package:venera_next/routing/app_navigation.dart';
import '../../support/comic_source_fixture.dart';
import 'package:flutter/services.dart';
import '../../support/comic_card_actions.dart';

class Source extends ComicSourceFixture {
  Source() : super(key: 'click-baseline');
  final calls = <Object>[];
  final detailCalls = <String>[];
  @override
  LoadComicFunc get loadComicInfo => (id) async {
    detailCalls.add(id);
    return Res(
      ComicDetails.fromJson({
        'title': 'Actual preview',
        'comicId': id,
        'sourceKey': key,
        'cover': '',
        'description': 'Actual overview',
        'tags': <String, dynamic>{},
      }),
    );
  };
  @override
  SearchPageData get searchPageData =>
      SearchPageData([], (keyword, page, options) async {
        calls.add([keyword, page, List.of(options)]);
        return Res([
          const Comic(
            'Actual result card',
            '',
            'book-a',
            null,
            null,
            '',
            'click-baseline',
            null,
            null,
          ),
        ], subData: 1);
      }, null);
}

class Routes extends NavigatorObserver {
  final pages = <AppPageRoute>[];
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is AppPageRoute) pages.add(route);
  }
}

void main() {
  App.dataPath = App.cachePath = Directory.systemTemp.path;
  for (final aggregate in [false, true]) {
    testWidgets(
      'F2 production ${aggregate ? 'aggregate' : 'single-source'} cards expose real preview and selection',
      (tester) async {
        final source = Source(), routes = Routes();
        final previous = Map<String, dynamic>.from(
          appdata.toJson()['settings'] as Map,
        );
        final navigator = appNavigation.rootNavigatorKey,
            previousMain = appNavigation.mainNavigatorKey;
        appNavigation.mainNavigatorKey = navigator;
        appdata.settings['language'] = 'en-US';
        appdata.settings['onClickFavorite'] = 'read';
        appdata.settings['comicDisplayMode'] = 'gallery';
        appdata.settings['blockedWords'] = <String>[];
        appdata.settings['searchSources'] = [source.key];
        appdata.settings['autoAddLanguageFilter'] = 'none';
        configureComicSourceRegistry(
          all: () => [source],
          find: (key) => key == source.key ? source : null,
          fromIntKey: (_) => source,
          isEmpty: () => false,
        );
        configureComicWidgets(
          comicPageBuilder:
              ({required id, required sourceKey, cover, title, heroID}) =>
                  ComicPage(
                    id: id,
                    sourceKey: sourceKey,
                    cover: cover,
                    title: title,
                    heroID: heroID,
                  ),
        );
        addTearDown(() async {
          await tester.pumpWidget(const SizedBox());
          configureComicWidgets();
          configureComicSourceRegistry(
            all: () => [],
            find: (_) => null,
            fromIntKey: (_) => null,
            isEmpty: () => true,
          );
          appNavigation.mainNavigatorKey = previousMain;
          previous.forEach((k, v) => appdata.settings[k] = v);
        });
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: navigator,
            navigatorObservers: [routes],
            home: Scaffold(
              body: aggregate
                  ? const AggregatedSearchPage(keyword: 'Alpha')
                  : SearchResultPage(text: 'Alpha', sourceKey: source.key),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: 'initialization is not product red',
        );
        expect(find.text('Actual result card'), findsOneWidget);
        expect(source.calls, [
          ['Alpha', 1, []],
        ]);
        await tester.tap(find.byType(TextField).first);
        final limit =
            find.byType(Focus, skipOffstage: false).evaluate().length + 1;
        var cardFocused = false;
        for (var i = 0; i < limit; i++) {
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();
          final tile = FocusManager.instance.primaryFocus?.context
              ?.findAncestorWidgetOfExactType<ComicTile>();
          if (tile?.comic.id == 'book-a') {
            cardFocused = true;
            break;
          }
        }
        expect(
          cardFocused,
          isTrue,
          reason: 'actual result card is reachable by keyboard',
        );
        final original = FocusManager.instance.primaryFocus;
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();
        expect(find.text('Actual overview'), findsOneWidget);
        expect(source.detailCalls, ['book-a']);
        expect(routes.pages, isEmpty);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(FocusManager.instance.primaryFocus, same(original));
        final card = find.byWidgetPredicate(
          (w) => w is ComicTile && w.comic.id == 'book-a',
        );
        await toggleComicCheckbox(tester, card);
        await tester.pumpAndSettle();
        expect(tester.widget<ComicTile>(card).selected, isTrue);
        expect(routes.pages, isEmpty);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(tester.widget<ComicTile>(card).selected, isFalse);
        final checkboxLimit = find.byType(Focus, skipOffstage: false).evaluate().length + 1;
        for (var i = 0; i < checkboxLimit; i++) {
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();
          if (FocusManager.instance.primaryFocus?.context?.findAncestorWidgetOfExactType<Checkbox>() != null) break;
        }
        expect(FocusManager.instance.primaryFocus!.context!.findAncestorWidgetOfExactType<Checkbox>(), isNotNull);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(routes.pages, isEmpty, reason: 'Enter on an independent checkbox must never open the comic body');
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
}
