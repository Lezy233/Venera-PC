import 'dart:io';
import 'dart:async';
import 'dart:ui' show CheckedState;
import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venera_next/features/comic_source/comic_source.dart';
import 'package:venera_next/features/comic_widgets/comic_widgets.dart';
import 'package:venera_next/foundation/app.dart';
import 'package:venera_next/foundation/appdata.dart';
import 'package:venera_next/foundation/res.dart';
import 'package:venera_next/foundation/translations.dart';

import '../../support/comic_source_fixture.dart';

class _Source extends ComicSourceFixture {
  _Source({this.longDescription = false}) : super(key: 'preview-source');
  final bool longDescription;
  final requests = <String>[];
  @override
  LoadComicFunc get loadComicInfo => (id) async {
    requests.add(id);
    return Res(
      ComicDetails.fromJson({
        'comicId': id,
        'sourceKey': key,
        'title': 'Details $id',
        'cover': '',
        'description': longDescription
            ? List.filled(60, 'Long overview $id').join('\n')
            : 'Overview $id',
        'tags': <String, dynamic>{},
        'chapters': {'one': 'Chapter one $id'},
      }),
    );
  };
}

class _DelayedSource extends ComicSourceFixture {
  _DelayedSource(String key) : super(key: key);
  final pending = <Completer<Res<ComicDetails>>>[];
  @override
  LoadComicFunc get loadComicInfo => (id) {
    final completer = Completer<Res<ComicDetails>>();
    pending.add(completer);
    return completer.future;
  };
}

