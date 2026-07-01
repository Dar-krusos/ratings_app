import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratings_app/ui/data_types.dart';
import 'package:ratings_app/providers.dart';
import 'package:ratings_app/sort.dart';

import 'package:ratings_app/ui/desktop/entries_table.dart';
import 'package:ratings_app/ui/dialogs.dart';

class MainScreen extends ConsumerStatefulWidget {

  const MainScreen({
    super.key,
  });

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {

  late final FocusNode rootFocusNode;
  late final FocusNode searchFocusNode;
  late final TextEditingController searchController;
  late Color enabledColor;
  late Color disabledColor;

  @override
  void initState() {
    super.initState();
    rootFocusNode = FocusNode();
    searchFocusNode = FocusNode();
    searchController = TextEditingController();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      rootFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    rootFocusNode.dispose();
    searchFocusNode.dispose();
    searchController.dispose();
    super.dispose();
  }
    
  @override
  Widget build(BuildContext context) {
    final commandManager = ref.read(commandManagerProvider.notifier);
    final commandManagerCheck = ref.watch(commandManagerProvider);

    if (MediaQuery.platformBrightnessOf(context) == Brightness.light) {
      enabledColor = Color(0xFF454545);
      disabledColor = Color(0xFFcac4d0);
    } else {
      enabledColor = Color(0xFFcac4d0);
      disabledColor = Color(0xFF454545);
    }

    return ProviderScope(
      overrides: [
        rootFocusNodeProvider.overrideWithValue(rootFocusNode)],
      child: Focus(
        autofocus: true,
        focusNode: rootFocusNode,
        onKeyEvent: (node, event) {
          if (
            rootFocusNode.hasPrimaryFocus &&
            event is KeyDownEvent &&
            !HardwareKeyboard.instance.isControlPressed
          ) {
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              searchController.text =  '';
              searchFocusNode.requestFocus();
            }
            else if (
              event.character != null &&
              event.character!.isNotEmpty
            ) {
              searchController.text +=
                  event.character!;

              searchFocusNode.requestFocus();

              WidgetsBinding.instance
                  .addPostFrameCallback((_) {

                searchController.selection =
                    TextSelection.collapsed(
                  offset:
                      searchController.text.length,
                );
              });
            }

            ref.read(searchProvider.notifier).update(searchController.text);
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: DefaultTabController(
          initialIndex: 0,
          length: 3,
          child: Scaffold(
            body: Column(
              children: [

                // first row 

                TabBar(
                  tabs: [
                    for (final tab in tabs)
                      Tab(
                        icon: Icon(tab.icon),
                        text: tab.title,
                      ),
                  ],
                  onTap: (index) {
                    Future.delayed(
                      const Duration(milliseconds: 150),
                      () {
                        ref.read(tabProvider.notifier)
                            .select(FilterType.values[index]);
                      },
                    );
                  },
                ),

                // second row

                Padding(
                  padding: const EdgeInsetsGeometry.directional(
                    start: 10,
                    end: 10,
                    top: 5,
                  ),
                  child: Row(
                    children: [
                        MultiSortButton(
                          ref: ref,
                          icon: Icon(Icons.sort),
                          tooltip: 'Sort by media type, then by rating',
                          onPressed: () {
                            ref
                              .read(sortProvider.notifier)
                              .setSort(SortType.typeThenRating);
                          },
                        ),

                        // search bar
                        
                        Expanded(
                          child: Padding(
                              padding: const EdgeInsetsGeometry.directional(end: 10),
                              child: SearchBar(
                                constraints: const BoxConstraints(minHeight: 30),
                                controller: searchController,
                                focusNode: searchFocusNode,
                                elevation: WidgetStatePropertyAll(0),
                                leading: Icon(Icons.search),
                                hintText: "Search",
                                onChanged: (value) {
                                  ref.read(searchProvider.notifier).update(value);
                                },
                                onTapOutside: (_) {
                                  rootFocusNode.requestFocus();
                                }
                              )
                          )
                        ),

                        // right-side buttons

                        IconButton( // undo button
                          icon: Icon(
                            Icons.undo_rounded,
                            color: commandManagerCheck.canUndo ? enabledColor : disabledColor,
                          ),
                          tooltip: 'Undo last change',
                          onPressed: () {
                            commandManager.undo();
                          },
                        ),
                        IconButton( // redo button
                          icon: Icon(
                            Icons.redo_rounded,
                            color: commandManagerCheck.canRedo ? enabledColor : disabledColor,
                            ),
                          tooltip: 'Redo last change',
                          onPressed: () {
                            commandManager.redo();
                          },
                        ),
                        IconButton( // add entry button
                          icon: Icon(Icons.add),
                          tooltip: 'Add new entry',
                          onPressed: () => showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AddEntryDialog(),
                          ),
                        ),
                        IconButton( // set database path button
                          icon: Icon(Icons.file_open),
                          tooltip: 'Change database path',
                          onPressed: () => showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => SetPathDialog(),
                          ),
                        ),
                    ],
                  ),
                ),

                // table of entries

                Expanded(
                  child: EntriesTable()
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}

class MultiSortButton extends IconButton {
  final WidgetRef ref;

  const MultiSortButton({
    super.key,
    required this.ref,
    required super.icon,
    super.tooltip,
    required super.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final currentTab = ref.watch(tabProvider);

    if (currentTab != FilterType.movies) {
      return SizedBox.shrink();
    }

    return IconButton(
      icon: super.icon,
      tooltip: super.tooltip,
      onPressed: super.onPressed,
    );
  }
}