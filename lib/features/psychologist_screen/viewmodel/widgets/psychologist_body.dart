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

  Stream<List<ChildModel>> _streamChildren() =>
      ServiceRegistry.child.getChildren();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PsychologistModel>(
      future: _loadProfile(),
      builder: (context, profileSnap) {
        final PsychologistModel? profile = profileSnap.data;

        final header = switch (profileSnap.connectionState) {
          ConnectionState.done => profileSnap.hasError || profile == null
              ? const SizedBox.shrink()
              : PsychologistHeader(psychologist: profile),
          _ => const PsychologistHeaderSkeleton(),
        };

        return Column(
          children: [
            header,
            Expanded(
              child: StreamBuilder<List<ChildModel>>(
                stream: _streamChildren(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
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
