import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venera_next/app_shell/desktop_chrome.dart';
import 'package:venera_next/app_shell/global_shortcuts.dart';
import 'package:venera_next/app_shell/main_page.dart';
import 'package:venera_next/app_shell/workspace/desktop_workspace.dart';
import 'package:venera_next/app_shell/workspace/workspace_tab_strip.dart';
import 'package:venera_next/components/scroll.dart';
import 'package:venera_next/components/window_frame.dart';
import 'package:venera_next/features/comic_details/comic_details.dart';
import 'package:venera_next/features/comic_source/comic_source.dart';
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
import 'package:venera_next/foundation/res.dart';
import 'package:venera_next/foundation/translations.dart';
import 'package:venera_next/routing/app_navigation.dart';
import '../components/sidebar_presentation_test.dart' show settleSidebarWork;
import '../support/comic_card_actions.dart';
import '../support/comic_source_fixture.dart';

class _PreviewSource extends ComicSourceFixture {
  _PreviewSource({super.key = 'preview-workspace'});
  final requests = <String>[];
  @override
  LoadComicFunc get loadComicInfo => (id) async {
    requests.add(id);
    return Res(
      ComicDetails.fromJson({
        'comicId': id,
        'sourceKey': key,
        'title': 'Full title $id',
        'cover': '',
        'description': 'Overview $id',
        'tags': <String, dynamic>{},
        'chapters': {'one': 'Chapter one $id'},
      }),
    );
  };
}

