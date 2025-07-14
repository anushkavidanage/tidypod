/// A Task Manager app
///
/// Copyright (C) 2025, Anushka Vidanage
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// Authors: Anushka Vidanage

import 'package:appflowy_board/appflowy_board.dart';
import 'package:flutter/material.dart';
import 'package:tidypod/constants/color_theme.dart';
import 'package:tidypod/models/category.dart';
import 'package:tidypod/models/kanban_board.dart';
import 'package:tidypod/models/task.dart';
import 'package:tidypod/utils/task_storage.dart';
import 'package:tidypod/widgets/task_card.dart';

class TabItem {
  String title;
  IconData icon;

  TabItem({required this.title, this.icon = Icons.star});
}

class TextItem extends AppFlowyGroupItem {
  final String s;

  TextItem(this.s);

  @override
  String get id => s;
}

class _RowWidget extends StatelessWidget {
  final AppFlowyGroupItem item;
  const _RowWidget({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  activeColor: brightOrange,
                  value: false,
                  onChanged: (_) => {},
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Text(
                      item.id,
                      // style: TextStyle(
                      //   // fontWeight: FontWeight.w500,
                      //   // fontSize: 16,
                      //   decoration: widget.task.isDone
                      //       ? TextDecoration.lineThrough
                      //       : TextDecoration.none,
                      //   color: widget.task.isDone ? Colors.grey : Colors.black,
                      // ),
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert),
                  onSelected: (value) {},
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: const [
                          Icon(Icons.edit, color: darkBlue),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: const [
                          Icon(Icons.delete, color: darkRed),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // if (widget.task.dueDate != null) ...[
            //   /// Second Row: Due Date
            //   Padding(
            //     padding: const EdgeInsets.only(left: 10, top: 4.0),
            //     child: Text(
            //       'Due: ${getDateTimeStr(widget.task.dueDate!, formatType: DateFormatType.longDate)}',
            //       // style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            //       style: TextStyle(
            //         fontSize: 12,
            //         color: widget.task.isDone ? Colors.grey : Colors.grey[600],
            //         decoration: widget.task.isDone
            //             ? TextDecoration.lineThrough
            //             : TextDecoration.none,
            //       ),
            //     ),
            //   ),
            // ],
          ],
        ),
      ),
    );
  }
}

class TabsView extends StatefulWidget {
  const TabsView({super.key});

  @override
  TabsViewState createState() => TabsViewState();
}

class TabsViewState extends State<TabsView> with TickerProviderStateMixin {
  TabController? _tabController;
  final List<TabItem> _tabItems = [];
  final List<Widget> _tabViews = [];
  var _categories = <String, Category>{};
  final AppFlowyBoardController boardData = AppFlowyBoardController();

  @override
  void initState() {
    super.initState();
    // final column = AppFlowyGroupData(
    //   id: initialCategories['Work']!.id,
    //   name: initialCategories['Work']!.id,
    //   items: initialCategories['Work']!.taskList,
    // );

    // boardData.addGroup(column);

    final column = AppFlowyGroupData(
      id: "1",
      name: "1",
      items: [
        TextItem("a"),
        TextItem("b"),
        TextItem("c"),
        TextItem("d"),
        // Task(
        //   title: "Compile ideas for new research",
        //   createdTime: DateTime.now(),
        //   updatedTime: DateTime.now(),
        //   categoryId: 'Work',
        //   isDone: false,
        // ),
        // Task(
        //   title: "Meeting with boss",
        //   createdTime: DateTime.now(),
        //   updatedTime: DateTime.now(),
        //   categoryId: 'Work',
        //   isDone: false,
        //   dueDate: DateTime.parse('2025-07-27'),
        // ),
        // Task(
        //   title: "Pay utiliy bills",
        //   createdTime: DateTime.now(),
        //   updatedTime: DateTime.now(),
        //   categoryId: 'Personal',
        //   isDone: false,
        // ),
        // Task(
        //   title: "Schedule dentist appointment",
        //   createdTime: DateTime.now(),
        //   updatedTime: DateTime.now(),
        //   categoryId: 'Personal',
        //   isDone: false,
        //   dueDate: DateTime.parse('2025-12-07'),
        // ),
      ],
    );

    boardData.addGroup(column);

    _addTabWithTitle("Home", init: true);
  }

