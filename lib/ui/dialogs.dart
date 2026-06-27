import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_selector/file_selector.dart';

import 'package:ratings_app/commands/command.dart';
import 'package:ratings_app/providers.dart';

typedef TypeEntry = DropdownMenuEntry<TypeLabel>;

// DropdownMenuEntry labels and values for the dropdown menu.

enum TypeLabel {
  none  (''),
  movie ('Movie'),
  series('Series'),
  game  ('Game'),
  book  ('Book');

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
  AddEntryDialogState createState() => AddEntryDialogState();
}

class AddEntryDialogState extends ConsumerState<AddEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final ratingController = TextEditingController();
  late String selectedDate;
  late TypeLabel selectedType;
  final noteController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    ratingController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New entry'),
      content: SingleChildScrollView(
        child: SizedBox(
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
                      return 'Please enter a value';
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
                      return 'Please enter a value';
                    } else if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),

                // date completed

                DatePickerForm(
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
              ],
            ),
          )
        )
      ),

      // buttons

      buttonPadding: EdgeInsets.symmetric(horizontal: 10.0),
      actions: [

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

              final commandManager = ref.read(commandManagerProvider.notifier);

              commandManager.execute(AddEntryCommand(
                provider: ref.read(entryRepositoryProvider),
                title: titleController.text,
                rating: int.parse(ratingController.text),
                dateCompleted: selectedDate,
                mediaType: selectedType.label,
                notes: noteController.text
              ));

              Navigator.pop(context);
            }
          },
        ),
      ]
    );
  }
}

class DatePickerForm extends StatefulWidget {

  final String? initialDate;
  final void Function(String) onChanged;

  const DatePickerForm({
    super.key,
    this.initialDate,
    required this.onChanged,
  });

  @override
  State<DatePickerForm> createState() => _DatePickerFormState();
}

class _DatePickerFormState extends State<DatePickerForm> {

  final dateController = TextEditingController();
  bool error = false;

  @override
  void initState() {
    super.initState();
    dateController.text = widget.initialDate ?? '';
  }

  @override
  void dispose() {
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: error ? 75 : 50,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [

          SizedBox(
            width: 200,
            child: TextFormField(
              controller: dateController,
              decoration: InputDecoration(
                labelText: 'Date completed',
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1.0,
                  )
                ),
                errorMaxLines: 2,
              ),
              onChanged: (value) {
                widget.onChanged(value);
              },
              validator: (value) {
                RegExp exp = RegExp(r'(\d{4}/\d{2}/\d{2})');

                if (value == null) {
                  setState(() { error = true; });
                  return 'Null value, please contact support';
                } else if (value != '' && exp.allMatches(value).isEmpty) {
                  setState(() { error = true; });
                  return 'Please enter a valid date or leave empty';
                }

                setState(() { error = false; });
                return null;
              },
            ),
          ),

          Padding(
            padding: EdgeInsetsDirectional.only(bottom: error ? 20 : 0),
            child: IconButton(
              icon: Icon(Icons.calendar_month),
              // hoverColor: Colors.transparent,
              padding: EdgeInsets.zero,
              tooltip: 'Select a date',
              onPressed: _selectDate,
            ),
          ),
        ]
      )
    );
  }

  Future<void> _selectDate() async {

    late String year = '';
    late String month = '';
    late String day = '';

    if (dateController.text != '') {
      year = dateController.text.substring(0, 4);
      month = dateController.text.substring(5, 7);
      day = dateController.text.substring(8, 10);
    }
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: year != ''
        ? DateTime.tryParse('$year-$month-$day')
        : DateTime.now(),
      firstDate: DateTime.fromMillisecondsSinceEpoch(0),
      lastDate: DateTime.now(),
      calendarDelegate: GregorianCalendarDelegate()
    );

    if (pickedDate == null) {
      return;
    }

    dateController.text = 
    '${pickedDate.year}/'
      '${pickedDate.month.toString().length > 1
        ? '${pickedDate.month}/'
        : '0${pickedDate.month}/'}'
      '${pickedDate.day.toString().length > 1
        ? '${pickedDate.day}'
        : '0${pickedDate.day}'}';

    setState(() {
      dateController.text = dateController.text;
      widget.onChanged(dateController.text);
    });
  }
}

class SetPathDialog extends ConsumerStatefulWidget {
  const SetPathDialog({super.key});

  @override
  SetPathDialogState createState() => SetPathDialogState();
}

class SetPathDialogState extends ConsumerState<SetPathDialog> {

  static const platform = MethodChannel('com.darkrusos.ratings_app');

  final _formKey = GlobalKey<FormState>();
  final directoryController = TextEditingController();
  final fileController = TextEditingController();

  String? folderPath;


  late final String currentPath;
  Uint8List? fileBytes;

  @override
  initState() {
    super.initState();

    late final String? currentFolder;
    late final String? currentFileName;
    (currentFolder, currentFileName) = ref.read(databasePathProvider);

    currentPath = '$currentFolder$currentFileName';
  }

  @override
  void dispose() {
    directoryController.dispose();
    fileController.dispose();
    super.dispose();
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
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Current path:\n$currentPath'),
            ),

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
                          if (Platform.isAndroid) {

                            await pickFolder();

                            if (folderPath != null) {
                              directoryController.text = folderPath!;
                            }
                          } else {

                            final directory = await getDirectoryPath();
                            if (directory != null) {
                              directoryController.text = directory;
                            }
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
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {

                            String directoryPath = directoryController.text;
                            if (directoryPath[directoryPath.length - 1] != '/') {
                              directoryPath = '$directoryPath/';
                            }

                            await ref.read(databasePathProvider.notifier).setPath(directoryPath, fileController.text, fileBytes);

                            if (!context.mounted) return;

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

  Future<void> pickFolder() async {
    try {
      final String? result = await platform.invokeMethod('pickFolder');
      setState(() {
        folderPath = result;
      });
    } on PlatformException catch (e) {
      setState(() {
        folderPath = "Error: ${e.message}";
      });
    }
  }
}