import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratings_app/database/database.dart';
import 'package:ratings_app/providers.dart';
import 'package:ratings_app/ui/linux/columns.dart';
import 'package:ratings_app/commands/command.dart';

class EntriesTable extends ConsumerStatefulWidget {

  const EntriesTable({super.key});

  @override
  ConsumerState<EntriesTable> createState() => _EntriesTableState();
}

class _EntriesTableState extends ConsumerState<EntriesTable> {

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
    final editingCell = ref.watch(cellEditingProvider);
    final commandManager = ref.watch(commandManagerProvider.notifier);

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
                        Builder(
                          builder: (context) {
                            final flex = 4;
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
                            
                            if (editingCell == (entry.id, ColumnType.title)) {
                              return Expanded(
                                flex: flex,
                                child: Padding(
                                  padding: EdgeInsetsGeometry.directional(start: 13),
                                  child: CustomFormField(
                                    entryId: entry.id,
                                    column: ColumnType.title,
                                    initialValue: entry.title,
                                    cellStyle: Theme.of(context).textTheme.bodyMedium,
                                    textColor: textColor,
                                    ref: ref,
                                    commandManager: commandManager,
                                  )
                                )
                              );
                            }

                            return Expanded(
                              flex: flex,
                              child: Padding(
                                padding: EdgeInsetsGeometry.directional(start: 8),
                                child: CustomText(
                                  entryId: entry.id,
                                  column: ColumnType.title,
                                  ref: ref,
                                  entryValue: entry.title,
                                  textColor: textColor,
                                  textLeftPadding: 5,
                                )
                              )
                            );
                          }
                        ),
                        
                        Builder(
                          builder: (context) {
                            final flex = 1;
                            
                            if (editingCell == (entry.id, ColumnType.rating)) {
                              return Expanded(
                                flex: flex,
                                child: Padding(
                                  padding: EdgeInsetsGeometry.directional(start: 4),
                                  child: CustomFormField(
                                    entryId: entry.id,
                                    column: ColumnType.rating,
                                    initialValue: entry.rating.toString(),
                                    cellStyle: Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.center,
                                    textColor: defaultTextColor,
                                    ref: ref,
                                    commandManager: commandManager,
                                  )
                                )
                              );
                            }

                            return Expanded(
                              flex: flex,
                              child: CustomText(
                                entryId: entry.id,
                                column: ColumnType.rating,
                                ref: ref,
                                entryValue: entry.rating.toString(),
                                alignment: Alignment.center,
                                textColor: defaultTextColor,
                              )
                            );
                          }
                        ),

                        Builder(
                          builder: (context) {
                            final flex = 2;
                            
                            if (editingCell == (entry.id, ColumnType.dateCompleted)) {
                              return Expanded(
                                flex: flex,
                                child: Padding(
                                  padding: EdgeInsetsGeometry.directional(start: 4),
                                  child: CustomFormField(
                                    entryId: entry.id,
                                    column: ColumnType.dateCompleted,
                                    initialValue: entry.dateCompleted!,
                                    cellStyle: Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.center,
                                    textColor: defaultTextColor,
                                    ref: ref,
                                    commandManager: commandManager,
                                  )
                                )
                              );
                            }

                            return Expanded(
                              flex: flex,
                              child: CustomText(
                                entryId: entry.id,
                                column: ColumnType.dateCompleted,
                                ref: ref,
                                entryValue: entry.dateCompleted!,
                                alignment: Alignment.center,
                                textColor: defaultTextColor,
                              )
                            );
                          }
                        ),

