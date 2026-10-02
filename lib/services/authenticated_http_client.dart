import 'package:http/http.dart' as http;

import 'auth_session_manager.dart';
import 'session_store.dart';

class AuthenticatedHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final authorization = _authorizationHeader(request.headers);
    final accessToken = _bearerToken(authorization);
    if (accessToken == null) return _inner.send(request);

    final bodyBytes = await request.finalize().toBytes();
    final response = await _inner.send(_copyRequest(request, bodyBytes));
    if (response.statusCode != 401 ||
        request.url.path.endsWith('/api/auth/refresh')) {
      return response;
    }

    final bufferedResponse = await http.Response.fromStream(response);
    final refreshResult = await AuthSessionManager.instance
        .refreshAfterUnauthorized(accessToken);
    if (refreshResult != SessionRefreshResult.refreshed) {
      return _asStreamedResponse(bufferedResponse);
    }

    final nextAccessToken = await SessionStore.readToken();
    if (nextAccessToken == null || nextAccessToken.isEmpty) {
      return _asStreamedResponse(bufferedResponse);
    }
    final retry = _copyRequest(request, bodyBytes)
      ..headers['Authorization'] = 'Bearer $nextAccessToken';
    return _inner.send(retry);
  }

  @override
  void close() => _inner.close();

  String? _authorizationHeader(Map<String, String> headers) {
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == 'authorization') return entry.value;
    }
    return null;
  }

  String? _bearerToken(String? header) {
    if (header == null || !header.toLowerCase().startsWith('bearer ')) {
      return null;
    }
    final token = header.substring(7).trim();
    return token.isEmpty ? null : token;
  }

  http.Request _copyRequest(http.BaseRequest source, List<int> bodyBytes) {
    final copy = http.Request(source.method, source.url)
      ..followRedirects = source.followRedirects
      ..maxRedirects = source.maxRedirects
      ..persistentConnection = source.persistentConnection
      ..headers.addAll(source.headers)
      ..bodyBytes = bodyBytes;
    return copy;
  }

  http.StreamedResponse _asStreamedResponse(http.Response response) {
    return http.StreamedResponse(
      http.ByteStream.fromBytes(response.bodyBytes),
      response.statusCode,
      contentLength: response.contentLength,
      request: response.request,
      headers: response.headers,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );
  }
}
