/// Entitate de domeniu pentru ecranul Course Overview.
class Course {
  const Course({
    required this.id,
    required this.screenTitle,
    required this.title,
    required this.duration,
    required this.durationMinutes,
    required this.lessonCount,
    required this.rating,
    required this.heroLabel,
    required this.imageUrl,
    required this.videoCount,
    required this.classCount,
    required this.lessons,
    required this.description,
    required this.priceLabel,
    required this.enrollLabel,
    required this.enrollEnabled,
  });

  final String id;
  final String screenTitle;
  final String title;
  final String duration;
  final int durationMinutes;
  final int lessonCount;
  final double rating;
  final String heroLabel;
  final String imageUrl;
  final int videoCount;
  final int classCount;
  final List<Lesson> lessons;
  final String description;
  final String priceLabel;
  final String enrollLabel;
  final bool enrollEnabled;
}

class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.duration,
    required this.durationSeconds,
    required this.completed,
    required this.locked,
  });

  final String id;
  final String title;
  final String duration;
  final int durationSeconds;
  final bool completed;
  final bool locked;
}
