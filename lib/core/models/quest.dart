enum QuestDifficulty { low, medium, high }

extension QuestDifficultyX on QuestDifficulty {
  String get uiLabel {
    switch (this) {
      case QuestDifficulty.low:
        return 'Low';
      case QuestDifficulty.medium:
        return 'Medium';
      case QuestDifficulty.high:
        return 'High';
    }
  }

  String get wireValue {
    switch (this) {
      case QuestDifficulty.low:
        return 'low';
      case QuestDifficulty.medium:
        return 'medium';
      case QuestDifficulty.high:
        return 'high';
    }
  }

  static QuestDifficulty fromWire(String v) {
    switch (v) {
      case 'low':
        return QuestDifficulty.low;
      case 'medium':
        return QuestDifficulty.medium;
      case 'high':
        return QuestDifficulty.high;
      default:
        return QuestDifficulty.medium;
    }
  }
}
