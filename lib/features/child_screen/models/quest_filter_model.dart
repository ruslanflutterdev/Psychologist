class QuestTimeFilter {
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const QuestTimeFilter({this.dateFrom, this.dateTo});

  bool get isActive => dateFrom != null || dateTo != null;

  static const inactive = QuestTimeFilter();

  QuestTimeFilter copyWith({DateTime? dateFrom, DateTime? dateTo}) {
    return QuestTimeFilter(dateFrom: dateFrom, dateTo: dateTo);
  }
}
