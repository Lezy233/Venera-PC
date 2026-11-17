import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venera_next/app_shell/workspace/workspace_pages.dart';
import 'package:venera_next/features/comic_details/comic_details.dart';
import 'package:venera_next/features/comic_source/comic_source.dart';
import 'package:venera_next/features/comic_widgets/comic_widgets.dart';
import 'package:venera_next/features/favorites/favorites.dart';
import 'package:venera_next/features/favorites/favorites_scope.dart';
import 'package:venera_next/features/history/history.dart';
import 'package:venera_next/features/history/history_scope.dart';
import 'package:venera_next/features/reader/reader.dart';
import 'package:venera_next/features/search/aggregated_search_page.dart';
import 'package:venera_next/features/search/search_result_page.dart';
import 'package:venera_next/foundation/app.dart';
import 'package:venera_next/foundation/appdata.dart';
import 'package:venera_next/foundation/res.dart';
import 'package:venera_next/routing/app_navigation.dart';

import '../../support/comic_card_actions.dart';
import '../../components/sidebar_presentation_test.dart' show settleSidebarWork;
import 'result_preview_test.dart' show Source, Routes;

class _PendingSource extends Source {
  final pending = <Completer<Res<ComicDetails>>>[];
  @override
  LoadComicFunc get loadComicInfo => (id) {
    detailCalls.add(id);
    final result = Completer<Res<ComicDetails>>();
    pending.add(result);
    return result.future;
  };
}

