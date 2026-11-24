import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venera_next/app_shell/desktop_chrome.dart';

void main() {
  testWidgets(
    'reader callbacks revoke immediately during build but notify after frame and never after disposal',
    (tester) async {
      final controller = DesktopChromeController();
      final actions = DesktopReaderActions(
        openSettings: () {},
        openChapters: () {},
        toggleThumbnails: () {},
        filterChapters: (_) {},
        submitChapterSearch: (_) {},
      );
      controller.setReaderActions(actions);
      final phases = <SchedulerPhase>[];
      controller.addListener(
        () => phases.add(SchedulerBinding.instance.schedulerPhase),
      );
      await tester.pumpWidget(
        Builder(
          builder: (_) {
            DesktopChromeScope.setReaderActions(controller, null);
            expect(controller.readerActions, isNull);
            expect(phases, isEmpty);
            return const SizedBox();
          },
        ),
      );
      expect(phases, [SchedulerPhase.postFrameCallbacks]);
      await tester.pumpWidget(
        Builder(
          builder: (_) {
            DesktopChromeScope.setReaderActions(controller, actions);
            expect(controller.readerActions, same(actions));
            controller.dispose();
            return const SizedBox();
          },
        ),
      );
      expect(phases, [SchedulerPhase.postFrameCallbacks]);
      expect(tester.takeException(), isNull);
    },
  );
}
