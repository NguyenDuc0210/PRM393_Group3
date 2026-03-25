
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lab/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('TC_INT_01 - Luồng truy cập ẩn danh và kiểm tra Navigation', (tester) async {
      app.main();

      final guestButtonFinder = find.text('TIẾP TỤC KHÔNG ĐĂNG NHẬP');
      
      bool foundLogin = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (guestButtonFinder.evaluate().isNotEmpty) {
          foundLogin = true;
          break;
        }
      }
      expect(foundLogin, true, reason: "Không tìm thấy màn hình Login sau 20s");

      await tester.tap(guestButtonFinder);

      bool foundMain = false;
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.text('Guides').evaluate().isNotEmpty) {
          foundMain = true;
          break;
        }
      }
      expect(foundMain, true, reason: "Không vào được MainScreen sau khi nhấn nút");

      expect(find.byIcon(Icons.map), findsWidgets);

      final toursTab = find.text('Tours');
      await tester.tap(toursTab);

      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byIcon(Icons.calendar_month), findsWidgets);
      
      print('Integration Test Passed Successfully!');
    });
  });
}
