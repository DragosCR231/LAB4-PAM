import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../error/exceptions.dart';
import 'api_constants.dart';

/// Client HTTP reutilizabil: trimite cererea GET, verifică codul de status
/// și decodează corpul răspunsului din JSON într-un `Map`.
class ApiClient {
  ApiClient({http.Client? client, this.baseUrl = ApiConstants.baseUrl}) : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  Future<Map<String, dynamic>> getJson(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final http.Response response;
    try {
      response = await _client.get(uri, headers: const {'Accept': 'application/json'}).timeout(ApiConstants.timeout);
    } on TimeoutException {
      rethrow;
    } on SocketException catch (error) {
      throw NetworkException(error.message);
    } on http.ClientException catch (error) {
      throw NetworkException(error.message);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ServerException(response.statusCode, response.reasonPhrase ?? 'Server error');
    }

    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const ParsingException('Expected a JSON object');
      }
      return decoded;
    } on FormatException catch (error) {
      throw ParsingException(error.message);
    }
  }

  void close() => _client.close();
}
