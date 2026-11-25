/// Erori „de business” pe care stratul Domain le expune către Presentation.
/// Nu depind de HTTP sau JSON – conțin doar un mesaj prietenos pentru utilizator.
sealed class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure(this.statusCode)
      : super('The server responded with an error ($statusCode). Please try again later.');

  final int statusCode;
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('Could not reach the server. Check your internet connection and try again.');
}

class TimeoutFailure extends Failure {
  const TimeoutFailure() : super('The server took too long to respond. Please try again.');
}

class ParsingFailure extends Failure {
  const ParsingFailure() : super('The server sent data in an unexpected format.');
}
