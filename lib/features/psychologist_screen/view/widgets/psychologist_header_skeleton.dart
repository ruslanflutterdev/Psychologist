import 'package:flutter/material.dart';

class PsychologistHeaderSkeleton extends StatelessWidget {
  const PsychologistHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.all(12),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          height: 56,
          child: Align(
            alignment: Alignment.centerLeft,
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
