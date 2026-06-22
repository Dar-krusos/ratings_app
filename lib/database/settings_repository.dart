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

  Future<void> setDatabasePath(
    String path,
  ) {
    return prefs.setString(
      'databasePath',
      path,
    );
  }
}