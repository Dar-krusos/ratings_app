import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:window_manager/window_manager.dart';

import 'package:ratings_app/providers.dart';
import 'package:ratings_app/commands/shortcuts.dart';
import 'package:ratings_app/ui/linux/no_path_startup.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  // if (prefs.getString('databasePath') == null) {
  //   await prefs.setString(
  //     'databasePath',
  //     '',
  //   );
  // }


  runApp(ProviderScope(
    overrides: [ sharedPreferencesProvider.overrideWithValue(prefs )],
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

class AppRoot extends ConsumerStatefulWidget {

  const AppRoot({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return AppRootState();
  }
}

class AppRootState extends ConsumerState<AppRoot> /* with WindowListener */ {

  @override
  void initState() {
    super.initState();

    // windowManager.addListener(this);
  }

  @override
  Widget build(BuildContext context) {

    // final prefs = ref.read(sharedPreferencesProvider);
    // final maximized = prefs.getBool('maximized');
    // final savedWindowHeight = prefs.getDouble('windowHeight');
    // final savedWindowWidth = prefs.getDouble('windowWidth');

    // if (maximized != null && maximized) {
    //   windowManager.maximize();
    // }
    // else if (savedWindowWidth != null && savedWindowHeight != null) {
    //   windowManager.setSize(Size(savedWindowWidth, savedWindowHeight));
    // }

    final path = ref.watch(databasePathProvider);
    if (path == null) {
      return const NoPathStartupScreen();
    }

    return MainApp();
  }

  // @override
  // Future<void> onWindowClose() async {

  //   final prefs = ref.read(sharedPreferencesProvider);

  //   final maximized = await windowManager.isMaximized();
  //   debugPrint(maximized.toString());
  //   await prefs.setBool('maximized', maximized);

  //   if (!maximized) {
  //     final size = await windowManager.getSize();
  //     await prefs.setDouble('windowHeight', size.height);
  //     await prefs.setDouble('windowWidth', size.width);
  //   }
  // }
}

class MainApp extends StatelessWidget {

  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShortcutsManager();
  }
}

// // linux
// set path to target db button
// right click show context menu to delete

// // android
// top bar: https://docs.flutter.dev/cookbook/lists/floating-app-bar
// top bar elements: tab bar (left) + buttons (right) [search, add, overflow (set path, undo, redo)]
// search box replaces tabs when in use
// possible item display: https://api.flutter.dev/flutter/material/ListTile-class.html
// hold to edit