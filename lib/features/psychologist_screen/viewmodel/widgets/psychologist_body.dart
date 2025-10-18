import 'package:flutter/material.dart';
import 'package:heros_journey/core/services/service_registry.dart';
import 'package:heros_journey/features/child_screen/models/child_model.dart';
import 'package:heros_journey/features/psychologist_screen/model/psychologist_model.dart';
import 'package:heros_journey/features/psychologist_screen/view/widgets/children_list.dart';
import 'package:heros_journey/features/psychologist_screen/view/widgets/psychologist_header_skeleton.dart';
import 'package:heros_journey/features/psychologist_screen/viewmodel/widgets/psychologist_header.dart';

class PsychologistBody extends StatelessWidget {
  final void Function(ChildModel child) onOpenChild;

  const PsychologistBody({super.key, required this.onOpenChild});

  Future<PsychologistModel> _loadProfile() =>
      ServiceRegistry.psychologist.getProfile();

  Future<List<ChildModel>> _loadChildren() =>
      ServiceRegistry.child.getChildren();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PsychologistModel>(
      future: _loadProfile(),
      builder: (context, profileSnap) {
        final header = switch (profileSnap.connectionState) {
          ConnectionState.done =>
            profileSnap.hasError
                ? const SizedBox.shrink()
                : PsychologistHeader(profile: profileSnap.data!),
          _ => const PsychologistHeaderSkeleton(),
        };

        return Column(
          children: [
            header,
            Expanded(
              child: FutureBuilder<List<ChildModel>>(
                future: _loadChildren(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Ошибка загрузки: ${snapshot.error}'),
                    );
                  }
                  final children = snapshot.data ?? const <ChildModel>[];
                  return ChildrenList(
                    children: children,
                    onOpenChild: onOpenChild,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
