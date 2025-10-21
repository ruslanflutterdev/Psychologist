import 'dart:async';
import 'package:flutter/material.dart';
import 'package:heros_journey/core/models/quest_models.dart';
import 'package:heros_journey/core/services/service_registry.dart';
import 'package:heros_journey/features/quest_catalog/models/quest_catalog_filter.dart';
import 'package:heros_journey/features/quest_catalog/view/widgets/quest_form_dialog.dart';
import 'package:heros_journey/features/quest_catalog/view_model/widgets/catalog_filter_row.dart';
import 'package:heros_journey/features/quest_catalog/view_model/widgets/catalog_quests_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class QuestsCatalogScreen extends StatefulWidget {
  const QuestsCatalogScreen({super.key});

  @override
  State<QuestsCatalogScreen> createState() => _QuestsCatalogScreenState();
}

class _QuestsCatalogScreenState extends State<QuestsCatalogScreen> {
  QuestCatalogFilter _filter = QuestCatalogFilter.initial;

  String get _currentUserId =>
      sb.Supabase.instance.client.auth.currentUser?.id ?? 'ANON';

  List<Quest> _quests = [];
  bool _isLoading = false;
  StreamSubscription<List<Quest>>? _questsSubscription;

  @override
  void initState() {
    super.initState();
    _loadQuests();
  }

  @override
  void dispose() {
    _questsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadQuests() async {
    setState(() => _isLoading = true);
    await _questsSubscription?.cancel();

    try {
      final loadedQuests = await ServiceRegistry.questCatalog.getAll();
      if (mounted) {
        setState(() => _quests = loadedQuests);
      }

      _questsSubscription = ServiceRegistry.questCatalog
          .getQuests(filter: _filter)
          .listen((list) {
        if (mounted) {
          setState(() => _quests = list);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleActive(Quest q) async {
    try {
      await ServiceRegistry.questCatalog.toggleActive(
        id: q.id,
        active: !q.active,
        toggledBy: _currentUserId,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  void _openCreateDialog() async {
    await showDialog<void>(
      context: context,
      builder: (_) => QuestFormDialog(
        onSave: (data) async {
          await ServiceRegistry.questCatalog.createQuest(
            title: data.title,
            description: data.description,
            type: data.type,
            xp: data.xp,
            createdBy: _currentUserId,
          );
        },
      ),
    );
  }

  void _openEditDialog(Quest quest) async {
    await showDialog<void>(
      context: context,
      builder: (_) => QuestFormDialog(
        initialQuest: quest,
        onSave: (data) async {
          await ServiceRegistry.questCatalog.updateQuest(
            id: quest.id,
            title: data.title,
            description: data.description,
            type: data.type,
            xp: data.xp,
            updatedBy: _currentUserId,
          );
        },
      ),
    );
  }

  void _handleFilterChange({
    String? search,
    QuestType? type,
    bool? onlyActive,
  }) {
    final newFilter = _filter.copyWith(
      search: search,
      type: type,
      onlyActive: onlyActive,
    );

    if (newFilter.search != _filter.search ||
        newFilter.type != _filter.type ||
        newFilter.onlyActive != _filter.onlyActive) {
      setState(() => _filter = newFilter);
      _loadQuests();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталог квестов'),
        actions: [
          IconButton(
            onPressed: _openCreateDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Создать квест',
          ),
          IconButton(
            onPressed: _isLoading ? null : _loadQuests,
            icon: _isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.refresh),
            tooltip: 'Обновить список квестов',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CatalogFilterRow(
                filter: _filter,
                onSearchChanged: (v) =>
                    _handleFilterChange(search: v?.isEmpty == true ? null : v),
                onTypeChanged: (t) => _handleFilterChange(type: t),
                onActiveToggled: (v) => _handleFilterChange(onlyActive: v),
              ),
              CatalogQuestsList(
                quests: _quests,
                isLoading: _isLoading,
                currentUserId: _currentUserId,
                onEdit: _openEditDialog,
                onToggleActive: _toggleActive,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
