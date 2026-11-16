import 'package:venera_next/components/appbar.dart';
import 'dart:convert';
import 'package:venera_next/app_shell/workspace/workspace_store.dart';
import 'dart:io';
import 'package:venera_next/features/comic_source/comic_source.dart';
import 'package:venera_next/features/comic_details/comic_details.dart';
import 'package:venera_next/foundation/res.dart';
import 'package:venera_next/app_shell/global_shortcuts.dart';
import '../support/comic_source_fixture.dart';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:venera_next/components/scroll.dart';
import 'package:venera_next/app_shell/workspace/desktop_workspace.dart';
import 'package:venera_next/app_shell/workspace/workspace_tab_strip.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venera_next/app_shell/desktop_chrome.dart';
import 'package:venera_next/app_shell/main_page.dart';
import 'package:venera_next/components/window_frame.dart';
import 'package:venera_next/features/comic_widgets/comic_widgets.dart';
import 'package:venera_next/features/favorites/favorites.dart';
import 'package:venera_next/features/favorites/favorites_scope.dart';
import 'package:venera_next/features/favorites/local_favorites_page.dart';
import 'package:venera_next/features/history/history.dart';
import 'package:venera_next/features/history/history_scope.dart';
import 'package:venera_next/foundation/app.dart';
import 'package:venera_next/foundation/appdata.dart';
import 'package:venera_next/foundation/comic_type.dart';
import 'package:venera_next/foundation/opencc.dart';
import 'package:venera_next/routing/app_navigation.dart';
import '../components/sidebar_presentation_test.dart' show settleSidebarWork;

class _DetailsSource extends ComicSourceFixture {
  _DetailsSource(this.grouped) : super(key: 'workspace-fixture');
  final bool grouped;
  final requests = <String>[];
  @override
  LoadComicFunc get loadComicInfo => (id) async {
    requests.add(id);
    return Res(
      ComicDetails.fromJson({
        'title': 'Controlled details $id',
        'cover': '',
        'description': 'Fixture description',
        'chapters': grouped
            ? {
                for (final volume in ['Volume A', 'Volume B'])
                  volume: {
                    for (var i = 1; i <= 80; i++)
                      '$volume-ep-$i': '$volume Episode $i',
                  },
              }
            : {for (var i = 1; i <= 80; i++) 'ep-$i': 'Episode $i'},
        'tags': <String, dynamic>{},
        'sourceKey': key,
        'comicId': id,
      }),
    );
  };
}