Future<void> _mount(
  WidgetTester tester,
  List<ComicSource> sources,
  List<Comic> comics, {
  double width = 1000,
  Brightness brightness = Brightness.light,
  String language = 'en-US',
  double textScale = 1,
  bool reduceMotion = false,
  bool manualReduceMotion = false,
}) async {
  final settings = Map<String, dynamic>.from(
    appdata.toJson()['settings'] as Map,
  );
  appdata.settings['language'] = language;
  appdata.settings['blockedWords'] = <String>[];
  appdata.settings['comicDisplayMode'] = 'gallery';
  appdata.settings['reduceMotion'] = manualReduceMotion;
  configureComicSourceRegistry(
    all: () => sources,
    find: (key) => sources.where((s) => s.key == key).firstOrNull,
    fromIntKey: (_) => null,
    isEmpty: () => sources.isEmpty,
  );
  configureComicWidgets();
  tester.view.physicalSize = Size(width, 760);
  tester.view.devicePixelRatio = 1;
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox());
    settings.forEach((k, v) => appdata.settings[k] = v);
    configureComicWidgets();
    configureComicSourceRegistry(
      all: () => [],
      find: (_) => null,
      fromIntKey: (_) => null,
      isEmpty: () => true,
    );
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.runAsync(AppTranslation.init);
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(brightness: brightness),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: reduceMotion,
        ),
        child: child!,
      ),
      home: Scaffold(
        body: Column(
          children: [
            const TextField(),
            Expanded(
              child: CustomScrollView(
                slivers: [SliverGridComics(comics: comics)],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  App.dataPath = App.cachePath = Directory.systemTemp.path;
  for (final manual in [false, true]) {
    for (final system in [false, true]) {
      testWidgets(
        'preview motion manual=$manual system=$system uses either independent switch',
        (tester) async {
          final source = _Source();
          await _mount(
            tester,
            [source],
            [
              Comic(
                'Motion card',
                '',
                'alpha',
                null,
                null,
                '',
                source.key,
                null,
                null,
              ),
            ],
            reduceMotion: system,
            manualReduceMotion: manual,
          );
          await tester.tap(find.byType(TextField));
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.space);
          await tester.pump();
          final route = ModalRoute.of(tester.element(find.byType(Dialog)))!;
          if (manual || system) {
            expect(
              route.animation!.value,
              1.0,
              reason: 'no animated entrance when either reduction is enabled',
            );
          } else {
            expect(route.animation!.value, lessThan(1.0));
          }
          await tester.pumpAndSettle();
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          await tester.pumpAndSettle();
          expect(find.byType(Dialog), findsNothing);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
  testWidgets(
    'keyboard Space on focused checkbox selects instead of previewing',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        final source = _Source();
        await _mount(
          tester,
          [source],
          [
            Comic(
              'Keyboard card',
              '',
              'alpha',
              null,
              null,
              '',
              source.key,
              null,
              null,
            ),
          ],
        );
        await tester.tap(find.byType(TextField));
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(find.byType(Checkbox), findsOneWidget);
        expect(
          tester
              .getSemantics(find.byType(Checkbox))
              .getSemanticsData()
              .flagsCollection
              .isChecked,
          CheckedState.isFalse,
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(
          FocusManager.instance.primaryFocus!.context!
              .findAncestorWidgetOfExactType<Checkbox>(),
          isNotNull,
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();
        expect(
          find.byType(Dialog),
          findsNothing,
          reason: 'checkbox has its own Space action',
        );
        expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
        expect(
          tester
              .getSemantics(find.byType(Checkbox))
              .getSemanticsData()
              .flagsCollection
              .isChecked,
          CheckedState.isTrue,
        );
        expect(source.requests, isEmpty);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    },
  );
  for (final width in [600.0, 1000.0, 1400.0]) {
    for (final brightness in Brightness.values) {
      for (final language in ['zh-CN', 'zh-TW']) {
        for (final reduced in [false, true]) {
          testWidgets(
            'preview $width $brightness $language 150% reduce=$reduced pinned close and scroll',
            (tester) async {
              final source = _Source(longDescription: true);
              await _mount(
                tester,
                [source],
                [
                  Comic(
                    'A very long comic title across multiple visible lines',
                    '',
                    'alpha',
                    null,
                    null,
                    '',
                    source.key,
                    null,
                    null,
                  ),
                ],
                width: width,
                brightness: brightness,
                language: language,
                textScale: 1.5,
                reduceMotion: reduced,
              );
              await tester.tap(find.byType(TextField));
              await tester.sendKeyEvent(LogicalKeyboardKey.tab);
              await tester.pump();
              final origin = FocusManager.instance.primaryFocus;
              await tester.sendKeyEvent(LogicalKeyboardKey.space);
              await tester.pumpAndSettle();
              expect(find.bySemanticsLabel('Comic preview'.tl), findsOneWidget);
              final close = find.byTooltip('Close'.tl).hitTestable();
              expect(close, findsOneWidget);
              final body = find.descendant(
                of: find.byType(Dialog),
                matching: find.byType(SingleChildScrollView),
              );
              await tester.drag(body, const Offset(0, -350));
              await tester.pumpAndSettle();
              expect(close, findsOneWidget);
              await tester.tapAt(tester.getCenter(close));
              await tester.pumpAndSettle();
              expect(find.byType(Dialog), findsNothing);
              expect(FocusManager.instance.primaryFocus, same(origin));
              expect(source.requests, ['alpha']);
              expect(tester.takeException(), isNull);
            },
          );
        }
      }
    }
  }
  testWidgets(
    'rapid preview isolates same ID across sources and ignores late results after close',
    (tester) async {
      final sources = [
        _DelayedSource('first'),
        _DelayedSource('second'),
        _DelayedSource('third'),
      ];
      await _mount(tester, sources, [
        for (final source in sources)
          Comic(
            'Card ${source.key}',
            '',
            'same',
            null,
            null,
            '',
            source.key,
            null,
            null,
          ),
      ]);
      await tester.tap(find.byType(TextField));
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(
        find.byType(Dialog),
        findsNothing,
        reason: 'text input Space is not a card command',
      );
      expect(sources.every((s) => s.pending.isEmpty), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump(const Duration(milliseconds: 200));
      expect(sources.map((s) => s.pending.length), [1, 0, 0]);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(sources.map((s) => s.pending.length), [1, 1, 0]);
      Res<ComicDetails> result(String title, String source) => Res(
        ComicDetails.fromJson({
          'title': title,
          'comicId': 'same',
          'sourceKey': source,
          'cover': '',
          'description': title,
          'tags': <String, dynamic>{},
        }),
      );
      sources[0].pending.single.complete(result('Stale first', 'first'));
      await tester.pump();
      expect(find.text('Stale first'), findsNothing);
      sources[1].pending.single.complete(result('Current second', 'second'));
      await tester.pumpAndSettle();
      expect(find.text('Current second'), findsNWidgets(2));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      sources[2].pending.single.complete(result('Late third', 'third'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
      expect(find.text('Late third'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'real hover checkbox selects independently and Escape clears selection',
    (tester) async {
      final previous = appdata.settings['comicDisplayMode'];
      appdata.settings['comicDisplayMode'] = 'gallery';
      configureComicWidgets();
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox());
        appdata.settings['comicDisplayMode'] = previous;
      });
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverGridComics(
                  comics: [
                    Comic(
                      'Selection alpha',
                      '',
                      'alpha',
                      null,
                      null,
                      '',
                      'preview-source',
                      null,
                      null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.byType(ComicTile)));
      await tester.pumpAndSettle();
      expect(find.byType(Checkbox).hitTestable(), findsOneWidget);
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
      await mouse.moveTo(const Offset(790, 590));
      await tester.pumpAndSettle();
      expect(
        find.byType(Checkbox).hitTestable(),
        findsOneWidget,
        reason: 'selected checkbox remains visible',
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
      expect(find.byType(ComicTile), findsOneWidget);
      expect(tester.takeException(), isNull);
      await mouse.removePointer();
    },
  );
  testWidgets(
    'real card Space previews without a route; arrows and Escape return focus',
    (tester) async {
      final source = _Source();
      final settings = Map<String, dynamic>.from(
        appdata.toJson()['settings'] as Map,
      );
      appdata.settings['language'] = 'en-US';
      appdata.settings['blockedWords'] = <String>[];
      appdata.settings['comicDisplayMode'] = 'gallery';
      configureComicSourceRegistry(
        all: () => [source],
        find: (key) => key == source.key ? source : null,
        fromIntKey: (_) => source,
        isEmpty: () => false,
      );
      configureComicWidgets();
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox());
        settings.forEach((k, v) => appdata.settings[k] = v);
        configureComicWidgets();
        configureComicSourceRegistry(
          all: () => [],
          find: (_) => null,
          fromIntKey: (_) => null,
          isEmpty: () => true,
        );
      });
      final comics = [
        for (final id in ['alpha', 'beta'])
          Comic(
            'Card $id',
            '',
            id,
            null,
            null,
            'Card overview $id',
            source.key,
            null,
            null,
          ),
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const TextField(),
                Expanded(
                  child: CustomScrollView(
                    slivers: [SliverGridComics(comics: comics)],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'initialization must be clean',
      );
      await tester.tap(find.byType(TextField));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final originalFocus = FocusManager.instance.primaryFocus;
      expect(originalFocus, isNotNull);
      expect(
        originalFocus!.context!
            .findAncestorWidgetOfExactType<ComicTile>()
            ?.comic
            .id,
        'alpha',
        reason:
            'Space must originate at the real alpha card, not an unrelated scope',
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Comic preview'), findsOneWidget);
      expect(find.text('Overview alpha'), findsOneWidget);
      expect(find.text('Chapter one alpha'), findsOneWidget);
      expect(source.requests, ['alpha']);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(find.text('Overview beta'), findsOneWidget);
      expect(source.requests, ['alpha', 'beta']);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Comic preview'), findsNothing);
      expect(FocusManager.instance.primaryFocus, same(originalFocus));
      expect(find.byType(ComicTile), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    },
  );
}
