import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/db/isar_service.dart';
import '../../../core/db/models/person.dart';

part 'contact_provider.g.dart';

@riverpod
Future<List<fc.Contact>> phoneContacts(Ref ref) async {
  final hasPermission = await fc.FlutterContacts.requestPermission();
  if (!hasPermission) return [];
  return fc.FlutterContacts.getContacts(withProperties: true);
}

@riverpod
Future<List<Person>> savedPersons(Ref ref) async {
  final db = ref.watch(isarProvider);
  return db.persons.where().sortByName().findAll();
}

@riverpod
Future<Person> getOrCreatePerson(
  Ref ref, {
  required String personName,
  String? phoneNumber,
  bool isFromContacts = false,
}) async {
  final db = ref.watch(isarProvider);

  // Try to find existing by phone number first
  if (phoneNumber != null && phoneNumber.isNotEmpty) {
    final existing = await db.persons
        .filter()
        .phoneNumberEqualTo(phoneNumber)
        .findFirst();
    if (existing != null) return existing;
  }

  // Try by exact name
  final existingByName = await db.persons
      .filter()
      .nameEqualTo(personName)
      .findFirst();
  if (existingByName != null) return existingByName;

  // Create new
  final person = Person()
    ..name = personName
    ..phoneNumber = phoneNumber
    ..isFromContacts = isFromContacts;

  await db.writeTxn(() => db.persons.put(person));
  return person;
}
