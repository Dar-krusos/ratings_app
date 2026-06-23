import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratings_app/providers.dart';
import 'package:ratings_app/commands/command.dart';

class ShortcutsManager extends ConsumerWidget {

  final Widget Function() createMainScreen;

  const ShortcutsManager({
    super.key,
    required this.createMainScreen
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commandManager = ref.read(commandManagerProvider.notifier);

    return Shortcuts(
      shortcuts: {
        SingleActivator(
          LogicalKeyboardKey.keyZ,
          control: true,
        ): UndoIntent(),
        SingleActivator(
          LogicalKeyboardKey.keyY,
          control: true,
        ): RedoIntent(),
      },
      child: Actions(
        dispatcher: ActionDispatcher(),
        actions: <Type, Action<Intent>>{
          UndoIntent: UndoAction(commandManager),
          RedoIntent: RedoAction(commandManager),
        },
        child: createMainScreen(),
      ),
    );
  }
}

class UndoIntent extends Intent {
  const UndoIntent();
}

class RedoIntent extends Intent {
  const RedoIntent();
}

class UndoAction extends Action<UndoIntent> {
  final CommandManager commandManager;

  UndoAction(this.commandManager);

  @override
  void invoke(covariant UndoIntent intent) => commandManager.undo();
}

class RedoAction extends Action<RedoIntent> {
  final CommandManager commandManager;

  RedoAction(this.commandManager);

  @override
  void invoke(covariant RedoIntent intent) => commandManager.redo();
}