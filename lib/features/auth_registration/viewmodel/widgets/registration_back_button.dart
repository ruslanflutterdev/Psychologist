import 'package:flutter/material.dart';

class RegistrationBackButton extends StatelessWidget {
  const RegistrationBackButton({super.key});

  void _goBack(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _goBack(context),
      icon: const Icon(Icons.arrow_back),
      label: const Text('Назад'),
    );
  }
}
