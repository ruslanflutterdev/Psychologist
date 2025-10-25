import 'package:flutter/material.dart';
import 'package:heros_journey/core/services/service_registry.dart';
import 'package:heros_journey/features/child_screen/models/child_progress_model.dart';
import 'package:heros_journey/features/progress_screen/viewmodel/widgets/meta_card.dart';
import 'package:heros_journey/features/progress_screen/viewmodel/widgets/radar_chart_card.dart';

class ProgressScreen extends StatefulWidget {
  final String childId;
  final String childName;

  const ProgressScreen({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late Future<ChildProgressModel?> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadOnce();
  }

  Future<ChildProgressModel?> _loadOnce() async {
    return ServiceRegistry.progress
        .getChildProgress(widget.childId)
        .first;
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _loadOnce();
    });
    // ignore: body_might_complete_normally_catch_error
    await _future.catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Прогресс — ${widget.childName}'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: FutureBuilder<ChildProgressModel?>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    snapshot.data == null) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    children: const [
                      SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  );
                }
                if (snapshot.hasError) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    children: [
                      Text(
                        'Ошибка загрузки прогресса: ${snapshot.error}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Потяните вниз, чтобы повторить',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                }
                final data = snapshot.data;
                if (data == null) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    children: [
                      Text(
                        'Нет данных для отображения',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Потяните вниз, чтобы обновить',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                }
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: RadarChartCard(data: data),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: MetaCard(data: data),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Потяните вниз, чтобы обновить',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
