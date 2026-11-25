import 'package:flutter_test/flutter_test.dart';

import 'package:learning_api_v4/features/learning/presentation/cubit/learning_cubit.dart';
import 'package:learning_api_v4/injection.dart';

import 'helpers.dart';

Future<LearningCubit> _loadedCubit({Map<String, dynamic>? feed, Map<String, dynamic>? details}) async {
  final cubit = createLearningCubit(httpClient: fakeApi(feed: feed, details: details));
  await cubit.load();
  return cubit;
}

List<String> _titles(LearningCubit cubit) => cubit.state.visibleLessons.map((l) => l.title).toList();

void main() {
  test('emits loading then success for both endpoints', () async {
    final cubit = createLearningCubit(httpClient: fakeApi());
    expect(cubit.state.homeStatus, LoadStatus.initial);

    final pending = cubit.load();
    expect(cubit.state.homeStatus, LoadStatus.loading);
    expect(cubit.state.courseStatus, LoadStatus.loading);
    await pending;

    expect(cubit.state.homeStatus, LoadStatus.success);
    expect(cubit.state.courseStatus, LoadStatus.success);
    expect(cubit.state.feed!.planItems, hasLength(2));
    expect(cubit.state.course!.lessons, hasLength(4));
  });

  test('a failing endpoint only affects its own section', () async {
    final cubit = createLearningCubit(httpClient: fakeApi(detailsStatus: 503));
    await cubit.load();

    expect(cubit.state.homeStatus, LoadStatus.success);
    expect(cubit.state.courseStatus, LoadStatus.error);
    expect(cubit.state.courseError, contains('503'));
  });

  test('emits empty when the course has no lessons', () async {
    final details = fixture('details');
    (details['course'] as Map<String, dynamic>)['lessons'] = <dynamic>[];
    final cubit = await _loadedCubit(details: details);
    expect(cubit.state.courseStatus, LoadStatus.empty);
  });

  test('searches lessons case-insensitively', () async {
    final cubit = await _loadedCubit();
    cubit.search('UNDERSTANDING');
    expect(_titles(cubit), ['Understanding React']);
  });

  test('filters available lessons and unlocks them after enrolling', () async {
    final cubit = await _loadedCubit();
    cubit.setFilter(LessonFilter.available);
    expect(_titles(cubit), isNot(contains('Build React')));

    cubit.enroll();
    expect(_titles(cubit), contains('Build React'));
  });

  test('sorts lessons by duration', () async {
    final cubit = await _loadedCubit();
    cubit.setSort(LessonSort.duration);
    expect(
        _titles(cubit), ['Introduction to React', 'Understanding React', 'Build React', 'Create first React project']);
  });

  test('toggles favorites and completes only unlocked lessons', () async {
    final cubit = await _loadedCubit();
    cubit.toggleFavorite('lesson-2');
    cubit.setFilter(LessonFilter.favorites);
    expect(_titles(cubit), ['Understanding React']);

    cubit.toggleCompleted('lesson-1');
    cubit.toggleCompleted('lesson-4');
    cubit.setFilter(LessonFilter.completed);
    expect(_titles(cubit), ['Introduction to React']);
  });
}
