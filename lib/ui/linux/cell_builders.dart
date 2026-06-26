import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratings_app/database/database.dart';
import 'package:ratings_app/commands/command.dart';
import 'package:ratings_app/providers.dart';
import 'package:ratings_app/ui/linux/edit_provider.dart';

import 'package:ratings_app/ui/linux/columns.dart';

enum EntryMenuEntry {
  deleteEntry(
    'Delete row',
  ),
  clearDate(
    'Clear date',
  );

  const EntryMenuEntry(this.label);
  final String label;
}

class ExitIntent extends Intent {
  const ExitIntent();
}
class DeleteIntent extends Intent {
  const DeleteIntent();
}

class CustomFormField extends ConsumerStatefulWidget {

  final int entryId;
  final ColumnType column;
  final String initialValue;
  final TextAlign? textAlign;
  final Color? textColor;
  final EdgeInsets? padding;

  const CustomFormField({
    super.key,
    required this.entryId,
    required this.column,
    required this.initialValue,
    this.textAlign,
    this.textColor,
    this.padding,
  });

  @override
  ConsumerState<CustomFormField> createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends ConsumerState<CustomFormField> {

  final focusNode = FocusNode();
  late final CommandManager commandManager;

  @override
  void initState() {
    super.initState();

    focusNode.requestFocus();
    commandManager = ref.read(commandManagerProvider.notifier);
  }

  @override
  void dispose() {
    super.dispose();

    focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle cellStyle = Theme.of(context).textTheme.labelLarge!;

    return Shortcuts(
      shortcuts: {
        const SingleActivator(
          LogicalKeyboardKey.escape,
        ): const ExitIntent(),
      },
      child: Actions(
        actions: {
          ExitIntent:
              CallbackAction<ExitIntent>(
            onInvoke: (_) {
              exitEditing();
              return null;
            },
          ),
        },
        child: Padding(
          padding: widget.padding ?? EdgeInsets.only(left: 4),
          child: TextFormField(
            key: ValueKey(widget.initialValue),
            autofocus: true,
            focusNode: focusNode,
            initialValue: widget.initialValue,
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
            ),
            maxLines: 1,
            style: TextStyle(
              color: widget.textColor ?? Colors.black,
              fontSize: cellStyle.fontSize,
              fontWeight: cellStyle.fontWeight,
              letterSpacing: cellStyle.letterSpacing,
              height: cellStyle.height,
              overflow: TextOverflow.ellipsis,
            ),
            textAlign: widget.textAlign ?? TextAlign.left,
            onFieldSubmitted: (value) {
              commandManager.execute(EditEntryFieldCommand(
                setter: ref.read(entryRepositoryProvider).updateEntry,
                id: widget.entryId,
                oldValue: companionCreator(widget.column, widget.initialValue),
                newValue: companionCreator(widget.column, value),
              ));

              exitEditing();
              commandManager.refresh();
            },
            onTapOutside: (value) { exitEditing(); },
          )
        )
      )
    );
  }

  void exitEditing() {
    ref.read(cellEditingProvider.notifier).clear();
    ref.read(rootFocusNodeProvider).requestFocus();
  }
}

class CustomText extends ConsumerStatefulWidget {

  final Entry entry;
  final ColumnType column;
  final Alignment? alignment;
  final Color? textColor;

  const CustomText({
    super.key,
    required this.entry,
    required this.column,
    this.alignment,
    this.textColor,
  });

  @override
  ConsumerState<CustomText> createState() => _CustomTextState();
}

class _CustomTextState extends ConsumerState<CustomText> {

  final _menuController = MenuController();
  bool hovered = false;

  late final CommandManager commandManager;
  late final String entryValue;

  @override
  void initState() {
    super.initState();

    commandManager = ref.read(commandManagerProvider.notifier);

    switch (widget.column) {
      case ColumnType.title:
        entryValue = widget.entry.title;
        break;
      case ColumnType.rating:
        entryValue = widget.entry.rating.toString();
        break;
      case ColumnType.dateCompleted:
        entryValue = widget.entry.dateCompleted!;
        break;
      case ColumnType.notes:
        entryValue = widget.entry.notes!;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Shortcuts(
      shortcuts: {
        const SingleActivator(
          LogicalKeyboardKey.delete,
        ): const DeleteIntent(),
      },
      child: Actions(
        actions: {
          DeleteIntent:
              CallbackAction<DeleteIntent>(
            onInvoke: (_) {
              _activate(EntryMenuEntry.deleteEntry, ref, widget.entry);
              return null;
            },
          ),
        },
        child: MenuAnchor(
          animated: true,
          controller: _menuController,
          style: MenuStyle(
            padding: WidgetStatePropertyAll(EdgeInsets.zero)
          ),
          menuChildren: [
            MenuItemButton(
              autofocus: true,
              onPressed: () => _activate(EntryMenuEntry.deleteEntry, ref, widget.entry),
              child: Text(EntryMenuEntry.deleteEntry.label),
            ),
          ],
          builder: (context, controller, child) {

            return GestureDetector(
              onSecondaryTapDown: (details) {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open(position: details.localPosition);
                }
              },

              child: TextButton(

                onPressed: () async {
                  if (controller.isOpen) {
                    controller.close();
                  }

                  ref
                    .read(cellEditingProvider.notifier)
                    .setCell(widget.entry.id, widget.column);
                },

                style: ButtonStyle(
                  alignment: widget.alignment ?? Alignment.centerLeft,
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    )
                  ),
                ),

                child: Text(
                  entryValue,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: widget.textColor,
                  )
                )
              )
            );
          }
        )
      )
    );
  }

  void _activate(EntryMenuEntry selection, WidgetRef ref, Entry entry) {
    if (selection == EntryMenuEntry.deleteEntry) {
      commandManager.execute(DeleteEntryCommand(
        provider: ref.read(entryRepositoryProvider),
        entry: entry,
      ));

      commandManager.refresh();
      _menuController.close();
    } else {
      return;
    }
  }
}

