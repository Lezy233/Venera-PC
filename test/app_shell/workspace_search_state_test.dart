import 'package:venera_next/features/settings/settings_page.dart';
import 'package:venera_next/features/search/search_selection.dart';
import 'package:venera_next/features/search/search_page.dart';
import 'package:venera_next/features/comic_source/comic_source.dart';
import 'package:venera_next/components/select.dart';
import '../support/creator_search_source.dart';
import 'dart:io';
import '../support/comic_card_actions.dart';
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

void main() {
  App.dataPath = App.cachePath = Directory.systemTemp.path;
  testWidgets(
    'two real search entries retain independent source options query focus and original favorites beneath each stack',
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
      appdata.settings['searchSources'] = ['a', 'b'];
      appdata.settings['defaultSearchTarget'] = 'a';
      appdata.settings['searchSelection'] = null;
      appdata.settings['searchProfiles'] = [];
      appdata.settings['defaultSearchProfile'] = null;
      appdata.settings['autoAddLanguageFilter'] = 'none';
      final sources = [
        CreatorSearchSource('a', displayName: 'Platform A'),
        CreatorSearchSource('b', displayName: 'Platform B'),
      ];
      configureComicSourceRegistry(
        all: () => sources,
        find: (key) => sources.where((s) => s.key == key).firstOrNull,
        fromIntKey: (_) => null,
        isEmpty: () => false,
      );
      addTearDown(
        () => configureComicSourceRegistry(
          all: () => [],
          find: (_) => null,
          fromIntKey: (_) => null,
          isEmpty: () => true,
        ),
      );
      final manager = LocalFavoritesManager.independent();
      final history = HistoryManager.create();
      final chrome = DesktopChromeController();
      final navigator = GlobalKey<NavigatorState>();
      final oldMain = appNavigation.mainNavigatorKey;
      appNavigation.mainNavigatorKey = navigator;
      configureComicWidgets(
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
        for (var i = 0; i < 200 && SearchSelection.isSaving(root.path); i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 10)),
          );
          await tester.pump();
        }
        expect(
          SearchSelection.isSaving(root.path),
          isFalse,
          reason: 'the actual F8 selection transaction must finish',
        );
        // Its completion publishes the final choice and then schedules the
        // workspace snapshot. Drain this second operation after its debounce.
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
        unorderedEquals(selectedIds.map((id) => ('local', id))),
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
        unorderedEquals(selectedIds.map((id) => ('local', id))),
      );
      expect(FocusManager.instance.primaryFocus, same(originalFocus));
      Future<void> openSearchEntry() async {
        await tester.tap(find.text('Settings').hitTestable());
        await settleWorkspace();
        final globalField = find.byType(TextField).hitTestable().first;
        await tester.tap(globalField);
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await settleWorkspace();
        expect(find.byType(SearchPage), findsOneWidget);
      }

      Finder input() => find
          .descendant(
            of: find.byType(SearchPage),
            matching: find.byType(TextField),
          )
          .hitTestable();
      bool selected(String label) => tester
          .widget<OptionChip>(find.widgetWithText(OptionChip, label))
          .isSelected;
      final secondTabId = host.record.tabs
          .firstWhere((t) => t.id != originalId)
          .id;
      await openSearchEntry();
      final searchA = tester.state(find.byType(SearchPage));
      await tester.tap(find.text('Other'));
      await settleWorkspace();
      await tester.enterText(input(), 'Alpha');
      await settleWorkspace();
      final searchFocusA = FocusManager.instance.primaryFocus;
      expect(selected('Platform A'), isTrue);
      expect(selected('Other'), isTrue);
      await tester.tap(
        find.descendant(
          of: find.byType(WorkspaceTabStrip),
          matching: find.byKey(ValueKey(secondTabId)),
        ),
      );
      await settleWorkspace();
      await openSearchEntry();
      final searchB = tester.state(find.byType(SearchPage));
      expect(searchB, isNot(same(searchA)));
      await tester.tap(find.text('Platform B'));
      await settleWorkspace();
      await tester.enterText(input(), 'Beta');
      await settleWorkspace();
      expect(selected('Platform B'), isTrue);
      expect(selected('Normal'), isTrue);
      await tester.tap(
        find.descendant(
          of: find.byType(WorkspaceTabStrip),
          matching: find.byKey(ValueKey(originalId)),
        ),
      );
      await settleWorkspace();
      expect(tester.state(find.byType(SearchPage)), same(searchA));
      expect(
        selected('Platform A'),
        isTrue,
        reason:
            'B may remember a default for new entries, but must not rewrite A current source',
      );
      expect(selected('Other'), isTrue);
      expect(tester.widget<TextField>(input()).controller!.text, 'Alpha');
      expect(FocusManager.instance.primaryFocus, same(searchFocusA));
      expect(
        sources.every((s) => s.requests.isEmpty),
        isTrue,
        reason: 'editing entry state alone must not start requests',
      );
      final saved = host.record.active!.current.view['search'];
      expect(saved, isA<Map>());
      expect(saved['keyword'], 'Alpha');
      expect(saved['sourceKey'], 'a');
      expect(saved['options'], ['other']);
      await tester.tap(
        find.descendant(
          of: find.byType(WorkspaceTabStrip),
          matching: find.byKey(ValueKey(secondTabId)),
        ),
      );
      await settleWorkspace();
      expect(tester.state(find.byType(SearchPage)), same(searchB));
      expect(selected('Platform B'), isTrue);
      expect(tester.widget<TextField>(input()).controller!.text, 'Beta');
      await tester.tap(find.byTooltip('New tab'));
      await settleWorkspace();
      await openSearchEntry();
      expect(
        selected('Platform B'),
        isTrue,
        reason: 'a new entry must still use F8 last explicit source',
      );
      expect(selected('Normal'), isTrue);
      expect(tester.widget<TextField>(input()).controller!.text, isEmpty);
      await tester.tap(
        find.descendant(
          of: find.byType(WorkspaceTabStrip),
          matching: find.byKey(ValueKey(originalId)),
        ),
      );
      await settleWorkspace();
      await tester.tap(
        find.descendant(
          of: find.byType(SearchPage),
          matching: find.byType(BackButton),
        ),
      );
      await settleWorkspace();
      await tester.tap(
        find.descendant(
          of: find.byType(SettingsPage),
          matching: find.byIcon(Icons.arrow_back),
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
        unorderedEquals(selectedIds.map((id) => ('local', id))),
      );
      expect(FocusManager.instance.primaryFocus, same(originalFocus));
      expect(sources.every((s) => s.requests.isEmpty), isTrue);
      expect(tester.takeException(), isNull);
    },
  );
}
