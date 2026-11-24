import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venera_next/components/settings_save_state.dart';
import 'package:venera_next/features/settings/appearance.dart';
import 'package:venera_next/features/settings/setting_components.dart';
import 'package:venera_next/foundation/app.dart';
import 'package:venera_next/foundation/appdata.dart';
import '../../components/sidebar_presentation_test.dart' show settleSidebarWork;

void main() {
  App.dataPath = App.cachePath = Directory.systemTemp.path;
  testWidgets(
    'real Appearance Reduce motion switch saves and reloads from disk',
    (tester) async {
      final root = Directory.systemTemp.createTempSync('ux1-f2-motion-');
      final oldPath = App.dataPath, oldCache = App.cachePath;
      final checkpoint = appdata.captureImportCheckpoint();
      App.dataPath = App.cachePath = root.path;
      appdata.settings['language'] = 'en-US';
      appdata.settings['reduceMotion'] = false;
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox());
        await settleSidebarWork(tester, () => appdata.saveData(false));
        await settleSidebarWork(
          tester,
          () => appdata.restoreImportCheckpoint(checkpoint, persist: false),
        );
        App.dataPath = oldPath;
        App.cachePath = oldCache;
        root.deleteSync(recursive: true);
      });
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AppearanceSettings())),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Reduce motion'), findsOneWidget);
      final setting = find.ancestor(
        of: find.text('Reduce motion'),
        matching: find.byType(SwitchSetting),
      );
      await tester.tap(
        find.descendant(of: setting, matching: find.byType(Switch)),
      );
      await tester.pump();
      await settleSidebarWork(
        tester,
        () => tester.state<SettingsSaveState>(setting).waitForSettingsSave(),
      );
      final disk =
          jsonDecode(File('${root.path}/appdata.json').readAsStringSync())
              as Map;
      expect(disk['settings']['reduceMotion'], isTrue);
      await tester.pumpWidget(const SizedBox());
      appdata.settings['reduceMotion'] = false;
      await settleSidebarWork(
        tester,
        () => appdata.loadDataForTesting(root.path),
      );
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AppearanceSettings())),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Switch>(
              find.descendant(
                of: find.ancestor(
                  of: find.text('Reduce motion'),
                  matching: find.byType(SwitchSetting),
                ),
                matching: find.byType(Switch),
              ),
            )
            .value,
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
