import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venera_next/components/select.dart';
import 'package:venera_next/components/settings_save_state.dart';
import 'package:venera_next/features/reader/brightness.dart';
import 'package:venera_next/features/reader/quick_settings_panel.dart';
import 'package:venera_next/features/reader/reader_mode_labels.dart';
import 'package:venera_next/features/reader/settings_effects.dart';
import 'package:venera_next/features/reader/settings_panel.dart';
import 'package:venera_next/features/settings/reader.dart';
import 'package:venera_next/features/settings/reader_presets.dart';
import 'package:venera_next/foundation/app.dart';
import 'package:venera_next/foundation/app_data_operations.dart';
import 'package:venera_next/foundation/appdata.dart';
import 'package:venera_next/foundation/context.dart';
import 'package:venera_next/foundation/image_work.dart';
import 'package:venera_next/foundation/log.dart';
import 'package:venera_next/foundation/reader_preference_store.dart';
import 'package:venera_next/foundation/reader_preferences.dart';
import 'package:venera_next/foundation/reader_presets.dart';

ReaderPreferenceStore _store([String comic = 'book']) => ReaderPreferenceStore(
  settings: appdata.settings,
  scope: ReaderPreferenceScope.comic,
  comicId: comic,
  sourceKey: 'local',
);

Future<void> _flush(WidgetTester tester, Future<void> future) async {
  var done = false;
  Object? error;
  future.then(
    (_) => done = true,
    onError: (Object failure) {
      error = failure;
      done = true;
    },
  );
  for (var i = 0; i < 500 && !done; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump();
  }
  expect(done, isTrue);
  expect(error, isNull);
  await tester.pump();
}

SettingsSaveState _owner(WidgetTester tester) =>
    tester.state<SettingsSaveState>(find.byType(ReaderQuickSettingsPanel));

Future<Directory> _open(
  WidgetTester tester, {
  bool Function()? isCurrent,
  ValueChanged<String>? onChanged,
}) async {
  final root = Directory.systemTemp.createTempSync('quick-settings-');
  final oldPath = App.dataPath, oldCache = App.cachePath;
  final previous = jsonDecode(jsonEncode(appdata.toJson()['settings'])) as Map;
  final muted = Log.isMuted;
  Log.isMuted = true;
  App.dataPath = App.cachePath = root.path;
  appdata.settings['deviceSpecificSettings'] = <String, dynamic>{};
  appdata.settings['comicSpecificSettings'] = <String, dynamic>{};
  appdata.settings['disableSyncFields'] = '';
  appdata.settings['autoReaderMode'] = false;
  appdata.settings['readerMode'] = 'waterfallTopToBottom';
  appdata.settings['readerBrightnessEnabled'] = false;
  appdata.settings['readerBrightness'] = 50;
  final preview = ReaderBrightnessPreview();
  final work = ImageWork();
  registerShowMessageHandler((_, _) {});
  tester.view.physicalSize = const Size(400, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.runAsync(work.dispose);
    preview.dispose();
    previous.forEach((key, value) => appdata.settings[key] = value);
    App.dataPath = oldPath;
    App.cachePath = oldCache;
    Log.isMuted = muted;
    root.deleteSync(recursive: true);
  });
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ReaderSettingsPanel(
          request: ReaderSettingsRequest(
            comicId: 'book',
            sourceKey: 'local',
            isCurrent: isCurrent ?? () => true,
            currentMode: () => _store().read(ReaderPreferences.readerMode),
            isDetectingLayout: () => false,
            detectLayout: () async {},
            applyReaderEffect: (_) {},
          ),
          work: work,
          brightnessPreview: preview,
          onChanged: onChanged ?? (_) {},
          isCurrent: isCurrent ?? () => true,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return root;
}

