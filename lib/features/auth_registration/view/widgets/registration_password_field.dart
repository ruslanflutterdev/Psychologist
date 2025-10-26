import 'package:flutter/material.dart';
import 'package:heros_journey/features/auth_registration/validators/password_validators.dart';

class RegistrationPasswordField extends StatelessWidget {
  final TextEditingController controller;
  const RegistrationPasswordField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: const InputDecoration(labelText: 'Пароль'),
      validator: validateSecurePassword,
    );
  }
}
