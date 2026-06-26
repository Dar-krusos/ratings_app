import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratings_app/ui/data_types.dart';
import 'package:ratings_app/providers.dart';

import 'package:ratings_app/ui/dialogs.dart';
import 'package:ratings_app/ui/android/entries_list.dart';
import 'package:ratings_app/ui/android/context_menus.dart';

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
  late bool searching;

  @override
  void initState() {
    super.initState();

    searching = false;
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
    // final commandManager = ref.read(commandManagerProvider.notifier);
    // final commandManagerCheck = ref.watch(commandManagerProvider);

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
            appBar: AppBar(
              title: Row(
                children: [

                  // tabs

                  Expanded(
                    child: TabBar(
                      splashBorderRadius: BorderRadius.circular(50),
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
                  ),

                  // search bar and buttons

                  Padding(
                    padding: const EdgeInsetsGeometry.directional(end: 5),
                    child: Row(
                      children: [

                          // search bar
                          
                          // Expanded(
                          //   child: Padding(
                          //       padding: const EdgeInsetsGeometry.directional(end: 10),
                          //       child: SearchBar(
                          //         constraints: const BoxConstraints(minHeight: 30),
                          //         controller: searchController,
                          //         focusNode: searchFocusNode,
                          //         elevation: WidgetStatePropertyAll(0),
                          //         leading: Icon(Icons.search),
                          //         hintText: "Search",
                          //         onChanged: (value) {
                          //           ref.read(searchProvider.notifier).update(value);
                          //         },
                          //         onTapOutside: (_) {
                          //           rootFocusNode.requestFocus();
                          //         }
                          //       )
                          //   )
                          // ),

                          // buttons

                          IconButton( // search button
                            icon: Icon(Icons.search),
                            tooltip: 'Search',
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              setState(() {
                                searching = true;
                              });
                            },
                          ),

                          // IconButton( // undo button
                          //   icon: Icon(
                          //     Icons.undo_rounded,
                          //     color: commandManagerCheck.canUndo ? enabledColor : disabledColor,
                          //   ),
                          //   tooltip: 'Undo last change',
                          //   onPressed: () {
                          //     commandManager.undo();
                          //   },
                          // ),
                          // IconButton( // redo button
                          //   icon: Icon(
                          //     Icons.redo_rounded,
                          //     color: commandManagerCheck.canRedo ? enabledColor : disabledColor,
                          //     ),
                          //   tooltip: 'Redo last change',
                          //   onPressed: () {
                          //     commandManager.redo();
                          //   },
                          // ),
                          IconButton( // add entry button
                            icon: Icon(Icons.add),
                            padding: const EdgeInsetsGeometry.symmetric(horizontal: 0),
                            tooltip: 'Add new entry',
                            visualDensity: VisualDensity.compact,
                            onPressed: () => showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AddEntryDialog(),
                            ),
                          ),
                          SortButton(), // sort menu button
                          OverflowButton(), // overflow menu button
                      ],
                    ),
                  ),
                ],
              ),
            ),
            body: Column(
              children: [

                // first row

                

                // list of entries

                EntriesList()
              ],
            ),
          ),
        ),
      )
    );
  }
}