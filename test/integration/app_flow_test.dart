
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../lib/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('TC_INT_01 - Luồng đăng nhập và điều hướng sang Guides', (tester) async {

      app.main();
      await tester.pumpAndSettle();

      final emailField = find.byType(TextField).first;
      expect(emailField, findsOneWidget);

      await tester.enterText(emailField, 'test@gmail.com');
      await tester.pumpAndSettle();

      final loginButton = find.text('ĐĂNG NHẬP');
      if (loginButton.evaluate().isNotEmpty) {
        await tester.tap(loginButton);
        await tester.pumpAndSettle();
      }

      expect(find.byIcon(Icons.map), findsWidgets);
    });
  });
}
