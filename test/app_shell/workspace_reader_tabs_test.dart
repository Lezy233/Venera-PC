import 'package:venera_next/features/reader/gallery_view.dart';
import 'package:venera_next/features/reader/auto_reading.dart';
import 'package:venera_next/features/reader/reader_session_scope.dart';
import 'package:image/image.dart' as img;
import 'package:venera_next/features/reader/reader_page.dart';
import 'package:venera_next/features/local_comics/local.dart';
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
  _DetailsSource(this.root, {String sourceKey = 'workspace-fixture'})
    : super(key: sourceKey);
  bool reordered = false;
  final String root;
  final chapterRequests = <(String, String?)>[];
  @override
  LoadComicPagesFunc get loadComicPages => (id, ep) async {
    chapterRequests.add((id, ep));
    return Res([for (var i = 1; i <= 12; i++) 'file://$root/$i.png']);
  };
  final requests = <String>[];
  @override
  LoadComicFunc get loadComicInfo => (id) async {
    requests.add(id);
    return Res(
      ComicDetails.fromJson({
        'title': 'Controlled details $id',
        'cover': '',
        'description': 'Fixture description',
        'chapters': reordered
            ? {'ep-2': 'Episode 2', 'ep-1': 'Episode 1'}
            : {'ep-1': 'Episode 1', 'ep-2': 'Episode 2'},
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
    'two real readers retain separate pages and background/current tab close releases only their own resources',
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
      appdata.settings['autoReaderMode'] = false;
      appdata.settings['readerMode'] = 'galleryLeftToRight';
      appdata.settings['readerScreenPicNumberForLandscape'] = 1;
      appdata.settings['enablePageAnimation'] = false;
      appdata.settings['enableClockAndBatteryInfoInReader'] = false;
      appdata.settings['preloadImageCount'] = 0;
      appdata.settings['autoPageTurningInterval'] = 60;

      appdata.implicitData.clear();
      appdata.settings['initialPage'] = '1';
      appdata.implicitData['favoriteFolder'] = {
        'name': 'Continuity',
        'isNetwork': false,
      };
      final manager = LocalFavoritesManager.independent();
      final history = HistoryManager.create();
      final chrome = DesktopChromeController();
      var readerClosed = 0;
      ComicSourceManager();
      configureComicTypeSourceKeyResolver();
      final source = _DetailsSource(root.path);
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
          LocalManager.current?.dispose();
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
        Directory('${root.path}/comics').createSync();
        File(
          '${root.path}/local_path',
        ).writeAsStringSync('${root.path}/comics');
        LocalManager(initializeSources: () async {});
        await LocalManager().init();
        final png = img.encodePng(img.Image(width: 100, height: 150));
        for (var i = 1; i <= 12; i++) {
          File('${root.path}/$i.png').writeAsBytesSync(png);
        }
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
                    child: ReaderSessionScope(
                      onClosed: () => readerClosed++,
                      child: WindowFrame(child!),
                    ),
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
      Future<void> settleWorkspace({bool automaticReading = false}) async {
        await tester.pump(const Duration(milliseconds: 400));
        await settleSidebarWork(tester, () => appdata.writeImplicitData());
        await tester.pump(const Duration(milliseconds: 400));
        await settleSidebarWork(
          tester,
          () => tester
              .state<DesktopWorkspaceState>(find.byType(DesktopWorkspace))
              .waitForSettingsSave(),
        );
        if (automaticReading) {
          await tester.pump();
        } else {
          await tester.pumpAndSettle();
        }
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
      expect(host.record.activeId, originalId);
      expect(host.record.tabs.length, count);
      await tester.tap(find.text('Read').hitTestable());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        find.byType(WorkspaceTabStrip),
        findsOneWidget,
        reason:
            'reading from details must stay in the current independent workspace stack',
      );
      await settleWorkspace();
      expect(find.byType(Reader), findsOneWidget);
      final reader = tester.state<ReaderState>(find.byType(Reader));
      expect(
        (reader.cid, reader.type.sourceKey),
        (first.id, 'workspace-fixture'),
      );
      expect(host.record.activeId, originalId);
      expect(host.record.active!.current.kind.name, 'reader');
      expect(source.chapterRequests, [(first.id, 'ep-1')]);
      expect(
        reader.focusNode.hasPrimaryFocus,
        isTrue,
        reason: 'the actual reading canvas must own page shortcuts',
      );
      // Traverse actual controls out of the nested reader, then back to its
      // canvas. A repeated node before reaching the shell is a keyboard trap.
      final seenFocus = <FocusNode>{};
      final focusLimit =
          find.byType(Focus, skipOffstage: false).evaluate().length + 1;
      var reachedWorkspace = false;
      for (var i = 0; i < focusLimit; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        final focused = FocusManager.instance.primaryFocus!;
        if (focused.context
                ?.findAncestorWidgetOfExactType<WorkspaceTabStrip>() !=
            null) {
          reachedWorkspace = true;
          break;
        }
        expect(
          seenFocus.add(focused),
          isTrue,
          reason:
              'reader Tab cycled before reaching the outer workspace: $focused',
        );
      }
      expect(reachedWorkspace, isTrue);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      try {
        for (
          var i = 0;
          i < focusLimit && !reader.focusNode.hasPrimaryFocus;
          i++
        ) {
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();
        }
      } finally {
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      }
      expect(reader.focusNode.hasPrimaryFocus, isTrue);
      expect(reader.page, 1);
      expect(source.chapterRequests, [(first.id, 'ep-1')]);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await settleWorkspace();
      expect(reader.page, 2);
      final readerView = host.record.active!.current.view['reader'];
      expect(
        readerView,
        isA<Map>(),
        reason:
            'the actual reader page must contribute its current image/chapter',
      );
      expect(readerView['page'], 2);
      expect(readerView['chapter'], 1);
      final viewportA = tester.state(find.byType(ReaderGalleryView));
      Future<void> startAutomatic() async {
        await tester.tapAt(tester.getCenter(find.byType(ReaderGalleryView)));
        await settleWorkspace();
        await tester.tap(
          find.byTooltip('Start or stop automatic reading').hitTestable(),
        );
        await settleWorkspace(automaticReading: true);
      }

      await startAutomatic();
      final otherId = host.record.tabs.firstWhere((t) => t.id != originalId).id;
      Finder tabFor(String id) => find.descendant(
        of: find.byType(WorkspaceTabStrip),
        matching: find.byKey(ValueKey(id)),
      );
      await tester.tap(tabFor(otherId));
      await settleWorkspace();
      expect(reader.autoReading.status, AutoReadingStatus.paused);
      expect(reader.imageWork.start(), isNull);
      final bookB = tester
          .widget<ComicTile>(find.byType(ComicTile).hitTestable().first)
          .comic;
      expect(bookB.id, isNot(first.id));
      await tester.tapAt(
        tester.getCenter(find.byType(ComicTile).hitTestable().first),
        buttons: kSecondaryMouseButton,
      );
      await settleWorkspace();
      await tester.tap(find.text('Details'));
      await settleWorkspace();
      await tester.tap(find.text('Read').hitTestable());
      await settleWorkspace();
      final readerB = tester.state<ReaderState>(find.byType(Reader));
      expect(readerB, isNot(same(reader)));
      expect(
        (readerB.cid, readerB.type.sourceKey),
        (bookB.id, 'workspace-fixture'),
      );
      expect(readerB.focusNode.hasPrimaryFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await settleWorkspace();
      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await settleWorkspace();
      expect(readerB.page, 3);
      expect(reader.page, 2);
      expect(source.chapterRequests, [(first.id, 'ep-1'), (bookB.id, 'ep-1')]);
      await tester.tap(find.text('All 2'));
      await tester.pumpAndSettle();
      final readerItems = find.byType(PopupMenuItem<String>);
      expect(
        find.descendant(
          of: readerItems,
          matching: find.text(reader.widget.name),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: readerItems,
          matching: find.text(readerB.widget.name),
        ),
        findsOneWidget,
      );
      expect(reader.widget.name, isNot(readerB.widget.name));
      expect(
        source.requests,
        [first.id, bookB.id],
        reason:
            'titles must use already known metadata, with no extra details requests',
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      final viewportB = tester.state(find.byType(ReaderGalleryView));
      await startAutomatic();
      expect(readerB.autoReading.isActive, isTrue);
      await tester.tap(tabFor(originalId));
      await settleWorkspace(automaticReading: true);
      expect(tester.state(find.byType(Reader)), same(reader));
      expect(tester.state(find.byType(ReaderGalleryView)), same(viewportA));
      expect(reader.page, 2);
      expect(readerB.page, 3);
      expect(reader.autoReading.status, isNot(AutoReadingStatus.paused));
      expect(readerB.autoReading.status, AutoReadingStatus.paused);
      expect(readerB.imageWork.start(), isNull);
      expect(reader.focusNode.hasPrimaryFocus, isTrue);
      expect(readerB.focusNode.hasFocus, isFalse);
      expect(source.chapterRequests.length, 2);
      // Close the noncurrent reader through its real hover-revealed button.
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: tester.getCenter(tabFor(otherId)));
      await mouse.moveTo(tester.getCenter(tabFor(otherId)));
      await tester.pump();
      final closeB = find
          .descendant(
            of: tabFor(otherId),
            matching: find.byTooltip('Close tab'),
          )
          .hitTestable();
      expect(closeB, findsOneWidget);
      await tester.tapAt(tester.getCenter(closeB));
      await settleWorkspace(automaticReading: true);
      expect(host.record.activeId, originalId);
      expect(host.record.tabs.map((t) => t.id), [originalId]);
      expect(tester.state(find.byType(Reader)), same(reader));
      expect(reader.focusNode.hasPrimaryFocus, isTrue);
      expect(reader.page, 2);
      expect(readerB.controller.isDisposed, isTrue);
      expect(readerB.imageWork.start(), isNull);
      expect(viewportB.mounted, isFalse);
      expect(readerB.autoReading.isActive, isFalse);
      expect(readerClosed, 1);
      expect(source.chapterRequests.length, 2);
      // Closing the current reader uses the real global keyboard command.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyW);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await settleWorkspace();
      expect(host.record.activeId, isNull);
      expect(host.record.tabs, isEmpty);
      expect(find.text('No tabs open'), findsOneWidget);
      expect(reader.controller.isDisposed, isTrue);
      expect(reader.imageWork.start(), isNull);
      expect(viewportA.mounted, isFalse);
      expect(reader.autoReading.isActive, isFalse);
      expect(readerClosed, 2);
      expect(source.chapterRequests.length, 2);
      expect(manager.getAllComics(), hasLength(60));
      await mouse.removePointer();
      expect(tester.takeException(), isNull);
    },
  );
}
