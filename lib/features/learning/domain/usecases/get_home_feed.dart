import '../../../../core/error/result.dart';
import '../entities/home_feed.dart';
import '../repositories/learning_repository.dart';

/// Caz de utilizare: „obține datele pentru ecranul Home”.
class GetHomeFeed {
  const GetHomeFeed(this._repository);

  final LearningRepository _repository;

  Future<Result<HomeFeed>> call() => _repository.getHomeFeed();
}
