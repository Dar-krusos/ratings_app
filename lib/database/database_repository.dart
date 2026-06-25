import 'package:drift/drift.dart';

import 'package:ratings_app/database/database.dart';
import 'package:ratings_app/ui/data_types.dart';
import 'package:ratings_app/sort.dart';

class EntryRepository {
  final AppDatabase db;

  EntryRepository(this.db);

  Stream<List<Entry>> watchEntries({
    required FilterType type,
    required SortType sortType,
    required bool descending,
    required String searchQuery
  }) {
    final all = db.select(db.entries);
    
    if (searchQuery != '') {
      all.where((e) => 
        e.title.like('%$searchQuery%') |
        e.rating.cast<String>().like('%$searchQuery%') |
        e.dateCompleted.like('%$searchQuery%') |
        e.notes.like('%$searchQuery%')
      );
    }
    final query = all;

    switch (type) {
      case FilterType.movies:
        query.where((e) => e.mediaType.isIn(['Movie', 'Series']));
        break;
      case FilterType.games:
        query.where((e) => e.mediaType.equals('Game'));
        break;
      case FilterType.books:
        query.where((e) => e.mediaType.equals('Book'));
        break;
    }

    switch (sortType) {

      case SortType.title:
        query.orderBy([
          (t) => OrderingTerm(
            expression: t.title,
            mode: descending
                ? OrderingMode.desc
                : OrderingMode.asc,
          ),
        ]);
        break;

      case SortType.rating:
        query.orderBy([
          (t) => OrderingTerm(
            expression: t.rating,
            mode: descending
                ? OrderingMode.desc
                : OrderingMode.asc,
          ),
        ]);
        break;

      case SortType.dateCompleted:
        query.orderBy([
          (t) => OrderingTerm(
            expression: t.dateCompleted.equals(''),
          ),

          (t) => OrderingTerm(
            expression: t.dateCompleted,
            mode: descending
                ? OrderingMode.desc
                : OrderingMode.asc,
          ),
        ]);
        break;

      case SortType.notes:
        query.orderBy([
          (t) => OrderingTerm(
            expression: t.notes.equals(''),
          ),
          
          (t) => OrderingTerm(
            expression: t.notes,
            mode: descending
                ? OrderingMode.desc
                : OrderingMode.asc,
          ),
          
        ]);
        break;
      
      case SortType.typeThenRating:
        query.orderBy([
          (t) => OrderingTerm(
            expression: t.mediaType,
            mode: descending
                ? OrderingMode.desc
                : OrderingMode.asc,
          ),

          (t) => OrderingTerm(
            expression: t.rating,
            mode: OrderingMode.desc
          ),
        ]);
    }

    return query.watch();
  }

  Future addEntry(String title, int rating, String dateCompleted, String mediaType, String notes) {
    return db.into(db.entries).insert(EntriesCompanion(
      title: Value(title),
      rating: Value(rating),
      dateCompleted: Value(dateCompleted),
      mediaType: Value(mediaType),
      notes: Value(notes)

    ));
  }

  Future updateEntry(int id, EntriesCompanion edit) {
    return (db.update(db.entries)..where(
      (e) => e.id.equals(id)
    )).write(edit);
  }

  Future deleteEntry(int id) {
    return (db.delete(db.entries)..where(
      (e) => e.id.equals(id)
    )).go();
  }
}