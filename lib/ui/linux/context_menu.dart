import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratings_app/providers.dart';


enum MenuEntry {
  deleteEntry(
    'Delete row',
    // SingleActivator(LogicalKeyboardKey.space),
  );

  const MenuEntry(this.label, [this.shortcut]);
  final String label;
  final MenuSerializableShortcut? shortcut;

  // deleteEntry(
  //   'Delete row',
  //   [
  //     SingleActivator(LogicalKeyboardKey.space),
  //     SingleActivator(LogicalKeyboardKey.enter),
  //   ]
  // );

  // const MenuEntry(this.label, [this.shortcuts]);
  // final String label;
  // final List<MenuSerializableShortcut>? shortcuts;
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

  final MenuController _menuController = MenuController();
  ShortcutRegistryEntry? _shortcutsEntry;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // _shortcutsEntry?.dispose();

    // final Map<ShortcutActivator, Intent> shortcuts =
    //     <ShortcutActivator, Intent>{
    //       for (final MenuEntry item in MenuEntry.values)
    //         if (item.shortcut != null)
    //           item.shortcut!: VoidCallbackIntent(() => _activate(item, ref, widget.id)),
    //         // if (item.shortcuts != null)
    //           // for (final shortcut in item.shortcuts!)
    //           //   shortcut: VoidCallbackIntent(() => _activate(item, ref, widget.id)),
    //     };
    // _shortcutsEntry = ShortcutRegistry.of(context).addAll(shortcuts);
  }

  @override
  void dispose() {
    _shortcutsEntry?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onSecondaryTapDown: _handleSecondaryTapDown,
      child: MenuAnchor(
        animated: true,
        controller: _menuController,
        menuChildren: <Widget>[
          MenuItemButton(
            child: Text(MenuEntry.deleteEntry.label),
            onPressed: () => _activate(MenuEntry.deleteEntry, ref, widget.id),
          ),
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

  void _handleSecondaryTapDown(TapDownDetails details) {
    _menuController.open(position: details.localPosition);
  }

  void _handleTapDown(TapDownDetails details) {
    if (_menuController.isOpen) {
      _menuController.close();
      return;
    }
  }
}