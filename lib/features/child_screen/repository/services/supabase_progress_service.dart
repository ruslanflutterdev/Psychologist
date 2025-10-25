import 'dart:async';
import 'package:heros_journey/features/child_screen/models/child_progress_model.dart';
import 'package:heros_journey/features/child_screen/repository/services/child_progress_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class SupabaseProgressService implements ProgressService {
  final sb.SupabaseClient _supabase;

  SupabaseProgressService(this._supabase);

  @override
  Stream<ChildProgressModel?> getChildProgress(String childId) async* {
    try {
      final row = await _supabase
          .from('progress_currents')
          .select('pq, eq, iq, soq, sq, max, updated_at')
          .eq('child_id', childId)
          .order('updated_at', ascending: false)
          .maybeSingle();

      if (row == null) {
        yield null;
        return;
      }

      int asInt(dynamic v) {
        if (v == null) return 0;
        if (v is int) return v;
        if (v is num) return v.toInt();
        return int.tryParse(v.toString()) ?? 0;
      }

      final pq = asInt(row['pq']);
      final eq = asInt(row['eq']);
      final iq = asInt(row['iq']);
      final soq = asInt(row['soq']);
      final sq = asInt(row['sq']);
      final maxVal = asInt(row['max']);

      final updatedAtRaw = row['updated_at'];
      final updatedAt = updatedAtRaw != null
          ? DateTime.tryParse(updatedAtRaw.toString()) ?? DateTime.now()
          : DateTime.now();

      final progress = ChildProgressModel(
        childId: childId,
        pq: pq.clamp(0, 100),
        eq: eq.clamp(0, 100),
        iq: iq.clamp(0, 100),
        soq: soq.clamp(0, 100),
        sq: sq.clamp(0, 100),
        max: (maxVal <= 0 ? 100 : maxVal),
        updatedAt: updatedAt,
      );

      yield progress;
    } catch (e) {
      yield null;
    }
  }
}
