import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {

  final SharedPreferences prefs;

  SettingsRepository(
    this.prefs,
  );

  String? get databasePath =>
      prefs.getString(
        'databasePath',
      );

  Future<bool> setDatabasePath(
    String path,
  ) async {
    return await prefs.setString(
      'databasePath',
      path,
    );
  }
}