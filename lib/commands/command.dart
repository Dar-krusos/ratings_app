import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratings_app/database/database.dart';
import 'package:ratings_app/database/database_repository.dart';

abstract class Command {
  bool get isNoOp;

  Future<void> undo();
  Future<void> redo();
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

    await command.redo();
    undoStack.add(command);
    redoStack.clear();
    refresh();
  }

  Future<void> undo() async {
    if (undoStack.isEmpty) return;

    final command = undoStack.removeLast();
    await command.undo();
    redoStack.add(command);
    refresh();
  }

  Future<void> redo() async {
    if (redoStack.isEmpty) return;

    final command = redoStack.removeLast();
    await command.redo();
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
  Future<void> undo() async {
    await provider.deleteEntry(_id!);
    debugPrint('undo: \n\treverted addition of entry with $_id - $title.');
  }

  @override
  Future<void> redo() async {
    int id = await provider.addEntry(_id, title, rating, dateCompleted, mediaType, notes);

    _id ??= id;
    debugPrint('redo: \n\tadded entry with $_id - $title.');
  }
}

class EditEntryFieldCommand implements Command {
  final Future<void> Function(int, EntriesCompanion) setter;
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
  Future<void> undo() async {
    await setter(id, oldValue);
    debugPrint('undo: \n\tfrom: ${newValue.toColumns(true)} \n\tto:   ${oldValue.toColumns(true)}');
  }

  @override
  Future<void> redo() async {
    await setter(id, newValue);
    debugPrint('redo: \n\tfrom: ${oldValue.toColumns(true)} \n\tto:   ${newValue.toColumns(true)}');
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
  Future<void> undo() async {
    await provider.addEntry(entry.id, entry.title, entry.rating, entry.dateCompleted!, entry.mediaType, entry.notes!);
    debugPrint('undo: \n\treverted deletion of entry with ${entry.id} - ${entry.title}.');
  }

  @override
  Future<void> redo() async {
    await provider.deleteEntry(entry.id);
    debugPrint('redo: \n\tdeleted entry with ${entry.id} - ${entry.title}.');
  }
}