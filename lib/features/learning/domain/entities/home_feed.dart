/// Entitate de domeniu pentru ecranul Home.
/// Este o clasă Dart „curată”: nu știe nimic despre JSON, HTTP sau Flutter.
class HomeFeed {
  const HomeFeed({
    required this.greeting,
    required this.subtitle,
    required this.avatarUrl,
    required this.hasUnreadNotifications,
    required this.learnedTitle,
    required this.learnedMinutes,
    required this.goalMinutes,
    required this.myCoursesTitle,
    required this.myCoursesAction,
    required this.promptTitle,
    required this.promptActionLabel,
    required this.promptImageUrl,
    required this.planTitle,
    required this.planItems,
    required this.meetupTitle,
    required this.meetupSubtitle,
    required this.meetupImageUrl,
  });

  final String greeting;
  final String subtitle;
  final String avatarUrl;
  final bool hasUnreadNotifications;
  final String learnedTitle;
  final int learnedMinutes;
  final int goalMinutes;
  final String myCoursesTitle;
  final String myCoursesAction;
  final String promptTitle;
  final String promptActionLabel;
  final String promptImageUrl;
  final String planTitle;
  final List<PlanItem> planItems;
  final String meetupTitle;
  final String meetupSubtitle;
  final String meetupImageUrl;

  double get learnedProgress => goalMinutes <= 0 ? 0 : (learnedMinutes / goalMinutes).clamp(0.0, 1.0).toDouble();
}

class PlanItem {
  const PlanItem({
    required this.id,
    required this.title,
    required this.completed,
    required this.total,
    required this.progress,
  });

  final String id;
  final String title;
  final int completed;
  final int total;
  final double progress;
}
