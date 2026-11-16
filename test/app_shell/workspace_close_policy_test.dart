import 'dart:convert';
import 'package:venera_next/components/select.dart';
import 'package:venera_next/features/settings/setting_components.dart';
import 'package:venera_next/features/local_comics/local.dart';
import 'package:venera_next/foundation/cache_manager.dart';
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
  _DetailsSource() : super(key: 'workspace-fixture');
  final requests = <String>[];
  @override
  LoadComicFunc get loadComicInfo => (id) async {
    requests.add(id);
    return Res(
      ComicDetails.fromJson({
        'title': 'Controlled details $id',
        'cover': '',
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
  for (final policy in ['left', 'right']) {
    testWidgets(
      'real APP settings persist $policy policy, close the middle tab, and preserve active content on other close',
      (tester) async {
        final root = Directory.systemTemp.createTempSync('ux1-continuity-');
        final oldPath = App.dataPath, oldCache = App.cachePath;
        final oldSettings = Map<String, dynamic>.from(
          appdata.toJson()['settings'] as Map,
        );
        final oldImplicit = Map<String, dynamic>.from(appdata.implicitData);
        App.dataPath = App.cachePath = root.path;
        LocalManager().path = root.path;
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
        final source = _DetailsSource();
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
          final cache = CacheManager.instance;
          if (cache != null) {
            await settleSidebarWork(tester, cache.dispose);
          }
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
        await tester.pumpAndSettle();
        Future<void> settleWorkspace() async {
          await tester.pump(const Duration(milliseconds: 400));
          await settleSidebarWork(tester, () => appdata.writeImplicitData());
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
        await tester.tap(find.text('Settings').hitTestable());
        await settleWorkspace();
        await tester.tap(find.text('APP').hitTestable());
        await settleWorkspace();
        final closeField = find.widgetWithText(
          SelectSetting,
          'After closing a tab',
        );
        final startupField = find.widgetWithText(
          SelectSetting,
          'Application startup',
        );
        expect(closeField, findsOneWidget);
        expect(startupField, findsOneWidget);
        expect(
          find.descendant(
            of: closeField,
            matching: find.text('Most recently viewed'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: startupField,
            matching: find.text('Restore last tabs'),
          ),
          findsOneWidget,
        );
        final stack = host.record.active!.routes.map((r) => r.id).toList();
        Future<void> choose(Finder field, String label) async {
          await tester.tap(
            find.descendant(of: field, matching: find.byType(Select)),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.widgetWithText(PopupMenuItem<String>, label));
          await settleWorkspace();
          expect(
            host.record.tabs.length,
            count,
            reason: 'editing workspace policies must not clear this session',
          );
          expect(host.record.activeId, originalId);
          expect(host.record.active!.routes.map((r) => r.id), stack);
        }

        await choose(closeField, 'Right tab');
        expect(appdata.settings['workspaceCloseTarget'], 'right');
        await choose(closeField, policy == 'left' ? 'Left tab' : 'Right tab');
        await choose(startupField, 'Open favorites');
        final data = jsonDecode(
          File('${root.path}/appdata.json').readAsStringSync(),
        )['settings'];
        expect(data['workspaceCloseTarget'], policy);
        expect(data['workspaceStartup'], 'fresh');
        await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
        try {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        } finally {
          await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
        }
        await settleWorkspace();
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
        await tester.runAsync(() => appdata.loadDataForTesting(root.path));
        await settleWorkspace();
        expect(appdata.settings['workspaceCloseTarget'], policy);
        expect(appdata.settings['workspaceStartup'], 'fresh');
        expect(host.record.tabs.length, count);
        expect(host.record.activeId, originalId);
        final middleId = host.record.tabs[1].id;
        await tester.tap(find.byTooltip('New tab'));
        await settleWorkspace();
        final rightId = host.record.activeId!;
        expect(host.record.tabs.map((t) => t.id), [
          originalId,
          middleId,
          rightId,
        ]);
        Finder tab(String id) => find.descendant(
          of: find.byType(WorkspaceTabStrip),
          matching: find.byKey(ValueKey(id)),
        );
        await tester.tap(tab(middleId));
        await settleWorkspace();
        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        try {
          await tester.sendKeyEvent(LogicalKeyboardKey.keyW);
        } finally {
          await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        }
        await settleWorkspace();
        expect(host.record.tabs.map((t) => t.id), [originalId, rightId]);
        expect(
          host.record.activeId,
          policy == 'left' ? originalId : rightId,
          reason:
              'saved $policy policy must choose the corresponding neighbor, independent of MRU',
        );
        if (policy == 'right') {
          await tester.tap(tab(originalId));
          await settleWorkspace();
        }
        expect(
          tester.state(find.byType(LocalFavoritesPage)),
          same(originalPage),
        );
        expect(
          tester
              .widget<SmoothCustomScrollView>(
                find
                    .descendant(
                      of: find.byType(LocalFavoritesPage),
                      matching: find.byType(SmoothCustomScrollView),
                    )
                    .first,
              )
              .controller,
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
        final beforeRect = tester.getRect(tab(rightId));
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(location: const Offset(1, 1));
        addTearDown(mouse.removePointer);
        await mouse.moveTo(tester.getCenter(tab(rightId)));
        await tester.pumpAndSettle();
        expect(
          tester.getRect(tab(rightId)),
          beforeRect,
          reason: 'hover must not move tab/close geometry',
        );
        final otherClose = find.descendant(
          of: tab(rightId),
          matching: find.byTooltip('Close tab'),
        );
        expect(otherClose.hitTestable(), findsOneWidget);
        await tester.tapAt(tester.getCenter(otherClose));
        await settleWorkspace();
        expect(host.record.tabs.map((t) => t.id), [originalId]);
        expect(
          host.record.activeId,
          originalId,
          reason: 'closing a non-current tab must not activate another stack',
        );
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
        expect(
          FocusManager.instance.primaryFocus,
          same(originalFocus),
          reason:
              'closing another tab must return focus to the original active content target',
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
