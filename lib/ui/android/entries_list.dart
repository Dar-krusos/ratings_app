import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratings_app/providers.dart';
import 'package:ratings_app/ui/android/edit_entry_dialog.dart';

class EntriesList extends ConsumerStatefulWidget {

  const EntriesList({super.key});

  @override
  ConsumerState<EntriesList> createState() => _EntriesListState();
}

class _EntriesListState extends ConsumerState<EntriesList> {

  final lightMovieColor = Color(0xFF016C6E);
  final lightSeriesColor = Color(0xFF8C0B2D);
  final darkMovieColor = Color(0xFF6EC9CB);
  final darkSeriesColor = Color(0xFFFF6684);

  late Color defaultTextColor;
  late final String? oldValue;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(entriesProvider);

    if (MediaQuery.platformBrightnessOf(context) == Brightness.light) {
      defaultTextColor = Colors.black;
    } else {
      defaultTextColor = Colors.white;
    }

    return entries.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text(error.toString())),
      data: (rows) {
        return Scrollbar(
          interactive: true,
          radius: const Radius.circular(10),
          thickness: 7,
          thumbVisibility: true,
          child: Padding(
            padding: const EdgeInsets.only(right: 7),
            child: ListView.builder(
              itemCount: rows.length,
              itemBuilder:
                  (context, index) {
                final entry = rows[index];

                return Card(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child:

                    entry.notes != ''

                    ? GestureDetector(
                      onLongPress: () => showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => EditEntryDialog(entry: entry),
                      ),

                      child: ExpansionTile(
                        minTileHeight: 72,
                        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),

                        leading: SizedBox(
                          width: 60,
                          child: Text(
                            entry.rating.toString(),
                            style: TextStyle(
                              fontSize: Theme.of(context).textTheme.headlineMedium?.fontSize,
                            ),
                            textAlign: TextAlign.center,
                          )
                        ),
                        title: Text(entry.title),
                        subtitle: entry.dateCompleted != '' ? Text(entry.dateCompleted!) : null,
                        children: [

                          entry.notes != ''

                          ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(entry.notes!),
                          )

                          : const SizedBox.shrink(),
                        ],
                      )
                    )

                    : ListTile(
                      minTileHeight: 72,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      splashColor: Theme.of(context).splashColor,
                      onTap: () {},
                      onLongPress: () => showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => EditEntryDialog(entry: entry),
                      ),

                      leading: SizedBox(
                        width: 60,
                        child: Text(
                          entry.rating.toString(),
                          style: TextStyle(
                            fontSize: Theme.of(context).textTheme.headlineMedium?.fontSize,
                          ),
                          textAlign: TextAlign.center,
                        )
                      ),
                      title: Text(entry.title),
                      subtitle: entry.dateCompleted != '' ? Text(entry.dateCompleted!) : null,
                    )
                  )
                );
              }
            )
          )
        );
      },
    );
  }
}