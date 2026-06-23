import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import 'package:ratings_app/providers.dart';
import 'package:ratings_app/main.dart';
class NoPathStartupScreen extends ConsumerStatefulWidget {
  const NoPathStartupScreen({super.key});

  @override
  NoPathStartupScreenState createState() {
    return NoPathStartupScreenState();
  }
}

class NoPathStartupScreenState extends ConsumerState<NoPathStartupScreen> {
  final _formKey = GlobalKey<FormState>();
  final directoryController = TextEditingController();
  final fileController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set database path'),
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.4,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 20,
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
                      onPressed: () async {
                        final directory = await FilePicker.getDirectoryPath();
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
                      onPressed: () async {
                        final file = await FilePicker.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: <String>[ 'db', 'sqlite' ]
                        );

                        if (file != null) {
                          final fileName = file.names[0];
                          fileController.text = fileName!;
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

                          ref.read(databasePathProvider.notifier).setPath('$directoryPath${fileController.text}');

                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => const MainApp(),
                            ),
                          );

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
            )
          )
        )
      ),
    );
  }
}