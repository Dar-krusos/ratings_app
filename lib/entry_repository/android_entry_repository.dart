import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart';

import 'package:ratings_app/entry_repository/entry_repository.dart';
import 'package:ratings_app/database/database.dart';

class AndroidEntryRepository extends EntryRepository {

  static const platform = MethodChannel('com.darkrusos.ratings_app');

  AndroidEntryRepository(super.db);

  @override
  Future<int> addEntry(int? id, String title, int rating, String dateCompleted, String mediaType, String notes) async {
    final returnId = await db.into(db.entries).insert(EntriesCompanion(
      id: id != null ? Value(id) : const Value.absent(),
      title: Value(title),
      rating: Value(rating),
      dateCompleted: Value(dateCompleted),
      mediaType: Value(mediaType),
      notes: Value(notes)
    ));

    final success = await writeFile(await db.readAsBytes());

    if (success != 0) {
      return success;
    } else {
      return returnId;
    }
  }

  @override
  Future<int> editEntry(int id, EntriesCompanion edit) async {
    final returnId = await (db.update(db.entries)..where(
      (e) => e.id.equals(id)
    )).write(edit);

    final success = await writeFile(await db.readAsBytes());

    if (success != 0) {
      return success;
    } else {
      return returnId;
    }
  }

  @override
  Future<int> deleteEntry(int id) async {
    final returnId = await (db.delete(db.entries)..where(
      (e) => e.id.equals(id)
    )).go();

    final success = await writeFile(await db.readAsBytes());

    if (success != 0) {
      return success;
    } else {
      return returnId;
    }
  }

  Future<int> writeFile(Uint8List bytes) async {
    try {
      await platform.invokeMethod('writeFile', {
        'uri': db.dbFolder,
        'fileName': db.dbFileName,
        'bytes': bytes,
      });
      return 0;
    } on PlatformException catch (e) {
      debugPrint("Error writing to file: ${e.message}");
      return 1;
    }
  }
}