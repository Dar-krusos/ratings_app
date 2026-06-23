import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_selector/file_selector.dart';

import 'package:ratings_app/providers.dart';

class NoPathStartupScreen extends ConsumerStatefulWidget {
  final Widget Function() createMainApp;

  const NoPathStartupScreen({
    super.key,
    required this.createMainApp,
  });

  @override
  NoPathStartupScreenState createState() => NoPathStartupScreenState();
}

class NoPathStartupScreenState extends ConsumerState<NoPathStartupScreen> {

  final _formKey = GlobalKey<FormState>();
  final directoryController = TextEditingController();
  final fileController = TextEditingController();
  Uint8List? fileBytes;

   @override
   void initState() {
     super.initState();
   }

   @override
   void dispose() {
     directoryController.dispose();
     fileController.dispose();
     super.dispose();
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set database path'),
      ),
      body: Center(
        child: SizedBox(
          width: Platform.isAndroid
          ? MediaQuery.sizeOf(context).width * 0.8
          : MediaQuery.sizeOf(context).width * 0.4,
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

                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => widget.createMainApp(),
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