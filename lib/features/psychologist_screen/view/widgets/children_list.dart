import 'package:flutter/material.dart';
import 'package:heros_journey/features/child_screen/models/child_model.dart';
import 'package:heros_journey/features/psychologist_screen/view/widgets/child_tile.dart';

class ChildrenList extends StatelessWidget {
  final List<ChildModel> children;
  final void Function(ChildModel child) onOpenChild;

  const ChildrenList({
    super.key,
    required this.children,
    required this.onOpenChild,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Детей пока нет',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: children.length,
      itemBuilder: (context, i) =>
          ChildTile(child: children[i], onTap: () => onOpenChild(children[i])),
    );
  }
}
