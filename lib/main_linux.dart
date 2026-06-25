import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ratings_app/providers.dart';
import 'package:ratings_app/commands/shortcuts.dart';
import 'package:ratings_app/ui/no_path_startup.dart';
import 'package:ratings_app/ui/linux/main_screen.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  runApp(ProviderScope(
    overrides: [ sharedPreferencesProvider.overrideWithValue(prefs)],
    child: MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', 'AU'),
      ],

      locale: const Locale('en', 'AU'),
      home: AppRoot(),
      themeMode: ThemeMode.system,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
    )));
}

class AppRoot extends ConsumerWidget {

  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final path = ref.watch(databasePathProvider);
    if (path == null) {
      return const NoPathStartupScreen(createMainApp: MainApp.new);
    } else {
      return MainApp();
    }
  }
}

class MainApp extends StatelessWidget {

  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShortcutsManager(createMainScreen: MainScreen.new);
  }
}

// add date picker to date editing
// [Escape] to cancel editing
// Window size management