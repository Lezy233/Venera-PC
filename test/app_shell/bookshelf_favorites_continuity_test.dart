import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:venera_next/components/scroll.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venera_next/components/bookshelf_workspace.dart';
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
import '../support/comic_card_actions.dart';

void main() {
  App.dataPath = App.cachePath = Directory.systemTemp.path;
  testWidgets(
    'real favorite selection scroll instance and focus survive bookshelf transitions',
    (tester) async {
      Future<void> settleWorkspace() async {
        await tester.pump(const Duration(milliseconds: 400));
        await settleSidebarWork(tester, () => appdata.writeImplicitData());
        await tester.pumpAndSettle();
      }

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
      await settleWorkspace();
      final page = find.byType(LocalFavoritesPage);
      final pageState = tester.state(page), pageElement = tester.element(page);
      final viewport = find
          .descendant(of: page, matching: find.byType(SmoothCustomScrollView))
          .first;
      final controller = tester
          .widget<SmoothCustomScrollView>(viewport)
          .controller!;
      final position = controller.position;

      await tester.sendEventToBinding(
        PointerScrollEvent(
          position: tester.getCenter(find.byType(ComicTile).first),
          scrollDelta: const Offset(0, 420),
          kind: PointerDeviceKind.mouse,
        ),
      );
      await settleWorkspace();
      expect(position.pixels, greaterThan(0));
      final cards = find
          .descendant(of: page, matching: find.byType(ComicTile))
          .hitTestable(at: Alignment.topCenter);
      final first = tester.widget<ComicTile>(cards.at(0)).comic;
      final second = tester.widget<ComicTile>(cards.at(1)).comic;
      await toggleComicCheckbox(tester, cards.at(0));
      await settleWorkspace();
      final secondCard = find.byWidgetPredicate(
        (w) => w is ComicTile && w.comic.id == second.id,
      );
      await toggleComicCheckbox(tester, secondCard);
      await settleWorkspace();
      final ids = {first.id, second.id};
      final pixels = controller.position.pixels;

      void intact() {
        expect(tester.state(page), same(pageState));
        expect(tester.element(page), same(pageElement));

        expect(
          tester.widget<SmoothCustomScrollView>(viewport).controller,
          same(controller),
        );
        expect(controller.position.pixels, closeTo(pixels, .01));
        final selection = tester
            .widget<SliverGridComics>(find.byType(SliverGridComics))
            .selections!;
        expect(
          selection.keys.map((c) => (c.id, c.sourceKey)),
          unorderedEquals(ids.map((id) => (id, 'local'))),
        );
        expect(find.text('Selected 2 comics'), findsOneWidget);
      }

      intact();
      print(
        'UX1 continuity entities=$ids offset=$pixels page=${identityHashCode(pageState)} controller=${identityHashCode(controller)}',
      );
      expect(chrome.canNavigate, isTrue);
      expect(chrome.leftAvailable, isTrue);
      final toggle = find.descendant(
        of: find.byType(BookshelfWorkspace),
        matching: find.byTooltip('Toggle bookshelf'),
      );
      expect(toggle, findsOneWidget);
      expect(
        FocusManager.instance.primaryFocus?.debugLabel,
        'comic-card-selection',
      );
      await tester.tap(toggle);
      await settleSidebarWork(tester, () => appdata.writeImplicitData());
      await settleWorkspace();
      expect(appdata.implicitData['bookshelfExpanded'], false);
      intact();
      tester.view.physicalSize = const Size(600, 900);
      await settleWorkspace();
      intact();
      expect(chrome.leftAvailable, isFalse);
      final returnTarget = FocusManager.instance.primaryFocus;
      expect(returnTarget?.debugLabel, 'comic-card-selection');
      await tester.tap(toggle);
      await settleWorkspace();
      expect(find.byKey(const ValueKey('bookshelf-scrim')), findsOneWidget);
      intact();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settleWorkspace();
      expect(find.byKey(const ValueKey('bookshelf-scrim')), findsNothing);
      expect(FocusManager.instance.primaryFocus, same(returnTarget));
      intact();
      tester.view.physicalSize = const Size(1400, 900);
      await settleWorkspace();
      expect(appdata.implicitData['bookshelfExpanded'], false);
      expect(chrome.leftAvailable, isTrue);
      intact();
      expect(FocusManager.instance.primaryFocus, same(returnTarget));
      expect(tester.takeException(), isNull);
      // Escape at the restored real selection target still clears only selection.
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settleWorkspace();
      expect(
        tester
            .widget<SliverGridComics>(find.byType(SliverGridComics))
            .selections,
        isEmpty,
      );
      // Exercise the live favorites query callback before disposing its owner.
      chrome.submitSearch('Book 00');
      await settleWorkspace();
      expect(
        tester
            .widget<SliverGridComics>(find.byType(SliverGridComics))
            .comics
            .map((c) => c.id),
        ['book-0'],
      );
      await tester.pumpWidget(const SizedBox());
      await settleSidebarWork(tester, () => appdata.writeImplicitData());
      await settleWorkspace();
      expect(chrome.leftAvailable, isFalse);
      expect(chrome.rightAvailable, isFalse);
      expect(chrome.bookshelfAvailable, isFalse);
      expect(chrome.canNavigate, isFalse);
      chrome.submitSearch('retired query');
      chrome.toggleLeftSidebar();
      chrome.toggleRightSidebar();
      chrome.toggleBookshelf();
      expect(tester.takeException(), isNull);
    },
  );
}
