import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:learning_api_v4/core/error/failures.dart';
import 'package:learning_api_v4/core/error/result.dart';
import 'package:learning_api_v4/core/network/api_client.dart';
import 'package:learning_api_v4/features/learning/data/datasources/learning_remote_data_source.dart';
import 'package:learning_api_v4/features/learning/data/models/course_details_model.dart';
import 'package:learning_api_v4/features/learning/data/models/home_feed_model.dart';
import 'package:learning_api_v4/features/learning/data/repositories/learning_repository_impl.dart';

import 'helpers.dart';

LearningRepositoryImpl _repository(http.Client client) =>
    LearningRepositoryImpl(LearningRemoteDataSourceImpl(ApiClient(client: client)));

void main() {
  group('JSON serialization', () {
    test('HomeFeedModel.fromJson parses the /feed response', () {
      final model = HomeFeedModel.fromJson(fixture('feed'));

      expect(model.header.greeting, 'Hi, Kristin');
      expect(model.header.notification.hasUnread, isTrue);
      expect(model.learnedToday.learnedMinutes, 46);
      expect(model.learningPlan.items, hasLength(2));
      expect(model.learningPlan.items.first.progress, closeTo(0.8333, 0.0001));
    });

    test('HomeFeedModel toJson -> fromJson keeps the same data', () {
      final model = HomeFeedModel.fromJson(fixture('feed'));
      final copy = HomeFeedModel.fromJson(model.toJson());
      expect(copy.toJson(), model.toJson());
    });

    test('CourseDetailsModel.fromJson parses the /feed/details response', () {
      final model = CourseDetailsModel.fromJson(fixture('details'));
      final course = model.toEntity();

      expect(course.title, 'React Front To back');
      expect(course.rating, 4.9);
      expect(course.lessons, hasLength(4));
      expect(course.lessons.last.locked, isTrue);
      expect(course.priceLabel, 'Free');
      expect(CourseDetailsModel.fromJson(model.toJson()).toJson(), model.toJson());
    });

    test('missing required field throws FormatException', () {
      final json = fixture('feed')..remove('header');
      expect(() => HomeFeedModel.fromJson(json), throwsFormatException);
    });
  });

  group('LearningRepositoryImpl', () {
    test('returns Ok with entities when the API answers 200', () async {
      final result = await _repository(fakeApi()).getHomeFeed();
      expect(result, isA<Ok>());
      expect((result as Ok).data.greeting, 'Hi, Kristin');
    });

    test('maps HTTP 500 to ServerFailure', () async {
      final result = await _repository(fakeApi(detailsStatus: 500)).getCourseDetails();
      expect((result as Err).failure, isA<ServerFailure>());
    });

    test('maps invalid JSON to ParsingFailure', () async {
      final client = MockClient((_) async => http.Response('<html>oops</html>', 200));
      final result = await _repository(client).getHomeFeed();
      expect((result as Err).failure, isA<ParsingFailure>());
    });

    test('maps connection errors to NetworkFailure', () async {
      final client = MockClient((_) async => throw http.ClientException('offline'));
      final result = await _repository(client).getHomeFeed();
      expect((result as Err).failure, isA<NetworkFailure>());
    });
  });
}
