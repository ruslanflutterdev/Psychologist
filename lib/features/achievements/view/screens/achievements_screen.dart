import 'package:flutter/material.dart';
import 'package:heros_journey/core/errors/auth_exception.dart';
import 'package:heros_journey/core/models/quest_models.dart';
import 'package:heros_journey/core/services/service_registry.dart';
import 'package:heros_journey/features/achievements/models/achievement_model.dart';
import 'package:heros_journey/features/achievements/view/widgets/achievement_card.dart';
import 'package:heros_journey/features/achievements/view/widgets/achievement_form_dialog.dart';
import 'package:heros_journey/features/child_screen/view_model/widgets/quest_picker_dialog.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final _service = ServiceRegistry.achievement;

  void _openCreateDialog() async {
    final success = await showDialog<bool>(
      context: context,
      builder: (_) => AchievementFormDialog(service: _service),
    );
    if (success == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ачивка успешно создана!')),
        );
      }
    }
  }

  Future<void> _toggleAttachment(AchievementModel achievement) async {
    try {
      if (achievement.isAttached) {
        await _service.detachFromQuest(achievementId: achievement.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ачивка отвязана.')),
          );
        }
      } else {
        await _handleAttachToQuest(achievement);
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка операции: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handleAttachToQuest(AchievementModel achievement) async {
    if (achievement.isAttached) {
      return;
    }

    final selectedQuest = await showDialog<Quest>(
      context: context,
      builder: (_) => QuestPickerDialog(catalog: ServiceRegistry.questCatalog),
    );

    if (selectedQuest != null) {
      try {
        await _service.attachToQuest(
          achievementId: achievement.id,
          questId: selectedQuest.id,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Ачивка привязана к квесту "${selectedQuest.title}".',
              ),
            ),
          );
        }
      } on AuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${e.message}. Сначала отвяжите её.'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ваши Ачивки'),
        actions: [
          IconButton(
            onPressed: _openCreateDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Создать ачивку',
          ),
        ],
      ),
      body: StreamBuilder<List<AchievementModel>>(
        stream: _service.getMyAchievements(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Ошибка загрузки ачивок: ${snapshot.error}'));
          }

          final achievements = snapshot.data ?? [];

          if (achievements.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'У вас пока нет созданных ачивок.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final ach = achievements[index];
              return AchievementCard(
                achievement: ach,
                onToggleAttachment: _toggleAttachment,
              );
            },
          );
        },
      ),
    );
  }
}
