import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/learning_cubit.dart';
import '../widgets/learning_widgets.dart';
import '../widgets/lesson_tile.dart';

class LessonDetailsScreen extends StatelessWidget {
  const LessonDetailsScreen({required this.lessonId, super.key});

  final String lessonId;

  @override
  Widget build(BuildContext context) => BlocBuilder<LearningCubit, LearningState>(
        builder: (context, state) {
          final lesson = state.lessonById(lessonId);
          final course = state.course;
          if (lesson == null || course == null) {
            return Scaffold(
              appBar: AppBar(leading: const BackButton()),
              body: const StatusMessage(
                title: 'Lesson not found',
                message: 'This lesson is no longer available.',
                icon: Icons.search_off,
              ),
            );
          }

          final cubit = context.read<LearningCubit>();
          final locked = state.isLocked(lesson);
          final completed = state.isCompleted(lesson);
          final favorite = state.favoriteIds.contains(lesson.id);
          final position = course.lessons.indexOf(lesson) + 1;

          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded, color: ink),
              ),
              title: const Text('Lesson', style: TextStyle(color: ink, fontWeight: FontWeight.w700, fontSize: 18)),
              centerTitle: true,
              actions: [FavoriteButton(favorite: favorite, onPressed: () => cubit.toggleFavorite(lesson.id))],
            ),
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        height: 200,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            NetworkPhoto(url: course.imageUrl),
                            Container(color: Colors.black.withOpacity(locked ? 0.55 : 0.25)),
                            Center(child: LessonStatusIcon(locked: locked, completed: completed, size: 62)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text('LESSON $position OF ${course.lessons.length}',
                        style: const TextStyle(
                            color: orange, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
                    const SizedBox(height: 6),
                    Text(lesson.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: ink)),
                    const SizedBox(height: 6),
                    Text(course.title, style: const TextStyle(color: muted, fontSize: 14)),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoPill(icon: Icons.schedule_rounded, text: lesson.duration),
                        _InfoPill(
                          icon: locked ? Icons.lock_outline_rounded : Icons.lock_open_rounded,
                          text: locked ? 'Locked' : 'Available',
                        ),
                        _InfoPill(
                          icon: completed ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                          text: completed ? 'Completed' : 'Not completed',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      child: locked
                          ? OutlinedButton.icon(
                              onPressed: () => Navigator.of(context).maybePop(),
                              icon: const Icon(Icons.lock_outline_rounded),
                              label: const Text('Enroll in the course to unlock'),
                            )
                          : FilledButton.icon(
                              onPressed: () => cubit.toggleCompleted(lesson.id),
                              style: FilledButton.styleFrom(
                                backgroundColor: completed ? ink : orange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                              ),
                              icon: Icon(completed ? Icons.undo_rounded : Icons.check_rounded),
                              label: Text(completed ? 'Mark as not completed' : 'Mark as completed'),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: muted),
            const SizedBox(width: 6),
            Text(text, style: const TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}
