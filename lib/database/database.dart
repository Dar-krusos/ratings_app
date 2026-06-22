import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratings_app/providers.dart';
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

class DatabasePathNotifier extends Notifier<String?> {

  @override
  String? build() {
    return ref
        .read(settingsRepositoryProvider)
        .databasePath;
  }

  Future<void> setPath(
    String path,
  ) async {

    await ref
        .read(settingsRepositoryProvider)
        .setDatabasePath(path);

    state = path;
  }
}