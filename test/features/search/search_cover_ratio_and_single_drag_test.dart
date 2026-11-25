import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venera_next/components/workspace_navigation_scope.dart';
import 'package:venera_next/foundation/workspace_record.dart';
import 'package:venera_next/app_shell/workspace/workspace_tab_strip.dart';
import 'package:venera_next/features/comic_widgets/comic_widgets.dart';
import 'package:venera_next/features/comic_source/comic_source.dart';
import 'package:venera_next/foundation/appdata.dart';
import 'package:venera_next/components/image.dart';

const _wide =
    'iVBORw0KGgoAAAANSUhEUgAAAAIAAAABCAIAAAB7QOjdAAAAIGNIUk0AAHomAACAhAAA+gAAAIDoAAB1MAAA6mAAADqYAAAXcJy6UTwAAAAGYktHRAD/AP8A/6C9p5MAAAAHdElNRQfqCxENIxam28LMAAAAJXRFWHRkYXRlOmNyZWF0ZQAyMDI2LTExLTE3VDEzOjM1OjIyKzAwOjAwPAOC8wAAACV0RVh0ZGF0ZTptb2RpZnkAMjAyNi0xMS0xN1QxMzozNToyMiswMDowME1eOk8AAAAodEVYdGRhdGU6dGltZXN0YW1wADIwMjYtMTEtMTdUMTM6MzU6MjIrMDA6MDAaSxuQAAAAD0lEQVQI12P8z8DAwMAAAAYIAQHDmmDFAAAAAElFTkSuQmCC';
const _tall =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAACCAIAAAAW4yFwAAAAIGNIUk0AAHomAACAhAAA+gAAAIDoAAB1MAAA6mAAADqYAAAXcJy6UTwAAAAGYktHRAD/AP8A/6C9p5MAAAAHdElNRQfqCxENIxam28LMAAAAJXRFWHRkYXRlOmNyZWF0ZQAyMDI2LTExLTE3VDEzOjM1OjIyKzAwOjAwPAOC8wAAACV0RVh0ZGF0ZTptb2RpZnkAMjAyNi0xMS0xN1QxMzozNToyMiswMDowME1eOk8AAAAodEVYdGRhdGU6dGltZXN0YW1wADIwMjYtMTEtMTdUMTM6MzU6MjIrMDA6MDAaSxuQAAAAEElEQVQI12NgYPjPxMDAAAAFCwEC0ZqkWQAAAABJRU5ErkJggg==';

Comic _comic(String id) =>
    Comic(id, '', id, null, const [], '', 'cover-ratio-fixture', null, null);

void main() {
  testWidgets('production gallery preserves wide and tall cover pixels', (
    tester,
  ) async {
    final previous = Map<String, dynamic>.from(
      appdata.toJson()['settings'] as Map,
    );
    appdata.settings['comicDisplayMode'] = 'gallery';
    configureComicWidgets(
      tileImageProviderResolver: (comic) =>
          MemoryImage(base64Decode(comic.id == 'wide' ? _wide : _tall)),
    );
    addTearDown(() {
      configureComicWidgets();
      previous.forEach((key, value) => appdata.settings[key] = value);
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              SizedBox(
                width: 160,
                height: 220,
                child: ComicTile(
                  comic: _comic('wide'),
                  displayMode: ComicTileDisplayMode.gallery,
                ),
              ),
              SizedBox(
                width: 160,
                height: 220,
                child: ComicTile(
                  comic: _comic('tall'),
                  displayMode: ComicTileDisplayMode.gallery,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    final images = tester
        .widgetList<AnimatedImage>(find.byType(AnimatedImage))
        .toList();
    expect(images, hasLength(2));
    expect(
      images.map((image) => (image.image as MemoryImage).bytes.length),
      containsAll(<int>[
        base64Decode(_wide).length,
        base64Decode(_tall).length,
      ]),
    );
    expect(images.every((image) => image.fit == BoxFit.contain), isTrue);
  });

  testWidgets('unselected production card drags one route to tab strip', (
    tester,
  ) async {
    final opened = <WorkspaceRouteRecord>[];
    final route = WorkspaceRouteRecord(
      kind: WorkspacePageKind.home,
      arguments: const {'title': 'Home'},
    );
    final tab = WorkspaceTabRecord(routes: [route]);
    final record = WorkspaceRecord(
      directory: '/tmp/ux1-5-7',
      tabs: [tab],
      activeId: tab.id,
      recent: [tab.id],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: WorkspaceNavigationScope(
            openBackground: opened.add,
            child: Column(
              children: [
                WorkspaceTabStrip(
                  record: record,
                  activate: (_) {},
                  close: (_) {},
                  newTab: () {},
                  visited: {tab.id},
                  reorder: (_, _) {},
                  openBackground: opened.add,
                ),
                Expanded(
                  child: Center(
                    child: ComicTile(
                      comic: _comic('book-7'),
                      displayMode: ComicTileDisplayMode.gallery,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final card = find.byType(ComicTile);
    final tabStrip = find.byType(WorkspaceTabStrip);
    final gesture = await tester.startGesture(
      tester.getCenter(card),
      kind: PointerDeviceKind.mouse,
    );
    await gesture.moveTo(tester.getCenter(tabStrip));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(opened, hasLength(1));
    expect(opened.single.kind, WorkspacePageKind.comic);
    expect(opened.single.arguments['id'], 'book-7');
    expect(opened.single.arguments['sourceKey'], 'cover-ratio-fixture');
  });
}
