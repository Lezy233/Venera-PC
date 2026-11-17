import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Real pointer hover and checkbox hit; never invokes a selection callback.
Future<void> toggleComicCheckbox(WidgetTester tester, Finder card) async {
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await mouse.addPointer(location: Offset.zero);
  await mouse.moveTo(tester.getCenter(card));
  await tester.pump();
  final checkbox = find.descendant(of: card, matching: find.byType(Checkbox));
  expect(checkbox.hitTestable(), findsOneWidget);
  await tester.tapAt(tester.getCenter(checkbox));
  await tester.pump();
  await mouse.removePointer();
  await tester.pump();
}
