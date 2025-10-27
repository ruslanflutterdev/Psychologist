import 'package:flutter/material.dart';
import 'package:heros_journey/features/child_screen/models/parent_contact_model.dart';
import 'package:heros_journey/features/child_screen/repository/services/parent_contact_service.dart';
import 'package:heros_journey/features/child_screen/view/widgets/parents_widgets/parent_contact_add_button.dart';
import 'package:heros_journey/features/child_screen/view/widgets/parents_widgets/parent_contact_details_card.dart';
import 'package:heros_journey/features/child_screen/view/widgets/parents_widgets/parent_contact_error.dart';
import 'package:heros_journey/features/child_screen/view/widgets/parents_widgets/parent_contact_loading.dart';
import 'package:heros_journey/features/child_screen/view_model/parents_widgets/parent_contact_form_dialog.dart';

class ParentContactCard extends StatefulWidget {
  final String childId;
  final ParentContactService service;

  const ParentContactCard({
    super.key,
    required this.childId,
    required this.service,
  });

  @override
  State<ParentContactCard> createState() => _ParentContactCardState();
}

class _ParentContactCardState extends State<ParentContactCard> {
  Future<ParentContactModel?>? _contactFuture;

  @override
  void initState() {
    super.initState();
    _loadContact();
  }

  void _loadContact() {
    setState(() {
      _contactFuture = widget.service.getContact(widget.childId);
    });
  }

  Future<void> _addOrEditContact(ParentContactModel? initial) async {
    final newContact = await showDialog<ParentContactModel>(
      context: context,
      builder: (_) => ParentContactFormDialog(initialContact: initial),
    );

    if (newContact != null) {
      await widget.service.saveContact(widget.childId, newContact);
      _loadContact();
    }
  }

  Future<void> _deleteContact() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить контакт?'),
        content: const Text(
          'Вы уверены, что хотите удалить контакты родителя?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.service.deleteContact(widget.childId);
      _loadContact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ParentContactModel?>(
      future: _contactFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const ParentContactLoading();
        }
        if (snapshot.hasError) {
          return ParentContactError(error: snapshot.error);
        }
        final contact = snapshot.data;
        if (contact == null) {
          return ParentContactAddButton(
            onPressed: () => _addOrEditContact(null),
          );
        }
        return ParentContactDetailsCard(
          contact: contact,
          onEdit: _addOrEditContact,
          onDelete: _deleteContact,
        );
      },
    );
  }
}
