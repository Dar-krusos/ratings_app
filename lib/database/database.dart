import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratings_app/providers.dart';
import 'package:ratings_app/database/tables.dart';
part 'database.g.dart';

@DriftDatabase(tables: [Entries])
class AppDatabase extends _$AppDatabase {
  AppDatabase(String path)
    : super(_openConnection(path));

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection(String path) {
    if (Platform.isAndroid) {
      return driftDatabase(
        name: 'app',
        native: DriftNativeOptions(
          databasePath: () async {
            final dbFolder = await getApplicationDocumentsDirectory();
            final file = File(p.join(dbFolder.path, 'app.db'));

            return file.path;
          },
        )
      );
    } else {
      return NativeDatabase(File(path));
    }
  }
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
    List<int>? fileBytes,
  ) async {

    if (fileBytes != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final dbPath = p.join(appDir.path, 'app.db');

      await File(dbPath).writeAsBytes(fileBytes);
    }

    await ref
        .read(settingsRepositoryProvider)
        .setDatabasePath(path);

    state = path;
  }
}