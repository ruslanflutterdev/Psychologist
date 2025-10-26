class ChildProgressModel {
  final String childId;
  final int pq;
  final int eq;
  final int iq;
  final int soq;
  final int sq;
  final int max;
  final DateTime updatedAt;

  const ChildProgressModel({
    required this.childId,
    required this.pq,
    required this.eq,
    required this.iq,
    required this.soq,
    required this.sq,
    required this.max,
    required this.updatedAt,
  });

  double get totalLevel {
    final sum = pq + eq + iq + soq + sq;
    return (sum / (max * 5)) * 100;
  }

  ChildProgressModel copyWith({
    int? pq,
    int? eq,
    int? iq,
    int? soq,
    int? sq,
    DateTime? updatedAt,
  }) {
    return ChildProgressModel(
      childId: childId,
      pq: pq ?? this.pq,
      eq: eq ?? this.eq,
      iq: iq ?? this.iq,
      soq: soq ?? this.soq,
      sq: sq ?? this.sq,
      max: max,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
