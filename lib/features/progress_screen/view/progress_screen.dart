import 'package:flutter/material.dart';
import 'package:heros_journey/core/services/service_registry.dart';
import 'package:heros_journey/features/child_screen/view/models/child_progress_model.dart';
import 'package:heros_journey/features/progress_screen/viewmodel/widgets/meta_card.dart';
import 'package:heros_journey/features/progress_screen/viewmodel/widgets/radar_chart_card.dart';

class ProgressScreen extends StatelessWidget {
  final String childId;
  final String childName;

  const ProgressScreen({
    super.key,
    required this.childId,
    required this.childName,
  });


  Future<ChildProgressModel> _load() =>
      ServiceRegistry.progress.getChildProgress(childId);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('Прогресс: $childName')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FutureBuilder<ChildProgressModel>(
              future: _load(),
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(
                    child: Text(
                      'Ошибка загрузки: ${snap.error}',
                      style: theme.textTheme.bodyMedium!
                          .copyWith(color: theme.colorScheme.error),
                    ),
                  );
                }

                final data = snap.data!;
                return Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 720;

                        final meta = MetaCard(data: data);
                        final chart = RadarChartCard(data: data);

                        if (isNarrow) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              meta,
                              const SizedBox(height: 16),
                              SizedBox(height: 380, child: chart),
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 4, child: meta),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 7,
                              child: SizedBox(height: 480, child: chart),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
