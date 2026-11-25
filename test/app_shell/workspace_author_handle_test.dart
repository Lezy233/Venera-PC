import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venera_next/components/desktop_chrome.dart';
import 'package:venera_next/app_shell/global_shortcuts.dart';
import 'package:venera_next/app_shell/main_page.dart';
import 'package:venera_next/app_shell/workspace/desktop_workspace.dart';
import 'package:venera_next/app_shell/workspace/workspace_tab_strip.dart';
import 'package:venera_next/components/scroll.dart';
import 'package:venera_next/components/window_frame.dart';
import 'package:venera_next/features/comic_source/comic_source.dart';
import 'package:venera_next/features/comic_widgets/comic_widgets.dart';
import 'package:venera_next/features/favorites/author_shelf_model.dart';
import 'package:venera_next/features/favorites/favorite_order.dart';
import 'package:venera_next/features/favorites/favorites.dart';
import 'package:venera_next/features/favorites/favorites_scope.dart';
import 'package:venera_next/features/favorites/local_favorites_page.dart';
import 'package:venera_next/features/history/history.dart';
import 'package:venera_next/features/history/history_scope.dart';
import 'package:venera_next/foundation/app.dart';
import 'package:venera_next/foundation/appdata.dart';
import 'package:venera_next/foundation/comic_type.dart';
import 'package:venera_next/foundation/opencc.dart';
import 'package:venera_next/foundation/workspace_record.dart';
import 'package:venera_next/foundation/res.dart';
import 'package:venera_next/foundation/translations.dart';
import 'package:venera_next/routing/app_navigation.dart';
import '../components/sidebar_presentation_test.dart' show settleSidebarWork;
import '../support/comic_card_actions.dart';
import '../support/comic_source_fixture.dart';

class _Source extends ComicSourceFixture {
  _Source({required super.key});
  final requests = <String>[];
  @override
  LoadComicFunc get loadComicInfo => (id) async {
    requests.add(id);
    return const Res.error('Background details must stay unrequested');
  };
}

