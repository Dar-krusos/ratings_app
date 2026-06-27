import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratings_app/database/database.dart';
import 'package:ratings_app/entry_repository/entry_repository.dart';

abstract class Command {
  bool get isNoOp;

  Future<int> undo();
  Future<int> redo();
}

class CommandManagerState {

  final bool canUndo;
  final bool canRedo;

  const CommandManagerState({
    required this.canUndo,
    required this.canRedo,
  });
}

class CommandManager extends Notifier<CommandManagerState> {

  final undoStack = <Command>[];
  final redoStack = <Command>[];

  @override
  CommandManagerState build() {
    return const CommandManagerState(
      canUndo: false,
      canRedo: false,
    );
  }

  void refresh() {
    state = CommandManagerState(
      canUndo: undoStack.isNotEmpty,
      canRedo: redoStack.isNotEmpty,
    );
  }

  Future<void> execute(Command command) async  {
    if (command.isNoOp) {
      return;
    }

    int id = await command.redo();

    if (id == 1) {
      return;
    }

    undoStack.add(command);
    redoStack.clear();
    refresh();
  }

  Future<void> undo() async {
    if (undoStack.isEmpty) return;

    final command = undoStack.last;
    int id = await command.undo();

    if (id == 1) {
      return;
    }

    undoStack.removeLast();
    redoStack.add(command);
    refresh();
  }

  Future<void> redo() async {
    if (redoStack.isEmpty) return;

    final command = redoStack.last;
    int id = await command.redo();

    if (id == 1) {
      return;
    }

    redoStack.removeLast();
    undoStack.add(command);
    refresh();
  }
}

class AddEntryCommand implements Command {

  final EntryRepository provider;
  final String title;
  final int rating;
  final String dateCompleted;
  final String mediaType;
  final String notes;

  int? _id;

  AddEntryCommand({
    required this.provider,
    required this.title,
    required this.rating,
    required this.dateCompleted,
    required this.mediaType,
    required this.notes,
  });

  @override
  bool get isNoOp => false;

  @override
  Future<int> undo() async {
    int id = await provider.deleteEntry(_id!);

    return checkResult(id, 'undo', 'reverted addition of entry with id $_id - $title.');
  }

  @override
  Future<int> redo() async {
    int id = await provider.addEntry(_id, title, rating, dateCompleted, mediaType, notes);

    return checkResult(id, 'redo', 'added entry with id $_id - $title.');
  }
}

class EditEntryCommand implements Command {
  final Future<int> Function(int, EntriesCompanion) setter;
  final int id;
  final EntriesCompanion oldValue;
  final EntriesCompanion newValue;

  EditEntryCommand({
    required this.setter,
    required this.id,
    required this.oldValue,
    required this.newValue,
  });

  @override
  bool get isNoOp => oldValue == newValue;

  @override
  Future<int> undo() async {
    int id = await setter(this.id, oldValue);

    return checkResult(id, 'undo', 'reverted edit of entry with id $id - current title: ${oldValue.title.value}.');
  }

  @override
  Future<int> redo() async {
    int id = await setter(this.id, newValue);

    return checkResult(id, 'redo', 'edited entry with id $id - current title: ${newValue.title.value}.');
  }
}

class EditEntryFieldCommand implements Command {
  final Future<int> Function(int, EntriesCompanion) setter;
  final int id;
  final EntriesCompanion oldValue;
  final EntriesCompanion newValue;

  EditEntryFieldCommand({
    required this.setter,
    required this.id,
    required this.oldValue,
    required this.newValue,
  });

  @override
  bool get isNoOp => oldValue == newValue;

  @override
  Future<int> undo() async {
    int id = await setter(this.id, oldValue);

    return checkResult(id, 'undo', 'entry with id ${this.id}\n\tfrom: ${newValue.toColumns(true)} \n\tto:   ${oldValue.toColumns(true)}');
  }

  @override
  Future<int> redo() async {
    int id = await setter(this.id, newValue);
    return checkResult(id, 'redo', 'entry with id ${this.id}\n\tfrom: ${oldValue.toColumns(true)} \n\tto:   ${newValue.toColumns(true)}');
  }
}

class DeleteEntryCommand implements Command {

  final EntryRepository provider;
  final Entry entry;

  DeleteEntryCommand({
    required this.provider,
    required this.entry,
  });

  @override
  bool get isNoOp => false;

  @override
  Future<int> undo() async {
    int id = await provider.addEntry(entry.id, entry.title, entry.rating, entry.dateCompleted!, entry.mediaType, entry.notes!);
    return checkResult(id, 'undo', 'reverted deletion of entry with id ${entry.id} - ${entry.title}.');
  }

  @override
  Future<int> redo() async {
    int id = await provider.deleteEntry(entry.id);
    return checkResult(id, 'redo', 'deleted entry with id ${entry.id} - ${entry.title}.');
  }
}

int checkResult(int id, String action, String message) {
  if (id == -1) {
    return 1;
  }

  debugPrint('$action: \n\t$message');
  return 0;
}