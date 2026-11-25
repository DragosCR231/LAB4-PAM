import '../../domain/entities/course.dart';
import 'json_helpers.dart';

/// DTO care oglindește JSON-ul de la GET /lab2026/v4/feed/details.
class CourseDetailsModel {
  const CourseDetailsModel({required this.navigationTitle, required this.course, required this.actions});

  final String navigationTitle;
  final CourseModel course;
  final ActionsModel actions;

  factory CourseDetailsModel.fromJson(Map<String, dynamic> json) => CourseDetailsModel(
        navigationTitle: readString(readOptionalMap(json, 'navigation'), 'title', fallback: 'Course Overview'),
        course: CourseModel.fromJson(readMap(json, 'course')),
        actions: ActionsModel.fromJson(readMap(json, 'actions')),
      );

  Map<String, dynamic> toJson() => {
        'navigation': {'title': navigationTitle},
        'course': course.toJson(),
        'actions': actions.toJson(),
      };

  Course toEntity() => Course(
        id: course.id,
        screenTitle: navigationTitle,
        title: course.title,
        duration: course.duration,
        durationMinutes: course.durationMinutes,
        lessonCount: course.lessonCount,
        rating: course.rating,
        heroLabel: course.hero.label,
        imageUrl: course.hero.imageUrl,
        videoCount: course.hero.videoCount,
        classCount: course.hero.classCount,
        lessons: course.lessons.map((lesson) => lesson.toEntity()).toList(),
        description: course.description,
        priceLabel: actions.priceLabel,
        enrollLabel: actions.enrollLabel,
        enrollEnabled: actions.enrollEnabled,
      );
}

class CourseModel {
  const CourseModel({
    required this.id,
    required this.title,
    required this.duration,
    required this.durationMinutes,
    required this.lessonCount,
    required this.rating,
    required this.hero,
    required this.lessons,
    required this.description,
  });

  final String id;
  final String title;
  final String duration;
  final int durationMinutes;
  final int lessonCount;
  final double rating;
  final HeroModel hero;
  final List<LessonModel> lessons;
  final String description;

  factory CourseModel.fromJson(Map<String, dynamic> json) => CourseModel(
        id: readString(json, 'id'),
        title: readString(json, 'title'),
        duration: readString(json, 'duration', fallback: ''),
        durationMinutes: readInt(json, 'durationMinutes', fallback: 0),
        lessonCount: readInt(json, 'lessonCount', fallback: 0),
        rating: readDouble(json, 'rating', fallback: 0),
        hero: HeroModel.fromJson(readMap(json, 'hero')),
        lessons: readList(json, 'lessons').map(LessonModel.fromJson).toList(),
        description: readString(readOptionalMap(json, 'description'), 'text', fallback: ''),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'duration': duration,
        'durationMinutes': durationMinutes,
        'lessonCount': lessonCount,
        'rating': rating,
        'hero': hero.toJson(),
        'lessons': lessons.map((lesson) => lesson.toJson()).toList(),
        'description': {'text': description},
      };
}

class HeroModel {
  const HeroModel({required this.label, required this.imageUrl, required this.videoCount, required this.classCount});

  final String label;
  final String imageUrl;
  final int videoCount;
  final int classCount;

  factory HeroModel.fromJson(Map<String, dynamic> json) => HeroModel(
        label: readString(json, 'label', fallback: ''),
        imageUrl: readString(json, 'imageUrl', fallback: ''),
        videoCount: readInt(json, 'videoCount', fallback: 0),
        classCount: readInt(json, 'classCount', fallback: 0),
      );

  Map<String, dynamic> toJson() => {
        'label': label,
        'imageUrl': imageUrl,
        'videoCount': videoCount,
        'classCount': classCount,
      };
}

class LessonModel {
  const LessonModel({
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

  factory LessonModel.fromJson(Map<String, dynamic> json) => LessonModel(
        id: readString(json, 'id'),
        title: readString(json, 'title'),
        duration: readString(json, 'duration', fallback: ''),
        durationSeconds: readInt(json, 'durationSeconds', fallback: 0),
        completed: readBool(json, 'completed'),
        locked: readBool(json, 'locked'),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'duration': duration,
        'durationSeconds': durationSeconds,
        'completed': completed,
        'locked': locked,
      };

  Lesson toEntity() => Lesson(
        id: id,
        title: title,
        duration: duration,
        durationSeconds: durationSeconds,
        completed: completed,
        locked: locked,
      );
}

class ActionsModel {
  const ActionsModel({
    required this.priceLabel,
    required this.priceAmount,
    required this.currency,
    required this.enrollLabel,
    required this.enrollEnabled,
  });

  final String priceLabel;
  final double priceAmount;
  final String currency;
  final String enrollLabel;
  final bool enrollEnabled;

  factory ActionsModel.fromJson(Map<String, dynamic> json) {
    final price = readMap(json, 'price');
    final enroll = readOptionalMap(json, 'enroll');
    return ActionsModel(
      priceLabel: readString(price, 'label'),
      priceAmount: readDouble(price, 'amount', fallback: 0),
      currency: readString(price, 'currency', fallback: 'USD'),
      enrollLabel: readString(enroll, 'label', fallback: 'Enroll Now'),
      enrollEnabled: readBool(enroll, 'enabled', fallback: true),
    );
  }

  Map<String, dynamic> toJson() => {
        'price': {'label': priceLabel, 'amount': priceAmount, 'currency': currency},
        'enroll': {'label': enrollLabel, 'enabled': enrollEnabled},
      };
}