  void _loadTasks() async {
    bool initialiseTasks = false;
    Map<String, Category> taskCatMap;

    if (initialiseTasks) {
      taskCatMap = initialCategories;
    } else {
      LoadedTasks loadedTasks = await TaskStorage.loadTasks();
      taskCatMap = loadedTasks.categories;
    }
    for (Category category in taskCatMap.values) {
      boardData.addGroup(
        AppFlowyGroupData(
          id: category.id,
          name: category.id,
          items: List<AppFlowyGroupItem>.from(category.taskList),
        ),
      );
    }
    // for (Task task in taskCatList.first) {
    //   assert(taskCatList.last.contains(task.categoryId));
    //   boardController.addGroupItem(task.categoryId, task);
    // }
    setState(() {
      _categories = taskCatMap;
    });
  }

  void _createTabController({int initialIndex = 0}) {
    _tabController?.dispose();
    _tabController = TabController(
      length: _tabItems.length,
      vsync: this,
      initialIndex: initialIndex.clamp(0, _tabItems.length - 1),
    );
    _tabController!.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _addTabWithTitle(String title, {bool init = false}) {
    _tabItems.add(TabItem(title: title));
    _tabViews.add(
      Center(
        child: Container(
          color: bgOffWhite,
          child: AppFlowyBoard(
            controller: boardData,
            cardBuilder: (context, column, columnItem) {
              return _RowWidget(
                item: columnItem as TextItem,
                key: ObjectKey(columnItem),
              );
            },
          ),
        ),
      ),
    );
    _createTabController(initialIndex: _tabItems.length - 1);
    if (!init) setState(() {});
  }

  Widget _buildCard(Task item) {
    return _RowWidget(item: item);
  }

  Future<void> _showTabNameDialog({
    String? initial,
    Function(String)? onSubmit,
  }) async {
    String tabName = initial ?? "";
    TextEditingController controller = TextEditingController(text: tabName);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(initial == null ? 'New Tab Name' : 'Edit Tab Name'),
        content: TextField(
          autofocus: true,
          controller: controller,
          onChanged: (value) => tabName = value,
          decoration: InputDecoration(hintText: 'Enter tab name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (tabName.trim().isNotEmpty) {
                onSubmit?.call(tabName.trim());
                Navigator.pop(context);
              }
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _handleEdit(int index) {
    _showTabNameDialog(
      initial: _tabItems[index].title,
      onSubmit: (newName) {
        setState(() {
          _tabItems[index].title = newName;
          _tabViews[index] = Center(child: Text("Content of $newName"));
        });
      },
    );
  }

  void _handleDelete(int index) {
    int currentIndex = _tabController?.index ?? 0;
    _tabItems.removeAt(index);
    _tabViews.removeAt(index);

    if (_tabItems.isEmpty) {
      _addTabWithTitle("Home");
      return;
    }

    _createTabController(
      initialIndex: currentIndex >= _tabItems.length
          ? _tabItems.length - 1
          : currentIndex,
    );

    setState(() {});
  }

  void _reorderTabs(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;

    setState(() {
      final tabItem = _tabItems.removeAt(oldIndex);
      final tabView = _tabViews.removeAt(oldIndex);
      _tabItems.insert(newIndex, tabItem);
      _tabViews.insert(newIndex, tabView);
      _createTabController(initialIndex: newIndex);
    });
  }

  Widget _buildCustomTab(int index) {
    return DragTarget<int>(
      onAccept: (fromIndex) => _reorderTabs(fromIndex, index),
      builder: (context, candidateData, rejectedData) {
        return LongPressDraggable<int>(
          data: index,
          feedback: Material(
            color: Colors.transparent,
            child: _buildTabContent(index, isDragging: true),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: _buildTabContent(index),
          ),
          child: _buildTabContent(index),
        );
      },
    );
  }

  Widget _buildTabContent(int index, {bool isDragging = false}) {
    return Tab(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: isDragging ? Colors.grey.shade300 : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_tabItems[index].icon, size: 16),
            SizedBox(width: 6),
            Text(_tabItems[index].title),
            SizedBox(width: 6),
            if (!isDragging)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _handleEdit(index);
                  } else if (value == 'delete') {
                    _handleDelete(index);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
                child: Icon(Icons.more_vert, size: 16),
                padding: EdgeInsets.zero,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Row(
      children: [
        Expanded(
          child: TabBar(
            isScrollable: true,
            controller: _tabController,
            tabs: List.generate(
              _tabItems.length,
              (index) => _buildCustomTab(index),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.add),
          tooltip: "Add New Tab",
          onPressed: () {
            _showTabNameDialog(onSubmit: (name) => _addTabWithTitle(name));
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Custom Tabs with Actions"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: _buildTabBar(),
        ),
      ),
      body: _tabController != null
          ? TabBarView(controller: _tabController, children: _tabViews)
          : Center(child: CircularProgressIndicator()),
    );
  }
}
