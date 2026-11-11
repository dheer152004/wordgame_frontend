import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nroq/services/backend_api.dart';

void main() {
  setUp(() {
    dotenv.loadFromString(
      envString: 'BACKEND_API_BASE_URL=https://test.example',
    );
  });

  test('submits a category request with authenticated JSON headers', () async {
    http.Request? submittedRequest;
    final api = BackendApi.withClient(
      MockClient((request) async {

        submittedRequest = request;
        return http.Response('', 201);
      }),
      authorizationHeaders: () async => {'Authorization': 'Bearer jwt_token'},
    );

    await api.requestCategory(
      categoryName: '  Toolbox ',
      description: ' Toolbox related words ',
    );

    expect(submittedRequest, isNotNull);
    expect(submittedRequest!.method, 'POST');
    expect(submittedRequest!.url.path, '/api/user-requests');
    expect(submittedRequest!.headers['accept'], 'application/json');
    expect(submittedRequest!.headers['content-type'], 'application/json');
    expect(submittedRequest!.headers['authorization'], 'Bearer jwt_token');
    expect(jsonDecode(submittedRequest!.body), {
      'categoryName': 'Toolbox',
      'description': 'Toolbox related words',
    });
  });
}
