import 'package:flutter/material.dart';

class RegistrationSubmitButton extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final VoidCallback onPressed;

  const RegistrationSubmitButton({
    super.key,
    required this.enabled,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: enabled ? onPressed : null,
      child: isLoading
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      )
          : const Text('Зарегистрироваться'),
    );
  }
}
