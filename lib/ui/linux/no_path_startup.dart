import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoPathStartupScreen extends ConsumerStatefulWidget {
  const NoPathStartupScreen({super.key});

  @override
  NoPathStartupScreenState createState() {
    return NoPathStartupScreenState();
  }
}

class NoPathStartupScreenState extends ConsumerState<NoPathStartupScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set database path'),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              FormField(
                builder: (field) {
                  return Row(
                    children: [
                      Text('Select folder where your database should be stored:')
                    ],
                  );
                },
              )
            ],
          )
        )
      ),
    );
  }
}