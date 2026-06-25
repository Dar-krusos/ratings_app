import 'package:test/test.dart';
import 'dart:io';

import 'package:ratings_app/database/database.dart';

void main() {

  late final AppDatabase database;

  test('AppDatabase creates new file when not pre-existing', () async {
    database = AppDatabase('test/test_database.db');
    final entries = await database.select(database.entries).get();
    expect(entries.isEmpty, true);
  });
  
  test('AppDatabase opens pre-existing file', () async {
    final database = AppDatabase('test/ratings.db');
    final entries = await database.select(database.entries).get();
    expect(entries.isNotEmpty, true);
  });

  tearDown(() async {
    await database.close();
  });

  tearDownAll(() async {
    await File('test/test_database.db').delete().catchError((err) {return err;});
  });
}
