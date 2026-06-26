import 'package:test/test.dart';
import 'dart:io';
import 'package:drift/drift.dart';

import 'package:ratings_app/database/database.dart';
import 'package:ratings_app/database/database_repository.dart';

void main() {
  late final AppDatabase db;
  late final EntryRepository entryRepository;
  late List<Entry> entries;

  setUpAll(() {
    db = AppDatabase('test/test_database.db');
    entryRepository = EntryRepository(db);
  });

  setUp(() async {
    entries = await db.select(db.entries).get();
  });

  test('EntryRepository adds entry to database', () async {

    expect(entries.isEmpty, true);

    final title = 'Test title';
    final rating = 57;
    final time = DateTime.now().toString();
    final type = 'Test Type';
    final notes = 'Test notes';

    await entryRepository.addEntry(null, title, rating, time, type, notes);
    entries = await db.select(db.entries).get();

    expect(entries.length, 1);
    expect(entries[0].title, title);
    expect(entries[0].rating, rating);
    expect(entries[0].dateCompleted, time);
    expect(entries[0].mediaType, type);
    expect(entries[0].notes, notes);
  });

  test('EntryRepository updates database entry', () async {

    expect(entries.length, 1);

    final title = 'Test title2';
    final rating = 58;
    final time = DateTime.now().toString();
    final type = 'Test Type2';
    final notes = 'Test notes2';

    final entryUpdate = EntriesCompanion(
      title: Value(title),
      rating: Value(rating),
      dateCompleted: Value(time),
      mediaType: Value(type),
      notes: Value(notes),
    );

    await entryRepository.editEntry(1, entryUpdate);
    entries = await db.select(db.entries).get();

    expect(entries.length, 1);
    expect(entries[0].title, title);
    expect(entries[0].rating, rating);
    expect(entries[0].dateCompleted, time);
    expect(entries[0].mediaType, type);
    expect(entries[0].notes, notes);
  });

  test('EntryRepository deletes database entry', () async {
    
    expect(entries.length, 1);

    await entryRepository.deleteEntry(1);
    entries = await db.select(db.entries).get();

    expect(entries.isEmpty, true);
  });

  tearDownAll(() async {
    await db.close();
    await File('test/test_database.db').delete().catchError((err) {return err;});
  });
}
