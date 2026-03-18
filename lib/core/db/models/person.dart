import 'package:isar/isar.dart';

part 'person.g.dart';

@collection
class Person {
  Id id = Isar.autoIncrement;
  String name = '';
  String? phoneNumber;
  String? avatarPath;
  bool isFromContacts = false;
}
