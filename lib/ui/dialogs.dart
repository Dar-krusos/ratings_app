import 'dart:io';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_selector/file_selector.dart';

import 'package:ratings_app/providers.dart';

typedef TypeEntry = DropdownMenuEntry<TypeLabel>;

// DropdownMenuEntry labels and values for the dropdown menu.
enum TypeLabel {
  none(''),
  movie('Movie'),
  series('Series'),
  game('Game'),
  book('Book');

  const TypeLabel(this.label);
  final String label;

  static final List<TypeEntry> entries = UnmodifiableListView<TypeEntry>(
    values.map<TypeEntry>(
      (TypeLabel type) => TypeEntry(
        value: type,
        label: type.label,
      ),
    ),
  );
}

class AddEntryDialog extends ConsumerStatefulWidget {
  const AddEntryDialog({super.key});

  @override
  AddEntryDialogState createState() {
    return AddEntryDialogState();
  }
}

class AddEntryDialogState extends ConsumerState<AddEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final ratingController = TextEditingController();
  late String selectedDate;
  late String selectedType;
  final noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New entry'),
      content: SizedBox(
        width: MediaQuery.sizeOf(context).width * 0.4,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [

              // fields

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
              DatePickerForm(
                onChanged: (date) {
                  selectedDate = date;
                },
              ),
              DropdownMenuFormField(
                width: 200,
                initialSelection: TypeLabel.none,
                requestFocusOnTap: true,
                label: const Text('Media type'),
                onSelected: (TypeLabel? type) {
                  setState(() {
                    selectedType = type!.label;
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
                                child: Text('Added new entry.'),
                              ),
                            ),
                          );

                          ref.read(entryRepositoryProvider).addEntry(
                            titleController.text,
                            int.parse(ratingController.text),
                            selectedDate,
                            selectedType,
                            noteController.text
                          );
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

class DatePickerForm extends StatefulWidget {
  final void Function(String) onChanged;

  const DatePickerForm({
    super.key,
    required this.onChanged,
  });

  @override
  State<DatePickerForm> createState() => _DatePickerFormState();
}

class _DatePickerFormState extends State<DatePickerForm> {
  String? dateString;

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.fromMillisecondsSinceEpoch(0),
      lastDate: DateTime.now(),
      calendarDelegate: GregorianCalendarDelegate()
    );

    if (pickedDate == null) {
      return;
    }

    dateString = 
    '${pickedDate.year}/'
      '${pickedDate.month.toString().length > 1
        ? '${pickedDate.month}/'
        : '0${pickedDate.month}/'}'
      '${pickedDate.day.toString().length > 1
        ? '${pickedDate.day}'
        : '0${pickedDate.day}'}';

    setState(() {
      widget.onChanged(dateString!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;
    final errorFontSize = Theme.of(context).textTheme.labelMedium!.fontSize;

    return FormField(
      validator: (value) {
        if (dateString == null) {
          return 'Please choose a date';
        }
        return null;
      },
      builder: (field) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 5,
          children: [
            Text('Date completed:'),
            OutlinedButton(
              onPressed: _selectDate,
              child: Text(dateString ?? 'Select Date')
            ),
            Text(
              field.errorText ?? '',
              softWrap: false,
              style: TextStyle(
                color: errorColor,
                fontSize: errorFontSize,
              ),
            )
          ],
        );
      },
    );
  }
}

class SetPathDialog extends ConsumerStatefulWidget {
  const SetPathDialog({super.key});

  @override
  SetPathDialogState createState() {
    return SetPathDialogState();
  }
}

class SetPathDialogState extends ConsumerState<SetPathDialog> {
  final _formKey = GlobalKey<FormState>();
  final directoryController = TextEditingController();
  final fileController = TextEditingController();

  late final String? currentPath;
  Uint8List? fileBytes;

  @override
  initState() {
    super.initState();
    currentPath = ref.read(databasePathProvider);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set database path'),
      content: SizedBox(
        width: Platform.isAndroid
          ? MediaQuery.sizeOf(context).width * 0.8
          : MediaQuery.sizeOf(context).width * 0.4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 20,
          children: [
            Text('Current path:\n${currentPath ?? "Not set"}'),

            if (currentPath != null)
              Divider(),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 10,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: directoryController,
                          decoration: InputDecoration(
                            labelText: 'Directory',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 1.0,
                              )
                            )
                          ),
                          validator: (value) {
                            if (value == '') {
                              return 'Please choose a directory';
                            }
                            return null;
                          },
                        )
                      ),
                      IconButton(
                        icon: Icon(Icons.file_open),
                        hoverColor: Colors.transparent,
                        tooltip: 'Select the database save location',
                        onPressed: () async {
                          final directory = await getDirectoryPath();
                          if (directory != null) {
                            directoryController.text = directory;
                          }
                        }
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: fileController,
                          decoration: InputDecoration(
                            labelText: 'Name of file to create/select',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 1.0,
                              )
                            )
                          ),
                          validator: (value) {
                            RegExp dbExp = RegExp(r'(.*\.db$)');
                            RegExp sqlExp = RegExp(r'(.*\.sqlite$)');

                            if (value == null || value == '') {
                              return 'Please choose a filename';
                            } else if (dbExp.allMatches(value).isEmpty && sqlExp.allMatches(value).isEmpty) {
                              return 'That is not a valid extension';
                            }
                            return null;
                          },
                        )
                      ),
                      IconButton(
                        icon: Icon(Icons.file_open),
                        hoverColor: Colors.transparent,
                        tooltip: 'Select an existing file',
                        onPressed: () async {
                          final file = await openFile(
                            acceptedTypeGroups: [
                              XTypeGroup(
                                label: 'Database files',
                                extensions: ['db', 'sqlite'],
                              )
                            ]
                          );

                          if (file != null) {
                            fileController.text = file.name;

                            if (Platform.isAndroid) {
                              fileBytes = await file.readAsBytes();
                              debugPrint('File with bytes length: ${fileBytes!.length}');
                            }
                          }
                        }
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                            
                            String directoryPath = directoryController.text;
                            if (directoryPath[directoryPath.length - 1] != '/') {
                              directoryPath = '$directoryPath/';
                            }

                            ref.read(databasePathProvider.notifier).setPath('$directoryPath${fileController.text}', fileBytes);

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Center(
                                  child: Text('Set database path.'),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ]
                  )
                ],
              ),
            )
          ]
        )
      )
    );
  }
}