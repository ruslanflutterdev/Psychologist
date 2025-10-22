import 'dart:nativewrappers/_internal/vm/bin/vmservice_io.dart' as app;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth flows', () {
    setUpAll(() async {
    });

    testWidgets('Registration navigates to Home', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final email = find.byKey(const Key('register_email'));
      final password = find.byKey(const Key('register_password'));
      final confirm = find.byKey(const Key('register_confirm'));
      final registerBtn = find.byKey(const Key('register_button'));

      await tester.tap(email);
      await tester.enterText(email, 'test+${DateTime.now().millisecondsSinceEpoch}@example.com');
      await tester.tap(password);
      await tester.enterText(password, 'Password123!');
      await tester.tap(confirm);
      await tester.enterText(confirm, 'Password123!');
      await tester.tap(registerBtn);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('home_screen')), findsOneWidget);
    });
  });
}