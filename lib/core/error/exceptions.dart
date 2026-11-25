/// Excepții tehnice aruncate în stratul Data (ApiClient / DataSource).
/// Repository-ul le prinde și le transformă în [Failure]-uri pentru Domain.
class ServerException implements Exception {
  const ServerException(this.statusCode, [this.message = 'Server error']);

  final int statusCode;
  final String message;

  @override
  String toString() => 'ServerException($statusCode): $message';
}

class NetworkException implements Exception {
  const NetworkException([this.message = 'No internet connection']);

  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

class ParsingException implements Exception {
  const ParsingException([this.message = 'Invalid JSON']);

  final String message;

  @override
  String toString() => 'ParsingException: $message';
}
