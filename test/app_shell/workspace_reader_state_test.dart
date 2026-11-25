import 'package:venera_next/features/reader/loading.dart';
import 'dart:convert';
import 'package:venera_next/app_shell/workspace/workspace_store.dart';
import 'package:venera_next/features/reader/gallery_view.dart';
import 'package:venera_next/features/reader/scaffold.dart';
import 'package:venera_next/features/reader/top_bar.dart';
import 'package:venera_next/features/reader/progress_bar.dart';
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
    'real reader stays inside its tab and pauses background work while retaining its exact page',
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
      // D8: a real reader control changes chrome, not the retained tab/reader.
      final modeViewport = tester.state(find.byType(ReaderGalleryView));
      final modeTab = host.record.active!;
      final modeTabs = host.record.tabs.map((tab) => tab.id).toList();
      await tester.tapAt(tester.getCenter(find.byType(ReaderGalleryView)));
      await settleWorkspace();
      final enterImmersive = find
          .byTooltip('Enter immersive reading')
          .hitTestable();
      expect(enterImmersive, findsOneWidget);
      // D8: ordinary reading keeps the merged workspace tab row and adds the
      // reader tool row below it, never a third independent title bar.
      expect(find.byType(WorkspaceTabStrip).hitTestable(), findsOneWidget);
      expect(find.byType(ReaderTopBar).hitTestable(), findsOneWidget);
      expect(
        tester.getRect(find.byType(ReaderTopBar)).top,
        greaterThanOrEqualTo(
          tester.getRect(find.byType(WorkspaceTabStrip)).bottom,
        ),
      );
      // Exactly one progress component while the tools are visible.
      expect(find.byType(ReaderProgressSlider), findsOneWidget);
      await tester.tap(enterImmersive);
      await settleWorkspace();
      expect(find.byType(WorkspaceTabStrip).hitTestable(), findsNothing);
      expect(find.byTooltip('Toggle bookshelf').hitTestable(), findsNothing);
      expect(tester.state<ReaderState>(find.byType(Reader)), same(reader));
      expect(tester.state(find.byType(ReaderGalleryView)), same(modeViewport));
      expect(host.record.active, same(modeTab));
      expect(host.record.tabs.map((tab) => tab.id), modeTabs);
      expect((reader.chapter, reader.page), (1, 2));
      expect(source.chapterRequests, [(first.id, 'ep-1')]);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settleWorkspace();
      expect(find.byType(WorkspaceTabStrip).hitTestable(), findsOneWidget);
      expect(find.byTooltip('Toggle bookshelf').hitTestable(), findsWidgets);
      expect(tester.state(find.byType(ReaderGalleryView)), same(modeViewport));
      expect((reader.chapter, reader.page), (1, 2));
      expect(
        tester.state<ReaderScaffoldState>(find.byType(ReaderScaffold)).isOpen,
        isTrue,
      );
      await tester.tapAt(tester.getCenter(find.byType(ReaderGalleryView)));
      await settleWorkspace();
      final canvas = tester.getRect(find.byType(ReaderGalleryView));
      final edge = Offset(canvas.right - 20, canvas.center.dy);
      await tester.tapAt(edge);
      await settleWorkspace();
      expect(reader.page, 2, reason: 'comic edge tap toggles tools only');
      expect(
        tester.state<ReaderScaffoldState>(find.byType(ReaderScaffold)).isOpen,
        isTrue,
      );
      await tester.pump(const Duration(seconds: 3));
      expect(
        tester.state<ReaderScaffoldState>(find.byType(ReaderScaffold)).isOpen,
        isTrue,
        reason: 'idle time must not hide tools',
      );
      await tester.tapAt(edge);
      await settleWorkspace();
      expect(reader.page, 2);
      expect(
        tester.state<ReaderScaffoldState>(find.byType(ReaderScaffold)).isOpen,
        isFalse,
      );
      // The window frame's resize edge overlaps the very bottom of the window,
      // so the compact rail's upper half is its usable hit area.
      expect(
        find
            .byType(ReaderProgressSlider)
            .hitTestable(at: const Alignment(0, -0.5)),
        findsOneWidget,
        reason: 'the compact rail stays usable above the window resize edge',
      );
      expect(find.byType(ReaderProgressSlider), findsOneWidget);
      final compactContent = tester.getRect(find.byType(ReaderGalleryView));
      final compactBar = tester.getRect(find.byType(ReaderBottomBar));
      expect(compactContent.bottom, lessThanOrEqualTo(compactBar.top));
      expect(compactBar.top, greaterThanOrEqualTo(compactContent.bottom));
      expect(find.byIcon(Icons.first_page), findsNothing);
      expect(find.byIcon(Icons.last_page), findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settleWorkspace();
      expect(
        tester.state<ReaderScaffoldState>(find.byType(ReaderScaffold)).isOpen,
        isTrue,
        reason: 'ordinary Escape recovers hidden tools without leaving Reader',
      );
      await tester.tap(find.byTooltip('Enter immersive reading').hitTestable());
      await settleWorkspace();
      final immersiveRect = tester.getRect(find.byType(ReaderGalleryView));
      await tester.tap(find.byTooltip('Chapters').hitTestable());
      await settleWorkspace();
      expect(find.text('Chapters').hitTestable(), findsOneWidget);
      expect(
        tester.getRect(find.byType(ReaderGalleryView)),
        immersiveRect,
        reason: 'chapter overlay must not shrink the comic viewport',
      );
      expect(
        tester.state<ReaderScaffoldState>(find.byType(ReaderScaffold)).isOpen,
        isTrue,
        reason: 'chapter button must not bubble into the comic toggle',
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settleWorkspace();
      expect(find.text('Chapters').hitTestable(), findsNothing);
      expect(
        find.byType(WorkspaceTabStrip).hitTestable(),
        findsNothing,
        reason: 'first Escape only closes the overlay',
      );
      expect((reader.chapter, reader.page), (1, 2));
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settleWorkspace();
      expect(find.byType(WorkspaceTabStrip).hitTestable(), findsOneWidget);
      expect((reader.chapter, reader.page), (1, 2));
      await tester.tapAt(tester.getCenter(find.byType(ReaderGalleryView)));
      await settleWorkspace();
      final viewportState = tester.state(find.byType(ReaderGalleryView));
      await tester.tapAt(tester.getCenter(find.byType(ReaderGalleryView)));
      await settleWorkspace();
      await tester.tap(
        find.byTooltip('Start or stop automatic reading').hitTestable(),
      );
      // Automatic reading keeps scheduling frames, so settle without
      // pumpAndSettle while it is running.
      await settleWorkspace(automaticReading: true);
      expect(reader.autoReading.isActive, isTrue);
      expect(reader.autoReading.status, isNot(AutoReadingStatus.paused));
      final otherId = host.record.tabs.firstWhere((t) => t.id != originalId).id;
      await tester.tap(
        find.descendant(
          of: find.byType(WorkspaceTabStrip),
          matching: find.byKey(ValueKey(otherId)),
        ),
      );
      await settleWorkspace();
      expect(
        reader.autoReading.status,
        AutoReadingStatus.paused,
        reason:
            'background must pause the actual automatic reader, not only mute its ticker',
      );
      expect(
        reader.imageWork.start(),
        isNull,
        reason: 'background must reject new image requests',
      );
      final backgroundPage = reader.page;
      final countBefore = source.chapterRequests.length;
      final otherFocus = FocusManager.instance.primaryFocus;
      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.pump(const Duration(seconds: 2));
      await settleWorkspace();
      expect(reader.page, backgroundPage);
      expect(source.chapterRequests.length, countBefore);
      expect(reader.focusNode.hasFocus, isFalse);
      await tester.tap(
        find.descendant(
          of: find.byType(WorkspaceTabStrip),
          matching: find.byKey(ValueKey(originalId)),
        ),
      );
      await settleWorkspace(automaticReading: true);
      expect(tester.state(find.byType(Reader)), same(reader));
      expect(tester.state(find.byType(ReaderGalleryView)), same(viewportState));
      expect(reader.page, 2);
      expect(reader.focusNode.hasPrimaryFocus, isTrue);
      expect(reader.autoReading.status, isNot(AutoReadingStatus.paused));
      expect(
        source.chapterRequests.length,
        1,
        reason: 'resume must retain the same loaded chapter',
      );
      // Reopen the existing tools, then stop through the real control.
      await tester.tapAt(tester.getCenter(find.byType(ReaderGalleryView)));
      await settleWorkspace(automaticReading: true);
      await tester.tap(
        find.byTooltip('Start or stop automatic reading').hitTestable(),
      );
      await settleWorkspace(automaticReading: true);
      expect(reader.autoReading.isActive, isFalse);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
      await settleWorkspace();
      expect(find.byType(Reader), findsNothing);
      expect(readerClosed, 1);
      expect(reader.controller.isDisposed, isTrue);
      expect(reader.imageWork.start(), isNull);
      expect(host.record.active!.current.kind.name, 'comic');
      await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
      await settleWorkspace();
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
      expect(source.chapterRequests.length, 1);
      expect(otherFocus, isNot(same(originalFocus)));
      expect(readerClosed, 1);
      // Establish a different chapter using its actual detail control, then
      // persist the image position before destroying the complete workspace.
      await tester.tapAt(
        tester.getCenter(firstCard),
        buttons: kSecondaryMouseButton,
      );
      await settleWorkspace();
      await tester.tap(find.text('Details'));
      await settleWorkspace();
      await tester.scrollUntilVisible(
        find.text('Episode 2'),
        200,
        scrollable: find
            .descendant(
              of: find.byType(ComicPage),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(find.text('Episode 2').hitTestable());
      await settleWorkspace();
      final diskReader = tester.state<ReaderState>(find.byType(Reader));
      expect((diskReader.chapter, diskReader.page), (2, 1));
      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await settleWorkspace();
      expect((diskReader.chapter, diskReader.page), (2, 2));
      expect(
        host.record.active!.current.view['reader'],
        containsPair('chapterId', 'ep-2'),
      );
      final knownReaderTitle = diskReader.widget.name;
      expect(host.record.active!.current.arguments['title'], knownReaderTitle);
      final beforeRestart = host.record.freeze();
      expect(
        jsonDecode(
          File('${root.path}/implicitData.json').readAsStringSync(),
        )[WorkspaceStore.key],
        beforeRestart,
      );
      final countBeforeRestart = source.chapterRequests.length;
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      // Wait for the real reader's accepted progress work before doInit.
      await settleSidebarWork(tester, () => appdata.writeImplicitData());
      // Version-1 snapshots from before title metadata remain readable. Use
      // actual disk, and reuse the mandatory reader load to learn its title.
      final legacyFile = File('${root.path}/implicitData.json');
      final legacyDisk = jsonDecode(legacyFile.readAsStringSync());
      for (final tab in legacyDisk[WorkspaceStore.key]['tabs']) {
        for (final route in tab['routes']) {
          if (route['kind'] == 'reader') route['arguments'].remove('title');
        }
      }
      legacyFile.writeAsStringSync(jsonEncode(legacyDisk));
      final detailsBeforeTitleRestore = source.requests.length;
      appdata.implicitData.clear();
      source.reordered = true;
      await settleSidebarWork(tester, appdata.doInit);
      await mountMain();
      await settleWorkspace();
      final restoredHost = tester.state<DesktopWorkspaceState>(
        find.byType(DesktopWorkspace),
      );
      expect(restoredHost, isNot(same(host)));
      expect(
        restoredHost.record.tabs.map((t) => t.id),
        (beforeRestart['tabs'] as List).map((t) => t['id']),
      );
      expect(restoredHost.record.activeId, originalId);
      final restoredReader = tester.state<ReaderState>(find.byType(Reader));
      expect(restoredReader, isNot(same(diskReader)));
      expect(
        (restoredReader.cid, restoredReader.type.sourceKey),
        (first.id, 'workspace-fixture'),
      );
      expect(
        (restoredReader.chapter, restoredReader.page),
        (1, 2),
        reason:
            'chapter identity ep-2 moves to index 1; numeric index must not select ep-1',
      );
      expect(source.chapterRequests.length, countBeforeRestart + 1);
      expect(source.chapterRequests.last, (first.id, 'ep-2'));
      expect(
        restoredHost.record.active!.current.view['reader']['chapterId'],
        'ep-2',
      );
      expect(
        restoredHost.record.active!.current.arguments['title'],
        knownReaderTitle,
      );
      expect(
        source.requests.length,
        detailsBeforeTitleRestore + 1,
        reason:
            'legacy title comes from the existing mandatory reader load, never a second request',
      );
      expect(
        jsonDecode(legacyFile.readAsStringSync())[WorkspaceStore.key],
        restoredHost.record.freeze(),
      );
      expect(manager.getAllComics(), hasLength(60));

      // A source removal must keep this exact route/position and must not
      // dispatch its identity to another installed source with the same IDs.
      final beforeMissing = restoredHost.record.freeze();
      expect(
        jsonDecode(
          File('${root.path}/implicitData.json').readAsStringSync(),
        )[WorkspaceStore.key],
        beforeMissing,
      );
      final infoBeforeMissing = source.requests.length;
      final pagesBeforeMissing = source.chapterRequests.length;
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      await settleSidebarWork(tester, () => appdata.writeImplicitData());
      final otherSource = _DetailsSource(
        root.path,
        sourceKey: 'another-source',
      );
      configureComicSourceRegistry(
        all: () => [otherSource],
        find: (key) => key == otherSource.key ? otherSource : null,
        fromIntKey: (key) =>
            key == otherSource.key.hashCode ? otherSource : null,
        isEmpty: () => false,
      );
      appdata.implicitData.clear();
      await settleSidebarWork(tester, appdata.doInit);
      await mountMain();
      await settleWorkspace();
      final missingHost = tester.state<DesktopWorkspaceState>(
        find.byType(DesktopWorkspace),
      );
      expect(missingHost.record.activeId, originalId);
      expect(
        missingHost.record.tabs.map((t) => t.id),
        restoredHost.record.tabs.map((t) => t.id),
      );
      expect(missingHost.record.active!.current.arguments['id'], first.id);
      expect(
        missingHost.record.active!.current.arguments['sourceKey'],
        'workspace-fixture',
      );
      expect(
        missingHost.record.active!.current.view['reader']['chapterId'],
        'ep-2',
      );
      expect(missingHost.record.active!.current.view['reader']['page'], 2);
      expect(find.byType(Reader), findsNothing);
      final unavailable = tester.widget<ReaderWithLoading>(
        find.byType(ReaderWithLoading),
      );
      expect(
        (unavailable.id, unavailable.sourceKey),
        (first.id, 'workspace-fixture'),
      );
      expect(find.text('comic not found'), findsOneWidget);
      expect(otherSource.requests, isEmpty);
      expect(otherSource.chapterRequests, isEmpty);
      expect(source.requests.length, infoBeforeMissing);
      expect(
        missingHost.record.active!.current.arguments['title'],
        knownReaderTitle,
      );
      expect(source.chapterRequests.length, pagesBeforeMissing);
      expect(manager.getAllComics(), hasLength(60));

      expect(tester.takeException(), isNull);
    },
  );
}
