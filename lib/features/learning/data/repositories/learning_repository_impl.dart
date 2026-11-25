import 'dart:async';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/home_feed.dart';
import '../../domain/repositories/learning_repository.dart';
import '../datasources/learning_remote_data_source.dart';

/// Implementarea contractului din Domain:
/// 1) cere date de la DataSource, 2) transformă DTO -> Entity,
/// 3) transformă excepțiile tehnice în Failure-uri.
class LearningRepositoryImpl implements LearningRepository {
  const LearningRepositoryImpl(this._remote);

  final LearningRemoteDataSource _remote;

  @override
  Future<Result<HomeFeed>> getHomeFeed() => _guard(() async => (await _remote.fetchHomeFeed()).toEntity());

  @override
  Future<Result<Course>> getCourseDetails() => _guard(() async => (await _remote.fetchCourseDetails()).toEntity());

  Future<Result<T>> _guard<T>(Future<T> Function() request) async {
    try {
      return Ok(await request());
    } on ServerException catch (error) {
      return Err(ServerFailure(error.statusCode));
    } on NetworkException {
      return const Err(NetworkFailure());
    } on TimeoutException {
      return const Err(TimeoutFailure());
    } on ParsingException {
      return const Err(ParsingFailure());
    } on FormatException {
      return const Err(ParsingFailure());
    } on TypeError {
      return const Err(ParsingFailure());
    }
  }
}
