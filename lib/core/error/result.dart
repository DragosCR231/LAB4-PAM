import 'failures.dart';

/// Rezultatul unei operații: fie [Ok] cu date, fie [Err] cu un [Failure].
/// Astfel, Presentation nu prinde excepții – doar tratează cele două cazuri.
sealed class Result<T> {
  const Result();

  R fold<R>({required R Function(Failure failure) onFailure, required R Function(T data) onSuccess}) => switch (this) {
        Ok<T>(:final data) => onSuccess(data),
        Err<T>(:final failure) => onFailure(failure),
      };
}

class Ok<T> extends Result<T> {
  const Ok(this.data);

  final T data;
}

class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}
