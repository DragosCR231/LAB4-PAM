import '../../domain/entities/course.dart';
import '../../domain/entities/home_feed.dart';

enum LoadStatus { initial, loading, success, empty, error }

enum LessonFilter { all, available, favorites, completed }

enum LessonSort { original, title, duration }

/// Starea UI. Cele două surse (feed și detalii curs) au stări de încărcare
/// și erori independente, deoarece vin din două request-uri HTTP diferite.
class LearningState {
  const LearningState({
    this.homeStatus = LoadStatus.initial,
    this.courseStatus = LoadStatus.initial,
    this.feed,
    this.course,
    this.homeError,
    this.courseError,
    this.searchQuery = '',
    this.filter = LessonFilter.all,
    this.sort = LessonSort.original,
    this.favoriteIds = const {},
    this.completedIds = const {},
    this.selectedTab = 'lessons',
    this.enrolled = false,
  });

  final LoadStatus homeStatus;
  final LoadStatus courseStatus;
  final HomeFeed? feed;
  final Course? course;
  final String? homeError;
  final String? courseError;
  final String searchQuery;
  final LessonFilter filter;
  final LessonSort sort;
  final Set<String> favoriteIds;
  final Set<String> completedIds;
  final String selectedTab;
  final bool enrolled;

  bool get isHomeLoading => homeStatus == LoadStatus.initial || homeStatus == LoadStatus.loading;

  bool get isCourseLoading => courseStatus == LoadStatus.initial || courseStatus == LoadStatus.loading;

  Lesson? lessonById(String id) {
    for (final lesson in course?.lessons ?? const <Lesson>[]) {
      if (lesson.id == id) return lesson;
    }
    return null;
  }

  bool isCompleted(Lesson lesson) => lesson.completed || completedIds.contains(lesson.id);

  bool isLocked(Lesson lesson) => lesson.locked && !enrolled;

  List<Lesson> get visibleLessons {
    final lessons = course?.lessons;
    if (lessons == null) return const [];
    final query = searchQuery.trim().toLowerCase();
    final result = lessons.where((lesson) {
      final matchesQuery = lesson.title.toLowerCase().contains(query);
      final matchesFilter = switch (filter) {
        LessonFilter.all => true,
        LessonFilter.available => !isLocked(lesson),
        LessonFilter.favorites => favoriteIds.contains(lesson.id),
        LessonFilter.completed => isCompleted(lesson),
      };
      return matchesQuery && matchesFilter;
    }).toList();

    switch (sort) {
      case LessonSort.original:
        break;
      case LessonSort.title:
        result.sort((a, b) => a.title.compareTo(b.title));
      case LessonSort.duration:
        result.sort((a, b) => a.durationSeconds.compareTo(b.durationSeconds));
    }
    return result;
  }

  LearningState copyWith({
    LoadStatus? homeStatus,
    LoadStatus? courseStatus,
    HomeFeed? feed,
    Course? course,
    String? homeError,
    String? courseError,
    bool clearHomeError = false,
    bool clearCourseError = false,
    String? searchQuery,
    LessonFilter? filter,
    LessonSort? sort,
    Set<String>? favoriteIds,
    Set<String>? completedIds,
    String? selectedTab,
    bool? enrolled,
  }) =>
      LearningState(
        homeStatus: homeStatus ?? this.homeStatus,
        courseStatus: courseStatus ?? this.courseStatus,
        feed: feed ?? this.feed,
        course: course ?? this.course,
        homeError: clearHomeError ? null : homeError ?? this.homeError,
        courseError: clearCourseError ? null : courseError ?? this.courseError,
        searchQuery: searchQuery ?? this.searchQuery,
        filter: filter ?? this.filter,
        sort: sort ?? this.sort,
        favoriteIds: favoriteIds ?? this.favoriteIds,
        completedIds: completedIds ?? this.completedIds,
        selectedTab: selectedTab ?? this.selectedTab,
        enrolled: enrolled ?? this.enrolled,
      );
}
