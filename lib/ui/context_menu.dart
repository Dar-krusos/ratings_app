import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratings_app/providers.dart';


enum MenuEntry {
  deleteEntry(
    'Delete row',
  );

  const MenuEntry(this.label);
  final String label;
}

class ContextMenu extends ConsumerStatefulWidget {
  const ContextMenu({
    super.key,
    required this.id,
    required this.child});

  final int id;
  final Widget child;

  @override
  ConsumerState<ContextMenu> createState() => _ContextMenuState();
}

class _ContextMenuState extends ConsumerState<ContextMenu> {

  final _menuController = MenuController();
  final _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        if (_menuController.isOpen) {
          _menuController.close();
        }
      },
      onLongPress: () {
        _menuController.open();
        _focusNode.requestFocus();
      },
      onSecondaryTapDown: (details) {
        _menuController.open(position: details.localPosition);
        _focusNode.requestFocus();
      },
      child: MenuAnchor(
        animated: true,
        controller: _menuController,
        style: MenuStyle(
          padding: WidgetStatePropertyAll(EdgeInsets.zero)
        ),
        menuChildren: [
          Shortcuts(
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
                    _activate(MenuEntry.deleteEntry, ref, widget.id);
                    return null;
                  },
                ),
              },
              child: MenuItemButton(
                autofocus: true,
                focusNode: _focusNode,
                onPressed: () => _activate(MenuEntry.deleteEntry, ref, widget.id),
                child: Text(MenuEntry.deleteEntry.label),
              ),
            )
          )
        ],
        child: widget.child,
      ),
    );
  }

  void _activate(MenuEntry selection, WidgetRef ref, int id) {
    switch (selection) {
      case MenuEntry.deleteEntry:
        ref.read(entryRepositoryProvider).deleteEntry(id);
    }
  }
}

class DeleteIntent extends Intent {
  const DeleteIntent();
}