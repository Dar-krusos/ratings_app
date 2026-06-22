import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

/// Flutter code sample for [DropdownMenu]s. The first dropdown menu
/// has the default outlined border and demos using the
/// [DropdownMenuEntry] style parameter to customize its appearance.
/// The second dropdown menu customizes the appearance of the dropdown
/// menu's text field with its [DropdownMenu.inputDecorationTheme] parameter.

void main() {
  runApp(const DropdownMenuExample());
}

typedef ColorEntry = DropdownMenuEntry<ColorLabel>;

// DropdownMenuEntry labels and values for the first dropdown menu.
enum ColorLabel {
  blue('Blue', Colors.blue),
  pink('Pink', Colors.pink),
  green('Green', Colors.green),
  yellow('Orange', Colors.orange),
  grey('Grey', Colors.grey);

  const ColorLabel(this.label, this.color);
  final String label;
  final Color color;

  static final List<ColorEntry> entries = UnmodifiableListView<ColorEntry>(
    values.map<ColorEntry>(
      (ColorLabel color) => ColorEntry(
        value: color,
        label: color.label,
        enabled: color.label != 'Grey',
        style: MenuItemButton.styleFrom(foregroundColor: color.color),
      ),
    ),
  );
}

class DropdownMenuExample extends StatefulWidget {
  const DropdownMenuExample({super.key});

  @override
  State<DropdownMenuExample> createState() => _DropdownMenuExampleState();
}

class _DropdownMenuExampleState extends State<DropdownMenuExample> {
  final TextEditingController colorController = TextEditingController();
  final TextEditingController iconController = TextEditingController();
  ColorLabel? selectedColor;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorSchemeSeed: Colors.green),
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const .symmetric(vertical: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: .min,
                    mainAxisAlignment: .center,
                    children: <Widget>[
                      DropdownMenu<ColorLabel>(
                        initialSelection: ColorLabel.green,
                        controller: colorController,
                        // The default requestFocusOnTap value depends on the platform.
                        // On mobile, it defaults to false, and on desktop, it defaults to true.
                        // Setting this to true will trigger a focus request on the text field, and
                        // the virtual keyboard will appear afterward.
                        requestFocusOnTap: true,
                        label: const Text('Color'),
                        onSelected: (ColorLabel? color) {
                          setState(() {
                            selectedColor = color;
                          });
                        },
                        dropdownMenuEntries: ColorLabel.entries,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}