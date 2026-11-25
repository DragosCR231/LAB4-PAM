/// Funcții mici pentru citirea sigură a valorilor din JSON.
/// Dacă un câmp obligatoriu lipsește sau are tip greșit se aruncă [FormatException],
/// pe care Repository-ul o transformă în `ParsingFailure`.
Map<String, dynamic> readMap(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is Map<String, dynamic>) return value;
  throw FormatException('Field "$key" must be a JSON object');
}

Map<String, dynamic> readOptionalMap(Map<String, dynamic> json, String key) {
  final value = json[key];
  return value is Map<String, dynamic> ? value : const <String, dynamic>{};
}

List<Map<String, dynamic>> readList(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is List) return value.whereType<Map<String, dynamic>>().toList();
  throw FormatException('Field "$key" must be a JSON array');
}

String readString(Map<String, dynamic> json, String key, {String? fallback}) {
  final value = json[key];
  if (value is String) return value;
  if (fallback != null) return fallback;
  throw FormatException('Field "$key" must be a string');
}

int readInt(Map<String, dynamic> json, String key, {int? fallback}) {
  final value = json[key];
  if (value is num) return value.toInt();
  if (fallback != null) return fallback;
  throw FormatException('Field "$key" must be a number');
}

double readDouble(Map<String, dynamic> json, String key, {double? fallback}) {
  final value = json[key];
  if (value is num) return value.toDouble();
  if (fallback != null) return fallback;
  throw FormatException('Field "$key" must be a number');
}

bool readBool(Map<String, dynamic> json, String key, {bool fallback = false}) {
  final value = json[key];
  return value is bool ? value : fallback;
}
