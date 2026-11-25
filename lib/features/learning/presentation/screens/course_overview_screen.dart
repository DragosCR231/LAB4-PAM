import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/learning_cubit.dart';
import '../../domain/entities/course.dart';
import '../widgets/learning_widgets.dart';
import '../widgets/lesson_filter_bar.dart';
import '../widgets/lesson_tile.dart';
import 'lesson_details_screen.dart';

class CourseOverviewScreen extends StatelessWidget {
  const CourseOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<LearningCubit, LearningState>(
        builder: (context, state) {
          final cubit = context.read<LearningCubit>();
          if (state.isCourseLoading && state.course == null) {
            return Scaffold(
              appBar: AppBar(leading: const BackButton()),
              body: const LoadingView(message: 'Loading course details...'),
            );
          }
          if (state.courseStatus == LoadStatus.error || state.course == null) {
            return Scaffold(
              appBar: AppBar(leading: const BackButton()),
              body: StatusMessage(
                title: 'Course unavailable',
                message: state.courseError ?? 'Course information could not be loaded.',
                onRetry: cubit.loadCourse,
              ),
            );
          }

          final course = state.course!;
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded, color: ink),
              ),
              title: Text(course.screenTitle,
                  style: const TextStyle(color: ink, fontWeight: FontWeight.w700, fontSize: 18)),
              centerTitle: true,
            ),
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: RefreshIndicator(
                  color: orange,
                  onRefresh: cubit.loadCourse,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    children: [
                      _CourseHero(course: course),
                      const SizedBox(height: 18),
                      Text(course.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: ink)),
                      const SizedBox(height: 13),
                      _CourseFacts(course: course),
                      const SizedBox(height: 21),
                      _OverviewTabs(selectedTab: state.selectedTab),
                      const SizedBox(height: 16),
                      if (state.selectedTab == 'lessons')
                        _LessonSection(state: state)
                      else
                        _DescriptionPanel(description: course.description),
                    ],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: _EnrollBar(
              price: course.priceLabel,
              label: state.enrolled ? 'Enrolled' : course.enrollLabel,
              enrolled: state.enrolled || !course.enrollEnabled,
            ),
          );
        },
      );
}

class _CourseHero extends StatelessWidget {
  const _CourseHero({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 210,
          child: Stack(
            fit: StackFit.expand,
            children: [
              NetworkPhoto(url: course.imageUrl),
              Container(color: Colors.black.withOpacity(0.22)),
              Positioned(
                top: 15,
                left: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  child: Text(course.heroLabel,
                      style: const TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
                ),
              ),
              Center(
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow_rounded, size: 36, color: orange),
                ),
              ),
              Positioned(
                bottom: 13,
                right: 14,
                child: Text('${course.videoCount} videos  ·  ${course.classCount} classes',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
              ),
            ],
          ),
        ),
      );
}

class _CourseFacts extends StatelessWidget {
  const _CourseFacts({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          _Fact(icon: Icons.schedule_rounded, text: course.duration),
          const SizedBox(width: 18),
          _Fact(icon: Icons.menu_book_rounded, text: '${course.lessonCount} lessons'),
          const SizedBox(width: 18),
          _Fact(icon: Icons.star_rounded, text: course.rating.toStringAsFixed(1), color: const Color(0xFFE5A31A)),
        ],
      );
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.text, this.color = muted});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: color),
            const SizedBox(width: 5),
            Flexible(
                child: Text(text,
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: muted, fontSize: 12))),
          ],
        ),
      );
}

class _OverviewTabs extends StatelessWidget {
  const _OverviewTabs({required this.selectedTab});

  final String selectedTab;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          _OverviewTab(label: 'Lessons', id: 'lessons', selected: selectedTab == 'lessons'),
          const SizedBox(width: 24),
          _OverviewTab(label: 'Description', id: 'description', selected: selectedTab == 'description'),
        ],
      );
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.label, required this.id, required this.selected});

  final String label;
  final String id;
  final bool selected;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => context.read<LearningCubit>().setTab(id),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Column(
            children: [
              Text(label, style: TextStyle(color: selected ? ink : muted, fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 8),
              Container(height: 3, width: 68, color: selected ? orange : Colors.transparent),
            ],
          ),
        ),
      );
}

class _LessonSection extends StatelessWidget {
  const _LessonSection({required this.state});

  final LearningState state;

  void _openLesson(BuildContext context, Lesson lesson) {
    if (state.isLocked(lesson)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Enroll to unlock this lesson.')));
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => LessonDetailsScreen(lessonId: lesson.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LearningCubit>();
    final lessons = state.visibleLessons;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LessonSearchField(onChanged: cubit.search),
        const SizedBox(height: 12),
        LessonFilterBar(
          filter: state.filter,
          sort: state.sort,
          onFilterChanged: cubit.setFilter,
          onSortChanged: cubit.setSort,
        ),
        const SizedBox(height: 7),
        if (lessons.isEmpty)
          const SizedBox(
            height: 190,
            child: StatusMessage(
              title: 'No lessons found',
              message: 'Try another search or filter.',
              icon: Icons.search_off,
            ),
          )
        else
          ...lessons.map(
            (lesson) => LessonTile(
              lesson: lesson,
              locked: state.isLocked(lesson),
              completed: state.isCompleted(lesson),
              favorite: state.favoriteIds.contains(lesson.id),
              onTap: () => _openLesson(context, lesson),
              onFavorite: () => cubit.toggleFavorite(lesson.id),
            ),
          ),
      ],
    );
  }
}

class _DescriptionPanel extends StatelessWidget {
  const _DescriptionPanel({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7)),
        child: description.trim().isEmpty
            ? const StatusMessage(
                title: 'No description yet',
                message: 'The author has not added a description for this course.',
                icon: Icons.notes_rounded,
              )
            : Text(description, style: const TextStyle(color: muted, fontSize: 14, height: 1.55)),
      );
}

class _EnrollBar extends StatelessWidget {
  const _EnrollBar({required this.price, required this.label, required this.enrolled});

  final String price;
  final String label;
  final bool enrolled;

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration:
              const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE9ECE8)))),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('PRICE',
                          style: TextStyle(color: muted, fontWeight: FontWeight.w700, fontSize: 10, letterSpacing: 1)),
                      Text(price, style: const TextStyle(color: ink, fontSize: 19, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(width: 22),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: enrolled
                            ? null
                            : () {
                                context.read<LearningCubit>().enroll();
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(const SnackBar(content: Text('Enrolled! All lessons are unlocked.')));
                              },
                        style: FilledButton.styleFrom(
                            backgroundColor: orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7))),
                        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
