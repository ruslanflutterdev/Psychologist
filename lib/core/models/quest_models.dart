enum QuestType { physical, emotional, cognitive, social, spiritual }

extension QuestTypeX on QuestType {
  String get uiLabel {
    switch (this) {
      case QuestType.physical:
        return 'Сила (Physical)';
      case QuestType.emotional:
        return 'Эмоции (Emotional)';
      case QuestType.cognitive:
        return 'Интеллект (Cognitive)';
      case QuestType.social:
        return 'Соц. навыки (Social)';
      case QuestType.spiritual:
        return 'Смысл/ценности (Spiritual)';
    }
  }
}

class Quest {
  final String id;
  final String title;
  final QuestType type;
  final bool active;

  const Quest({
    required this.id,
    required this.title,
    required this.type,
    this.active = true,
  });
}

enum ChildQuestStatus { assigned, completed }

class ChildQuest {
  final String id;
  final String childId;
  final Quest quest;
  final ChildQuestStatus status;
  final String? childComment;
  final String? photoUrl;
  final DateTime? completedAt;

  const ChildQuest({
    required this.id,
    required this.childId,
    required this.quest,
    required this.status,
    this.childComment,
    this.photoUrl,
    this.completedAt,
  });

  ChildQuest copyWith({
    ChildQuestStatus? status,
    String? childComment,
    String? photoUrl,
    DateTime? completedAt,
  }) {
    return ChildQuest(
      id: id,
      childId: childId,
      quest: quest,
      status: status ?? this.status,
      childComment: childComment ?? this.childComment,
      photoUrl: photoUrl ?? this.photoUrl,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
