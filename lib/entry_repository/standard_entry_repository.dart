import 'package:drift/drift.dart';

import 'package:ratings_app/entry_repository/entry_repository.dart';
import 'package:ratings_app/database/database.dart';

class StandardEntryRepository extends EntryRepository {

  StandardEntryRepository(super.db);

  @override
  Future<int> addEntry(int? id, String title, int rating, String dateCompleted, String mediaType, String notes) async {
    return await db.into(db.entries).insert(EntriesCompanion(
      id: id != null ? Value(id) : const Value.absent(),
      title: Value(title),
      rating: Value(rating),
      dateCompleted: Value(dateCompleted),
      mediaType: Value(mediaType),
      notes: Value(notes)
    ));
  }

  @override
  Future<int> editEntry(int id, EntriesCompanion edit) async {
    return await (db.update(db.entries)..where(
      (e) => e.id.equals(id)
    )).write(edit);
  }

  @override
  Future<int> deleteEntry(int id) async {
    return await (db.delete(db.entries)..where(
      (e) => e.id.equals(id)
    )).go();
  }
}