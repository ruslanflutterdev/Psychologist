import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heros_journey/core/services/service_registry.dart';
import 'package:heros_journey/core/session/session_cubit.dart';
import 'package:heros_journey/features/child_screen/view/models/child_model.dart';
import 'package:heros_journey/features/child_screen/view/screens/child_screen.dart';

class PsychologistScreen extends StatelessWidget {
  const PsychologistScreen({super.key});

  void _logout(BuildContext context) {
    context.read<SessionCubit>().clear();
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  Future<List<ChildModel>> _loadChildren() {
    return ServiceRegistry.child.getChildren();
  }

  void _openChild(BuildContext context, ChildModel child) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChildScreen(childId: child.id, childName: child.name),
      ),
    );
  }

  Widget _buildChildTile(BuildContext context, ChildModel child) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(child.name),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _openChild(context, child),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<ChildModel> children) {
    return ListView.builder(
      itemCount: children.length,
      itemBuilder: (context, i) => _buildChildTile(context, children[i]),
    );
  }

  Widget _buildBody(BuildContext context) {
    return FutureBuilder<List<ChildModel>>(
      future: _loadChildren(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Ошибка загрузки: ${snapshot.error}'));
        }
        final children = snapshot.data ?? const <ChildModel>[];
        return _buildList(context, children);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _logout(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Панель психолога'),
          actions: [
            TextButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Выйти'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
        body: _buildBody(context),
      ),
    );
  }
}
