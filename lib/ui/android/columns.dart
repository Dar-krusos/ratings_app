import 'package:flutter/material.dart';

import 'package:ratings_app/sort.dart';

class SortableHeader extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const SortableHeader({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {

    return TextButton(
      onPressed: onPressed,

      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class TableColumn {
  final String title;
  final int flex;
  final SortType sortType;

  const TableColumn({
    required this.title,
    required this.flex,
    required this.sortType,
  });
}

const columns = [

  TableColumn(
    title: 'Title',
    flex: 5,
    sortType: SortType.title,
  ),

  TableColumn(
    title: 'Rating',
    flex: 1,
    sortType: SortType.rating,
  ),

  TableColumn(
    title: 'Date completed',
    flex: 2,
    sortType: SortType.dateCompleted,
  ),

  TableColumn(
    title: 'Notes',
    flex: 3,
    sortType: SortType.notes,
  ),
];