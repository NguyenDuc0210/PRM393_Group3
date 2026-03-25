
import 'package:flutter_test/flutter_test.dart';
import 'package:lab/models/location.dart';

void main() {
  group('Unit Test - Location Model', () {
    test('Kiểm tra khởi tạo Location', () {
      final location = Location(
        id: 1, name: 'Hanoi', address: 'VN', description: 'Capital',
        countStar: 5, imageUrl: 'img.png', continent: 'asia'
      );

      expect(location.name, 'Hanoi');
      expect(location.isStarred, false);
    });

    test('Kiểm tra hàm copyWith', () {
      final location = Location(
        id: 1, name: 'Old', address: 'Add', description: 'Desc',
        countStar: 0, imageUrl: 'img.png', continent: 'asia'
      );

      final updated = location.copyWith(name: 'New');
      expect(updated.name, 'New');
    });
  });
}
