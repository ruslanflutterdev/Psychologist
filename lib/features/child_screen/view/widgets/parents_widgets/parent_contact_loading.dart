import 'package:flutter/material.dart';

class ParentContactLoading extends StatelessWidget {
  const ParentContactLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 40,
      child: Center(child: LinearProgressIndicator()),
    );
  }
}
