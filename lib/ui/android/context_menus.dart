import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratings_app/providers.dart';
import 'package:ratings_app/ui/dialogs.dart';

// Sort button and its menu for the main screen.

enum SortMenuEntry {

  title(
    'Title',
  ),
  rating(
    'Rating',
  ),
  dateCompleted(
    'Date Completed',
  ),
  typeThenRating(
    'Type -> Rating',
  ),
  notes(
    'Notes',
  );

  const SortMenuEntry(this.label);
  final String label;
}

class SortButton extends ConsumerStatefulWidget {
  const SortButton({super.key});

  @override
  ConsumerState<SortButton> createState() => _SortButtonState();
}

class _SortButtonState extends ConsumerState<SortButton> {

  final _menuController = MenuController();
  final _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {

    return MenuAnchor(
      animated: true,
      controller: _menuController,
      style: MenuStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.zero)
      ),
      menuChildren: [
        MenuItemButton(
          onPressed: () => _activate(SortMenuEntry.title),
          child: Text(SortMenuEntry.title.label),
        ),
        MenuItemButton(
          onPressed: () => _activate(SortMenuEntry.rating),
          child: Text(SortMenuEntry.rating.label),
        ),
        MenuItemButton(
          onPressed: () => _activate(SortMenuEntry.dateCompleted),
          child: Text(SortMenuEntry.dateCompleted.label),
        ),
        MenuItemButton(
          onPressed: () => _activate(SortMenuEntry.typeThenRating),
          child: Text(SortMenuEntry.typeThenRating.label),
        ),
        MenuItemButton(
          onPressed: () => _activate(SortMenuEntry.notes),
          child: Text(SortMenuEntry.notes.label),
        ),
      ],
      builder: (context, controller, child) {
        return IconButton(
          icon: Icon(Icons.sort),
          tooltip: 'Choose sort order',
          visualDensity: VisualDensity.compact,
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
              _focusNode.requestFocus();
            }
          },
        );
      },
    );
  }

  void _activate(SortMenuEntry selection) {

    switch (selection) {
      case SortMenuEntry.title:
        // Handle title sort
        break;
      case SortMenuEntry.rating:
        // Handle rating sort
        break;
      case SortMenuEntry.dateCompleted:
        // Handle date completed sort
        break;
      case SortMenuEntry.typeThenRating:
        // Handle type then rating sort
        break;
      case SortMenuEntry.notes:
        // Handle notes sort
        break;
    }
  }
}

// Overflow button and its menu for the main screen

enum OverflowMenuEntry {

  undo(
    'Undo',
  ),
  redo(
    'Redo',
  ),
  setDBPath(
    'Set Database Path',
  );

  const OverflowMenuEntry(this.label);
  final String label;
}

class OverflowButton extends ConsumerStatefulWidget {
  const OverflowButton({super.key});

  @override
  ConsumerState<OverflowButton> createState() => _OverflowButtonState();
}

class _OverflowButtonState extends ConsumerState<OverflowButton> {

  final _menuController = MenuController();
  final _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {

    return MenuAnchor(
      animated: true,
      controller: _menuController,
      style: MenuStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.zero)
      ),
      menuChildren: [
        MenuItemButton(
          onPressed: () => _activate(OverflowMenuEntry.undo, ref),
          child: Text(OverflowMenuEntry.undo.label),
        ),
        MenuItemButton(
          onPressed: () => _activate(OverflowMenuEntry.redo, ref),
          child: Text(OverflowMenuEntry.redo.label),
        ),
        MenuItemButton(
          onPressed: () => _activate(OverflowMenuEntry.setDBPath, ref),
          child: Text(OverflowMenuEntry.setDBPath.label),
        ),
      ],
      builder: (context, controller, child) {
        return IconButton(
          icon: Icon(Icons.menu),
          tooltip: 'Open overflow menu',
          visualDensity: VisualDensity.compact,
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
              _focusNode.requestFocus();
            }
          },
        );
      },
    );
  }

  void _activate(OverflowMenuEntry selection, WidgetRef ref) {

    final commandManager = ref.read(commandManagerProvider.notifier);

    switch (selection) {
      case OverflowMenuEntry.undo:
        commandManager.undo();
        break;
      case OverflowMenuEntry.redo:
        commandManager.redo();
        break;
      case OverflowMenuEntry.setDBPath:
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => SetPathDialog(),
        );
        break;
    }
  }
}