import 'package:flutter_test/flutter_test.dart';
import 'package:nroq/services/app_version_service.dart';

void main() {
  group('AppVersionService.compareVersions', () {
    test('compares numeric segments rather than strings', () {
      expect(
        AppVersionService.compareVersions('1.10.0', '1.9.9'),
        greaterThan(0),
      );
      expect(AppVersionService.compareVersions('2.0.0', '2.0.1'), lessThan(0));
    });

    test('treats missing trailing segments as zero', () {
      expect(AppVersionService.compareVersions('1.2', '1.2.0'), 0);
    });
  });
}
