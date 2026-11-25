import 'package:flutter/material.dart';

import '../../domain/entities/course.dart';
import 'learning_widgets.dart';

class LessonTile extends StatelessWidget {
  const LessonTile({
    required this.lesson,
    required this.locked,
    required this.completed,
    required this.favorite,
    required this.onTap,
    required this.onFavorite,
    super.key,
  });

  final Lesson lesson;
  final bool locked;
  final bool completed;
  final bool favorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(top: 7),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7)),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          leading: LessonStatusIcon(locked: locked, completed: completed),
          title: Text(
            lesson.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: locked ? muted : ink, fontWeight: FontWeight.w600, fontSize: 13),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(lesson.duration, style: const TextStyle(color: muted, fontSize: 12)),
          ),
          trailing: FavoriteButton(favorite: favorite, onPressed: onFavorite),
        ),
      );
}

class LessonStatusIcon extends StatelessWidget {
  const LessonStatusIcon({required this.locked, required this.completed, this.size = 40, super.key});

  final bool locked;
  final bool completed;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: locked ? const Color(0xFFF2F3F1) : const Color(0xFFFFF0E9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          locked
              ? Icons.lock_outline_rounded
              : completed
                  ? Icons.check_rounded
                  : Icons.play_arrow_rounded,
          color: locked ? muted : orange,
          size: size * 0.52,
        ),
      );
}

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({required this.favorite, required this.onPressed, super.key});

  final bool favorite;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: favorite ? 'Remove from favorites' : 'Add to favorites',
        onPressed: onPressed,
        icon: Icon(favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: favorite ? orange : muted, size: 20),
      );
}
