import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Панель психолога (Dashboard)')),
      body: const Center(child: Text('Desktop layout — заглушка')),
    );
  }
}
