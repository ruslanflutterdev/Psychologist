import 'package:flutter/material.dart';
import 'package:heros_journey/core/errors/auth_exception.dart';
import 'package:heros_journey/features/achievements/repository/achievement_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

class AchievementFormDialog extends StatefulWidget {
  final AchievementService service;

  const AchievementFormDialog({super.key, required this.service});

  @override
  State<AchievementFormDialog> createState() => _AchievementFormDialogState();
}

class _AchievementFormDialogState extends State<AchievementFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  bool _isSaving = false;
  String? _formError;

  static const Map<String, IconData> availableIcons = {
    'star': Icons.star,
    'bolt': Icons.bolt,
    'school': Icons.school,
    'emoji_events': Icons.emoji_events,
    'thumb_up': Icons.thumb_up,
    'verified': Icons.verified,
    'psychology': Icons.psychology,
    'favorite': Icons.favorite,
    'auto_awesome': Icons.auto_awesome,
  };

  String _selectedIconName = 'star';

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  String? _validateField(String? v, String name) {
    final val = v?.trim() ?? '';
    if (val.isEmpty) return 'Введите $name';
    if (val.length < 3) return 'Минимум 3 символа';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedIconName.isEmpty) {
      if (_selectedIconName.isEmpty) {
        setState(() => _formError = 'Выберите иконку ачивки.');
      }
      return;
    }

    setState(() {
      _isSaving = true;
      _formError = null;
    });

    final userId = Supabase.instance.client.auth.currentUser?.id;

    try {
      if (userId == null) {
        throw AuthException('UNAUTHORIZED', 'Пользователь не авторизован.');
      }

      await widget.service.createAchievement(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        iconName: _selectedIconName,
        userId: userId,
      );

      if (mounted) Navigator.of(context).pop(true);
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _formError = e.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _formError = 'Неизвестная ошибка: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Создать новую ачивку'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Название ачивки'),
                  validator: (v) => _validateField(v, 'название'),
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: 'Описание'),
                  maxLines: 3,
                  validator: (v) => _validateField(v, 'описание'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Иконка ачивки',
                    prefixIcon: Icon(availableIcons[_selectedIconName]),
                  ),
                  initialValue: _selectedIconName,
                  items: availableIcons.keys.map((name) {
                    return DropdownMenuItem(
                      value: name,
                      child: Row(
                        children: [
                          Icon(availableIcons[name]),
                          const SizedBox(width: 8),
                          Text(name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() => _selectedIconName = newValue);
                    }
                  },
                  validator: (v) =>
                      v?.isNotEmpty != true ? 'Выберите иконку' : null,
                ),
                if (_formError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _formError!,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Создать'),
        ),
      ],
    );
  }
}
