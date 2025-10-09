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
}
