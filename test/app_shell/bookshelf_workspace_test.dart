import 'dart:io';
import '../components/sidebar_presentation_test.dart' show settleSidebarWork;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venera_next/components/navigation_bar.dart';
import 'package:venera_next/components/window_frame.dart';
import 'package:venera_next/components/desktop_chrome.dart';
import 'package:venera_next/components/bookshelf_workspace.dart';
import 'package:venera_next/design_system/tokens.dart';
import 'package:venera_next/foundation/app.dart';
import 'package:venera_next/foundation/appdata.dart';

void main() {
  testWidgets(
    'desktop bookshelf collapses and compact overlay preserves content',
    (tester) async {
      final directory = Directory.systemTemp.createTempSync('ux1-shell-');
      final previous = Map<String, dynamic>.of(appdata.implicitData);
      App.dataPath = directory.path;
      appdata.settings['language'] = 'en-US';
      appdata.implicitData.clear();
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1400, 900);
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox());
        await settleSidebarWork(tester, () => appdata.writeImplicitData());
        appdata.implicitData = previous;
        directory.deleteSync(recursive: true);
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      final navigator = GlobalKey<NavigatorState>();
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('window_manager'),
        (_) async => false,
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('window_manager'),
          null,
        ),
      );
      final chrome = DesktopChromeController();
      addTearDown(chrome.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: DesktopChromeScope(
            controller: chrome,
            child: WindowFrame(
              NaviPane(
                bookshelf: true,
                paneItems: [
                  PaneItemEntry(
                    label: 'Favorites',
                    icon: Icons.book_outlined,
                    activeIcon: Icons.book,
                  ),
                ],
                paneActions: const [],
                observer: NaviObserver(),
                navigatorKey: navigator,
                pageBuilder: (_) =>
                    const TextField(key: ValueKey('workspace-content')),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('workspace-content')),
        'retained selection',
      );
      final element = tester.element(
        find.byKey(const ValueKey('workspace-content')),
      );
      final workspaceToggle = find.descendant(
        of: find.byType(BookshelfWorkspace),
        matching: find.byTooltip('Toggle bookshelf'),
      );
      expect(workspaceToggle, findsOneWidget);
      expect(
        tester.getRect(workspaceToggle).top,
        greaterThanOrEqualTo(AppSizes.titleBarHeight),
      );
      expect(
        tester.getRect(find.byType(BookshelfWorkspace)).top,
        greaterThanOrEqualTo(AppSizes.titleBarHeight),
      );
      final expandedX = tester
          .getTopLeft(find.byKey(const ValueKey('workspace-content')))
          .dx;
      await tester.tap(workspaceToggle);
      await settleSidebarWork(tester, () => appdata.writeImplicitData());
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('workspace-content'))).dx,
        lessThan(expandedX),
      );
      tester.view.physicalSize = const Size(600, 900);
      await tester.pumpAndSettle();
      final compactRect = tester.getRect(
        find.byKey(const ValueKey('workspace-content')),
      );
      await tester.tap(workspaceToggle);
      await settleSidebarWork(tester, () => appdata.writeImplicitData());
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('bookshelf-scrim')), findsOneWidget);
      expect(
        tester.getRect(find.byKey(const ValueKey('workspace-content'))),
        compactRect,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('bookshelf-scrim')), findsNothing);
      tester.view.physicalSize = const Size(1400, 900);
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('workspace-content'))).dx,
        AppSpacing.xs,
      );
      expect(
        tester.element(find.byKey(const ValueKey('workspace-content'))),
        same(element),
      );
      expect(find.text('retained selection'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
