import 'dart:convert';
import 'package:venera_next/app_shell/workspace/workspace_record.dart';
import 'package:venera_next/app_shell/workspace/workspace_store.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:venera_next/app_shell/workspace/desktop_workspace.dart';
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

void main() {
  App.dataPath = App.cachePath = Directory.systemTemp.path;
  for (final scenario in [
    'missing',
    'bad-version',
    'bad-view',
    'unknown-route',
  ]) {
    testWidgets(
      'real disk $scenario workspace safely falls back once and preserves favorite entities',
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
        final navigator = GlobalKey<NavigatorState>();
        final oldMain = appNavigation.mainNavigatorKey;
        appNavigation.mainNavigatorKey = navigator;
        configureComicWidgets(
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
                type: ComicType.local,
                tags: const [],
              ),
            );
          }
          await manager.debugWaitForHashedIdsRefresh();
        });
        final page = WorkspaceRouteRecord(kind: WorkspacePageKind.favorites);
        final tab = WorkspaceTabRecord(routes: [page]);
        final snapshot = WorkspaceRecord(
          directory: root.path,
          tabs: [tab],
          activeId: tab.id,
          recent: [tab.id],
        ).freeze();
        if (scenario == 'bad-version') snapshot['version'] = 999;
        if (scenario == 'bad-view') {
          (snapshot['tabs'] as List).first['routes'].first['view'] = {
            'local-favorites': {'scroll': '420'},
          };
        }
        if (scenario == 'unknown-route') {
          (snapshot['tabs'] as List).first['routes'].first['kind'] =
              'unrecognized-auxiliary-route';
        }
        if (scenario != 'missing') {
          appdata.implicitData[WorkspaceStore.key] = snapshot;
        }
        appdata.implicitData['unrelated-workspace-test'] = {'keep': 42};
        await settleSidebarWork(tester, () async {
          await appdata.saveData(false);
          await appdata.writeImplicitData();
          appdata.implicitData.clear();
          await appdata.doInit();
        });
        final disk = jsonDecode(
          File('${root.path}/implicitData.json').readAsStringSync(),
        );
        expect(disk['unrelated-workspace-test'], {'keep': 42});
        await tester.pumpWidget(
          FavoritesScope(
            manager: manager,
            child: HistoryScope(
              manager: history,
              child: MaterialApp(
                navigatorKey: appNavigation.rootNavigatorKey,
                builder: (context, child) => DesktopChromeScope(
                  controller: chrome,
                  child: WindowFrame(child!),
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

        final message = scenario == 'missing'
            ? 'No saved workspace. Opened favorites.'
            : 'The saved workspace could not be restored. Opened favorites.';
        expect(find.text(message), findsOneWidget);
        final host = tester.state<DesktopWorkspaceState>(
          find.byType(DesktopWorkspace),
        );
        expect(host.record.tabs.length, 1);
        expect(host.record.active!.current.kind, WorkspacePageKind.favorites);
        expect(find.byType(LocalFavoritesPage), findsOneWidget);
        expect(
          manager.getAllComics().map((c) => (c.sourceKey, c.id)),
          unorderedEquals([for (var i = 0; i < 60; i++) ('local', 'book-$i')]),
        );
        expect(appdata.implicitData['unrelated-workspace-test'], {'keep': 42});
        await tester.tap(find.byTooltip('Dismiss'));
        await settleWorkspace();
        expect(find.text(message), findsNothing);
        await tester.tap(find.byTooltip('New tab'));
        await settleWorkspace();
        expect(host.record.tabs.length, 2);
        expect(
          find.text(message),
          findsNothing,
          reason: 'recovery must not loop on each interaction',
        );
        expect(manager.getAllComics(), hasLength(60));
        expect(tester.takeException(), isNull);
      },
    );
  }
}
