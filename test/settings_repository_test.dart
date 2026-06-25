import 'package:test/test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ratings_app/database/settings_repository.dart';

void main() {
    WidgetsFlutterBinding.ensureInitialized();
  late final SettingsRepository settingsRepository;

  setUp(() async {

    final prefs = await SharedPreferences.getInstance();
    settingsRepository = SettingsRepository(prefs);
  });

  test('SettingsRepository databasePath value get and set', () async {

    final initialPath = settingsRepository.databasePath;

    await settingsRepository.setDatabasePath('');
    expect(settingsRepository.databasePath, '');

    await settingsRepository.setDatabasePath(initialPath!);
    expect(settingsRepository.databasePath, initialPath);
  });
}
