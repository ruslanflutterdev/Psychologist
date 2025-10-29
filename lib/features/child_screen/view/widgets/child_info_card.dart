import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heros_journey/features/child_screen/models/child_model.dart';
import 'package:intl/intl.dart';

class ChildInfoCard extends StatelessWidget {
  final bool isLoading;
  final ChildModel? child;

  const ChildInfoCard({
    super.key,
    required this.isLoading,
    required this.child,
  });

  void _copyToClipboard(BuildContext context, String number) {
    Clipboard.setData(ClipboardData(text: number));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Номер скопирован в буфер обмена')),
    );
  }

  Widget _buildRow(BuildContext context, String label, String value,
      {TextStyle? style, Widget? trailing}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: style ??
                        theme.textTheme.bodyMedium!
                            .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Card(
        margin: EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (child == null) {
      return const Card(
        margin: EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Данные ребёнка не найдены'),
        ),
      );
    }

    final formattedDate = child!.updatedAt != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(child!.updatedAt!)
        : 'Нет данных';
    final hasParentNumber = child!.parentNumber?.isNotEmpty == true;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Информация о ребёнке', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _buildRow(context, 'Имя ребёнка', child!.firstName),
            const SizedBox(height: 6),
            _buildRow(context, 'Фамилия ребёнка', child!.lastName),
            const SizedBox(height: 6),
            _buildRow(context, 'Возраст ребёнка', '${child!.age}'),
            const SizedBox(height: 6),
            _buildRow(context, 'Пол ребёнка', child!.gender.uiLabel),
            const SizedBox(height: 6),
            _buildRow(context, 'Архетип', child!.archetype ?? 'Не определен'),
            const Divider(height: 24),
            Text('Контакты родителя', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            if (child!.parentFullName?.isNotEmpty == true) ...[
              _buildRow(context, 'ФИО родителя', child!.parentFullName!),
              const SizedBox(height: 6),
            ],
            _buildRow(
              context,
              'Телефон',
              hasParentNumber ? child!.parentNumber! : 'Номер не указан',
              trailing: hasParentNumber
                  ? IconButton(
                      icon: const Icon(Icons.copy, size: 16),
                      tooltip: 'Копировать номер',
                      onPressed: () =>
                          _copyToClipboard(context, child!.parentNumber!),
                    )
                  : null,
            ),
            const Divider(height: 24),
            _buildRow(
              context,
              'Последнее обновление профиля',
              formattedDate,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
