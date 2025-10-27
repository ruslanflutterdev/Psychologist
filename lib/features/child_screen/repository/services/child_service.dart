import 'package:heros_journey/features/child_screen/models/child_model.dart';

abstract class ChildService {
  Stream<List<ChildModel>> getChildren();
}
