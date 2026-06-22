import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratings_app/providers.dart';
import 'package:ratings_app/ui/linux/columns.dart';

class EntriesTable extends ConsumerWidget {
  const EntriesTable({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {

    final entries =
        ref.watch(entriesProvider);

    return entries.when(

      loading: () =>
          const Center(
            child:
                CircularProgressIndicator(),
          ),

      error: (error, stackTrace) =>
          Center(
            child: Text(
              error.toString(),
            ),
          ),

      data: (rows) {

        return Column(
          children: [

            SizedBox(
              height: 48,

              child: Row(
                children: [

                  for (final column in columns)

                    Expanded(
                      flex: column.flex,

                      child: SortableHeader(
                        text: column.title,

                        onPressed: () {

                          ref
                              .read(
                                sortProvider.notifier,
                              )
                              .setSort(
                                column.sortType,
                              );
                        },
                      ),
                    ),
                ],
              )
            ),

            const Divider(
              height: 1,
            ),

            Expanded(
              child: ListView.builder(
                itemCount: rows.length,

                itemBuilder:
                    (context, index) {

                  final entry =
                      rows[index];

                  return SizedBox(
                    height: 40,

                    child: Row(
                      children: [

                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),

                            child: Text(
                              entry.title,
                              overflow:
                                  TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                        Expanded(
                          flex: 1,
                          child: Text(
                            '${entry.rating}',
                          ),
                        ),

                        Expanded(
                          flex: 2,
                          child: Text(
                            entry.dateCompleted
                                    ?.toString() ??
                                '',
                          ),
                        ),

                        Expanded(
                          flex: 3,
                          child: Text(
                            entry.notes
                                    ?.toString() ??
                                '',
                          ),
                        ),
                      ],
                    ),
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