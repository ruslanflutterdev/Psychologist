import 'dart:async';
import 'package:heros_journey/core/services/agreement_service.dart';

class MockAgreementService implements AgreementService {
  final Duration latency;

  const MockAgreementService({
    this.latency = const Duration(milliseconds: 200),
  });

  static const String _text = '''
PsyWell — Пользовательское соглашение (мок)

1. Общие положения
Настоящее соглашение регулирует порядок использования веб-приложения для психологов PsyWell.

2. Персональные данные
Пользователь подтверждает, что ознакомился с политикой обработки данных и соглашается с ней.

3. Ограничение ответственности
Сервис предоставляется «как есть» без гарантий пригодности для конкретных целей.

4. Заключительные положения
Используя сервис, пользователь подтверждает согласие с условиями.

(Тестовый мок-текст; замените на актуальную редакцию при подключении API.)
''';

  @override
  Future<String> getUserAgreementText() async {
    await Future<void>.delayed(latency);
    return _text;
  }
}
