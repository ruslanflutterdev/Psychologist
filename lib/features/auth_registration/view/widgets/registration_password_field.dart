import 'package:flutter/material.dart';

class RegistrationPasswordField extends StatelessWidget {
  final TextEditingController controller;
  const RegistrationPasswordField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: const InputDecoration(labelText: 'Пароль'),
      validator: (v) {
        final val = v?.trim() ?? '';
        if (val.isEmpty) return 'Введите пароль';
        if (val.length < 6) return 'Минимум 6 символов';
        return null;
      },
    );
  }
}
