import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venera_next/components/bookshelf_workspace.dart';
import 'package:venera_next/components/settings_save_state.dart';
import 'package:venera_next/foundation/app.dart';
import 'package:venera_next/foundation/context.dart';
import 'package:venera_next/foundation/appdata.dart';
import 'package:venera_next/foundation/translations.dart';
import '../components/sidebar_presentation_test.dart' show settleSidebarWork;

void main() {
  for (final width in [600.0, 1000.0, 1400.0]) {
    for (final dark in [false, true]) {
      for (final locale in ['zh-CN', 'zh-TW']) {
        for (final reduced in [false, true]) {
          testWidgets(
            'shell width=$width dark=$dark $locale text150 reduced=$reduced',
            (tester) async {
              final root = Directory.systemTemp.createTempSync('ux1-matrix-');
              App.dataPath = root.path;
              final old = Map<String, dynamic>.of(appdata.implicitData);
              appdata.implicitData.clear();
              appdata.settings['language'] = locale;
              await AppTranslation.init();
              tester.view.physicalSize = Size(width, 900);
              tester.view.devicePixelRatio = 1;
              addTearDown(() async {
                await tester.pumpWidget(const SizedBox());
                await settleSidebarWork(
                  tester,
                  () => appdata.writeImplicitData(),
                );
                appdata.implicitData = old;
                root.deleteSync(recursive: true);
                tester.view.resetPhysicalSize();
                tester.view.resetDevicePixelRatio();
              });
              final focus = FocusNode();
              addTearDown(focus.dispose);
              await tester.pumpWidget(
                MaterialApp(
                  theme: ThemeData(
                    brightness: dark ? Brightness.dark : Brightness.light,
                  ),
                  home: MediaQuery(
                    data: MediaQueryData(
                      size: Size(width, 900),
                      textScaler: const TextScaler.linear(1.5),
                      disableAnimations: reduced,
                    ),
                    child: BookshelfWorkspace(
                      navigation: ListView(
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: Text('Favorites'.tl),
                          ),
                        ],
                      ),
                      child: Material(child: TextField(focusNode: focus)),
                    ),
                  ),
                ),
              );
              await tester.pumpAndSettle();
              final label = 'Toggle bookshelf'.tl;
              final content = tester.element(find.byType(TextField));
              final before = tester.getRect(find.byType(TextField));
              // Keyboard activates the actual button, not an exposed callback.
              await tester.sendKeyEvent(LogicalKeyboardKey.tab);
              await tester.sendKeyEvent(LogicalKeyboardKey.space);
              await settleSidebarWork(
                tester,
                () => appdata.writeImplicitData(),
              );
              await tester.pumpAndSettle();
              if (width < 720) {
                expect(tester.getRect(find.byType(TextField)), before);
                await tester.sendKeyEvent(LogicalKeyboardKey.escape);
                await tester.pumpAndSettle();
                expect(
                  find.byKey(const ValueKey('bookshelf-scrim')),
                  findsNothing,
                );
                await tester.tap(find.byTooltip(label));
                await tester.pumpAndSettle();
                await tester.tapAt(Offset(width - 10, 400));
                await tester.pumpAndSettle();
                expect(
                  find.byKey(const ValueKey('bookshelf-scrim')),
                  findsNothing,
                );
              }
              expect(tester.element(find.byType(TextField)), same(content));
              expect(tester.takeException(), isNull);
            },
          );
        }
      }
    }
  }
  testWidgets(
    'real disk write failure is visible, retry saves latest intent and disk reload restores it',
    (tester) async {
      final root = Directory.systemTemp.createTempSync('ux1-write-fault-');
      App.dataPath = root.path;
      appdata.settings['language'] = 'en-US';
      final old = Map<String, dynamic>.of(appdata.implicitData);
      appdata.implicitData = {'unrelated': 42};
      registerShowMessageHandler((_, _) {});
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      final temp = Directory('${root.path}/implicitData.json.tmp')
        ..createSync();
      addTearDown(() async {
        if (temp.existsSync()) temp.deleteSync();
        await tester.pumpWidget(const SizedBox());
        await settleSidebarWork(tester, () => appdata.writeImplicitData());
        appdata.implicitData = old;
        root.deleteSync(recursive: true);
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      Widget tree() => const MaterialApp(
        home: BookshelfWorkspace(
          navigation: Text('navigation'),
          child: Material(child: TextField()),
        ),
      );
      await tester.pumpWidget(tree());
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Toggle bookshelf'));
      final state = tester.state<SettingsSaveState>(
        find.byType(BookshelfWorkspace),
      );
      await settleSidebarWork(tester, () async {
        try {
          await state.waitForSettingsSave();
        } catch (_) {}
      });
      await tester.pumpAndSettle();
      expect(find.text('Retry'), findsOneWidget);
      expect(File('${root.path}/implicitData.json').existsSync(), isFalse);
      temp.deleteSync();
      // New intent supersedes the failed assignment; no stale retry may invert it.
      await tester.tap(find.byTooltip('Toggle bookshelf'));
      await settleSidebarWork(tester, () => state.waitForSettingsSave());
      await tester.pumpAndSettle();
      expect(find.text('Retry'), findsNothing);
      final disk =
          jsonDecode(File('${root.path}/implicitData.json').readAsStringSync())
              as Map<String, dynamic>;
      expect(disk['bookshelfExpanded'], isTrue);
      expect(disk['unrelated'], 42);
      await tester.tap(find.byTooltip('Toggle bookshelf'));
      await settleSidebarWork(tester, () => state.waitForSettingsSave());
      await tester.pumpWidget(const SizedBox());
      appdata.implicitData =
          jsonDecode(File('${root.path}/implicitData.json').readAsStringSync())
              as Map<String, dynamic>;
      await tester.pumpWidget(tree());
      await tester.pumpAndSettle();
      expect(find.text('navigation'), findsNothing);
      expect(tester.getTopLeft(find.byType(TextField)).dx, 0);
      expect(tester.takeException(), isNull);
    },
  );
}
