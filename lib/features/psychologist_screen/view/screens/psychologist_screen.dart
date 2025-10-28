import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heros_journey/core/services/service_registry.dart';
import 'package:heros_journey/core/session/session_cubit.dart';
import 'package:heros_journey/features/child_screen/models/child_model.dart';
import 'package:heros_journey/features/child_screen/view/screens/child_screen.dart';
import 'package:heros_journey/features/psychologist_screen/model/psychologist_model.dart';
import 'package:heros_journey/features/psychologist_screen/viewmodel/widgets/psychologist_body.dart';
import 'package:heros_journey/features/quest_catalog/view/screens/quests_catalog_screen.dart';

class PsychologistScreen extends StatelessWidget {
  const PsychologistScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await ServiceRegistry.auth.logout();
    await ServiceRegistry.auth.clearAllLocalData();
    if (!context.mounted) return;
    context.read<SessionCubit>().clear();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    }
  }

  void _openChild(BuildContext context, ChildModel child) {
    Navigator.of(context).push(
      MaterialPageRoute<ChildScreen>(
        builder: (_) => ChildScreen(
          childId: child.id,
          childName: child.name,
        ),
      ),
    );
  }

  void _openQuestsCatalog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<QuestsCatalogScreen>(
        builder: (_) => const QuestsCatalogScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, dynamic>(
      builder: (context, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) => _logout(context),
          child: Scaffold(
            appBar: AppBar(
              title: const _AppBarTitle(),
              backgroundColor: Colors.white,
              scrolledUnderElevation: 0,
              elevation: 0.5,
              actions: [
                IconButton(
                  tooltip: 'Каталог квестов',
                  icon: const Icon(Icons.library_add),
                  onPressed: () => _openQuestsCatalog(context),
                ),
                TextButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Выйти'),
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
                ),
              ],
            ),
            body: PsychologistBody(onOpenChild: (c) => _openChild(context, c)),
          ),
        );
      },
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PsychologistModel>(
      future: ServiceRegistry.psychologist.getProfile(),
      builder: (context, snapshot) {
        final Widget title = () {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Text('Панель психолога');
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Text('Панель психолога');
          }
          final p = snapshot.data;
          return Text(p?.fullName ?? 'Панель психолога');
        }();
        return title;
      },
    );
  }
}
