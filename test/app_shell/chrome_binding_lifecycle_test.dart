import 'dart:io';
import 'package:flutter/material.dart';
import 'package:venera_next/foundation/app.dart';
import 'package:venera_next/features/favorites/favorites.dart';
import 'package:venera_next/features/favorites/favorites_scope.dart';
import 'package:venera_next/features/history/history.dart';
import 'package:venera_next/features/history/history_scope.dart';
import '../components/sidebar_presentation_test.dart' show settleSidebarWork;
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venera_next/app_shell/desktop_chrome.dart';
import 'package:venera_next/app_shell/main_page.dart';
import 'package:venera_next/components/navigation_bar.dart';
import 'package:venera_next/foundation/appdata.dart';

class _Chrome extends DesktopChromeController {
  final phases = <SchedulerPhase>[];
  final callbacks = <List<Object>>[];

  @override
  void bindGlobalActions({
    required VoidCallback openSettings,
    required VoidCallback openSearch,
    required void Function(int) navigate,
    required VoidCallback back,
  }) {
    phases.add(SchedulerBinding.instance.schedulerPhase);
    callbacks.add([openSettings, openSearch, navigate, back]);
    super.bindGlobalActions(
      openSettings: openSettings,
      openSearch: openSearch,
      navigate: navigate,
      back: back,
    );
  }
}

void main() {
  App.dataPath=App.cachePath=Directory.systemTemp.path;
  late LocalFavoritesManager favorites;
  late HistoryManager history;
  Widget scoped(Widget child)=>FavoritesScope(manager:favorites,child:HistoryScope(manager:history,child:child));
  setUp(() async {
    final path=App.dataPath,cache=App.cachePath;
    final implicit=Map<String,dynamic>.of(appdata.implicitData);
    final root=Directory.systemTemp.createTempSync('ux1-chrome-binding-');
    App.dataPath=App.cachePath=root.path;
    appdata.implicitData.clear();
    favorites=LocalFavoritesManager.independent();history=HistoryManager.create();
    await favorites.init();await history.init();
    addTearDown(() async {
      await appdata.writeImplicitData();
      await favorites.debugWaitForHashedIdsRefresh();favorites.close();history.close();
      appdata.implicitData=implicit;App.dataPath=path;App.cachePath=cache;root.deleteSync(recursive:true);
    });
    final settings = Map<String, dynamic>.from(
      appdata.toJson()['settings'] as Map,
    );
    appdata.settings['initialPage'] = '3';
    appdata.settings['language'] = 'en-US';
    addTearDown(
      () => settings.forEach((key, value) => appdata.settings[key] = value),
    );
  });

  testWidgets(
    'main page binds once after build and survives dependency rebuilds',
    (tester) async {
      final chrome = _Chrome();
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox());
        chrome.dispose();
      });
      final key = GlobalKey();
      Widget host(double scale) => MaterialApp(
        home: DesktopChromeScope(
          controller: chrome,
          child: Builder(
            builder: (_) {
              // Simulate repeated inherited dependency updates in the build
              // phase so the real StatefulElement invokes the lifecycle hook.
              final element = key.currentContext as StatefulElement?;
              element?.didChangeDependencies();
              element?.didChangeDependencies();
              return MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                child: scoped(MainPage(key: key)),
              );
            },
          ),
        ),
      );
      await tester.pumpWidget(host(1));
      expect(tester.takeException(), isNull);
      expect(chrome.phases, [SchedulerPhase.postFrameCallbacks]);
      expect(chrome.canNavigate, isTrue);
      await tester.pump();
      expect(chrome.phases, hasLength(1));
      // Force the real State's dependency lifecycle, plus an inherited rebuild.
      await tester.pumpWidget(host(1.1));
      await tester.pump();
      expect(chrome.phases, hasLength(1));
      expect(tester.takeException(), isNull);
      chrome.navigateTo(2);
      await tester.pump(const Duration(milliseconds:400));
      await settleSidebarWork(tester,()=>appdata.writeImplicitData());
      await tester.pumpAndSettle();
      expect(tester.state<NaviPaneState>(find.byType(NaviPane)).currentPage, 2);
      expect(chrome.phases, hasLength(1));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      expect(chrome.canNavigate, isFalse);
    },
  );

  testWidgets(
    'replacement controller receives the same stable callbacks after build',
    (tester) async {
      final first = _Chrome(), second = _Chrome();
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox());
        first.dispose();
        second.dispose();
      });
      final key = GlobalKey();
      Widget host(_Chrome chrome) => MaterialApp(
        home: DesktopChromeScope(
          controller: chrome,
          child: Builder(
            builder: (_) {
              (key.currentContext as StatefulElement?)?.didChangeDependencies();
              return scoped(MainPage(key: key));
            },
          ),
        ),
      );
      await tester.pumpWidget(host(first));
      expect(tester.takeException(), isNull);
      final state = key.currentState;
      await tester.pumpWidget(host(second));
      await tester.pump();
      expect(key.currentState, same(state));
      expect(first.phases, [SchedulerPhase.postFrameCallbacks]);
      expect(second.phases, [SchedulerPhase.postFrameCallbacks]);
      for (var i = 0; i < 4; i++) {
        expect(second.callbacks.single[i], same(first.callbacks.single[i]));
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
