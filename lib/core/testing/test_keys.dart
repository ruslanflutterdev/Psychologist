import 'package:flutter/widgets.dart';

class Tk {

  static const addQuestBtn = Key('child.addQuestButton');
  static const assignedList = Key('child.assignedList');
  static const questPicker = Key('quest.picker');


  static Key filterChip(String t) => Key('quest.filter.$t');
  static Key questTile(String id) => Key('quest.tile.$id');
  static Key assignBtn(String id) => Key('quest.assign.$id');

  static Key completedItem(String id) => Key('child.completed.$id');
  static Key completedTitle(String id) => Key('child.completed.title.$id');
  static Key completedComment(String id) => Key('child.completed.comment.$id');
  static Key completedPhoto(String id) => Key('child.completed.photo.$id');
  static Key completedDate(String id) => Key('child.completed.date.$id');
}
