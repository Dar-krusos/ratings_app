import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'package:ratings_app/database/tables.dart';
part 'database.g.dart';

@DriftDatabase(tables: [Entries])
class AppDatabase extends _$AppDatabase {
  AppDatabase(String path)
    : super(NativeDatabase(
      File(path)
    ));

  @override
  int get schemaVersion => 1;
}
