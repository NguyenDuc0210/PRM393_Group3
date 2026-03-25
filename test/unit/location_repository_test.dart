
import 'package:flutter_test/flutter_test.dart';
import 'package:lab/models/location.dart';

void main() {
  group('LAB 11.1 - Repository Unit Tests', () {
    test('Kiểm tra dữ liệu mẫu từ Repository', () {

      final locations = Location.sampleLocations;

      final tokyo = locations.firstWhere((l) => l.name == 'Tokyo');

      expect(tokyo.continent, 'asia');
      expect(tokyo.id, 200);
    });
  });
}