EntriesCompanion companionCreator(ColumnType columnType, String value) {
  switch (columnType) {
    case ColumnType.title:
      return EntriesCompanion(title: Value(value));
    case ColumnType.rating:
      return EntriesCompanion(rating: Value(int.parse(value)));
    case ColumnType.dateCompleted:
      return EntriesCompanion(dateCompleted: Value(value));
    case ColumnType.notes:
      return EntriesCompanion(notes: Value(value));
  }
}

class DateCell extends ConsumerWidget {

  final _menuController = MenuController();

  final Entry entry;
  final Color? textColor;

  DateCell({
    super.key,
    required this.entry,
    this.textColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return MenuAnchor(
      animated: true,
      controller: _menuController,
      style: MenuStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.zero)
      ),
      menuChildren: [

        // 'Clear date' menu item
        
        MenuItemButton(
          autofocus: true,
          onPressed: () => _activate(EntryMenuEntry.clearDate, ref, entry),
          child: Text(EntryMenuEntry.clearDate.label),
        ),

        // 'Delete' menu item

        MenuItemButton(
          onPressed: () => _activate(EntryMenuEntry.deleteEntry, ref, entry),
          child: Text(EntryMenuEntry.deleteEntry.label),
        ),
      ],
      builder: (context, controller, child) {

        final commandManager = ref.read(commandManagerProvider.notifier);

        late String year = '';
        late String month = '';
        late String day = '';

        if (entry.dateCompleted != null && entry.dateCompleted != '') {
          year = entry.dateCompleted!.substring(0, 4);
          month = entry.dateCompleted!.substring(5, 7);
          day = entry.dateCompleted!.substring(8, 10);
        }

        return GestureDetector(
          onLongPress: () {
            controller.open();
          },
          onSecondaryTapDown: (details) {
            controller.open(position: details.localPosition);
          },
          child: TextButton(
            onPressed: () async {
              if (controller.isOpen) {
                controller.close();
              }

              final pickedDate = await showDatePicker(
                context: context,
                initialDate: year != ''
                  ? DateTime.tryParse('$year-$month-$day')
                  : DateTime.now(),
                firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                lastDate: DateTime.now(),
              );

              if (pickedDate == null) {
                return;
              }

              final dateString = 
                '${pickedDate.year}/'
                  '${pickedDate.month.toString().length > 1
                    ? '${pickedDate.month}/'
                    : '0${pickedDate.month}/'}'
                  '${pickedDate.day.toString().length > 1
                    ? '${pickedDate.day}'
                    : '0${pickedDate.day}'}';

              commandManager.execute(EditEntryFieldCommand(
                setter: ref.read(entryRepositoryProvider).updateEntry,
                id: entry.id,
                oldValue: companionCreator(ColumnType.dateCompleted, entry.dateCompleted!),
                newValue: companionCreator(ColumnType.dateCompleted, dateString),
              ));
              
              ref.read(rootFocusNodeProvider).requestFocus();
              commandManager.refresh();
            },

            style: ButtonStyle(
              overlayColor: WidgetStatePropertyAll(Theme.of(context).hoverColor),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                )
              ),
              visualDensity: VisualDensity.standard
            ),

            child: Text(
              entry.dateCompleted!,
              style: TextStyle(
                color: textColor,
              )
            )
          )
        );
      },
    );
  }

  void _activate(EntryMenuEntry selection, WidgetRef ref, Entry entry) {

    final commandManager = ref.read(commandManagerProvider.notifier);

    switch (selection) {
      case EntryMenuEntry.deleteEntry:
        commandManager.execute(DeleteEntryCommand(
          provider: ref.read(entryRepositoryProvider),
          entry: entry,
        ));
        break;
      case EntryMenuEntry.clearDate:
        commandManager.execute(EditEntryFieldCommand(
          setter: ref.read(entryRepositoryProvider).updateEntry,
          id: entry.id,
          oldValue: companionCreator(ColumnType.dateCompleted, entry.dateCompleted!),
          newValue: companionCreator(ColumnType.dateCompleted, ''),
        ));
        break;
    }

    commandManager.refresh();
    _menuController.close();
  }
}