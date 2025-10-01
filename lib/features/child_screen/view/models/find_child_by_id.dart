import 'package:heros_journey/core/services/service_registry.dart';
import 'package:heros_journey/features/child_screen/view/models/child_model.dart';

Future<ChildModel?> findChildById(String id) async {
  final list = await ServiceRegistry.child.getChildren();
  try {
    return list.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
}
