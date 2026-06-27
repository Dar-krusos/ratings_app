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

  final String dbFolder;
  final String dbFileName;

  AppDatabase(String folder, String fileName)
    : dbFolder = folder,
      dbFileName = fileName,
      super(_openConnection(folder, fileName));

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection(String folder, String fileName) {
    if (Platform.isAndroid) {
      return driftDatabase(
        name: 'app',
        native: DriftNativeOptions(
          databasePath: () async {
            final appDbFolder = await getApplicationDocumentsDirectory();
            final file = File(p.join(appDbFolder.path, 'app.db'));

            return file.path;
          },
        )
      );
    } else {
      return NativeDatabase(File('$folder$fileName'));
    }
  }

  Future<Uint8List> readAsBytes() async {
    final appDbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(appDbFolder.path, 'app.db'));
    return file.readAsBytes();
  }
}

class DatabasePathNotifier extends Notifier<(String?, String?)> {

  @override
  (String?, String?) build() {
    return (
      ref.read(settingsRepositoryProvider).databaseFolder,
      ref.read(settingsRepositoryProvider).databaseFileName
    );
  }

  Future<void> setPath(
    String folderPath,
    String fileName,
    List<int>? fileBytes,
  ) async {

    if (fileBytes != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final appDbPath = p.join(appDir.path, 'app.db');

      await File(appDbPath).writeAsBytes(fileBytes);
    }

    await ref
        .read(settingsRepositoryProvider)
        .setDatabaseFolder(folderPath);
    await ref
        .read(settingsRepositoryProvider)
        .setDatabaseFileName(fileName);

    state = (folderPath, fileName);
  }
}