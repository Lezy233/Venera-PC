import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venera_next/features/comic_source/comic_source.dart';
import 'package:venera_next/features/comic_widgets/comic_widgets.dart';
import 'package:venera_next/features/settings/setting_components.dart';
import 'package:venera_next/foundation/app.dart';
import 'package:venera_next/foundation/appdata.dart';
import '../components/sidebar_presentation_test.dart' show settleSidebarWork;

void main() {
  testWidgets(
    'density control changes production cover grid without shrinking text',
    (tester) async {
      final root = Directory.systemTemp.createTempSync('ux1-density-');
      App.dataPath = App.cachePath = root.path;
      appdata.settings['language'] = 'en-US';
      appdata.settings['favoritesDensity'] = 'comfortable';
      appdata.settings['blockedWords'] = <String>[];
      configureComicWidgets(
        favoriteDisplayStateResolver: () =>
            const ComicFavoriteDisplayState(isGallery: true, galleryColumns: 0),
      );
      tester.view.physicalSize = const Size(1000, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox());
        await settleSidebarWork(tester, () => appdata.writeImplicitData());
        configureComicWidgets();
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        root.deleteSync(recursive: true);
      });
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const SelectSetting(
                  title: 'Favorite density',
                  settingKey: 'favoritesDensity',
                  optionTranslation: {
                    'comfortable': 'Comfortable',
                    'compact': 'Compact',
                  },
                ),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverGridComics(
                        useFavoriteDisplaySettings: true,
                        comics: List.generate(
                          12,
                          (i) => Comic(
                            'Long title $i with a readable second line',
                            '',
                            '$i',
                            'Visible author $i',
                            const [],
                            '',
                            'local',
                            null,
                            null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final comfortable = tester.getSize(find.byType(ComicTile).first);
      final initialFont = tester
          .widget<Text>(find.text('Long title 0 with a readable second line'))
          .style
          ?.fontSize;
      await tester.tap(find.text('Comfortable'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Compact').last);
      await settleSidebarWork(tester, () => appdata.writeImplicitData());
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byType(ComicTile).first).width,
        lessThan(comfortable.width),
      );
      expect(
        tester
            .widget<Text>(find.text('Long title 0 with a readable second line'))
            .style
            ?.fontSize,
        initialFont,
      );
      expect(find.text('Visible author 0'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
