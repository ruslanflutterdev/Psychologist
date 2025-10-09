import 'package:flutter/material.dart';

class RegistrationEmailField extends StatelessWidget {
  final TextEditingController controller;
  const RegistrationEmailField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(labelText: 'Email'),
      validator: (v) {
        final val = v?.trim() ?? '';
        if (val.isEmpty) return 'Введите E-mail';
        if (!val.contains('@')) return 'Некорректный E-mail';
        return null;
      },
    );
  }
}
