import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {

  final SharedPreferences prefs;

  SettingsRepository(
    this.prefs,
  );

  String? get databaseFolder =>
      prefs.getString(
        'databaseFolder',
      );

  String? get databaseFileName =>
      prefs.getString(
        'databaseFileName',
      );

  Future<bool> setDatabaseFolder(
    String path,
  ) async {
    return await prefs.setString(
      'databaseFolder',
      path,
    );
  }

  Future<bool> setDatabaseFileName(
    String path,
  ) async {
    return await prefs.setString(
      'databaseFileName',
      path,
    );
  }
}