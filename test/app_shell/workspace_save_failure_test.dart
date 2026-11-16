import 'dart:convert';
import 'package:venera_next/app_shell/workspace/workspace_record.dart';
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
  testWidgets(
    'production workspace reports a real disk save fault and retries the latest snapshot without losing content',
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
      final snapshotFile = File('${root.path}/implicitData.json');
      final before = jsonDecode(
        snapshotFile.readAsStringSync(),
      )[WorkspaceStore.key];
      final obstacle = Directory('${root.path}/implicitData.json.tmp')
        ..createSync();
      addTearDown(() {
        if (obstacle.existsSync()) obstacle.deleteSync();
      });
      await tester.tap(find.byTooltip('New tab'));
      await tester.pump(const Duration(milliseconds: 400));
      for (var i = 0; i < 200 && host.savingSettings; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
        await tester.pump();
      }
      expect(
        host.savingSettings,
        isFalse,
        reason:
            'disk failure must settle into actionable feedback, not an indefinite spinner',
      );
      expect(host.hasSettingsSaveError, isTrue);
      expect(
        find.widgetWithText(TextButton, 'Retry').hitTestable(),
        findsOneWidget,
      );
      expect(
        jsonDecode(snapshotFile.readAsStringSync())[WorkspaceStore.key],
        before,
        reason:
            'failed atomic save must preserve the previous durable workspace',
      );
      expect(host.record.tabs.length, 3);
      obstacle.deleteSync();
      await tester.tap(find.widgetWithText(TextButton, 'Retry'));
      await settleSidebarWork(tester, host.waitForSettingsSave);
      await tester.pumpAndSettle();
      expect(host.hasSettingsSaveError, isFalse);
      expect(find.widgetWithText(TextButton, 'Retry'), findsNothing);
      final repaired = WorkspaceRecord.fromJson(
        jsonDecode(snapshotFile.readAsStringSync())[WorkspaceStore.key],
        directory: root.path,
      );
      expect(repaired.toJson(), host.record.toJson());
      // Two rapid actual inputs must persist the latest order and activation.
      await tester.tap(find.byTooltip('New tab'));
      await tester.pump();
      await tester.tap(find.byTooltip('New tab'));
      await settleWorkspace();
      expect(host.record.tabs.length, 5);
      final latest = WorkspaceRecord.fromJson(
        jsonDecode(snapshotFile.readAsStringSync())[WorkspaceStore.key],
        directory: root.path,
      );
      expect(latest.toJson(), host.record.toJson());
      await tester.tap(
        find.descendant(
          of: find.byType(WorkspaceTabStrip),
          matching: find.byKey(ValueKey(originalId)),
        ),
      );
      await settleWorkspace();
      expect(tester.state(find.byType(LocalFavoritesPage)), same(originalPage));
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
      expect(tester.takeException(), isNull);
    },
  );
}