void main() {
  App.dataPath = App.cachePath = Directory.systemTemp.path;
  for (final mode in AuthorShelfState.values) {
    testWidgets(
      'production author handle ${mode.name} drops distinct sources once without reordering',
      (tester) async {
        final root = Directory.systemTemp.createTempSync('ux1-author-handle-');
        final oldPath = App.dataPath, oldCache = App.cachePath;
        final oldSettings = Map<String, dynamic>.from(
          appdata.toJson()['settings'] as Map,
        );
        final oldImplicit = appdata.implicitData;
        final oldMain = appNavigation.mainNavigatorKey;
        App.dataPath = App.cachePath = root.path;
        appdata.implicitData = {
          'favoriteFolder': {'name': 'Handle', 'isNetwork': false},
        };
        appdata.settings['language'] = mode == AuthorShelfState.collapsed
            ? 'zh-TW'
            : mode == AuthorShelfState.normal
            ? 'zh-CN'
            : 'en-US';
        appdata.settings['reduceMotion'] = mode == AuthorShelfState.collapsed;
        appdata.settings['blockedWords'] = <String>[];
        appdata.settings['onClickFavorite'] = 'viewDetail';
        appdata.settings['favoritesFilterPanelOpen'] = false;
        appdata.settings['favoritesDisplayMode'] = 'gallery';
        appdata.settings['workspaceStartup'] = 'restore';
        final favorites = LocalFavoritesManager.independent();
        final history = HistoryManager.create();
        final chrome = DesktopChromeController();
        final sources = [_Source(key: 'handle-a'), _Source(key: 'handle-b')];
        configureComicSourceRegistry(
          all: () => sources,
          find: (key) => sources.where((s) => s.key == key).firstOrNull,
          fromIntKey: (key) =>
              sources.where((s) => s.key.hashCode == key).firstOrNull,
          isEmpty: () => false,
        );
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
        final compact = mode == AuthorShelfState.collapsed;
        final medium = mode == AuthorShelfState.normal;
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
          await settleSidebarWork(tester, () async {
            await appdata.writeImplicitData();
            await favorites.closeAndWait();
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
          oldSettings.forEach((k, v) => appdata.settings[k] = v);
          appdata.implicitData = oldImplicit;
          appNavigation.mainNavigatorKey = oldMain;
          App.dataPath = oldPath;
          App.cachePath = oldCache;
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
          tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            const MethodChannel('window_manager'),
            null,
          );
          root.deleteSync(recursive: true);
        });
        await tester.runAsync(() async {
          await OpenCC.init();
          await AppTranslation.init();
          await favorites.init();
          await history.init();
          await favorites.createFolder('Handle');
          for (final source in sources) {
            await favorites.addComic(
              'Handle',
              FavoriteItem(
                id: 'shared',
                name: 'Shared ${source.key}',
                coverPath: '',
                author: '',
                type: ComicType.fromKey(source.key),
                tags: ['author:Alpha', 'author:Beta'],
              ),
            );
          }
          for (final author in ['Alpha', 'Beta']) {
            await favorites.addComic(
              'Handle',
              FavoriteItem(
                id: author,
                name: 'Tail $author',
                coverPath: '',
                author: author,
                type: ComicType.fromKey(sources.first.key),
                tags: [],
              ),
            );
            await favorites.setShelfState(
              folder: 'Handle',
              author: author,
              state: mode,
              token: favorites.orderScopeToken(
                const FavoriteOrderScope.folder('Handle'),
              )!,
              generation: favorites.connectionGeneration,
              dataPath: root.path,
              isCurrent: () => true,
            );
          }
          await favorites.setOrderScopeMode(
            const FavoriteOrderScope.folder('Handle'),
            'authorManual',
          );
          await favorites.debugWaitForHashedIdsRefresh();
        });
        await tester.pumpWidget(
          FavoritesScope(
            manager: favorites,
            child: HistoryScope(
              manager: history,
              child: MaterialApp(
                navigatorKey: appNavigation.rootNavigatorKey,
                theme: ThemeData(
                  brightness: compact ? Brightness.dark : Brightness.light,
                ),
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(compact || medium ? 1.5 : 1),
                    disableAnimations: medium,
                  ),
                  child: DesktopChromeScope(
                    controller: chrome,
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
          for (var i = 0; i < 3; i++) {
            await tester.pump(const Duration(milliseconds: 400));
            await settleSidebarWork(tester, () => appdata.writeImplicitData());
            await settleSidebarWork(
              tester,
              () => tester
                  .state<DesktopWorkspaceState>(find.byType(DesktopWorkspace))
                  .waitForSettingsSave(),
            );
          }
          await tester.pumpAndSettle(
            const Duration(milliseconds: 100),
            EnginePhase.sendSemanticsUpdate,
            const Duration(seconds: 3),
          );
        }

        await settle();
        expect(tester.takeException(), isNull);
        Finder group(String author) => find.byKey(
          ValueKey<(String, String, String?)>((
            mode == AuthorShelfState.collapsed
                ? 'author-shelf-scroll'
                : 'author-shelf-grid',
            'Handle',
            author,
          )),
        );
        Finder card(String author, String source) => find.descendant(
          of: group(author),
          matching: find.byWidgetPredicate(
            (w) =>
                w is ComicTile &&
                w.comic.id == 'shared' &&
                w.comic.sourceKey == source,
          ),
        );
        final host = tester.state<DesktopWorkspaceState>(
          find.byType(DesktopWorkspace),
        );
        final active = host.record.activeId;
        final page = tester.state(find.byType(LocalFavoritesPage));
        final order = Map.of(favorites.authorShelfOrders('Handle'));
        final membership = favorites
            .getFolderComics('Handle')
            .map((c) => (c.id, c.sourceKey))
            .toList();
        final businessScroll = find
            .descendant(
              of: find.byType(SmoothCustomScrollView).first,
              matching: find.byType(Scrollable),
            )
            .first;
        final arrow = find.byKey(
          const ValueKey<(String, String, String?)>((
            'author-shelf-arrow',
            'Handle',
            'Beta',
          )),
        );
        final handle = find.byKey(
          const ValueKey<(String, String, String?)>((
            'author-selection-handle',
            'Handle',
            'Beta',
          )),
        );
        await tester.scrollUntilVisible(arrow, 250, scrollable: businessScroll);
        await settle();
        Offset handleOrigin() =>
            tester.getRect(arrow).centerLeft - const Offset(22, 0);
        Future<void> dragHandle({bool cancel = false}) async {
          final gesture = await tester.startGesture(
            handleOrigin(),
            kind: PointerDeviceKind.mouse,
          );
          await gesture.moveBy(const Offset(0, -30));
          await tester.pump();
          if (cancel) {
            await tester.sendKeyEvent(LogicalKeyboardKey.escape);
            await tester.pump();
          }
          await gesture.moveTo(
            tester.getCenter(find.byType(WorkspaceTabStrip)),
          );
          await tester.pump();
          await gesture.up();
          await gesture.removePointer();
          await settle();
        }

        await dragHandle();
        expect(
          host.record.tabs.length,
          1,
          reason: 'empty selection cannot begin a workspace drag',
        );
        expect(favorites.authorShelfOrders('Handle'), order);
        await tester.scrollUntilVisible(
          card('Alpha', sources[0].key),
          -250,
          scrollable: businessScroll,
        );
        await settle();
        await toggleComicCheckbox(tester, card('Alpha', sources[0].key));
        await settle();
        await toggleComicCheckbox(tester, card('Alpha', sources[1].key));
        await settle();
        await tester.scrollUntilVisible(arrow, 250, scrollable: businessScroll);
        await settle();
        expect(
          tester.widget<ComicTile>(card('Beta', sources[0].key)).selected,
          isTrue,
        );
        // The independent header handle belongs immediately before the old arrow.
        // Exercise this real coordinate before asserting the missing affordance.
        final origin = handleOrigin();
        expect(tester.getCenter(handle), origin);
        final scrollController = tester
            .widget<SmoothCustomScrollView>(
              find.byType(SmoothCustomScrollView).first,
            )
            .controller!;
        final offset = scrollController.offset;
        final originalFocus = FocusManager.instance.primaryFocus;
        await tester.tapAt(origin);
        await settle();
        expect(
          host.record.tabs.length,
          1,
          reason: 'handle click must not open or change selection',
        );
        for (final author in ['Beta']) {
          for (final source in sources) {
            expect(
              tester.widget<ComicTile>(card(author, source.key)).selected,
              isTrue,
            );
            expect(
              tester
                  .getRect(handle)
                  .overlaps(
                    tester.getRect(
                      find.descendant(
                        of: card(author, source.key),
                        matching: find.byType(Checkbox),
                      ),
                    ),
                  ),
              isFalse,
            );
          }
        }
        await dragHandle(cancel: true);
        expect(
          host.record.tabs.length,
          1,
          reason: 'Escape cancellation cannot create a background tab',
        );
        expect(FocusManager.instance.primaryFocus, same(originalFocus));
        await dragHandle();
        expect(
          host.record.tabs.length,
          3,
          reason:
              'the actual author header selection handle must drop two entities',
        );
        // The drop inserts at the drop position, so the original tab is not
        // necessarily first; assert the two real detail tabs by kind instead.
        expect(
          host.record.tabs
              .where((t) => t.current.kind == WorkspacePageKind.comic)
              .map(
                (t) => (
                  t.current.arguments['id'],
                  t.current.arguments['sourceKey'],
                ),
              ),
          unorderedEquals([
            ('shared', sources[0].key),
            ('shared', sources[1].key),
          ]),
        );
        expect(host.record.activeId, active);
        expect(tester.state(find.byType(LocalFavoritesPage)), same(page));
        expect(favorites.authorShelfOrders('Handle'), order);
        expect(
          favorites.getFolderComics('Handle').map((c) => (c.id, c.sourceKey)),
          membership,
        );
        expect(sources.every((s) => s.requests.isEmpty), isTrue);
        expect(FocusManager.instance.primaryFocus, same(originalFocus));
        expect(scrollController.offset, offset);
        // The selected card body still owns its original long-press sorting;
        // this action only changes Beta, never opens workspace tabs.
        final reorder = await tester.startGesture(
          tester.getCenter(
            find.descendant(
              of: card('Beta', sources[1].key),
              matching: find.text('Shared ${sources[1].key}'),
            ),
          ),
          kind: PointerDeviceKind.mouse,
        );
        await tester.pump(
          kLongPressTimeout + const Duration(milliseconds: 100),
        );
        await reorder.moveTo(tester.getCenter(card('Beta', sources[0].key)));
        await tester.pump(const Duration(milliseconds: 100));
        await reorder.up();
        await reorder.removePointer();
        await settle();
        final groups = authorShelves(
          favorites.getFolderComics('Handle'),
          orders: favorites.authorShelfOrders('Handle'),
        );
        expect(
          groups
              .singleWhere((g) => g.author == 'Beta')
              .items
              .map((c) => (c.id, c.sourceKey)),
          [
            ('shared', sources[1].key),
            ('shared', sources[0].key),
            ('Beta', sources[0].key),
          ],
        );
        expect(
          groups
              .singleWhere((g) => g.author == 'Alpha')
              .items
              .map((c) => (c.id, c.sourceKey)),
          [
            ('shared', sources[0].key),
            ('shared', sources[1].key),
            ('Alpha', sources[0].key),
          ],
        );
        expect(host.record.tabs.length, 3);
        expect(
          favorites.getFolderComics('Handle').map((c) => (c.id, c.sourceKey)),
          membership,
        );
        // Traverse with actual Tab keys to the accessible handle, then use the
        // equivalent background-open command without activating any new tab.
        for (
          var i = 0;
          i < 60 &&
              FocusManager.instance.primaryFocus?.debugLabel !=
                  'author-selection-handle';
          i++
        ) {
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();
        }
        expect(
          FocusManager.instance.primaryFocus?.debugLabel,
          'author-selection-handle',
        );
        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        await settle();
        expect(host.record.tabs.length, 5);
        expect(host.record.activeId, active);
        expect(sources.every((s) => s.requests.isEmpty), isTrue);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
