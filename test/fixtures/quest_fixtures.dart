import 'package:equatable/equatable.dart';

class Quest extends Equatable {
  final String id;
  final String title;
  final String type;
  final String? previewUrl;

  const Quest({
    required this.id,
    required this.title,
    required this.type,
    this.previewUrl,
  });

  @override
  List<Object?> get props => [id, title, type, previewUrl];
}

class ChildQuest extends Equatable {
  final String id;
  final String questId;
  final String title;
  final bool completed;
  final String? comment;
  final String? previewUrl;
  final DateTime? completedAt;

  const ChildQuest({
    required this.id,
    required this.questId,
    required this.title,
    this.completed = false,
    this.comment,
    this.previewUrl,
    this.completedAt,
  });

  ChildQuest copyWith({
    bool? completed,
    String? comment,
    String? previewUrl,
    DateTime? completedAt,
  }) {
    return ChildQuest(
      id: id,
      questId: questId,
      title: title,
      completed: completed ?? this.completed,
      comment: comment ?? this.comment,
      previewUrl: previewUrl ?? this.previewUrl,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    questId,
    title,
    completed,
    comment,
    previewUrl,
    completedAt,
  ];
}

const childId = 'child-1';
final availableQuests = <Quest>[
  const Quest(id: 'q1', title: 'Поднять штангу', type: 'strength'),
  const Quest(id: 'q2', title: 'Пробежать милю', type: 'strength'),
  const Quest(id: 'q3', title: 'Решить головоломку', type: 'wisdom'),
];

final initiallyAssigned = <ChildQuest>[
  ChildQuest(
    id: 'a1',
    questId: 'q0',
    title: 'Разминка',
    completed: true,
    comment: 'Отлично!',
    previewUrl: 'https://pics/1.jpg',
    completedAt: DateTime(2025, 1, 10),
  ),
];
