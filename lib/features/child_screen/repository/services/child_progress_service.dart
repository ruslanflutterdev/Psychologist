import 'package:heros_journey/features/child_screen/models/child_progress_model.dart';

abstract class ProgressService {
  Stream<ChildProgressModel?> getChildProgress(String childId);
}
