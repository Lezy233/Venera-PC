import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venera_next/components/effects.dart';
import 'package:venera_next/features/reader/auto_reading.dart';
import 'package:venera_next/features/reader/platform_effects_controller.dart';
import 'package:venera_next/features/reader/progress_bar.dart';
import 'package:venera_next/features/reader/progress_navigation.dart';
import 'package:venera_next/features/reader/scaffold.dart';
import 'package:venera_next/features/reader/shell_data.dart';
import 'package:venera_next/foundation/appdata.dart';
import 'package:venera_next/foundation/image_work.dart';
import 'package:venera_next/foundation/reader_settings.dart';

/// UX1 6.7: hidden tools keep one compact progress rail that occupies real
/// layout space below the comic. It must not be an overlay painted on top of
/// the content and must not keep the expanded chapter controls.
void main() {
  Future<void> mount(
    WidgetTester tester, {
    ThemeData? theme,
    double textScale = 1,
    bool reduceMotion = false,
  }) async {
    final work = ImageWork();
    final favorites = ChangeNotifier();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      await work.dispose();
      favorites.dispose();
    });
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: MediaQuery(
          data: MediaQueryData(
            textScaler: TextScaler.linear(textScale),
            disableAnimations: reduceMotion,
          ),
          child: Scaffold(
            body: SizedBox.expand(
              child: ReaderScaffold(
                key: const ValueKey('shell'),
                data: ReaderShellData(
                  comicId: 'book',
                  sourceKey: 'local',
                  title: 'Book',
                  chapterTitle: 'One',
                  hasChapters: true,
                  vertical: false,
                  gallery: true,
                  animating: false,
                  onCommentsPage: false,
                  swipeToCollect: false,
                  preferences: ReaderSettings.resolve(
                    global: {
                      'showPageNumberInReader': false,
                      'enableClockAndBatteryInfoInReader': false,
                    },
                  ),
                  automaticReading: AutoReadingStatus.stopped,
                ),
                progress: ReaderProgressRequest(
                  identity: Object(),
                  page: 2,
                  maxPage: 10,
                  chapter: 1,
                  maxChapter: 3,
                  reversed: false,
                  isCurrent: () => true,
                  toPage: (_, {animated = true}) => true,
                  toChapter: (_) => true,
                ),
                onExit: () async {},
                onFullscreen: null,
                onToggleAutomaticReading: () => false,
                acquireSidebarPause: () => () {},
                readImagePickContext: () => null,
                imageWork: work,
                orientation: ReaderOrientation.system,
                onRotate: null,
                onSystemUiChanged: (_) {},
                createChapterMenu: () => null,
                favoriteChanges: favorites,
                createFavoriteQuery: () => null,
                createImageFavorite: () => null,
                createImageExport: () => null,
                createSettings: () => null,
                createChapterComments: () => null,
                chapterNavigation: null,
                child: const ColoredBox(
                  key: ValueKey('comic-content'),
                  color: Color(0xff758473),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  ReaderScaffoldState shell(WidgetTester tester) =>
      tester.state<ReaderScaffoldState>(find.byType(ReaderScaffold));

  testWidgets(
    'hidden tools keep one compact rail below the comic instead of an overlay',
    (tester) async {
      await mount(tester);
      final compactBar = find.byType(ReaderBottomBar);
      final rail = find.byType(ReaderProgressSlider);
      expect(compactBar, findsOneWidget);
      expect(rail, findsOneWidget);
      expect(tester.getSize(compactBar).height, ReaderBottomBar.compactHeight);
      final content = tester.getRect(
        find.byKey(const ValueKey('comic-content')),
      );
      final bar = tester.getRect(compactBar);
      expect(
        content.bottom,
        lessThanOrEqualTo(bar.top),
        reason: 'the compact rail must own layout space, not cover the comic',
      );
      expect(bar.top, greaterThanOrEqualTo(content.bottom));
      expect(content.overlaps(bar), isFalse);
      expect(
        tester.getSize(find.byType(ReaderScaffold)).height,
        content.height + bar.height,
      );
      expect(find.byType(BlurEffect), findsNothing);
      expect(find.byIcon(Icons.first_page), findsNothing);
      expect(find.byIcon(Icons.last_page), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('showing tools keeps exactly one progress component', (
    tester,
  ) async {
    await mount(tester);
    expect(find.byType(ReaderProgressSlider), findsOneWidget);
    shell(tester).openOrClose();
    await tester.pumpAndSettle();
    // One progress component in the expanded bar; no second floating copy.
    expect(find.byType(ReaderProgressSlider), findsOneWidget);
    // The expanded bar owns its 1px top hairline on top of the 105px slot.
    expect(
      tester.getSize(find.byType(ReaderBottomBar)).height,
      greaterThanOrEqualTo(ReaderBottomBar.height),
    );
    expect(find.byIcon(Icons.first_page), findsOneWidget);
    expect(find.byIcon(Icons.last_page), findsOneWidget);
    final expanded = tester.getRect(find.byType(ReaderBottomBar));
    expect(expanded.bottom, tester.getSize(find.byType(ReaderScaffold)).height);
    // The comic keeps the same bottom edge as the compact rail slot.
    shell(tester).openOrClose();
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byType(ReaderBottomBar)).height,
      ReaderBottomBar.compactHeight,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact rail follows dark theme, 150% text and reduced motion', (
    tester,
  ) async {
    await mount(
      tester,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
      ),
      textScale: 1.5,
      reduceMotion: true,
    );
    expect(find.byType(ReaderProgressSlider), findsOneWidget);
    expect(
      tester.getSize(find.byType(ReaderBottomBar)).height,
      ReaderBottomBar.compactHeight,
    );
    expect(find.byIcon(Icons.first_page), findsNothing);
    expect(find.byIcon(Icons.last_page), findsNothing);
    // The chrome follows the app theme: no dark-exception surface and no blur.
    final context = tester.element(find.byType(ReaderScaffold));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(find.byType(BlurEffect), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('manual reduced motion opens the tool row without animation', (
    tester,
  ) async {
    final previous = appdata.settings['reduceMotion'];
    appdata.settings['reduceMotion'] = true;
    addTearDown(() => appdata.settings['reduceMotion'] = previous);
    await mount(tester);
    shell(tester).openOrClose();
    // A single frame is enough when the manual reduced-motion preference is on.
    await tester.pump();
    expect(
      tester.getRect(find.byType(ReaderBottomBar)).bottom,
      tester.getSize(find.byType(ReaderScaffold)).height,
      reason: 'manual reduced motion must not wait for the menu animation',
    );
    expect(find.byIcon(Icons.first_page), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
