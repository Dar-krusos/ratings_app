import 'dart:io';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratings_app/database/database.dart';
import 'package:ratings_app/commands/command.dart';
import 'package:ratings_app/providers.dart';
import 'package:ratings_app/ui/dialogs.dart';


class EditEntryDialog extends ConsumerStatefulWidget {

  final Entry entry;
  
  const EditEntryDialog({
    super.key,
    required this.entry
  });

  @override
  EditEntryDialogState createState() => EditEntryDialogState();
}

class EditEntryDialogState extends ConsumerState<EditEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final ratingController = TextEditingController();
  late String selectedDate;
  late TypeLabel selectedType;
  final noteController = TextEditingController();


  @override
  void initState() {
    super.initState();

    titleController.text = widget.entry.title;
    ratingController.text = widget.entry.rating.toString();
    noteController.text = widget.entry.notes ?? '';
    selectedDate = widget.entry.dateCompleted!;

    switch (widget.entry.mediaType) {
      case 'Movie':
        selectedType = TypeLabel.movie;
        break;
      case 'Series':
        selectedType = TypeLabel.series;
        break;
      case 'Game':
        selectedType = TypeLabel.game;
        break;
      case 'Book':
        selectedType = TypeLabel.book;
        break;
      default:
        selectedType = TypeLabel.none;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit entry'),
      content: SizedBox(
        width: Platform.isAndroid
        ? MediaQuery.sizeOf(context).width * 0.8
        : MediaQuery.sizeOf(context).width * 0.4,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [

              // title

              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 1.0,
                    )
                  )
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),

              // rating

              TextFormField(
                controller: ratingController,
                decoration: InputDecoration(
                  labelText: 'Rating',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 1.0,
                    )
                  )
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  } else if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),

              // date completed

              DatePickerForm(
                initialDate: selectedDate,
                onChanged: (date) {
                  selectedDate = date;
                },
              ),

              // media type

              DropdownMenuFormField(
                width: 200,
                initialSelection: selectedType,
                requestFocusOnTap: true,
                label: const Text('Media type'),
                onSelected: (TypeLabel? type) {
                  setState(() {
                    selectedType = type!;
                  });
                },
                dropdownMenuEntries: TypeLabel.entries,
                validator: (value) {
                  if (value == TypeLabel.none) {
                    return 'Please select a media type';
                  }
                  return null;
                },
              ),

              // notes

              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 1.0,
                    )
                  )
                ),
                maxLines: 3,
              ),

              // buttons

              Padding(
                padding: EdgeInsetsGeometry.directional(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  spacing: 20,
                  children: [
                    ElevatedButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    ElevatedButton(
                      child: const Text('Submit'),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Center(
                                child: Text('Entry updated.'),
                              ),
                            ),
                          );

                          final commandManager = ref.read(commandManagerProvider.notifier);

                          commandManager.execute(EditEntryCommand(
                            setter: ref.read(entryRepositoryProvider).editEntry,
                            id: widget.entry.id,
                            oldValue: EntriesCompanion(
                              title: drift.Value(widget.entry.title),
                              rating: drift.Value(widget.entry.rating),
                              dateCompleted: drift.Value(widget.entry.dateCompleted),
                              mediaType: drift.Value(widget.entry.mediaType),
                              notes: drift.Value(widget.entry.notes),
                            ),
                            newValue: EntriesCompanion(
                              title: drift.Value(titleController.text),
                              rating: drift.Value(int.parse(ratingController.text)),
                              dateCompleted: drift.Value(selectedDate),
                              mediaType: drift.Value(selectedType.label),
                              notes: drift.Value(noteController.text),
                            ),
                          ));

                          Navigator.pop(context);
                        }
                      },
                    ),
                  ]
                )
              )
            ],
          ),
        )
      )
    );
  }
}
