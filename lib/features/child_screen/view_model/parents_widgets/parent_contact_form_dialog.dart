import 'package:flutter/material.dart';
import 'package:heros_journey/features/child_screen/models/parent_contact_model.dart';
import 'package:heros_journey/features/child_screen/validators/general_validators.dart';

class ParentContactFormDialog extends StatefulWidget {
  final ParentContactModel? initialContact;

  const ParentContactFormDialog({super.key, this.initialContact});

  @override
  State<ParentContactFormDialog> createState() =>
      _ParentContactFormDialogState();
}

class _ParentContactFormDialogState extends State<ParentContactFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialContact?.fullName);
    _phoneCtrl = TextEditingController(text: widget.initialContact?.phone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final newContact = ParentContactModel(
        fullName: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
      );
      Navigator.of(context).pop(newContact);
    }
  }

  Widget _buildTitle() {
    final isEditing = widget.initialContact != null;
    return Text(
      isEditing ? 'Редактировать контакты' : 'Добавить контакты родителя',
    );
  }

  Widget _buildFormContent() {
    return SizedBox(
      width: 400,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'ФИО родителя/опекуна',
              ),
              validator: validateFullName,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Телефон',
                hintText: '+7 XXX XXX XX XX',
              ),
              validator: validatePhoneRK,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions() {
    final isEditing = widget.initialContact != null;
    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Отмена'),
      ),
      FilledButton(
        onPressed: _save,
        child: Text(isEditing ? 'Сохранить' : 'Добавить'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _buildTitle(),
      content: _buildFormContent(),
      actions: _buildActions(),
    );
  }
}
