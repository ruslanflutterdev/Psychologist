import 'package:flutter/material.dart';
import 'package:heros_journey/core/services/service_registry.dart';

class AgreementScreen extends StatelessWidget {
  const AgreementScreen({super.key});

  Future<String> _load() => ServiceRegistry.agreement.getUserAgreementText();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Пользовательское соглашение')),
      body: FutureBuilder<String>(
        future: _load(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Ошибка загрузки: ${snap.error}'));
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Text(
                snap.data ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        },
      ),
    );
  }
}
