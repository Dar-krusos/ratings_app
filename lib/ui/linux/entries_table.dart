import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratings_app/providers.dart';
import 'package:ratings_app/ui/linux/edit_provider.dart';

import 'package:ratings_app/ui/linux/columns.dart';
import 'package:ratings_app/ui/linux/cell_builders.dart';

class EntriesTable extends ConsumerWidget {

  final lightMovieColor = Color(0xFF016C6E);
  final lightSeriesColor = Color(0xFF8C0B2D);
  final darkMovieColor = Color(0xFF6EC9CB);
  final darkSeriesColor = Color(0xFFFF6684);

  EntriesTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(entriesProvider);
    final editingCell = ref.watch(cellEditingProvider);
    late final Color defaultTextColor;

    if (MediaQuery.platformBrightnessOf(context) == Brightness.light) {
      defaultTextColor = Colors.black;
    } else {
      defaultTextColor = Colors.white;
    }

    return entries.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text(error.toString())),
      data: (rows) {
        return Column(
          children: [
            SizedBox(
              height: 48,
              child: Row(
                children: [

                  // headers

                  for (final column in columns)
                    Expanded(
                      flex: column.flex,
                      child: SortableHeader(
                        text: column.title,
                        onPressed: () {
                          ref
                            .read(sortProvider.notifier)
                            .setSort(column.sortType);
                        },
                      ),
                    ),
                ],
              )
            ),

            const Divider(height: 1,),

            // table

            Expanded(
              child: ListView.builder(
                itemCount: rows.length,
                itemExtent: 40,
                itemBuilder:
                    (context, index) {
                  final entry = rows[index];

                  return Row(
                    children: [

                      // title

                      Builder(
                        builder: (context) {
                          Color textColor;

                          if (MediaQuery.platformBrightnessOf(context) == Brightness.light) {
                            if (entry.mediaType == 'Movie') {
                              textColor = lightMovieColor;
                            } else if (entry.mediaType == 'Series') {
                              textColor = lightSeriesColor;
                            } else {
                              textColor = defaultTextColor;
                            }
                          } else {
                            if (entry.mediaType == 'Movie') {
                              textColor = darkMovieColor;
                            } else if (entry.mediaType == 'Series') {
                              textColor = darkSeriesColor;
                            } else {
                              textColor = defaultTextColor;
                            }
                          }

                          return Expanded(
                            key: ValueKey(entry.title),
                            flex: 4,
                            child: Padding(
                              padding: EdgeInsetsGeometry.directional(start: 8),
                              child: 

                                editingCell == (entry.id, ColumnType.title)

                                ? CustomFormField(
                                  entryId: entry.id,
                                  column: ColumnType.title,
                                  initialValue: entry.title,
                                  textColor: textColor,
                                  padding: EdgeInsets.only(left: 12)
                                )

                                : CustomText(
                                  entry: entry,
                                  column: ColumnType.title,
                                  textColor: textColor,
                                )
                            )
                          );
                        }
                      ),

                      // rating
                      
                      Builder(
                        builder: (context) {

                          return Expanded(
                            key: ValueKey(entry.rating.toString()),
                            flex: 1,
                            child: 

                              editingCell == (entry.id, ColumnType.rating)

                              ? CustomFormField(
                                entryId: entry.id,
                                column: ColumnType.rating,
                                initialValue: entry.rating.toString(),
                                textAlign: TextAlign.center,
                                textColor: defaultTextColor,
                              )

                              : CustomText(
                              entry: entry,
                              column: ColumnType.rating,
                              alignment: Alignment.center,
                              textColor: defaultTextColor,
                              )
                          );
                        }
                      ),

                      // date completed

                      Builder(
                        builder: (context) {

                          return Expanded(
                            flex: 2,
                            child:

                              editingCell == (entry.id, ColumnType.dateCompleted)

                              ? CustomFormField(
                                entryId: entry.id,
                                column: ColumnType.dateCompleted,
                                initialValue: entry.dateCompleted!,
                                textAlign: TextAlign.center,
                              )

                              : DateCell(
                                entry: entry,
                                textColor: defaultTextColor,
                              )
                          );
                        }
                      ),

                      // notes

                      Builder(
                        builder: (context) {

                          return Expanded(
                            flex: 4,
                            child: Padding(
                              padding: EdgeInsetsGeometry.directional(end: 14),
                              child: Tooltip(
                                constraints: BoxConstraints(maxWidth: 400),
                                message: entry.notes,
                                  child:

                                    editingCell == (entry.id, ColumnType.notes)

                                    ? CustomFormField(
                                      entryId: entry.id,
                                      column: ColumnType.notes,
                                      initialValue: entry.notes!,
                                      textColor: defaultTextColor,
                                      padding: EdgeInsets.only(left: 12)
                                    )

                                    : CustomText(
                                      entry: entry,
                                      column: ColumnType.notes,
                                      textColor: defaultTextColor,
                                    )
                              )
                            )
                          );
                        }
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}