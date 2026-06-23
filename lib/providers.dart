import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratings_app/database/database.dart';
import 'package:ratings_app/database/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ratings_app/repository.dart';
import 'package:ratings_app/ui/data_types.dart';
import 'package:ratings_app/sort.dart';
import 'package:ratings_app/commands/command.dart';

final entryRepositoryProvider =
    Provider<EntryRepository>(
  (ref) => EntryRepository(
    ref.watch(databaseProvider),
  ),
);

final sharedPreferencesProvider =
    Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(),
);

final settingsRepositoryProvider =
    Provider<SettingsRepository>(
  (ref) => SettingsRepository(
    ref.watch(sharedPreferencesProvider),
  ),
);

final databaseProvider =
    Provider<AppDatabase>(
  (ref) {

    final path = ref.watch(databasePathProvider);

    final db = AppDatabase(path!);

    ref.onDispose(() {
      db.close();
    });

    return db;
  },
);

final tabProvider = NotifierProvider<TabNotifier, FilterType>(TabNotifier.new);

final entriesProvider = StreamProvider<List<Entry>>((ref) {
    final currentTab = ref.watch(tabProvider);
    final sort = ref.watch(sortProvider);
    final searchQuery = ref.watch(searchProvider);

    return ref.watch(entryRepositoryProvider)
        .watchEntries(
          type: currentTab,
          sortType: sort.column,
          descending: sort.descending,
          searchQuery: searchQuery,
        );
  },
);

final databasePathProvider = NotifierProvider<DatabasePathNotifier, String?>(DatabasePathNotifier.new);

final sortProvider = NotifierProvider<SortNotifier, SortState>(SortNotifier.new);

final searchProvider = NotifierProvider<SearchNotifier, String>(SearchNotifier.new);

final commandManagerProvider = NotifierProvider<CommandManager, CommandManagerState>(CommandManager.new);

final rootFocusNodeProvider = Provider<FocusNode>((ref) => throw UnimplementedError());

class TabNotifier extends Notifier<FilterType> {
  @override
  FilterType build() {
    return FilterType.movies; 
  }

  void select(FilterType type) {
    state = type;
  }
}

class SearchNotifier extends Notifier<String> {
  @override
  String build() {
    return '';
  }

  void update(String string) {
    state = string;
  }
}