void main() {
  App.dataPath = App.cachePath = Directory.systemTemp.path;
  for (final aggregate in [false, true]) {
    for (final preference in ['read', 'viewDetail']) {
      for (final keyboard in [false, true]) {
        testWidgets(
          'F2 ${aggregate ? 'aggregate' : 'single'} $preference ${keyboard ? 'Enter' : 'mouse'} body preserves selection and returns once',
          (tester) async {
            final root = Directory.systemTemp.createTempSync('f2-body-');
            final oldPath = App.dataPath, oldCache = App.cachePath;
            final oldSettings = Map<String, dynamic>.from(
              appdata.toJson()['settings'] as Map,
            );
            final oldMain = appNavigation.mainNavigatorKey;
            App.dataPath = App.cachePath = root.path;
            final source = _PendingSource(), routes = Routes();
            final favorites = LocalFavoritesManager.independent();
            final history = HistoryManager.create();
            final navigator = appNavigation.rootNavigatorKey;
            appNavigation.mainNavigatorKey = navigator;
            appdata.settings['language'] = 'en-US';
            appdata.settings['onClickFavorite'] = preference;
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
              comicReaderBuilder: ({required id, required sourceKey, title}) =>
                  ReaderWithLoading(id: id, sourceKey: sourceKey, title: title),
            );
            await tester.runAsync(() async {
              await favorites.init();
              await history.init();
            });
            addTearDown(() async {
              await tester.pumpWidget(const SizedBox());
              for (final result in source.pending) {
                if (!result.isCompleted) {
                  result.complete(const Res.error('fixture retired'));
                }
              }
              await tester.pump();
              await settleSidebarWork(tester, () async {
                await favorites.closeAndWait();
                history.close();
              });
              configureComicWidgets();
              configureComicSourceRegistry(
                all: () => [],
                find: (_) => null,
                fromIntKey: (_) => null,
                isEmpty: () => true,
              );
              oldSettings.forEach((k, v) => appdata.settings[k] = v);
              appNavigation.mainNavigatorKey = oldMain;
              App.dataPath = oldPath;
              App.cachePath = oldCache;
              root.deleteSync(recursive: true);
            });
            await tester.pumpWidget(
              FavoritesScope(
                manager: favorites,
                child: HistoryScope(
                  manager: history,
                  child: MaterialApp(
                    navigatorKey: navigator,
                    navigatorObservers: [routes],
                    home: Scaffold(
                      body: aggregate
                          ? const AggregatedSearchPage(keyword: 'Alpha')
                          : SearchResultPage(
                              text: 'Alpha',
                              sourceKey: source.key,
                            ),
                    ),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            expect(source.calls, [
              ['Alpha', 1, []],
            ]);
            final card = find.byWidgetPredicate(
              (w) => w is ComicTile && w.comic.id == 'book-a',
            );
            final page = tester.state(
              aggregate
                  ? find.byType(AggregatedSearchPage)
                  : find.byType(SearchResultPage),
            );
            await toggleComicCheckbox(tester, card);
            await tester.pumpAndSettle();
            expect(tester.widget<ComicTile>(card).selected, isTrue);
            expect(routes.pages, isEmpty);
            final hero = tester.widget<ComicTile>(card).heroID;
            if (keyboard) {
              await tester.tap(find.byType(TextField).first);
              final limit =
                  find.byType(Focus, skipOffstage: false).evaluate().length + 1;
              var found = false;
              for (var i = 0; i < limit; i++) {
                await tester.sendKeyEvent(LogicalKeyboardKey.tab);
                await tester.pump();
                final context = FocusManager.instance.primaryFocus?.context;
                if (context
                            ?.findAncestorWidgetOfExactType<ComicTile>()
                            ?.comic
                            .id ==
                        'book-a' &&
                    context?.findAncestorWidgetOfExactType<Checkbox>() ==
                        null) {
                  found = true;
                  break;
                }
              }
              expect(found, isTrue);
              await tester.sendKeyEvent(LogicalKeyboardKey.enter);
            } else {
              await tester.tapAt(
                tester.getCenter(find.text('Actual result card')),
              );
            }
            expect(routes.pages, hasLength(1));
            // Mount the actual destination and its pending production loading UI.
            // The source deliberately stays pending; this test is route/identity,
            // while decoded Reader pixels and shell AltLeft are GUI evidence.
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 400));
            final destination = preference == 'read'
                ? tester.widget<ReaderWithLoading>(
                    find.byType(ReaderWithLoading),
                  )
                : tester.widget<ComicPage>(find.byType(ComicPage));
            final record = describeWorkspacePage(destination);
            expect(record!.arguments['id'], 'book-a');
            expect(record.arguments['sourceKey'], source.key);
            expect(record.arguments['title'], 'Actual result card');
            if (destination is ComicPage) expect(destination.heroID, hero);
            expect(source.detailCalls, ['book-a']);
            expect(find.byType(CircularProgressIndicator), findsWidgets);
            expect(tester.takeException(), isNull);
            // Dispatch the platform's real back-route event through WidgetsApp.
            await tester.binding.handlePopRoute();
            await tester.pumpAndSettle();
            expect(find.text('Actual result card'), findsOneWidget);
            expect(
              tester.state(
                aggregate
                    ? find.byType(AggregatedSearchPage)
                    : find.byType(SearchResultPage),
              ),
              same(page),
            );
            expect(tester.widget<ComicTile>(card).selected, isTrue);
            expect(routes.pages, hasLength(1));
            expect(source.calls, [
              ['Alpha', 1, []],
            ]);
            expect(source.detailCalls, ['book-a']);
            expect(tester.takeException(), isNull);
            await tester.tapAt(
              tester.getCenter(find.text('Actual result card')),
              buttons: kSecondaryMouseButton,
            );
            await tester.pumpAndSettle();
            expect(
              routes.pages,
              hasLength(1),
              reason: 'opening a menu does not open the body',
            );
            await tester.tap(find.text('Details').last);
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 400));
            final detail = tester.widget<ComicPage>(find.byType(ComicPage));
            expect(
              (detail.id, detail.sourceKey, detail.title),
              ('book-a', source.key, 'Actual result card'),
            );
            expect(
              routes.pages,
              hasLength(2),
              reason: 'explicit Details remains details even under read',
            );
            await tester.binding.handlePopRoute();
            await tester.pumpAndSettle();
            expect(tester.widget<ComicTile>(card).selected, isTrue);
            expect(source.detailCalls, ['book-a', 'book-a']);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
  testWidgets('custom card onTap wins over the default read preference', (
    tester,
  ) async {
    final previous = appdata.settings['onClickFavorite'];
    appdata.settings['onClickFavorite'] = 'read';
    addTearDown(() => appdata.settings['onClickFavorite'] = previous);
    var full = 0, compact = 0;
    const a = Comic(
      'Custom full',
      '',
      'a',
      null,
      null,
      '',
      'source-a',
      null,
      null,
    );
    const b = Comic(
      'Custom compact',
      '',
      'b',
      null,
      null,
      '',
      'source-b',
      null,
      null,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              Expanded(
                child: ComicTile(comic: a, onTap: () => full++),
              ),
              SimpleComicTile(
                comic: b,
                withTitle: true,
                onTap: () => compact++,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Custom full'));
    await tester.tap(find.text('Custom compact'));
    await tester.pumpAndSettle();
    expect((full, compact), (1, 1));
    expect(find.byType(ReaderWithLoading), findsNothing);
    expect(find.byType(ComicPage), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
