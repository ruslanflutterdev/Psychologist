import 'package:flutter/material.dart';

class ChildErrorText extends StatelessWidget {
  final String? error;

  const ChildErrorText({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    if (error == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        error!,
        style: theme.textTheme.bodyMedium!.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}
