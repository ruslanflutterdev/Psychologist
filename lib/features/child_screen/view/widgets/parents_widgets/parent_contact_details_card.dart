import 'package:flutter/material.dart';
import 'package:heros_journey/features/child_screen/models/parent_contact_model.dart';
import 'package:heros_journey/features/child_screen/view/widgets/parents_widgets/contact_detail_row.dart';

class ParentContactDetailsCard extends StatelessWidget {
  final ParentContactModel contact;
  final ValueSetter<ParentContactModel> onEdit;
  final VoidCallback onDelete;

  const ParentContactDetailsCard({
    super.key,
    required this.contact,
    required this.onEdit,
    required this.onDelete,
  });

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Контакты родителя', style: theme.textTheme.titleMedium),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              tooltip: 'Редактировать',
              onPressed: () => onEdit(contact),
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                size: 20,
                color: theme.colorScheme.error,
              ),
              tooltip: 'Удалить',
              onPressed: onDelete,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const Divider(height: 16),
            ContactDetailRow(label: 'ФИО', value: contact.fullName),
            const SizedBox(height: 8),
            ContactDetailRow(label: 'Телефон', value: contact.phone),
          ],
        ),
      ),
    );
  }
}
