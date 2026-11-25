import 'package:http/http.dart' as http;

import 'core/network/api_client.dart';
import 'features/learning/data/datasources/learning_remote_data_source.dart';
import 'features/learning/data/repositories/learning_repository_impl.dart';
import 'features/learning/domain/repositories/learning_repository.dart';
import 'features/learning/domain/usecases/get_course_details.dart';
import 'features/learning/domain/usecases/get_home_feed.dart';
import 'features/learning/presentation/cubit/learning_cubit.dart';

/// Compoziția dependențelor (Dependency Injection manual).
/// Aici se „leagă” straturile: ApiClient -> DataSource -> Repository -> UseCases -> Cubit.
/// Pentru teste se poate trimite un `http.Client` fals (MockClient).
LearningCubit createLearningCubit({http.Client? httpClient}) {
  final apiClient = ApiClient(client: httpClient);
  final LearningRemoteDataSource remote = LearningRemoteDataSourceImpl(apiClient);
  final LearningRepository repository = LearningRepositoryImpl(remote);
  return LearningCubit(
    getHomeFeed: GetHomeFeed(repository),
    getCourseDetails: GetCourseDetails(repository),
  );
}
