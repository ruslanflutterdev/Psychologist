class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String iconPath;
  final bool active;
  final String createdBy;
  final DateTime createdAt;
  final String? questId;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.active,
    required this.createdBy,
    required this.createdAt,
    this.questId,
  });

  bool get isAttached => questId != null;

  AchievementModel copyWith({
    String? title,
    String? description,
    String? iconPath,
    bool? active,
    String? questId,
  }) {
    return AchievementModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconPath: iconPath ?? this.iconPath,
      active: active ?? this.active,
      createdBy: createdBy,
      createdAt: createdAt,
      questId: questId,
    );
  }
}
