import 'package:flutter/material.dart';

class ParentContactAddButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ParentContactAddButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.person_add),
        label: const Text('Добавить контакты родителя'),
      ),
    );
  }
}
