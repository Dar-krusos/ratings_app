import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratings_app/ui/linux/columns.dart';
import 'package:ratings_app/ui/linux/entries_table.dart';

final cellEditingProvider = NotifierProvider<CellEditingNotifier, (int entryId, ColumnType column)?>(CellEditingNotifier.new);

final rootFocusNodeProvider = Provider<FocusNode>((ref) => throw UnimplementedError());