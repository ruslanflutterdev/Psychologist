import 'package:flutter/material.dart';

enum ConsentMark { none, check, cross }

class ConsentSquare extends StatelessWidget {
  final ConsentMark value;
  final ValueChanged<ConsentMark> onChanged;
  final double size;

  const ConsentSquare({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 22,
  });

  void _cycle() {
    switch (value) {
      case ConsentMark.none:
        onChanged(ConsentMark.check);
        break;
      case ConsentMark.check:
        onChanged(ConsentMark.cross);
        break;
      case ConsentMark.cross:
        onChanged(ConsentMark.none);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    IconData? icon;
    if (value == ConsentMark.check) icon = Icons.check;
    if (value == ConsentMark.cross) icon = Icons.close;

    return InkWell(
      onTap: _cycle,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(color: cs.outline),
          borderRadius: BorderRadius.circular(4),
          color: icon == null ? null : cs.primary.withValues(alpha: 0.08),
        ),
        alignment: Alignment.center,
        child: icon == null
            ? null
            : Icon(icon, size: size * 0.75, color: cs.primary),
      ),
    );
  }
}
