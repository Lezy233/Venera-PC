import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venera_next/app_shell/desktop_chrome.dart';
import 'package:venera_next/app_shell/main_page.dart';
import 'package:venera_next/app_shell/workspace/desktop_workspace.dart';
import 'package:venera_next/app_shell/workspace/workspace_store.dart';
import 'package:venera_next/components/window_frame.dart';
import 'package:venera_next/features/comic_widgets/comic_widgets.dart';
import 'package:venera_next/features/favorites/favorites.dart';
import 'package:venera_next/features/favorites/favorites_scope.dart';
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
  testWidgets(
    'real MainPage directory A to B to A retires queued owners and restores only its own disk workspace and entities',
    (tester) async {
      final oldPath = App.dataPath, oldCache = App.cachePath;
      final oldSettings = Map<String, dynamic>.from(
        appdata.toJson()['settings'] as Map,
      );
      final oldImplicit = Map<String, dynamic>.from(appdata.implicitData);
      final oldMain = appNavigation.mainNavigatorKey;
      final root = Directory.systemTemp.createTempSync(
        'ux1-directory-lifecycle-',
      );
      final managers = <LocalFavoritesManager>[];
      final histories = <HistoryManager>[];
      final controllers = <DesktopChromeController>[];
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1000, 700);
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('window_manager'),
        (_) async => false,
      );
      configureComicWidgets(
        favoriteDisplayStateResolver: () =>
            const ComicFavoriteDisplayState(isGallery: true, galleryColumns: 4),
      );
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox());
        await settleSidebarWork(tester, () => appdata.writeImplicitData());
        await tester.runAsync(() async {
          for (final m in managers) {
            await m.debugWaitForHashedIdsRefresh();
            m.close();
          }
          for (final h in histories) {
            h.close();
          }
        });
        for (final c in controllers) {
          c.dispose();
        }
        configureComicWidgets();
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('window_manager'),
          null,
        );
        oldSettings.forEach((k, v) => appdata.settings[k] = v);
        appdata.implicitData = oldImplicit;
        App.dataPath = oldPath;
        App.cachePath = oldCache;
        appNavigation.mainNavigatorKey = oldMain;
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        root.deleteSync(recursive: true);
      });
      await tester.runAsync(OpenCC.init);
      Future<(LocalFavoritesManager, HistoryManager)> openDirectory(
        String label,
      ) async {
        App.dataPath = App.cachePath = '${root.path}/$label';
        Directory(App.dataPath).createSync();
        await settleSidebarWork(tester, () => appdata.doInit());
        appdata.settings['language'] = 'en-US';
        appdata.settings['blockedWords'] = <String>[];
        appdata.settings['favoritesFilterPanelOpen'] = false;
        appdata.settings['favoritesDisplayMode'] = 'gallery';
        appdata.settings['initialPage'] = '1';
        appdata.implicitData['favoriteFolder'] = {
          'name': label,
          'isNetwork': false,
        };
        final m = LocalFavoritesManager.independent(),
            h = HistoryManager.create();
        managers.add(m);
        histories.add(h);
        await tester.runAsync(() async {
          await m.init();
          await h.init();
          await m.createFolder(label);
          await m.addComic(
            label,
            FavoriteItem(
              id: '$label-entity',
              name: '$label real entity',
              coverPath: '',
              author: 'Author',
              type: ComicType.local,
              tags: const [],
            ),
          );
          await m.debugWaitForHashedIdsRefresh();
        });
        return (m, h);
      }

      Future<DesktopWorkspaceState> mount(
        LocalFavoritesManager m,
        HistoryManager h,
      ) async {
        final c = DesktopChromeController();
        controllers.add(c);
        await tester.pumpWidget(
          FavoritesScope(
            manager: m,
            child: HistoryScope(
              manager: h,
              child: MaterialApp(
                navigatorKey: appNavigation.rootNavigatorKey,
                builder: (context, child) => DesktopChromeScope(
                  controller: c,
                  child: WindowFrame(child!),
                ),
                home: const MainPage(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        return tester.state<DesktopWorkspaceState>(
          find.byType(DesktopWorkspace),
        );
      }

      Future<void> settle(DesktopWorkspaceState host) async {
        await tester.pump(const Duration(milliseconds: 400));
        await settleSidebarWork(tester, () => host.waitForSettingsSave());
        await tester.pumpAndSettle();
      }

      Map<String, dynamic> disk(String label) => jsonDecode(
        File('${root.path}/$label/implicitData.json').readAsStringSync(),
      );
      final a = await openDirectory('A');
      final hostA = await mount(a.$1, a.$2);
      await tester.tap(find.byTooltip('New tab'));
      await settle(hostA);
      final aSnapshot = disk('A')[WorkspaceStore.key];
      expect(aSnapshot['tabs'], hasLength(2));
      final lateA = hostA.store.assignment(hostA.record);
      // Establish a real pending UI mutation, then retire that mount before its timer.
      await tester.tap(find.byTooltip('New tab'));
      await tester.pump();
      await tester.pumpWidget(const SizedBox());
      final b = await openDirectory('B');
      final hostB = await mount(b.$1, b.$2);
      await tester.tap(find.byTooltip('New tab'));
      await settle(hostB);
      final bSnapshot = disk('B');
      expect(bSnapshot[WorkspaceStore.key]['directory'], '${root.path}/B');
      expect(
        hostB.record.tabs
            .map((t) => t.id)
            .toSet()
            .intersection(hostA.record.tabs.map((t) => t.id).toSet()),
        isEmpty,
      );
      expect(find.text('B real entity'), findsOneWidget);
      expect(find.text('A real entity'), findsNothing);
      await settleSidebarWork(tester, lateA);
      expect(
        disk('B'),
        bSnapshot,
        reason: 'retired A assignment must not write into B',
      );
      expect(disk('A')[WorkspaceStore.key], aSnapshot);
      await tester.pumpWidget(const SizedBox());
      App.dataPath = App.cachePath = '${root.path}/A';
      appdata.implicitData.clear();
      await settleSidebarWork(tester, () => appdata.doInit());
      final restoredA = await mount(a.$1, a.$2);
      await settleSidebarWork(tester, lateA);
      expect(restoredA.record.freeze(), aSnapshot);
      expect(find.text('A real entity'), findsOneWidget);
      expect(find.text('B real entity'), findsNothing);
      expect(
        disk('A')[WorkspaceStore.key],
        aSnapshot,
        reason:
            'a replacement owner retires the original even after directory returns',
      );
      expect(disk('B'), bSnapshot);
      expect(a.$1.getAllComics().map((c) => c.id), ['A-entity']);
      expect(b.$1.getAllComics().map((c) => c.id), ['B-entity']);
      expect(tester.takeException(), isNull);
    },
  );
}
