import 'package:flutter/material.dart';
import 'package:heros_journey/features/child_screen/view/models/child_model.dart';

class ChildTile extends StatelessWidget {
  final ChildModel child;
  final VoidCallback onTap;

  const ChildTile({super.key, required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(child.name),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
