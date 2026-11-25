import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Răspunsuri reale salvate de la API (test/fixtures), ca testele să nu depindă de internet.
Map<String, dynamic> fixture(String name) =>
    jsonDecode(File('test/fixtures/$name.json').readAsStringSync()) as Map<String, dynamic>;

/// Un server HTTP fals: răspunde la /feed și /feed/details cu JSON-ul dat.
MockClient fakeApi({
  Map<String, dynamic>? feed,
  Map<String, dynamic>? details,
  int feedStatus = 200,
  int detailsStatus = 200,
}) =>
    MockClient((request) async {
      final path = request.url.path;
      if (path.endsWith('/v4/feed')) {
        return _json(feed ?? fixture('feed'), feedStatus);
      }
      if (path.endsWith('/v4/feed/details')) {
        return _json(details ?? fixture('details'), detailsStatus);
      }
      return http.Response('Not found', 404);
    });

http.Response _json(Map<String, dynamic> body, int status) => http.Response.bytes(
      utf8.encode(jsonEncode(body)),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
