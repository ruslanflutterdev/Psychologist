import 'package:flutter/material.dart';

class ConsentRow extends StatelessWidget {
  final Widget checkbox;
  final VoidCallback onOpenAgreement;

  const ConsentRow({
    super.key,
    required this.checkbox,
    required this.onOpenAgreement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        checkbox,
        const SizedBox(width: 10),
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Я ознакомился с ', style: theme.textTheme.bodyMedium),
              InkWell(
                onTap: onOpenAgreement,
                child: Text(
                  'пользовательским соглашением',
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: theme.colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