void main() {
  App.dataPath = App.cachePath = Directory.systemTemp.path;
  for (final grouped in [false, true]) {
    testWidgets(
      'real details expansion and scroll survive tabs and disk while Alt Left preserves the favorite scene; grouped=$grouped',
      (tester) async {
        final root = Directory.systemTemp.createTempSync('ux1-continuity-');
        final oldPath = App.dataPath, oldCache = App.cachePath;
        final oldSettings = Map<String, dynamic>.from(
          appdata.toJson()['settings'] as Map,
        );
        final oldImplicit = Map<String, dynamic>.from(appdata.implicitData);
        App.dataPath = App.cachePath = root.path;
        appdata.settings['language'] = 'en-US';
        appdata.settings['blockedWords'] = <String>[];
        appdata.settings['favoritesDisplayMode'] = 'gallery';
        appdata.settings['favoritesDensity'] = 'comfortable';
        appdata.settings['favoritesFilterPanelOpen'] = false;
        appdata.implicitData.clear();
        appdata.settings['initialPage'] = '1';
        appdata.implicitData['favoriteFolder'] = {
          'name': 'Continuity',
          'isNetwork': false,
        };
        final manager = LocalFavoritesManager.independent();
        final history = HistoryManager.create();
        final chrome = DesktopChromeController();
        final source = _DetailsSource(grouped);
        configureComicSourceRegistry(
          all: () => [source],
          find: (key) => key == source.key ? source : null,
          fromIntKey: (key) => key == source.key.hashCode ? source : null,
          isEmpty: () => false,
        );
        final navigator = GlobalKey<NavigatorState>();
        final oldMain = appNavigation.mainNavigatorKey;
        appNavigation.mainNavigatorKey = navigator;
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
          favoriteDisplayStateResolver: () => const ComicFavoriteDisplayState(
            isGallery: true,
            galleryColumns: 4,
          ),
        );
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('window_manager'),
          (_) async => false,
        );
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(1400, 900);
        addTearDown(() async {
          await tester.pumpWidget(const SizedBox());
          await settleSidebarWork(tester, () => appdata.writeImplicitData());
          await tester.runAsync(() async {
            await manager.debugWaitForHashedIdsRefresh();
            manager.close();
            history.close();
          });
          chrome.dispose();
          configureComicWidgets();
          configureComicSourceRegistry(
            all: () => [],
            find: (_) => null,
            fromIntKey: (_) => null,
            isEmpty: () => true,
          );
          tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            const MethodChannel('window_manager'),
            null,
          );
          oldSettings.forEach((k, v) => appdata.settings[k] = v);
          appdata.implicitData = oldImplicit;
          appNavigation.mainNavigatorKey = oldMain;
          App.dataPath = oldPath;
          App.cachePath = oldCache;
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
          root.deleteSync(recursive: true);
        });
        await tester.runAsync(() async {
          await OpenCC.init();
          await manager.init();
          await history.init();
          await manager.createFolder('Continuity');
          for (var i = 0; i < 60; i++) {
            await manager.addComic(
              'Continuity',
              FavoriteItem(
                id: 'book-$i',
                name: 'Book ${i.toString().padLeft(2, '0')}',
                coverPath: '',
                author: 'Author',
                type: ComicType.fromKey('workspace-fixture'),
                tags: const [],
              ),
            );
          }
          await manager.debugWaitForHashedIdsRefresh();
        });
        Future<void> mountMain() async {
          await tester.pumpWidget(
            FavoritesScope(
              manager: manager,
              child: HistoryScope(
                manager: history,
                child: MaterialApp(
                  navigatorKey: appNavigation.rootNavigatorKey,
                  builder: (context, child) => DesktopChromeScope(
                    controller: chrome,
                    child: GlobalShortcuts(
                      chrome: chrome,
                      child: WindowFrame(child!),
                    ),
                  ),
                  home: const MainPage(),
                ),
              ),
            ),
          );
        }

        await mountMain();
        await tester.pumpAndSettle();
        Future<void> settleWorkspace() async {
          await tester.pump(const Duration(milliseconds: 400));
          await settleSidebarWork(tester, () => appdata.writeImplicitData());
          // Loading completion may publish a view after the first snapshot was
          // queued. Drain its actual save, rather than animate a saving spinner
          // while filesystem IO is unable to progress in fake time.
          await tester.pump(const Duration(milliseconds: 400));
          await settleSidebarWork(
            tester,
            () => tester
                .state<DesktopWorkspaceState>(find.byType(DesktopWorkspace))
                .waitForSettingsSave(),
          );
          await tester.pumpAndSettle();
        }

        expect(find.byTooltip('New tab'), findsOneWidget);
        final host = tester.state<DesktopWorkspaceState>(
          find.byType(DesktopWorkspace),
        );
        final originalId = host.record.activeId!;
        final originalPage = tester.state(find.byType(LocalFavoritesPage));
        final viewport = find
            .descendant(
              of: find.byType(LocalFavoritesPage),
              matching: find.byType(SmoothCustomScrollView),
            )
            .first;
        final originalController = tester
            .widget<SmoothCustomScrollView>(viewport)
            .controller!;
        await tester.sendEventToBinding(
          PointerScrollEvent(
            position: tester.getCenter(find.byType(ComicTile).first),
            scrollDelta: const Offset(0, 420),
            kind: PointerDeviceKind.mouse,
          ),
        );
        await settleWorkspace();
        expect(originalController.offset, closeTo(420, .01));
        final visible = find.byType(ComicTile).hitTestable();
        final first = tester.widget<ComicTile>(visible.at(0)).comic;
        final second = tester.widget<ComicTile>(visible.at(1)).comic;
        await tester.longPressAt(tester.getCenter(visible.at(0)));
        await settleWorkspace();
        await tester.tapAt(
          tester.getCenter(
            find.byWidgetPredicate(
              (w) => w is ComicTile && w.comic.id == second.id,
            ),
          ),
        );
        await settleWorkspace();
        final selectedIds = {first.id, second.id};
        final originalFocus = FocusManager.instance.primaryFocus;
        expect(originalFocus?.debugLabel, 'local-favorites-selection');
        expect(
          tester
              .widget<SliverGridComics>(find.byType(SliverGridComics))
              .selections!
              .keys
              .map((c) => (c.sourceKey, c.id)),
          unorderedEquals(selectedIds.map((id) => ('workspace-fixture', id))),
        );
        await tester.tap(find.byTooltip('New tab'));
        await settleWorkspace();
        expect(find.text('All 2'), findsOneWidget);
        expect(
          tester.state(find.byType(LocalFavoritesPage)),
          isNot(same(originalPage)),
        );
        expect(
          tester
              .widget<SliverGridComics>(find.byType(SliverGridComics))
              .selections,
          isEmpty,
        );
        await tester.tap(
          find.descendant(
            of: find.byType(WorkspaceTabStrip),
            matching: find.byKey(ValueKey(originalId)),
          ),
        );
        await settleWorkspace();
        expect(
          tester.state(find.byType(LocalFavoritesPage)),
          same(originalPage),
        );
        final restoredViewport = find
            .descendant(
              of: find.byType(LocalFavoritesPage),
              matching: find.byType(SmoothCustomScrollView),
            )
            .first;
        expect(
          tester.widget<SmoothCustomScrollView>(restoredViewport).controller,
          same(originalController),
        );
        expect(originalController.offset, closeTo(420, .01));
        expect(
          tester
              .widget<SliverGridComics>(find.byType(SliverGridComics))
              .selections!
              .keys
              .map((c) => (c.sourceKey, c.id)),
          unorderedEquals(selectedIds.map((id) => ('workspace-fixture', id))),
        );
        expect(FocusManager.instance.primaryFocus, same(originalFocus));
        final count = host.record.tabs.length;
        final firstCard = find
            .byWidgetPredicate((w) => w is ComicTile && w.comic.id == first.id)
            .hitTestable();
        await tester.tapAt(
          tester.getCenter(firstCard),
          buttons: kSecondaryMouseButton,
        );
        await settleWorkspace();
        await tester.tap(find.text('Details'));
        await settleWorkspace();
        final details = tester.widget<ComicPage>(find.byType(ComicPage));
        expect(
          (details.sourceKey, details.id),
          ('workspace-fixture', first.id),
        );
        expect(source.requests, [first.id]);
        expect(host.record.activeId, originalId);
        expect(host.record.tabs.length, count);
        final detailState = tester.state(find.byType(ComicPage));
        final detailViewport = find.descendant(
          of: find.byType(ComicPage),
          matching: find.byType(SmoothCustomScrollView),
        );
        final detailController = tester
            .widget<SmoothCustomScrollView>(detailViewport)
            .controller!;
        final chapterViewKey = grouped
            ? 'comic-chapter-group'
            : 'comic-chapters';
        Future<void> selectGroup() async {
          if (!grouped) return;
          await tester.scrollUntilVisible(
            find.text('Volume B'),
            200,
            scrollable: find
                .descendant(
                  of: find.byType(ComicPage),
                  matching: find.byType(Scrollable),
                )
                .first,
          );
          await tester.tap(find.text('Volume B').hitTestable());
          await settleWorkspace();
          expect(
            tester.widget<AppTabBar>(find.byType(AppTabBar)).controller!.index,
            1,
          );
        }

        await selectGroup();
        final expand = find.text('Show all (80)');
        await tester.scrollUntilVisible(
          expand,
          250,
          scrollable: find
              .descendant(
                of: find.byType(ComicPage),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await settleWorkspace();
        await tester.tap(expand.hitTestable());
        await settleWorkspace();
        expect(find.text('Show all (80)'), findsNothing);
        final detailsOffset = detailController.offset;
        expect(detailsOffset, greaterThan(0));
        final detailsView = host.record.active!.current.view;
        expect(
          detailsView[chapterViewKey],
          isA<Map>(),
          reason:
              'the real expanded chapter control must contribute durable state',
        );
        expect(detailsView[chapterViewKey]['expanded'], isTrue);
        if (grouped) expect(detailsView[chapterViewKey]['group'], 'Volume B');
        expect(
          detailsView['comic-details']['scroll'],
          closeTo(detailsOffset, .01),
        );
        final otherTab = host.record.tabs
            .firstWhere((t) => t.id != originalId)
            .id;
        await tester.tap(
          find.descendant(
            of: find.byType(WorkspaceTabStrip),
            matching: find.byKey(ValueKey(otherTab)),
          ),
        );
        await settleWorkspace();
        await tester.tap(
          find.descendant(
            of: find.byType(WorkspaceTabStrip),
            matching: find.byKey(ValueKey(originalId)),
          ),
        );
        await settleWorkspace();
        expect(tester.state(find.byType(ComicPage)), same(detailState));
        expect(
          tester.widget<SmoothCustomScrollView>(detailViewport).controller,
          same(detailController),
        );
        expect(detailController.offset, closeTo(detailsOffset, .01));
        expect(source.requests, [first.id]);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
        await settleWorkspace();
        expect(find.byType(ComicPage), findsNothing);
        expect(host.record.activeId, originalId);
        expect(host.record.tabs.length, count);
        expect(
          tester.state(find.byType(LocalFavoritesPage)),
          same(originalPage),
        );
        expect(originalController.offset, closeTo(420, .01));
        expect(
          tester
              .widget<SliverGridComics>(find.byType(SliverGridComics))
              .selections!
              .keys
              .map((c) => (c.sourceKey, c.id)),
          unorderedEquals(selectedIds.map((id) => ('workspace-fixture', id))),
        );
        expect(FocusManager.instance.primaryFocus, same(originalFocus));
        expect(source.requests, [first.id]);
        await tester.tapAt(
          tester.getCenter(firstCard),
          buttons: kSecondaryMouseButton,
        );
        await settleWorkspace();
        await tester.tap(find.text('Details'));
        await settleWorkspace();
        await selectGroup();
        await tester.scrollUntilVisible(
          expand,
          250,
          scrollable: find
              .descendant(
                of: find.byType(ComicPage),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await settleWorkspace();
        await tester.tap(expand.hitTestable());
        await settleWorkspace();
        final savedOffset = tester
            .widget<SmoothCustomScrollView>(detailViewport)
            .controller!
            .offset;
        final beforeRestart = host.record.freeze();
        expect(
          jsonDecode(
            File('${root.path}/implicitData.json').readAsStringSync(),
          )[WorkspaceStore.key],
          beforeRestart,
        );
        final oldDetails = tester.state(find.byType(ComicPage));
        final requestCount = source.requests.length;
        await tester.pumpWidget(const SizedBox());
        await tester.pump();
        appdata.implicitData.clear();
        await settleSidebarWork(tester, appdata.doInit);
        await mountMain();
        await settleWorkspace();
        final restoredHost = tester.state<DesktopWorkspaceState>(
          find.byType(DesktopWorkspace),
        );
        expect(restoredHost.record.activeId, originalId);
        expect(tester.state(find.byType(ComicPage)), isNot(same(oldDetails)));
        expect(tester.widget<ComicPage>(find.byType(ComicPage)).id, first.id);
        expect(
          tester.widget<ComicPage>(find.byType(ComicPage)).sourceKey,
          'workspace-fixture',
        );
        expect(find.text('Show all (80)'), findsNothing);
        expect(
          tester
              .widget<SmoothCustomScrollView>(detailViewport)
              .controller!
              .offset,
          closeTo(savedOffset, .01),
        );
        expect(
          restoredHost.record.active!.current.view[chapterViewKey]['expanded'],
          isTrue,
        );
        expect(source.requests.length, requestCount + 1);
        expect(source.requests.last, first.id);
        if (grouped) {
          expect(
            restoredHost.record.active!.current.view[chapterViewKey]['group'],
            'Volume B',
          );
          expect(
            tester.widget<AppTabBar>(find.byType(AppTabBar)).controller!.index,
            1,
          );
        }
        expect(manager.getAllComics(), hasLength(60));
        expect(tester.takeException(), isNull);
      },
    );
  }
}
