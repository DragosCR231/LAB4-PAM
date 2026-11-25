import '../../../../core/error/result.dart';
import '../entities/course.dart';
import '../repositories/learning_repository.dart';

/// Caz de utilizare: „obține detaliile cursului (lecții, preț, rating)”.
class GetCourseDetails {
  const GetCourseDetails(this._repository);

  final LearningRepository _repository;

  Future<Result<Course>> call() => _repository.getCourseDetails();
}