                        Builder(
                          builder: (context) {
                            final flex = 4;
                            
                            if (editingCell == (entry.id, ColumnType.notes)) {
                              return Expanded(
                                flex: flex,
                                child: Padding(
                                  padding: EdgeInsetsGeometry.directional(start: 5, end: 15),
                                  child: Tooltip(
                                    constraints: BoxConstraints(maxWidth: 400),
                                    message: entry.notes,
                                    child: CustomFormField(
                                      entryId: entry.id,
                                      column: ColumnType.notes,
                                      initialValue: entry.notes!,
                                      cellStyle: Theme.of(context).textTheme.bodyMedium,
                                      textColor: defaultTextColor,
                                      ref: ref,
                                      commandManager: commandManager,
                                    )
                                  )
                                )
                              );
                            }

                            return Expanded(
                              flex: flex,
                              child: Padding(
                                padding: EdgeInsetsGeometry.directional(end: 15),
                                child: Tooltip(
                                  constraints: BoxConstraints(maxWidth: 400),
                                  message: entry.notes,
                                  child: CustomText(
                                    entryId: entry.id,
                                    column: ColumnType.notes,
                                    ref: ref,
                                    entryValue: entry.notes!,
                                    textColor: defaultTextColor,
                                    textLeftPadding: 5,
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

class CustomFormField extends StatelessWidget {

  final int entryId;
  final ColumnType column;
  final String initialValue;
  final TextStyle? cellStyle;
  final TextAlign? textAlign;
  final Color? textColor;
  final WidgetRef ref;
  final CommandManager commandManager;

  const CustomFormField({
    super.key,
    required this.entryId,
    required this.column,
    required this.initialValue,
    this.cellStyle,
    this.textAlign,
    this.textColor,
    required this.ref,
    required this.commandManager,
  });

  @override
  Widget build(context) {
    return TextFormField(
      key: ValueKey(initialValue),
      initialValue: initialValue,
      autofocus: true,
      decoration: InputDecoration(
        border: InputBorder.none,
        isDense: true,
      ),
      maxLines: 1,
      style: TextStyle(
        color: textColor ?? Colors.black,
        fontSize: cellStyle?.fontSize,
        letterSpacing: cellStyle?.letterSpacing,
        height: cellStyle?.height,
        overflow: TextOverflow.ellipsis,
      ),
      textAlign: textAlign ?? TextAlign.left,
      onFieldSubmitted: (value) {
        commandManager.execute(EditEntryFieldCommand(
          setter: ref.read(entryRepositoryProvider).updateEntry,
          id: entryId,
          oldValue: companionCreator(column, initialValue),
          newValue: companionCreator(column, value),
        ));
        ref.read(rootFocusNodeProvider).requestFocus();
        commandManager.refresh();
      },
      onTapOutside: (value) {
        ref.read(rootFocusNodeProvider).requestFocus();
      },
    );
  }

  EntriesCompanion companionCreator(ColumnType columnType, String value) {
    switch (columnType) {
      case ColumnType.title:
        return EntriesCompanion(title: drift.Value(value));
      case ColumnType.rating:
        return EntriesCompanion(rating: drift.Value(int.parse(value)));
      case ColumnType.dateCompleted:
        return EntriesCompanion(dateCompleted: drift.Value(value));
      case ColumnType.notes:
        return EntriesCompanion(notes: drift.Value(value));
    }
  }
}

class CustomText extends StatelessWidget {

  final int entryId;
  final ColumnType column;
  final WidgetRef ref;
  final String entryValue;
  final Alignment? alignment;
  final Color? textColor;
  final double? textLeftPadding;
  final Tooltip? tooltip;

  const CustomText({
    super.key,
    required this.entryId,
    required this.column,
    required this.ref,
    required this.entryValue,
    this.alignment,
    this.textColor,
    this.textLeftPadding,
    this.tooltip,
  });

  @override
  Widget build(context) {
    return FocusableActionDetector(
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        splashFactory: NoSplash.splashFactory,
        onTap: () {
          ref
            .read(cellEditingProvider.notifier)
            .setCell(entryId, column);
        },
        child: SizedBox(
          height: 40,
          child: Padding(
            padding: EdgeInsetsGeometry.directional(start: textLeftPadding ?? 0),
            child: Align(
              alignment: alignment ?? Alignment.centerLeft,
              child: Text(
                entryValue,
                key: ValueKey(entryValue),
                style: TextStyle(
                  color: textColor ?? Colors.black,
                )
              )
            )
          )
        )
      )
    );
  }
}

class CellEditingNotifier extends Notifier<(int entryId, ColumnType column)?> {
  @override
  (int entryId, ColumnType column)? build() {
    return null;
  }

  void setCell(int entryId, ColumnType column) {
    state = (entryId, column);
  }
}