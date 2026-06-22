import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SortType {
  title,
  rating,
  dateCompleted,
  notes,
  typeThenRating,
}

class SortState {

  final SortType column;
  final bool descending;

  const SortState({
    required this.column,
    required this.descending,
  });
}

class SortNotifier extends Notifier<SortState> {

  @override
  SortState build() {
    return const SortState(
      column: SortType.rating,
      descending: true,
    );
  }

  void setSort(
    SortType column,
  ) {

    if (state.column == column) {

      state = SortState(
        column: column,
        descending: !state.descending,
      );

    } else {
      late bool descending;
      if (column == SortType.rating || column == SortType.dateCompleted) {
        descending = true;
      } else {
        descending = false;
      }

      state = SortState(
        column: column,
        descending: descending,
      );
    }
  }
}

SortType mapFieldToSortType(
  String field,
) {
  switch (field) {

    case 'title':
      return SortType.title;

    case 'rating':
      return SortType.rating;

    case 'dateCompleted':
      return SortType.dateCompleted;

    case 'notes':
      return SortType.notes;

    default:
      return SortType.title;
  }
}