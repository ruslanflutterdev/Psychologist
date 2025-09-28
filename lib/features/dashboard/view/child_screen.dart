import 'package:flutter/material.dart';

class ChildScreen extends StatelessWidget {
  final String childId;
  final String childName;

  const ChildScreen({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Карточка ребёнка')),
      body: Center(child: Text('Ребёнок: $childName (ID: $childId)')),
    );
  }
}
