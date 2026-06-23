import 'package:flutter/material.dart';

enum FilterType {
  movies,
  games,
  books,
}

class TabData {
  final IconData icon;
  final String title;

  const TabData({
    required this.icon,
    required this.title,
  });
}

const tabs = [

  TabData(
    icon: Icons.movie,
    title: 'Movies',
  ),

  TabData(
    icon: Icons.games,
    title: 'Games',
  ),

  TabData(
    icon: Icons.book,
    title: 'Books',
  ),
];