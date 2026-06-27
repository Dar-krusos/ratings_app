import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratings_app/providers.dart';
import 'package:ratings_app/sort.dart';

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
          onPressed: () => _activate(SortMenuEntry.title, ref),
          child: Text(SortMenuEntry.title.label),
        ),
        MenuItemButton(
          onPressed: () => _activate(SortMenuEntry.rating, ref),
          child: Text(SortMenuEntry.rating.label),
        ),
        MenuItemButton(
          onPressed: () => _activate(SortMenuEntry.dateCompleted, ref),
          child: Text(SortMenuEntry.dateCompleted.label),
        ),
        MenuItemButton(
          onPressed: () => _activate(SortMenuEntry.typeThenRating, ref),
          child: Text(SortMenuEntry.typeThenRating.label),
        ),
        MenuItemButton(
          onPressed: () => _activate(SortMenuEntry.notes, ref),
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

  void _activate(SortMenuEntry selection, WidgetRef ref) {

    late final SortType sortType;

    switch (selection) {
      case SortMenuEntry.title:
        sortType = SortType.title;
        break;
      case SortMenuEntry.rating:
        sortType = SortType.rating;
        break;
      case SortMenuEntry.dateCompleted:
        sortType = SortType.dateCompleted;
        break;
      case SortMenuEntry.typeThenRating:
        sortType = SortType.typeThenRating;
        break;
      case SortMenuEntry.notes:
        sortType = SortType.notes;
        break;
    }

    ref.read(sortProvider.notifier).setSort(sortType);
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