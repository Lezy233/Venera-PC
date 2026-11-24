import 'dart:convert';
import 'package:image/image.dart' as img;
import 'package:venera_next/components/workspace_page_scope.dart';
import 'package:venera_next/app_shell/workspace/workspace_store.dart';
import 'package:venera_next/features/comic_details/cover_viewer.dart';
import 'package:venera_next/components/image.dart';
import 'dart:io';
import '../support/comic_card_actions.dart';
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
import 'package:venera_next/components/desktop_chrome.dart';
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
  _DetailsSource(this.cover) : super(key: 'workspace-fixture');
  final String cover;
  final requests = <String>[];
  @override
  LoadComicFunc get loadComicInfo => (id) async {
    requests.add(id);
    return Res(
      ComicDetails.fromJson({
        'title': 'Controlled details $id',
        'cover': cover,
        'description': 'Fixture description',
        'tags': <String, dynamic>{},
        'sourceKey': key,
        'comicId': id,
      }),
    );
  };
}

void main() {
  App.dataPath = App.cachePath = Directory.systemTemp.path;
  testWidgets(
    'real cover auxiliary route retains runtime history and restores its parent once with feedback from disk',
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
      final source = _DetailsSource('file://${root.path}/cover.png');
      configureComicSourceRegistry(
        all: () => [source],
        find: (key) => key == source.key ? source : null,
        fromIntKey: (key) => key == source.key.hashCode ? source : null,
        isEmpty: () => false,
      );
      final navigator = GlobalKey<NavigatorState>();
      final oldMain = appNavigation.mainNavigatorKey;
      appNavigation.mainNavigatorKey = navigator;
      var pageBuilds = 0;
      configureComicWidgets(
        comicPageBuilder:
            ({required id, required sourceKey, cover, title, heroID}) {
              pageBuilds++;
              return ComicPage(
                id: id,
                sourceKey: sourceKey,
                cover: cover,
                title: title,
                heroID: heroID,
              );
            },
        favoriteDisplayStateResolver: () =>
            const ComicFavoriteDisplayState(isGallery: true, galleryColumns: 4),
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
        File(
          '${root.path}/cover.png',
        ).writeAsBytesSync(img.encodePng(img.Image(width: 100, height: 150)));
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
      final visible = find
          .byType(ComicTile)
          .hitTestable(at: Alignment.topCenter);
      final first = tester.widget<ComicTile>(visible.at(0)).comic;
      final second = tester.widget<ComicTile>(visible.at(1)).comic;
      await toggleComicCheckbox(tester, visible.at(0));
      await settleWorkspace();
      await toggleComicCheckbox(
        tester,
        find.byWidgetPredicate(
          (w) => w is ComicTile && w.comic.id == second.id,
        ),
      );
      await settleWorkspace();
      final selectedIds = {first.id, second.id};
      final originalFocus = FocusManager.instance.primaryFocus;
      expect(originalFocus?.debugLabel, 'comic-card-selection');
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
      expect(tester.state(find.byType(LocalFavoritesPage)), same(originalPage));
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
      expect((details.sourceKey, details.id), ('workspace-fixture', first.id));
      expect(source.requests, [first.id]);
      expect(
        pageBuilds,
        1,
        reason:
            'observing navigation must not eagerly execute the real page builder a second time',
      );
      expect(host.record.activeId, originalId);
      expect(host.record.tabs.length, count);
      final detailsState = tester.state(find.byType(ComicPage));
      final binding = WorkspacePageScope.read(
        tester.element(find.byType(ComicPage)),
      )!;
      Future<void> openCover() async {
        final cover = find
            .descendant(
              of: find.byType(ComicPage),
              matching: find.byType(AnimatedImage),
            )
            .first;
        await tester.tapAt(tester.getCenter(cover));
        await settleWorkspace();
        expect(find.byType(ComicCoverViewer), findsOneWidget);
        expect(
          tester.widget<ComicCoverViewer>(find.byType(ComicCoverViewer)).title,
          'Controlled details ${first.id}',
        );
      }

      Future<void> back() async {
        await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
        await settleWorkspace();
      }

      await openCover();
      final coverState = tester.state(find.byType(ComicCoverViewer));
      expect(binding.active, isFalse);
      final otherId = host.record.tabs.firstWhere((t) => t.id != originalId).id;
      Finder tabFor(String id) => find.descendant(
        of: find.byType(WorkspaceTabStrip),
        matching: find.byKey(ValueKey(id)),
      );
      await tester.tap(tabFor(otherId));
      await settleWorkspace();
      await tester.tap(tabFor(originalId));
      await settleWorkspace();
      expect(tester.state(find.byType(ComicCoverViewer)), same(coverState));
      expect(
        binding.active,
        isFalse,
        reason:
            'reactivating an auxiliary route must not reactivate the covered parent',
      );
      expect(host.record.freeze()['tabs'].first['restoreParent'], isTrue);
      await back();
      expect(tester.state(find.byType(ComicPage)), same(detailsState));
      expect(binding.active, isTrue);
      await back();
      expect(tester.state(find.byType(LocalFavoritesPage)), same(originalPage));
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
      await tester.tapAt(
        tester.getCenter(firstCard),
        buttons: kSecondaryMouseButton,
      );
      await settleWorkspace();
      await tester.tap(find.text('Details'));
      await settleWorkspace();
      await openCover();
      final beforeRestart = host.record.freeze();
      expect(
        jsonDecode(
          File('${root.path}/implicitData.json').readAsStringSync(),
        )[WorkspaceStore.key],
        beforeRestart,
      );
      final requestsBefore = source.requests.length;
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      appdata.implicitData.clear();
      await settleSidebarWork(tester, appdata.doInit);
      await mountMain();
      await settleWorkspace();
      final restored = tester.state<DesktopWorkspaceState>(
        find.byType(DesktopWorkspace),
      );
      expect(restored.record.activeId, originalId);
      expect(
        restored.record.tabs.map((t) => t.id),
        (beforeRestart['tabs'] as List).map((t) => t['id']),
      );
      expect(find.byType(ComicCoverViewer), findsNothing);
      expect(tester.widget<ComicPage>(find.byType(ComicPage)).id, first.id);
      expect(source.requests.length, requestsBefore + 1);
      expect(
        find.text(
          'Temporary pages were not restored. Returned to their previous pages.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Dismiss'));
      await settleWorkspace();
      expect(
        find.text(
          'Temporary pages were not restored. Returned to their previous pages.',
        ),
        findsNothing,
      );
      expect(
        jsonDecode(
          File('${root.path}/implicitData.json').readAsStringSync(),
        )[WorkspaceStore.key]['tabs'].first['restoreParent'],
        isFalse,
      );
      expect(manager.getAllComics(), hasLength(60));
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      appdata.implicitData.clear();
      await settleSidebarWork(tester, appdata.doInit);
      await mountMain();
      await settleWorkspace();
      expect(
        find.text(
          'Temporary pages were not restored. Returned to their previous pages.',
        ),
        findsNothing,
      );
      expect(tester.widget<ComicPage>(find.byType(ComicPage)).id, first.id);
      expect(source.requests.length, requestsBefore + 2);
      expect(tester.takeException(), isNull);
    },
  );
}
