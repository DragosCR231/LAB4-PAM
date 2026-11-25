import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/learning_cubit.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/home_feed.dart';
import '../widgets/learning_widgets.dart';
import 'course_overview_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openCourse(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CourseOverviewScreen()),
    );
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<LearningCubit, LearningState>(
        builder: (context, state) {
          final cubit = context.read<LearningCubit>();
          if (state.isHomeLoading && state.feed == null) {
            return const Scaffold(body: LoadingView(message: 'Loading your learning feed...'));
          }
          if (state.homeStatus == LoadStatus.error || state.feed == null) {
            return Scaffold(
              body: StatusMessage(
                title: 'Could not load your learning data',
                message: state.homeError ?? 'Please try again.',
                onRetry: cubit.load,
              ),
            );
          }
          final data = state.feed!;

          return Scaffold(
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: RefreshIndicator(
                    color: orange,
                    onRefresh: cubit.load,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(22, 12, 22, 36),
                      children: [
                        Row(
                          children: [
                            ClipOval(
                              child: SizedBox(
                                width: 52,
                                height: 52,
                                child: NetworkPhoto(url: data.avatarUrl),
                              ),
                            ),
                            const SizedBox(width: 13),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data.greeting,
                                      style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: ink)),
                                  const SizedBox(height: 2),
                                  Text(data.subtitle, style: const TextStyle(color: muted, fontSize: 14)),
                                ],
                              ),
                            ),
                            IconButton.filledTonal(
                              tooltip: 'Notifications',
                              onPressed: () {},
                              style: IconButton.styleFrom(
                                backgroundColor: ink,
                                foregroundColor: Colors.white,
                                fixedSize: const Size(46, 46),
                              ),
                              icon: Badge(
                                isLabelVisible: data.hasUnreadNotifications,
                                backgroundColor: orange,
                                smallSize: 9,
                                child: const Icon(Icons.notifications_none_rounded),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _DailyProgress(
                          title: data.learnedTitle,
                          learnedMinutes: data.learnedMinutes,
                          goalMinutes: data.goalMinutes,
                          progress: data.learnedProgress,
                        ),
                        const SizedBox(height: 25),
                        SectionHeading(
                          title: data.myCoursesTitle,
                          action: data.myCoursesAction,
                          onAction: () => _openCourse(context),
                        ),
                        const SizedBox(height: 9),
                        _CourseCardSection(state: state, onOpen: () => _openCourse(context), onRetry: cubit.loadCourse),
                        const SizedBox(height: 24),
                        _LearningPrompt(
                          title: data.promptTitle,
                          imageUrl: data.promptImageUrl,
                          actionLabel: data.promptActionLabel,
                          onTap: () => _openCourse(context),
                        ),
                        const SizedBox(height: 24),
                        SectionHeading(title: data.planTitle),
                        const SizedBox(height: 8),
                        if (state.homeStatus == LoadStatus.empty)
                          const SizedBox(
                            height: 150,
                            child: StatusMessage(
                              title: 'No plan yet',
                              message: 'Your learning plan is empty.',
                              icon: Icons.event_note_outlined,
                            ),
                          )
                        else
                          ...data.planItems.map((item) => _PlanRow(item: item)),
                        const SizedBox(height: 18),
                        _MeetupBanner(
                          title: data.meetupTitle,
                          subtitle: data.meetupSubtitle,
                          imageUrl: data.meetupImageUrl,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
}

class _DailyProgress extends StatelessWidget {
  const _DailyProgress({
    required this.title,
    required this.learnedMinutes,
    required this.goalMinutes,
    required this.progress,
  });

  final String title;
  final int learnedMinutes;
  final int goalMinutes;
  final double progress;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(color: paleGreen, borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            SizedBox(
              width: 62,
              height: 62,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    backgroundColor: Colors.white,
                    color: const Color(0xFF68836A),
                  ),
                  const Center(child: Icon(Icons.bolt_rounded, color: Color(0xFF68836A), size: 25)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ink)),
                  const SizedBox(height: 4),
                  Text('$learnedMinutes min  /  $goalMinutes min', style: const TextStyle(color: muted, fontSize: 13)),
                ],
              ),
            ),
            Text('${(progress * 100).round()}%',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF536F56))),
          ],
        ),
      );
}

/// Cardul cursului vine din al doilea endpoint (/feed/details), deci are
/// propria stare de încărcare / eroare, independentă de restul ecranului.
class _CourseCardSection extends StatelessWidget {
  const _CourseCardSection({required this.state, required this.onOpen, required this.onRetry});

  final LearningState state;
  final VoidCallback onOpen;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final course = state.course;
    if (course != null) return _CourseCard(course: course, onTap: onOpen);
    return Container(
      height: 104,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      alignment: Alignment.center,
      child: state.courseStatus == LoadStatus.error
          ? InlineError(message: state.courseError ?? 'Course could not be loaded.', onRetry: onRetry)
          : const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 3, color: orange)),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course, required this.onTap});

  final Course course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(width: 76, height: 76, child: NetworkPhoto(url: course.imageUrl)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.heroLabel,
                          style: const TextStyle(
                              color: orange, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(course.title, style: const TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 5),
                      Text('${course.lessonCount} lessons  ·  ${course.duration}',
                          style: const TextStyle(color: muted, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 15, color: orange),
              ],
            ),
          ),
        ),
      );
}

class _LearningPrompt extends StatelessWidget {
  const _LearningPrompt({required this.title, required this.imageUrl, required this.actionLabel, required this.onTap});

  final String title;
  final String imageUrl;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 156,
          child: Stack(
            fit: StackFit.expand,
            children: [
              NetworkPhoto(url: imageUrl),
              Container(color: ink.withOpacity(0.56)),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: onTap,
                      style: FilledButton.styleFrom(backgroundColor: orange, foregroundColor: Colors.white),
                      icon: const Icon(Icons.play_arrow_rounded, size: 19),
                      label: Text(actionLabel),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({required this.item});

  final PlanItem item;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: paleGreen, borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.auto_awesome_outlined, color: Color(0xFF68836A), size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: const TextStyle(color: ink, fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 7),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: item.progress,
                        minHeight: 5,
                        backgroundColor: const Color(0xFFE9ECE8),
                        color: orange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text('${item.completed}/${item.total}',
                  style: const TextStyle(color: muted, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
}

class _MeetupBanner extends StatelessWidget {
  const _MeetupBanner({required this.title, required this.subtitle, required this.imageUrl});

  final String title;
  final String subtitle;
  final String imageUrl;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 128,
          child: Stack(
            fit: StackFit.expand,
            children: [
              NetworkPhoto(url: imageUrl),
              Container(color: ink.withOpacity(0.5)),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
