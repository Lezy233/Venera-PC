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
  for (final enlargedDark in [false, true]) {
    testWidgets(
      'real workspace overflow and full-title keyboard menu; dark150=$enlargedDark',
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
                name:
                    'A deliberately complete long comic title ${i.toString().padLeft(2, '0')} for pointer and keyboard overflow',
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
                theme: ThemeData(
                  brightness: enlargedDark ? Brightness.dark : Brightness.light,
                ),
                builder: (context, child) => DesktopChromeScope(
                  controller: chrome,
                  child: GlobalShortcuts(
                    chrome: chrome,
                    child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler: TextScaler.linear(enlargedDark ? 1.5 : 1),
                      ),
                      child: WindowFrame(child!),
                    ),
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
          // First detail activation publishes its loaded view after the first
          // queue barrier. Wait for that actual save before settling animations.
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
        final beforeRecent = List<String>.of(host.record.recent);
        final candidates = find.byType(ComicTile).hitTestable();
        final comics = [
          for (var i = 0; i < 3; i++)
            tester.widget<ComicTile>(candidates.at(i)).comic,
        ];
        final created = <String>[];
        for (final comic in comics) {
          final card = find
              .byWidgetPredicate(
                (w) => w is ComicTile && w.comic.id == comic.id,
              )
              .hitTestable();
          await tester.tapAt(
            tester.getCenter(card),
            buttons: kSecondaryMouseButton,
          );
          await settleWorkspace();
          expect(find.text('Open in background tab'), findsOneWidget);
          await tester.tap(find.text('Open in background tab'));
          await settleWorkspace();
          created.add(host.record.tabs.last.id);
          expect(host.record.activeId, originalId);
          expect(
            source.requests,
            isEmpty,
            reason: 'unviewed details must not issue requests',
          );
          expect(find.byType(ComicPage, skipOffstage: false), findsNothing);
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
        }
        expect(host.record.tabs.length, count + 3);
        expect(
          host.record.recent,
          beforeRecent,
          reason: 'unviewed background tabs stay out of MRU',
        );
        final horizontal = find
            .descendant(
              of: find.byType(WorkspaceTabStrip),
              matching: find.byType(Scrollable),
            )
            .first;
        final position = tester.state<ScrollableState>(horizontal).position;
        Finder tabFor(String id) => find.descendant(
          of: find.byType(WorkspaceTabStrip),
          matching: find.byKey(ValueKey(id)),
        );
        final originalRect = tester.getRect(tabFor(originalId));
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(location: tester.getCenter(tabFor(originalId)));
        await mouse.moveTo(tester.getCenter(tabFor(originalId)));
        await tester.pump(const Duration(seconds: 1));
        // Hover must not shift tab bounds or its close hit region.
        expect(tester.getRect(tabFor(originalId)), originalRect);
        for (final width in [1400.0, 1000.0, 600.0]) {
          tester.view.physicalSize = Size(width, 900);
          await settleWorkspace();
          final contentSize = tester.getSize(
            find.byKey(appNavigation.mainNavigatorKey!),
          );
          expect(
            contentSize.height,
            greaterThan(tester.view.physicalSize.height * .6),
            reason:
                'shell feedback must not starve the real content viewport at width $width',
          );
          await tester.sendEventToBinding(
            PointerScrollEvent(
              position: tester.getCenter(horizontal),
              scrollDelta: const Offset(420, 0),
              kind: PointerDeviceKind.mouse,
            ),
          );
          await tester.pumpAndSettle();
          expect(
            position.pixels,
            greaterThan(0),
            reason: 'horizontal pointer scrolling at width $width',
          );
          expect(
            find.descendant(
              of: find.byType(WorkspaceTabStrip),
              matching: find.byIcon(Icons.chevron_left),
            ),
            findsNothing,
          );
          await tester.tap(find.text('All ${count + 3}'));
          await tester.pumpAndSettle();
          final items = find.byType(PopupMenuItem<String>);
          expect(items, findsNWidgets(count + 3));
          for (final comic in comics) {
            final title = tester.widget<Text>(
              find.descendant(of: items, matching: find.text(comic.title)),
            );
            expect(title.data, comic.title);
            expect(title.maxLines, isNull);
          }
          expect(
            find.descendant(
              of: items,
              matching: find.byIcon(Icons.pending_outlined),
            ),
            findsNWidgets(3),
          );
          expect(tester.takeException(), isNull);
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          await tester.pumpAndSettle();
        }
        final longTab = tabFor(created.last);
        final beforeHover = tester.getRect(longTab);
        await mouse.moveTo(tester.getCenter(longTab));
        await tester.pump(const Duration(seconds: 1));
        expect(tester.getRect(longTab), beforeHover);
        expect(
          find.byWidgetPredicate(
            (w) => w is Text && w.textSpan?.toPlainText() == comics.last.title,
          ),
          findsOneWidget,
          reason: 'real hover shows the complete long title',
        );
        await mouse.moveTo(const Offset(4, 4));
        await tester.pumpAndSettle();
        // Select a known unseen tab through the actual popup keyboard focus.
        await tester.tap(find.text('All ${count + 3}'));
        await tester.pumpAndSettle();
        var focusedTarget = false;
        for (var step = 0; step < count + 4; step++) {
          final item = FocusManager.instance.primaryFocus?.context
              ?.findAncestorWidgetOfExactType<PopupMenuItem<String>>();
          if (item?.value == created[1]) {
            focusedTarget = true;
            break;
          }
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pump();
        }
        expect(focusedTarget, isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await settleWorkspace();
        expect(host.record.activeId, created[1]);
        final active = tester.widget<ComicPage>(find.byType(ComicPage));
        expect(
          (active.id, active.sourceKey),
          (comics[1].id, 'workspace-fixture'),
        );
        expect(source.requests, [comics[1].id]);
        expect(host.record.recent.contains(created[0]), isFalse);
        expect(host.record.recent.contains(created[2]), isFalse);
        await tester.tap(find.text('All ${count + 3}'));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(PopupMenuItem<String>).first);
        await settleWorkspace();
        expect(host.record.activeId, originalId);
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
        expect(FocusManager.instance.primaryFocus, same(originalFocus));
        await mouse.removePointer();
        final unseenToClose = created.last;
        final closeBounds = tester.getSize(tabFor(unseenToClose));
        final focusLimit =
            find.byType(Focus, skipOffstage: false).evaluate().length + 1;
        final seenCloseFocus = <FocusNode>{};
        var reachedClose = false;
        for (var step = 0; step < focusLimit; step++) {
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await settleWorkspace();
          final focused = FocusManager.instance.primaryFocus!;
          var inTarget = false;
          focused.context?.visitAncestorElements((e) {
            if (e.widget.key == ValueKey(unseenToClose)) inTarget = true;
            return true;
          });
          if (inTarget &&
              focused.context
                      ?.findAncestorWidgetOfExactType<IconButton>()
                      ?.tooltip ==
                  'Close tab') {
            reachedClose = true;
            break;
          }
          expect(
            seenCloseFocus.add(focused),
            isTrue,
            reason:
                'Tab must reach the revealed non-current close without cycling',
          );
        }
        expect(reachedClose, isTrue);
        expect(tester.getSize(tabFor(unseenToClose)), closeBounds);
        // Traversing real favorite cards may scroll them into view. Closing
        // another tab must preserve the scene at the moment of that action.
        final beforeKeyboardCloseOffset = originalController.offset;
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await settleWorkspace();
        expect(host.record.tabs.any((t) => t.id == unseenToClose), isFalse);
        expect(host.record.activeId, originalId);
        expect(
          tester.state(find.byType(LocalFavoritesPage)),
          same(originalPage),
        );
        expect(
          originalController.offset,
          closeTo(beforeKeyboardCloseOffset, .01),
        );
        expect(
          tester
              .widget<SliverGridComics>(find.byType(SliverGridComics))
              .selections!
              .keys
              .map((c) => c.id),
          unorderedEquals(selectedIds),
        );
        expect(source.requests, [comics[1].id]);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
