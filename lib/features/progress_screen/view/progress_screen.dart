import 'dart:async';
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
  final _progressController = StreamController<ChildProgressModel?>.broadcast();
  StreamSubscription<ChildProgressModel?>? _progressSubscription;
  bool _initialLoadCompleted = false;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    _progressController.close();
    super.dispose();
  }

  void _startListening() {
    _initialLoadCompleted = false;
    _progressSubscription?.cancel();

    _progressSubscription =
        ServiceRegistry.progress.getChildProgress(widget.childId).listen(
      (data) {
        _progressController.add(data);
        if (!_initialLoadCompleted) {
          setState(() => _initialLoadCompleted = true);
        }
      },
      onError: (Object e) {
        if (!_initialLoadCompleted) {
          _progressController.addError(e);
        }
        setState(() => _initialLoadCompleted = true);
      },
    );
  }

  Future<void> _refresh() async {
    _startListening();
    await _progressController.stream.first
        .timeout(const Duration(seconds: 5), onTimeout: () => null)
        .catchError((_) => null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('Прогресс: ${widget.childName}')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    child: StreamBuilder<ChildProgressModel?>(
                      stream: _progressController.stream,
                      builder: (context, snap) {
                        final data = snap.data;

                        if (snap.connectionState == ConnectionState.waiting ||
                            !_initialLoadCompleted) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snap.hasError && data == null) {
                          return Center(
                            child: Text(
                              'Ошибка загрузки: ${snap.error}',
                              style: theme.textTheme.bodyMedium!.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          );
                        }

                        if (data == null) {
                          return const Center(
                            child: Text(
                              'Прогресс ещё не рассчитан. Потяните вниз, чтобы обновить.',
                              style: TextStyle(fontSize: 16),
                            ),
                          );
                        }

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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
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
                                      child:
                                          SizedBox(height: 480, child: chart),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
