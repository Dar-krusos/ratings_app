import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratings_app/database/database.dart';
import 'package:ratings_app/database/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ratings_app/repository.dart';
import 'package:ratings_app/ui/linux/main_screen.dart';
import 'package:ratings_app/ui/linux/columns.dart';
import 'package:ratings_app/ui/linux/entries_table.dart';
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

final databasePathProvider =
    Provider<String?>(
  (ref) {
    return ref
        .watch(
          settingsRepositoryProvider,
        )
        .databasePath;
  },
);

final databaseProvider =
    Provider<AppDatabase>(
  (ref) {

    final path =
        ref.watch(
          databasePathProvider,
        );

    return AppDatabase(path!);
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

final sortProvider = NotifierProvider<SortNotifier, SortState>(SortNotifier.new);

final searchProvider = NotifierProvider<SearchNotifier, String>(SearchNotifier.new);

final cellEditingProvider = NotifierProvider<CellEditingNotifier, (int entryId, ColumnType column)?>(CellEditingNotifier.new);

final commandManagerProvider = NotifierProvider<CommandManager, CommandManagerState>(CommandManager.new);

final rootFocusNodeProvider = Provider<FocusNode>((ref) => throw UnimplementedError());