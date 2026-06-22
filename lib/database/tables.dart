import 'package:drift/drift.dart';

class Entries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  IntColumn get rating => integer()();
  TextColumn get dateCompleted => text().nullable()();
  TextColumn get mediaType => text()();
  TextColumn get notes => text().nullable()();
}