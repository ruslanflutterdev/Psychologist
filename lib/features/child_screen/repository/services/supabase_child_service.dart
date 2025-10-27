import 'package:heros_journey/features/child_screen/models/child_model.dart';
import 'package:heros_journey/features/child_screen/repository/services/child_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class SupabaseChildService implements ChildService {
  final sb.SupabaseClient _supabase;

  SupabaseChildService(this._supabase);

  ChildModel _mapRow(Map<String, dynamic> r) {
    ChildGender mapGender(String? gender) {
      if (gender == 'female') return ChildGender.female;
      return ChildGender.male;
    }

    return ChildModel(
      id: r['id'] as String,
      firstName: r['first_name'] as String,
      lastName: r['last_name'] as String,
      age: r['age'] as int,
      gender: mapGender(r['gender'] as String?),
      archetype: r['archetype'] as String?,
      updatedAt: DateTime.tryParse(r['updated_at'] as String),
    );
  }

  @override
  Stream<List<ChildModel>> getChildren() {
    return _supabase
        .from('child_profiles')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .map(
          (rows) =>
              rows.map<Map<String, dynamic>>((e) => e).map(_mapRow).toList(),
        );
  }
}
