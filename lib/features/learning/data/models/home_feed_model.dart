import '../../domain/entities/home_feed.dart';
import 'json_helpers.dart';

/// DTO (Data Transfer Object) care oglindește exact JSON-ul de la
/// GET /lab2026/v4/feed. Conține deserializare (fromJson), serializare (toJson)
/// și conversia spre entitatea de domeniu (toEntity).
class HomeFeedModel {
  const HomeFeedModel({
    required this.header,
    required this.learnedToday,
    required this.myCourses,
    required this.learningPrompt,
    required this.learningPlan,
    required this.meetup,
  });

  final HeaderModel header;
  final LearnedTodayModel learnedToday;
  final SectionModel myCourses;
  final LearningPromptModel learningPrompt;
  final LearningPlanModel learningPlan;
  final MeetupModel meetup;

  factory HomeFeedModel.fromJson(Map<String, dynamic> json) => HomeFeedModel(
        header: HeaderModel.fromJson(readMap(json, 'header')),
        learnedToday: LearnedTodayModel.fromJson(readMap(json, 'learnedToday')),
        myCourses: SectionModel.fromJson(readMap(json, 'myCourses')),
        learningPrompt: LearningPromptModel.fromJson(readMap(json, 'learningPrompt')),
        learningPlan: LearningPlanModel.fromJson(readMap(json, 'learningPlan')),
        meetup: MeetupModel.fromJson(readMap(json, 'meetup')),
      );

  Map<String, dynamic> toJson() => {
        'header': header.toJson(),
        'learnedToday': learnedToday.toJson(),
        'myCourses': myCourses.toJson(),
        'learningPrompt': learningPrompt.toJson(),
        'learningPlan': learningPlan.toJson(),
        'meetup': meetup.toJson(),
      };

  HomeFeed toEntity() => HomeFeed(
        greeting: header.greeting,
        subtitle: header.subtitle,
        avatarUrl: header.avatarUrl,
        hasUnreadNotifications: header.notification.hasUnread,
        learnedTitle: learnedToday.title,
        learnedMinutes: learnedToday.learnedMinutes,
        goalMinutes: learnedToday.goalMinutes,
        myCoursesTitle: myCourses.title,
        myCoursesAction: myCourses.actionLabel,
        promptTitle: learningPrompt.title,
        promptActionLabel: learningPrompt.actionLabel,
        promptImageUrl: learningPrompt.imageUrl,
        planTitle: learningPlan.title,
        planItems: learningPlan.items.map((item) => item.toEntity()).toList(),
        meetupTitle: meetup.title,
        meetupSubtitle: meetup.subtitle,
        meetupImageUrl: meetup.imageUrl,
      );
}

class HeaderModel {
  const HeaderModel({
    required this.greeting,
    required this.subtitle,
    required this.avatarUrl,
    required this.notification,
  });

  final String greeting;
  final String subtitle;
  final String avatarUrl;
  final NotificationModel notification;

  factory HeaderModel.fromJson(Map<String, dynamic> json) => HeaderModel(
        greeting: readString(json, 'greeting'),
        subtitle: readString(json, 'subtitle', fallback: ''),
        avatarUrl: readString(json, 'avatarUrl', fallback: ''),
        notification: NotificationModel.fromJson(readOptionalMap(json, 'notification')),
      );

  Map<String, dynamic> toJson() => {
        'greeting': greeting,
        'subtitle': subtitle,
        'avatarUrl': avatarUrl,
        'notification': notification.toJson(),
      };
}

class NotificationModel {
  const NotificationModel({required this.hasUnread, required this.iconUrl});

  final bool hasUnread;
  final String iconUrl;

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
        hasUnread: readBool(json, 'hasUnread'),
        iconUrl: readString(json, 'iconUrl', fallback: ''),
      );

  Map<String, dynamic> toJson() => {'hasUnread': hasUnread, 'iconUrl': iconUrl};
}

class LearnedTodayModel {
  const LearnedTodayModel({
    required this.title,
    required this.learnedMinutes,
    required this.goalMinutes,
    required this.formatted,
    required this.progress,
  });

  final String title;
  final int learnedMinutes;
  final int goalMinutes;
  final String formatted;
  final double progress;

  factory LearnedTodayModel.fromJson(Map<String, dynamic> json) => LearnedTodayModel(
        title: readString(json, 'title', fallback: 'Learned today'),
        learnedMinutes: readInt(json, 'learnedMinutes'),
        goalMinutes: readInt(json, 'goalMinutes'),
        formatted: readString(json, 'formatted', fallback: ''),
        progress: readDouble(json, 'progress', fallback: 0),
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'learnedMinutes': learnedMinutes,
        'goalMinutes': goalMinutes,
        'formatted': formatted,
        'progress': progress,
      };
}

class SectionModel {
  const SectionModel({required this.title, required this.actionLabel});

  final String title;
  final String actionLabel;

  factory SectionModel.fromJson(Map<String, dynamic> json) => SectionModel(
        title: readString(json, 'title'),
        actionLabel: readString(json, 'actionLabel', fallback: ''),
      );

  Map<String, dynamic> toJson() => {'title': title, 'actionLabel': actionLabel};
}

class LearningPromptModel {
  const LearningPromptModel({required this.title, required this.actionLabel, required this.imageUrl});

  final String title;
  final String actionLabel;
  final String imageUrl;

  factory LearningPromptModel.fromJson(Map<String, dynamic> json) => LearningPromptModel(
        title: readString(json, 'title'),
        actionLabel: readString(json, 'actionLabel', fallback: 'Get Started'),
        imageUrl: readString(json, 'imageUrl', fallback: ''),
      );

  Map<String, dynamic> toJson() => {'title': title, 'actionLabel': actionLabel, 'imageUrl': imageUrl};
}

class LearningPlanModel {
  const LearningPlanModel({required this.title, required this.items});

  final String title;
  final List<PlanItemModel> items;

  factory LearningPlanModel.fromJson(Map<String, dynamic> json) => LearningPlanModel(
        title: readString(json, 'title'),
        items: readList(json, 'items').map(PlanItemModel.fromJson).toList(),
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'items': items.map((item) => item.toJson()).toList(),
      };
}

class PlanItemModel {
  const PlanItemModel({
    required this.id,
    required this.title,
    required this.completed,
    required this.total,
    required this.progress,
    required this.progressIconUrl,
  });

  final String id;
  final String title;
  final int completed;
  final int total;
  final double progress;
  final String progressIconUrl;

  factory PlanItemModel.fromJson(Map<String, dynamic> json) => PlanItemModel(
        id: readString(json, 'id'),
        title: readString(json, 'title'),
        completed: readInt(json, 'completed'),
        total: readInt(json, 'total'),
        progress: readDouble(json, 'progress', fallback: 0),
        progressIconUrl: readString(json, 'progressIconUrl', fallback: ''),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'completed': completed,
        'total': total,
        'progress': progress,
        'progressIconUrl': progressIconUrl,
      };

  PlanItem toEntity() => PlanItem(id: id, title: title, completed: completed, total: total, progress: progress);
}

class MeetupModel {
  const MeetupModel({required this.title, required this.subtitle, required this.imageUrl});

  final String title;
  final String subtitle;
  final String imageUrl;

  factory MeetupModel.fromJson(Map<String, dynamic> json) => MeetupModel(
        title: readString(json, 'title'),
        subtitle: readString(json, 'subtitle', fallback: ''),
        imageUrl: readString(json, 'imageUrl', fallback: ''),
      );

  Map<String, dynamic> toJson() => {'title': title, 'subtitle': subtitle, 'imageUrl': imageUrl};
}
