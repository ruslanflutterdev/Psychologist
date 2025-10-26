import 'package:flutter/material.dart';

class ParentContactError extends StatelessWidget {
  final Object? error;

  const ParentContactError({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Ошибка загрузки контактов: ${error ?? "Неизвестная ошибка"}',
      ),
    );
  }
}