void main() {
  App.dataPath = App.cachePath = Directory.systemTemp.path;
  for (final scenario in [
    'preview',
    'preview-read',
    'drag',
    'drag-compact',
    'drag-medium',
    'drag-mixed',
    'menu',
    'keyboard',
  ]) {
    final dragScenario = scenario.startsWith('drag');
    final compact = scenario == 'drag-compact';
    final medium = scenario == 'drag-medium';
    final largeText = compact || medium;
    testWidgets(
      'production workspace ${scenario == 'preview' ? 'preview preserves two selections 420px instance focus and promotes only once' : 'real selection $scenario and Escape'}',
      (tester) async {
        final root = Directory.systemTemp.createTempSync('ux1-f2-preview-');
        final oldPath = App.dataPath, oldCache = App.cachePath;
        final oldSettings = Map<String, dynamic>.from(
          appdata.toJson()['settings'] as Map,
        );
        final oldImplicit = Map<String, dynamic>.from(appdata.implicitData);
        final oldMain = appNavigation.mainNavigatorKey;
        App.dataPath = App.cachePath = root.path;
        appdata.settings['language'] = compact
            ? 'zh-TW'
            : medium
            ? 'zh-CN'
            : 'en-US';
        appdata.settings['reduceMotion'] = compact;
        appdata.settings['blockedWords'] = <String>[];
        appdata.settings['onClickFavorite'] = scenario == 'preview-read'
            ? 'read'
            : 'viewDetail';
        appdata.settings['favoritesDisplayMode'] = 'gallery';
        appdata.settings['favoritesFilterPanelOpen'] = false;
        appdata.settings['workspaceStartup'] = 'restore';
        appdata.implicitData.clear();
        appdata.implicitData['favoriteFolder'] = {
          'name': 'F2',
          'isNetwork': false,
        };
        final manager = LocalFavoritesManager.independent();
        final history = HistoryManager.create();
        final chrome = DesktopChromeController();
        final source = _PreviewSource();
        final otherSource = _PreviewSource(key: 'preview-workspace-other');
        configureComicSourceRegistry(
          all: () => [source, otherSource],
          find: (key) => key == source.key
              ? source
              : key == otherSource.key
              ? otherSource
              : null,
          fromIntKey: (key) => key == source.key.hashCode
              ? source
              : key == otherSource.key.hashCode
              ? otherSource
              : null,
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
        tester.view.physicalSize = Size(
          compact
              ? 600
              : medium
              ? 1000
              : 1400,
          900,
        );
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
          await AppTranslation.init();
          await OpenCC.init();
          await manager.init();
          await history.init();
          await manager.createFolder('F2');
          for (var i = 0; i < 60; i++) {
            await manager.addComic(
              'F2',
              FavoriteItem(
                id: 'book-$i',
                name: 'Book $i',
                coverPath: '',
                author: 'Author',
                type: ComicType.fromKey(
                  scenario == 'drag-mixed' && i.isOdd
                      ? otherSource.key
                      : source.key,
                ),
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
                theme: ThemeData(
                  brightness: compact ? Brightness.dark : Brightness.light,
                ),
                navigatorKey: appNavigation.rootNavigatorKey,
                builder: (context, child) => DesktopChromeScope(
                  controller: chrome,
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.linear(largeText ? 1.5 : 1),
                      disableAnimations: medium,
                    ),
                    child: GlobalShortcuts(
                      chrome: chrome,
                      child: WindowFrame(child!),
                    ),
                  ),
                ),
                home: const MainPage(),
              ),
            ),
          ),
        );
        Future<void> settle() async {
          await tester.pump(const Duration(milliseconds: 400));
          await settleSidebarWork(tester, () => appdata.writeImplicitData());
          await tester.pump(const Duration(milliseconds: 400));
          await settleSidebarWork(
            tester,
            () => tester
                .state<DesktopWorkspaceState>(find.byType(DesktopWorkspace))
                .waitForSettingsSave(),
          );
          // The new viewport's post-frame view registration can schedule a
          // second debounced snapshot. Let it start before waiting on disk.
          await tester.pump(const Duration(milliseconds: 400));
          await settleSidebarWork(
            tester,
            () => tester
                .state<DesktopWorkspaceState>(find.byType(DesktopWorkspace))
                .waitForSettingsSave(),
          );
          await tester.pumpAndSettle(
            const Duration(milliseconds: 100),
            EnginePhase.sendSemanticsUpdate,
            const Duration(seconds: 3),
          );
        }

        await settle();
        expect(tester.takeException(), isNull);
        final host = tester.state<DesktopWorkspaceState>(
          find.byType(DesktopWorkspace),
        );
        final originalTab = host.record.activeId;
        final page = tester.state(find.byType(LocalFavoritesPage));
        final scroll = tester
            .widget<SmoothCustomScrollView>(
              find
                  .descendant(
                    of: find.byType(LocalFavoritesPage),
                    matching: find.byType(SmoothCustomScrollView),
                  )
                  .first,
            )
            .controller!;
        await tester.sendEventToBinding(
          PointerScrollEvent(
            position: tester.getCenter(find.byType(ComicTile).first),
            scrollDelta: const Offset(0, 420),
            kind: PointerDeviceKind.mouse,
          ),
        );
        await settle();
        expect(scroll.offset, closeTo(420, .01));
        final cards = find
            .byType(ComicTile)
            .hitTestable(at: Alignment.topCenter);
        final first = tester.widget<ComicTile>(cards.at(0)).comic;
        final second = tester.widget<ComicTile>(cards.at(1)).comic;
        if (scenario == 'drag-mixed') {
          expect(first.sourceKey, isNot(second.sourceKey));
        }
        Finder card(String id) =>
            find.byWidgetPredicate((w) => w is ComicTile && w.comic.id == id);
        await toggleComicCheckbox(tester, card(first.id));
        await toggleComicCheckbox(tester, card(second.id));
        await settle();
        final focus = FocusManager.instance.primaryFocus;
        final routes = host.record.tabs.single.routes.length;
        final recent = List<String>.from(host.record.recent);
        void retained() {
          expect(host.record.activeId, originalTab);
          expect(tester.state(find.byType(LocalFavoritesPage)), same(page));
          expect(scroll.offset, closeTo(420, .01));
          expect(
            tester
                .widget<SliverGridComics>(find.byType(SliverGridComics))
                .selections!
                .keys
                .map((c) => (c.id, c.sourceKey)),
            unorderedEquals([
              (first.id, first.sourceKey),
              (second.id, second.sourceKey),
            ]),
          );
        }

        retained();
        if (scenario == 'menu') {
          await tester.tapAt(
            tester.getCenter(card(first.id)),
            buttons: kSecondaryMouseButton,
          );
          await settle();
          expect(find.text('Open selected in background tabs'), findsOneWidget);
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          await settle();
          retained();
          expect(host.record.tabs.length, 1);
          await tester.tapAt(
            tester.getCenter(card(first.id)),
            buttons: kSecondaryMouseButton,
          );
          await settle();
          await tester.tap(find.text('Open selected in background tabs'));
          await settle();
          expect(host.record.tabs.length, 3);
          retained();
          expect(source.requests, isEmpty);
          expect(
            host.record.tabs
                .skip(1)
                .map(
                  (t) => (
                    t.current.arguments['id'],
                    t.current.arguments['sourceKey'],
                  ),
                ),
            unorderedEquals([(first.id, source.key), (second.id, source.key)]),
          );
          expect(tester.takeException(), isNull);
          return;
        }
        if (scenario == 'keyboard') {
          for (final modifier in [
            LogicalKeyboardKey.controlLeft,
            LogicalKeyboardKey.metaLeft,
          ]) {
            final before = host.record.tabs.length;
            await tester.sendKeyDownEvent(modifier);
            await tester.sendKeyEvent(LogicalKeyboardKey.enter);
            await tester.sendKeyUpEvent(modifier);
            await settle();
            expect(host.record.tabs.length, before + 2);
            retained();
            expect(source.requests, isEmpty);
            expect(
              host.record.tabs
                  .skip(before)
                  .map(
                    (t) => (
                      t.current.arguments['id'],
                      t.current.arguments['sourceKey'],
                    ),
                  ),
              unorderedEquals([
                (first.id, source.key),
                (second.id, source.key),
              ]),
            );
          }
          expect(FocusManager.instance.primaryFocus, same(focus));
          expect(tester.takeException(), isNull);
          return;
        }
        if (dragScenario) {
          final tabBar = tester.getCenter(find.byType(WorkspaceTabStrip));
          final gesture = await tester.startGesture(
            tester.getCenter(card(first.id)),
            kind: PointerDeviceKind.mouse,
          );
          await gesture.moveBy(const Offset(0, -30));
          await tester.pump();
          await gesture.moveTo(tabBar);
          await tester.pump();
          await gesture.up();
          await settle();
          expect(
            host.record.tabs.length,
            3,
            reason: 'drop creates exactly two background detail tabs',
          );
          expect(
            host.record.tabs
                .skip(1)
                .map(
                  (t) => (
                    t.current.arguments['id'],
                    t.current.arguments['sourceKey'],
                  ),
                ),
            unorderedEquals([
              (first.id, first.sourceKey),
              (second.id, second.sourceKey),
            ]),
          );
          retained();
          expect(source.requests, isEmpty);
          final cancelled = await tester.startGesture(
            tester.getCenter(card(first.id)),
            kind: PointerDeviceKind.mouse,
          );
          await cancelled.moveBy(const Offset(0, -30));
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          await tester.pump();
          expect(
            find.text('Open @count in background tabs'.tlParams({'count': 2})),
            findsNothing,
            reason:
                'Escape removes the actual drag feedback before mouse release',
          );
          await cancelled.moveTo(tabBar);
          await tester.pump();
          await cancelled.up();
          await settle();
          expect(
            host.record.tabs.length,
            3,
            reason: 'Escape cancels the real in-flight drag without new tabs',
          );
          retained();
          expect(otherSource.requests, isEmpty);
          expect(tester.takeException(), isNull);
          return;
        }
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await settle();
        expect(find.bySemanticsLabel('Comic preview'), findsOneWidget);
        expect(find.text('Overview ${second.id}'), findsOneWidget);
        expect(find.text('Chapter one ${second.id}'), findsOneWidget);
        expect(source.requests, [second.id]);
        expect(host.record.tabs.length, 1);
        expect(host.record.tabs.single.routes.length, routes);
        expect(host.record.recent, recent);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await settle();
        retained();
        expect(FocusManager.instance.primaryFocus, same(focus));
        // Background promotion must not activate or eagerly load its detail page.
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await settle();
        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        await settle();
        retained();
        expect(FocusManager.instance.primaryFocus, same(focus));
        expect(host.record.tabs.length, 2);
        expect(host.record.tabs.last.current.arguments['id'], second.id);
        expect(
          host.record.tabs.last.current.arguments['sourceKey'],
          source.key,
        );
        expect(source.requests, [
          second.id,
          second.id,
        ], reason: 'only two temporary previews, no background detail request');
        // Plain Enter opens within the current tab, and Alt+Left returns to the scene.
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await settle();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await settle();
        expect(host.record.activeId, originalTab);
        expect(host.record.tabs.length, 2);
        expect(find.byType(ComicPage), findsOneWidget);
        expect(tester.widget<ComicPage>(find.byType(ComicPage)).id, second.id);
        expect(host.record.tabs.first.routes.length, routes + 1);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
        await settle();
        retained();
        expect(FocusManager.instance.primaryFocus, same(focus));
        expect(host.record.tabs.first.routes.length, routes);
        expect(find.byType(ComicPage), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
