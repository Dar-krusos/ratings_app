import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratings_app/ui/linux/columns.dart';

class CellEditingNotifier extends Notifier<(int entryId, ColumnType column)?> {
  @override
  (int entryId, ColumnType column)? build() {
    return null;
  }

  void clear() {
    state = null;
  }

  void setCell(int entryId, ColumnType column) {
    state = (entryId, column);
  }
}

final cellEditingProvider = NotifierProvider<CellEditingNotifier, (int entryId, ColumnType column)?>(CellEditingNotifier.new);