/// Preset records are global settings; every preset test starts and ends with a
/// clean library so later cases do not inherit earlier bindings.
void _isolatePresets(WidgetTester tester) {
  Object? presets = appdata.settings['readerModePresets'];
  Object? selections = appdata.settings['readerPresetSelections'];
  Object? bindings = appdata.settings['readerPresetBindings'];
  appdata.settings['readerModePresets'] = <dynamic>[];
  appdata.settings['readerPresetSelections'] = <String, dynamic>{};
  appdata.settings['readerPresetBindings'] = <String, dynamic>{};
  addTearDown(() {
    appdata.settings['readerModePresets'] = presets;
    appdata.settings['readerPresetSelections'] = selections;
    appdata.settings['readerPresetBindings'] = bindings;
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  App.dataPath = App.cachePath = Directory.systemTemp.path;
  testWidgets('seven quick controls and comic scope replace the full list', (
    tester,
  ) async {
    await _open(tester);
    expect(readerQuickSettings, hasLength(7));
    expect(readerQuickSettings.toSet(), hasLength(7));
    expect(find.byType(ReaderSettings), findsNothing);
    expect(find.text('Scope: This comic'), findsOneWidget);
    expect(find.text('Number of images preloaded'), findsNothing);
    expect(find.byType(SwitchListTile), findsNWidgets(5));
    expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(2));
    final slider = tester.getRect(find.byType(Slider));
    expect(slider.top, greaterThan(0));
    expect(slider.bottom, lessThan(700));
    expect(tester.getRect(find.text('All settings')).bottom, lessThan(700));
    expect(tester.takeException(), isNull);
  });

  testWidgets('brightness previews immediately while its comic save waits', (
    tester,
  ) async {
    await _open(tester);
    final preview = tester
        .widget<ReaderQuickSettingsPanel>(find.byType(ReaderQuickSettingsPanel))
        .brightnessPreview;
    final sliderPosition = tester.getTopLeft(find.byType(Slider));
    final release = Completer<void>();
    final exclusive = AppDataOperations.instance.run(() => release.future);
    addTearDown(() {
      if (!release.isCompleted) release.complete();
    });
    tester.widget<Slider>(find.byType(Slider)).onChanged!(80);
    await tester.pump();
    expect(preview.brightness, 80);
    expect(preview.enabled, isTrue);
    expect(find.text('80%'), findsOneWidget);
    expect(tester.getTopLeft(find.byType(Slider)), sliderPosition);
    expect(appdata.settings['readerBrightness'], 50);
    release.complete();
    await _flush(
      tester,
      Future.wait([exclusive, _owner(tester).waitForSettingsSave()]),
    );
    expect(_store().read(ReaderPreferences.readerBrightness), 80);
    expect(_store().read(ReaderPreferences.readerBrightnessEnabled), isTrue);
    expect(_store('other').read(ReaderPreferences.readerBrightness), 50);
    expect(appdata.settings['readerBrightness'], 50);
    expect(preview.brightness, isNull);
    expect(preview.enabled, isNull);
    expect(tester.getTopLeft(find.byType(Slider)), sliderPosition);
  });

  testWidgets(
    'mode uses the full page override and changes reflect both ways',
    (tester) async {
      await _open(tester);
      appdata.settings.setComicReaderModeOverride('book', 'local', null);
      await tester.pump();
      final dropdown = find.byType(DropdownButtonFormField<String>).first;
      tester.widget<DropdownButtonFormField<String>>(dropdown).onChanged!(
        'galleryLeftToRight',
      );
      await _flush(tester, _owner(tester).waitForSettingsSave());
      expect(
        appdata.settings.comicReaderModeOverride('book', 'local'),
        'galleryLeftToRight',
      );
      expect(_store().read(ReaderPreferences.readerMode), 'galleryLeftToRight');
      expect(
        appdata.settings.isComicSpecificSettingsEnabled('book', 'local'),
        isFalse,
      );
      expect(appdata.settings['readerMode'], 'waterfallTopToBottom');
      await tester.tap(find.text('All settings'));
      await tester.pumpAndSettle();
      expect(find.byType(ReaderSettings), findsOneWidget);
      final scope = tester.widget<SegmentedButton<ReaderSettingsScope>>(
        find.byType(SegmentedButton<ReaderSettingsScope>),
      );
      expect(scope.selected, {ReaderSettingsScope.comic});
      final mode = find.byWidgetPredicate(
        (w) =>
            w is Select && w.current == readerModeLabels['galleryLeftToRight'],
      );
      expect(mode, findsOneWidget);
      tester.widget<Select>(mode).onTap!(
        ['default', ...readerModeLabels.keys].indexOf('continuousTopToBottom'),
      );
      await _flush(tester, appdata.saveData(false));
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.byType(ReaderQuickSettingsPanel), findsOneWidget);
      expect(
        tester.widget<DropdownButtonFormField<String>>(dropdown).initialValue,
        'continuousTopToBottom',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('remaining toggles use their existing comic preference keys', (
    tester,
  ) async {
    final changed = <String>[];
    final root = await _open(tester, onChanged: changed.add);
    for (final title in [
      'Reverse tap to turn Pages',
      'Double tap to zoom',
      'Page animation',
      'Thumbnails',
    ]) {
      final tile = tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, title),
      );
      tile.onChanged!(!tile.value);
      await _flush(tester, _owner(tester).waitForSettingsSave());
    }
    expect(changed, [
      'reverseTapToTurnPages',
      'enableDoubleTapToZoom',
      'enablePageAnimation',
      'readerThumbnailState',
    ]);
    final saved =
        jsonDecode(File('${root.path}/appdata.json').readAsStringSync()) as Map;
    final settings = saved['settings'] as Map;
    final records = settings['comicSpecificSettings'] as Map;
    final comic = records['book@local'] as Map;
    expect(comic['enabled'], isTrue);
    expect(comic['reverseTapToTurnPages'], isTrue);
    expect(comic['enableDoubleTapToZoom'], isFalse);
    expect(comic['enablePageAnimation'], isFalse);
    expect(comic['readerThumbnailState'], 'collapsed');
    expect(records.containsKey('other@local'), isFalse);
  });

  testWidgets('failed save retries and repairs the original comic assignment', (
    tester,
  ) async {
    final root = await _open(tester);
    final blocked = Directory('${root.path}/appdata.json')..createSync();
    tester.widget<Slider>(find.byType(Slider)).onChanged!(35);
    for (var i = 0; i < 500 && find.text('Retry').evaluate().isEmpty; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
    }
    expect(find.text('Retry'), findsOneWidget);
    blocked.deleteSync();
    await tester.tap(find.text('Retry'));
    await _flush(tester, _owner(tester).waitForSettingsSave());
    expect(_store().read(ReaderPreferences.readerBrightness), 35);
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('retired request rejects edits and all-settings navigation', (
    tester,
  ) async {
    var current = true;
    final changed = <String>[];
    await _open(tester, isCurrent: () => current, onChanged: changed.add);
    final callback = tester
        .widget<DropdownButtonFormField<String>>(
          find.byType(DropdownButtonFormField<String>).first,
        )
        .onChanged!;
    current = false;
    callback('galleryLeftToRight');
    await tester.tap(find.text('All settings'));
    await tester.pumpAndSettle();
    expect(changed, isEmpty);
    expect(appdata.settings.comicReaderModeOverride('book', 'local'), isNull);
    expect(find.byType(ReaderSettings), findsNothing);
  });

  testWidgets('failed preset selection offers retry and keeps recovery', (
    tester,
  ) async {
    final root = await _open(tester);
    _isolatePresets(tester);
    final comicStore = ReaderPresetStore(
      scope: ReaderPreferenceScope.comic,
      comicId: 'book',
      sourceKey: 'local',
    );
    await tester.runAsync(() => comicStore.createFromCurrent('Reader wide'));
    await tester.pumpAndSettle();
    final preset = comicStore.list.single;
    await tester.runAsync(() => appdata.saveData(false));
    final dataFile = File('${root.path}/appdata.json');
    if (dataFile.existsSync()) dataFile.deleteSync();
    final blocked = Directory('${root.path}/appdata.json')..createSync();
    final selectorFind = find.byType(ReaderPresetSelector);
    final dropdown = find.byWidgetPredicate(
      (widget) =>
          widget is DropdownButtonFormField<String> &&
          widget.decoration.labelText == 'Preset',
    );
    tester.widget<DropdownButtonFormField<String>>(dropdown).onChanged!(
      preset.id,
    );
    for (var i = 0; i < 500 && find.text('Retry').evaluate().isEmpty; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
    }
    expect(find.text('Retry'), findsOneWidget);
    expect(comicStore.selectedId, isNull);
    expect(comicStore.recovery, isNotNull);
    blocked.deleteSync();
    await tester.tap(find.text('Retry'));
    await _flush(
      tester,
      tester.state<SettingsSaveState>(selectorFind).waitForSettingsSave(),
    );
    expect(find.text('Retry'), findsNothing);
    expect(comicStore.recovery, isNull);
    // B3: retrying recovery persists the restored valid state and must not
    // replay the failed preset application by itself.
    expect(comicStore.selectedId, isNull);
    expect(
      tester.widget<DropdownButtonFormField<String>>(dropdown).initialValue,
      '',
    );
    // An explicit new selection then saves normally.
    tester.widget<DropdownButtonFormField<String>>(dropdown).onChanged!(
      preset.id,
    );
    await _flush(
      tester,
      tester.state<SettingsSaveState>(selectorFind).waitForSettingsSave(),
    );
    expect(comicStore.selectedId, preset.id);
    await tester.runAsync(() => appdata.saveData(false));
    expect(appdata.settings.readerPresetId(comicStore.selectionKey), preset.id);
    expect(tester.takeException(), isNull);
  });

  testWidgets('clearing the quick panel preset selection persists', (
    tester,
  ) async {
    await _open(tester);
    _isolatePresets(tester);
    final comicStore = ReaderPresetStore(
      scope: ReaderPreferenceScope.comic,
      comicId: 'book',
      sourceKey: 'local',
    );
    await tester.runAsync(() => comicStore.createFromCurrent('Reader wide'));
    await tester.pumpAndSettle();
    final preset = comicStore.list.single;
    await tester.runAsync(() => comicStore.apply(preset.id, comicStore.scope));
    await tester.pumpAndSettle();
    final selector = tester.state<SettingsSaveState>(
      find.byType(ReaderPresetSelector),
    );
    expect(comicStore.selectedId, preset.id);
    final dropdown = find.byWidgetPredicate(
      (widget) =>
          widget is DropdownButtonFormField<String> &&
          widget.decoration.labelText == 'Preset',
    );
    tester.widget<DropdownButtonFormField<String>>(dropdown).onChanged!('');
    await _flush(tester, selector.waitForSettingsSave());
    expect(comicStore.selectedId, isNull);
    expect(
      tester.widget<DropdownButtonFormField<String>>(dropdown).initialValue,
      '',
    );
    await tester.runAsync(() => appdata.saveData(false));
    expect(appdata.settings.readerPresetId(comicStore.selectionKey), isNull);
  });

  testWidgets('preset selection survives quick panel close and disk reload', (
    tester,
  ) async {
    final root = await _open(tester);
    _isolatePresets(tester);
    final comicStore = ReaderPresetStore(
      scope: ReaderPreferenceScope.comic,
      comicId: 'book',
      sourceKey: 'local',
    );
    appdata.settings['readerMode'] = 'waterfallTopToBottom';
    await tester.runAsync(() => comicStore.createFromCurrent('Reader wide'));
    await tester.pumpAndSettle();
    final preset = comicStore.list.single;
    expect(preset.name, 'Reader wide');

    // Select through the real dropdown in the quick panel.
    await tester.tap(find.byType(DropdownButtonFormField<String>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reader wide').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    // The preset selection is owned by the selector's save state; the real
    // disk write needs runAsync before frames can settle.
    await _flush(
      tester,
      tester
          .state<SettingsSaveState>(find.byType(ReaderPresetSelector))
          .waitForSettingsSave(),
    );
    await tester.pumpAndSettle();

    expect(comicStore.selectedId, preset.id);
    expect(comicStore.list, hasLength(1));

    // Closing and reopening the quick panel keeps the persisted selection.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    final preview = ReaderBrightnessPreview();
    addTearDown(preview.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReaderQuickSettingsPanel(
            comicId: 'book',
            sourceKey: 'local',
            brightnessPreview: preview,
            isCurrent: () => true,
            onChanged: (_) {},
            onAllSettings: () async {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<DropdownButtonFormField<String>>(
            find.byType(DropdownButtonFormField<String>).last,
          )
          .initialValue,
      preset.id,
    );

    // The selection is on disk, not only in this widget's state.
    await tester.runAsync(() => appdata.saveData(false));
    final saved =
        jsonDecode(File('${root.path}/appdata.json').readAsStringSync()) as Map;
    final settings = saved['settings'] as Map;
    final selections = settings['readerPresetSelections'] as Map;
    expect(selections.values, contains(preset.id));
    final bindings = settings['readerPresetBindings'] as Map;
    expect(bindings.values, contains(preset.id));
    expect(appdata.settings.readerPresetId(comicStore.selectionKey), preset.id);
    expect(tester.takeException(), isNull);
  });
}
