import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venera_next/components/bookshelf_workspace.dart';
import 'package:venera_next/foundation/app.dart';
import 'package:venera_next/foundation/app_data_operations.dart';
import 'package:venera_next/foundation/appdata.dart';

void main() {
  testWidgets(
    'home bookshelf autosave keeps pending and success feedback out of shell',
    (tester) async {
      final root = Directory.systemTemp.createTempSync('ux1-home-save-');
      final oldData = Directory.systemTemp.path;
      final oldCache = Directory.systemTemp.path;
      final oldImplicit = Map<String, dynamic>.from(appdata.implicitData);
      App.dataPath = App.cachePath = root.path;
      appdata.implicitData = <String, dynamic>{};
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        App.dataPath = oldData;
        App.cachePath = oldCache;
        appdata.implicitData = oldImplicit;
        root.deleteSync(recursive: true);
      });

      await tester.pumpWidget(
        MaterialApp(
          home: BookshelfWorkspace(
            navigation: const SizedBox(),
            child: const Center(child: Text('Home content')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final release = Completer<void>();
      final exclusive = AppDataOperations.instance.run(() => release.future);
      await tester.tap(find.byTooltip('Toggle bookshelf'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Saved'), findsNothing);
      release.complete();
      await exclusive;
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Saved'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
