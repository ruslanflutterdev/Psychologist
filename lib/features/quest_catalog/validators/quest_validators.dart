import 'package:heros_journey/core/models/quest_models.dart';

String? validateQuestTitle(String? v) {
  final val = v?.trim() ?? '';
  if (val.isEmpty) return 'Название квеста обязательно';
  if (val.length < 3) return 'Минимум 3 символа';
  return null;
}

String? validateQuestXP(String? v) {
  final val = v?.trim() ?? '';
  if (val.isEmpty) return 'Опыт (XP) обязателен';
  final xp = int.tryParse(val);
  if (xp == null || xp < 0) return 'Введите целое число >= 0';
  return null;
}

String? validateQuestType(QuestType? t) {
  if (t == null) return 'Выберите сферу';
  return null;
}
