import 'package:flutter_test/flutter_test.dart';
import 'package:nroq/models/profile_models.dart';

void main() {
  test('profile JSON does not contain authentication tokens', () {
    final user = UserProfile.fromJson({
      'token': 'access-secret',
      'refreshToken': 'refresh-secret',
      'id': 1,
      'username': 'tester',
    });

    final persistedProfile = user.toJson();

    expect(persistedProfile.containsKey('token'), isFalse);
    expect(persistedProfile.containsKey('refreshToken'), isFalse);
  });
}
