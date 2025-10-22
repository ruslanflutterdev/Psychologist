import 'package:flutter/material.dart';
import 'package:heros_journey/core/models/quest_models.dart';
import 'package:heros_journey/features/quest_catalog/validators/quest_validators.dart';

class QuestFormPayload {
  final String title;
  final String description;
  final QuestType type;
  final int xp;
  final bool active;

  const QuestFormPayload({
    required this.title,
    this.description = '',
    required this.type,
    required this.xp,
    this.active = true,
  });
}

class QuestFormDialog extends StatefulWidget {
  final Quest? initialQuest;
  final Future<void> Function(QuestFormPayload data) onSave;

  const QuestFormDialog({super.key, this.initialQuest, required this.onSave});

  @override
  State<QuestFormDialog> createState() => _QuestFormDialogState();
}

class _QuestFormDialogState extends State<QuestFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _xpCtrl;
  QuestType? _selectedType;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final q = widget.initialQuest;
    _titleCtrl = TextEditingController(text: q?.title);
    _descCtrl = TextEditingController(text: q?.description);
    _xpCtrl = TextEditingController(text: q?.xp.toString());
    _selectedType = q?.type;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _xpCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedType == null) {
      setState(() {});
      return;
    }

    setState(() => _isSaving = true);

    try {
      final payload = QuestFormPayload(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        type: _selectedType!,
        xp: int.parse(_xpCtrl.text.trim()),
      );

      await widget.onSave(payload);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialQuest != null;
    return AlertDialog(
      title: Text(isEditing ? 'Редактировать квест' : 'Создать новый квест'),
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
                  decoration: const InputDecoration(
                    labelText: 'Название квеста',
                  ),
                  validator: validateQuestTitle,
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Краткое описание',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<QuestType>(
                  decoration: InputDecoration(
                    labelText: 'Сфера',
                    errorText: validateQuestType(_selectedType),
                  ),
                  value: _selectedType,
                  items: QuestType.values
                      .map(
                        (t) =>
                            DropdownMenuItem(value: t, child: Text(t.uiLabel)),
                      )
                      .toList(),
                  onChanged: (t) => setState(() => _selectedType = t),
                  validator: validateQuestType,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _xpCtrl,
                  decoration: const InputDecoration(labelText: 'Опыт (XP)'),
                  keyboardType: TextInputType.number,
                  validator: validateQuestXP,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
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
              : Text(isEditing ? 'Сохранить изменения' : 'Создать'),
        ),
      ],
    );
  }
}
