import '../../../../core/error/result.dart';
import '../entities/course.dart';
import '../entities/home_feed.dart';

/// Contractul (interfața) stratului Domain.
/// Implementarea concretă se află în stratul Data (`LearningRepositoryImpl`),
/// deci Domain nu depinde de Data – dependența este inversată.
abstract interface class LearningRepository {
  Future<Result<HomeFeed>> getHomeFeed();

  Future<Result<Course>> getCourseDetails();
}
