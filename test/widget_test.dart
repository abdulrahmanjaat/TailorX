// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tailorx_app/main.dart';

void main() {
  testWidgets('renders TailorX splash tagline', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TailorXApp()));

    expect(find.text('Crafted precision for modern ateliers'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
  });
}
