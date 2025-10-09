import 'package:flutter/material.dart';

class ConsentCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double size;

  const ConsentCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(color: cs.outline),
          borderRadius: BorderRadius.circular(4),
          color: value ? cs.primary.withValues(alpha: 0.08) : null,
        ),
        alignment: Alignment.center,
        child: value
            ? Icon(Icons.check, size: size * .82, color: cs.primary)
            : null,
      ),
    );
  }
}
