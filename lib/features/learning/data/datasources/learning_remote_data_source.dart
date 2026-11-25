import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';
import '../models/course_details_model.dart';
import '../models/home_feed_model.dart';

/// Sursa de date la distanță: apelează serviciul REST și întoarce modele (DTO).
/// Aruncă excepții tehnice (ServerException, NetworkException, ...).
abstract interface class LearningRemoteDataSource {
  Future<HomeFeedModel> fetchHomeFeed();

  Future<CourseDetailsModel> fetchCourseDetails();
}

class LearningRemoteDataSourceImpl implements LearningRemoteDataSource {
  const LearningRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<HomeFeedModel> fetchHomeFeed() async {
    final json = await _apiClient.getJson(ApiConstants.feedPath);
    return HomeFeedModel.fromJson(json);
  }

  @override
  Future<CourseDetailsModel> fetchCourseDetails() async {
    final json = await _apiClient.getJson(ApiConstants.courseDetailsPath);
    return CourseDetailsModel.fromJson(json);
  }
}
