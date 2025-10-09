import 'package:heros_journey/features/child_screen/models/child_model.dart';
import 'package:heros_journey/features/child_screen/repository/services/child_service.dart';

class MockChildService implements ChildService {
  final List<ChildModel> _children = const [
    ChildModel(
      id: '1',
      firstName: 'Иван',
      lastName: 'Петров',
      age: 10,
      gender: ChildGender.male,
    ),
    ChildModel(
      id: '2',
      firstName: 'Алина',
      lastName: 'Садыкова',
      age: 11,
      gender: ChildGender.female,
    ),
    ChildModel(
      id: '3',
      firstName: 'Марат',
      lastName: 'Нурланов',
      age: 9,
      gender: ChildGender.male,
    ),
    ChildModel(
      id: '4',
      firstName: 'Саша',
      lastName: 'Иванова',
      age: 12,
      gender: ChildGender.female,
    ),
    ChildModel(
      id: '5',
      firstName: 'Диана',
      lastName: 'Ахметова',
      age: 10,
      gender: ChildGender.female,
    ),
  ];

  @override
  Future<List<ChildModel>> getChildren() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _children;
  }
}
