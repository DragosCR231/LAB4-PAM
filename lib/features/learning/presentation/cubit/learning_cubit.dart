import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_course_details.dart';
import '../../domain/usecases/get_home_feed.dart';
import 'learning_state.dart';

export 'learning_state.dart';

/// Stratul Presentation: Cubit-ul cunoaște doar use case-urile din Domain,
/// nu știe nimic despre HTTP, JSON sau URL-uri.
class LearningCubit extends Cubit<LearningState> {
  LearningCubit({required GetHomeFeed getHomeFeed, required GetCourseDetails getCourseDetails})
      : _getHomeFeed = getHomeFeed,
        _getCourseDetails = getCourseDetails,
        super(const LearningState());

  final GetHomeFeed _getHomeFeed;
  final GetCourseDetails _getCourseDetails;

  /// Pornește ambele request-uri în paralel (async) și așteaptă finalizarea lor.
  Future<void> load() => Future.wait([loadHome(), loadCourse()]);

  Future<void> loadHome() async {
    emit(state.copyWith(homeStatus: LoadStatus.loading, clearHomeError: true));
    final result = await _getHomeFeed();
    if (isClosed) return;
    result.fold(
      onFailure: (failure) => emit(state.copyWith(homeStatus: LoadStatus.error, homeError: failure.message)),
      onSuccess: (feed) => emit(state.copyWith(
        homeStatus: feed.planItems.isEmpty ? LoadStatus.empty : LoadStatus.success,
        feed: feed,
      )),
    );
  }

  Future<void> loadCourse() async {
    emit(state.copyWith(courseStatus: LoadStatus.loading, clearCourseError: true));
    final result = await _getCourseDetails();
    if (isClosed) return;
    result.fold(
      onFailure: (failure) => emit(state.copyWith(courseStatus: LoadStatus.error, courseError: failure.message)),
      onSuccess: (course) => emit(state.copyWith(
        courseStatus: course.lessons.isEmpty ? LoadStatus.empty : LoadStatus.success,
        course: course,
      )),
    );
  }

  void search(String query) => emit(state.copyWith(searchQuery: query));

  void setFilter(LessonFilter filter) => emit(state.copyWith(filter: filter));

  void setSort(LessonSort sort) => emit(state.copyWith(sort: sort));

  void setTab(String tab) => emit(state.copyWith(selectedTab: tab));

  void toggleFavorite(String id) {
    final favorites = Set<String>.from(state.favoriteIds);
    if (!favorites.add(id)) favorites.remove(id);
    emit(state.copyWith(favoriteIds: favorites));
  }

  void toggleCompleted(String id) {
    final lesson = state.lessonById(id);
    if (lesson == null || state.isLocked(lesson)) return;
    final completed = Set<String>.from(state.completedIds);
    if (!completed.add(id)) completed.remove(id);
    emit(state.copyWith(completedIds: completed));
  }

  void enroll() => emit(state.copyWith(enrolled: true));
}
