import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratings_app/providers.dart';
import 'package:ratings_app/ui/linux/entries_table.dart';

enum FilterType {
  movies,
  games,
  books,
}

class EntriesTabController extends ConsumerWidget {
  const EntriesTabController({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return DefaultTabController(
      initialIndex: 1,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: TabBar(
            tabs: <Widget>[
              for (final tab in tabs)
                Tab(
                  icon: Icon(tab.icon),
                  child: Text(tab.title),
                ),
            ],
            onTap: (index) {
              ref
                  .read(tabProvider.notifier)
                  .select(
                    FilterType.values[index],
                  );
            },
          ),
        ),
        body: TabBarView(
          children: [
            for (int i = 0; i < 3; i++)
              EntriesTable()
          ]
        ),
      ),
    );
  }
}

class TabData {
  final IconData icon;
  final String title;

  const TabData({
    required this.icon,
    required this.title,
  });
}

const tabs = [

  TabData(
    icon: Icons.movie,
    title: 'Movies',
  ),

  TabData(
    icon: Icons.games,
    title: 'Games',
  ),

  TabData(
    icon: Icons.book,
    title: 'Books',
  ),
];

class TabNotifier extends Notifier<FilterType> {
  @override
  FilterType build() {
    return FilterType.movies;
  }

  void select(FilterType type) {
    state = type;
  }
}