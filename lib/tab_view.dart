// Tab view
//
// Copyright (C) 2025, Anushka Vidanage
//
// Licensed under the GNU General Public License, Version 3 (the "License");
//
// License: https://www.gnu.org/licenses/gpl-3.0.en.html
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
//
// Authors: Anushka Vidanage

import 'package:flutter/material.dart';

import 'package:tidypod/api/rest_api.dart';
import 'package:tidypod/constants/app.dart';
import 'package:tidypod/constants/color_theme.dart';
import 'package:tidypod/models/category.dart';
import 'package:tidypod/models/task.dart';
import 'package:tidypod/utils/data_sync_process.dart';
import 'package:tidypod/utils/misc.dart';
import 'package:tidypod/utils/task_storage.dart';
import 'package:tidypod/widgets/msg_card.dart';

class TabItem {
  String title;
  IconData icon;
  List<Task> items;

  TabItem({
    required this.title,
    this.icon = Icons.lightbulb_circle_rounded,
    required this.items,
  });
}

class TabView extends StatefulWidget {
  const TabView({super.key});

  @override
  TabViewState createState() => TabViewState();
}

class TabViewState extends State<TabView> with TickerProviderStateMixin {
  TabController? _tabController;
  var _categories = <String, Category>{};
  static Future? _asyncDataFetch;
  bool _isControllerReady = false;

  @override
  void initState() {
    super.initState();
    _asyncDataFetch = _loadTasks();
  }

  Future<Map<String, Category>> _loadTasks() async {
    LoadedTasks loadedTasks = LoadedTasks({
      updateTimeLabel: '',
    }, <String, Category>{});

    var dataSyncStaus = await checkDataInSync(context, TabView());
    if (dataSyncStaus == DataSyncStatus.insync ||
        dataSyncStaus == DataSyncStatus.clientahead) {
      loadedTasks = await TaskStorage.loadTasks();
    } else if (dataSyncStaus == DataSyncStatus.serverahead) {
      loadedTasks = await loadServerTaskData(context, TabView());
    }
    // LoadedTasks loadedTasks = await TaskStorage.loadTasks();
    // taskCatMap = loadedTasks.categories;

    _categories = loadedTasks.categories;
    if (_categories.isNotEmpty) {
      _createTabController();
    }
    return loadedTasks.categories;
  }

  void _createTabController({int initialIndex = 0}) {
    _tabController?.dispose();
    _tabController = TabController(
      length: _categories.length,
      vsync: this,
      initialIndex: initialIndex.clamp(0, _categories.length - 1),
    );
    _tabController!.addListener(() {
      if (mounted) setState(() {});
    });
    _isControllerReady = true;
  }

  void _addCategory(String name, {bool init = false}) async {
    final localCategory = Category(
      id: name,
      createdTime: DateTime.now(),
      updatedTime: DateTime.now(),
      taskList: <Task>[],
    );

    _categories[name] = localCategory;
    _createTabController(initialIndex: _categories.length - 1);
    TaskStorage.saveTasks(_categories);
    if (!init) setState(() {});
  }

  Future<void> _showCategoryNameDialog({
    String? initial,
    Function(String)? onSubmit,
  }) async {
    String tabName = initial ?? "";
    TextEditingController controller = TextEditingController(text: tabName);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          initial == null ? 'New Category Name' : 'Edit Category Name',
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Note: Category names must be unique',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 11),
              ),
              SizedBox(height: 15),
              TextField(
                autofocus: true,
                controller: controller,
                onChanged: (value) => tabName = value,
                decoration: InputDecoration(hintText: 'Enter category name'),
              ),
            ],
          ),
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

  void _editCategory(String key) {
    _showCategoryNameDialog(
      initial: _categories[key]!.id,
      onSubmit: (newKey) {
        setState(() {
          _categories = updateMapKeyPreserveOrder(_categories, key, newKey);
        });
        TaskStorage.saveTasks(_categories);
      },
    );
  }

  Map<String, Category> updateMapKeyPreserveOrder(
    Map<String, Category> originalMap,
    String oldKey,
    String newKey,
  ) {
    Map<String, Category> updatedMap = {};

    originalMap.forEach((key, value) {
      if (key == oldKey) {
        // Update category id
        value.id = newKey;
        // update each task in that category
        for (Task task in value.taskList) {
          task.categoryId = newKey;
        }
        updatedMap[newKey] = value;
      } else {
        updatedMap[key] = value;
      }
    });

    return updatedMap;
  }

  void _deleteCategory(String key) {
    int currentIndex = _tabController?.index ?? 0;
    _categories.remove(key);

    // if (_categories.isEmpty) {
    //   _addCategory("Default Category");
    //   TaskStorage.saveTasks(_categories);
    //   return;
    // }

    _createTabController(
      initialIndex: currentIndex >= _categories.length
          ? _categories.length - 1
          : currentIndex,
    );

    setState(() {});
    TaskStorage.saveTasks(_categories);
  }

  void _reorderCategory(int fromIndex, int toIndex) {
    if (fromIndex == toIndex) return;

    // Convert to a list
    List categoryList = [];
    _categories.forEach((k, v) => categoryList.add([k, v]));

    // Remove and add items from and to list
    var categoryData = categoryList.removeAt(fromIndex);
    categoryData.last.updatedTime = DateTime.now(); // Update time
    categoryList.insert(toIndex, categoryData);

    // Create a new category map
    Map<String, Category> newCategories = {};
    for (var element in categoryList) {
      newCategories[element.first] = element.last;
    }

    setState(() {
      _categories = newCategories;
      _createTabController(initialIndex: toIndex);
    });
    TaskStorage.saveTasks(_categories);
  }

  Widget _buildCustomCategory(int index) {
    return DragTarget<int>(
      onAccept: (fromIndex) => _reorderCategory(fromIndex, index),
      builder: (context, candidateData, rejectedData) {
        return LongPressDraggable<int>(
          data: index,
          feedback: Material(
            color: Colors.transparent,
            child: _buildCategoryContent(
              _categories.keys.toList()[index],
              isDragging: true,
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: _buildCategoryContent(_categories.keys.toList()[index]),
          ),
          child: _buildCategoryContent(_categories.keys.toList()[index]),
        );
      },
    );
  }

  Widget _buildCategoryContent(String key, {bool isDragging = false}) {
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
            Icon(Icons.lightbulb_circle_rounded, size: 16),
            SizedBox(width: 6),
            Text(_categories[key]!.id),
            SizedBox(width: 6),
            if (!isDragging)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _editCategory(key);
                  } else if (value == 'delete') {
                    _deleteCategory(key);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20, color: darkBlue),
                        Text(' Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: darkRed),
                        Text(' Delete'),
                      ],
                    ),
                  ),
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
              _categories.length,
              (index) => _buildCustomCategory(index),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.add),
          tooltip: "Add New Category",
          onPressed: () {
            _showCategoryNameDialog(onSubmit: (name) => _addCategory(name));
          },
        ),
      ],
    );
  }

  Widget _buildReorderableList(String key) {
    final category = _categories[key];

    return Column(
      children: [
        Expanded(
          child: ReorderableListView.builder(
            proxyDecorator: (child, index, animation) =>
                Material(type: MaterialType.transparency, child: child),
            padding: const EdgeInsets.all(10),
            itemCount: category!.taskList.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final item = category.taskList.removeAt(oldIndex);
                category.taskList.insert(newIndex, item);
              });
            },
            itemBuilder: (context, taskIndex) {
              final task = category.taskList[taskIndex];
              return Padding(
                key: ValueKey(taskIndex),
                padding: const EdgeInsets.fromLTRB(2.0, 4.0, 2.0, 4.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: lightOrange, // Border color
                      width: 0.5,
                    ),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: task.isDone ? Colors.grey : Colors.black,
                      ),
                    ),
                    subtitle: task.dueDate != null
                        ? Text(
                            'Due: ${getDateTimeStr(task.dueDate!, formatType: DateFormatType.longDate)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: task.isDone
                                  ? Colors.grey
                                  : Colors.grey[600],
                              decoration: task.isDone
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          )
                        : null,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Checkbox(
                      activeColor: brightOrange,
                      value: task.isDone,
                      onChanged: (_) => {_toggleTask(task)},
                    ),
                    trailing: Container(
                      padding: EdgeInsets.only(right: 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        // mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                // _editListItem(key, taskIndex);
                                _showEditTaskDialog(
                                  _categories[key]!.taskList[taskIndex],
                                );
                              } else if (value == 'delete') {
                                _deleteTask(key, taskIndex);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 20, color: darkBlue),
                                    Text(' Edit'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      size: 20,
                                      color: darkRed,
                                    ),
                                    Text(' Delete'),
                                  ],
                                ),
                              ),
                            ],
                            padding: EdgeInsets.zero,
                            child: Icon(Icons.more_vert),
                          ),
                          // IconButton(
                          //   icon: Icon(Icons.edit, color: Colors.blue),
                          //   onPressed: () => _editListItem(index, itemIndex),
                          //   tooltip: 'Edit item',
                          // ),
                          // IconButton(
                          //   icon: Icon(Icons.delete, color: Colors.red),
                          //   onPressed: () => _deleteListItem(index, itemIndex),
                          //   tooltip: 'Delete item',
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddTaskDialog(String categoryVal) {
    final titleController = TextEditingController();
    // String selectedCategory = _categories.first;
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('New Task'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(hintText: 'Enter task title'),
                ),
                SizedBox(height: 15),

                ElevatedButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() => selectedDate = pickedDate);
                    }
                  },
                  child: Text(
                    selectedDate == null
                        ? 'Pick Due Date (optional)'
                        : 'Due: ${selectedDate!.toLocal().toString().split(' ')[0]}',
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  'Category: $categoryVal',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),

                // DropdownButton<String>(
                //   value: selectedCategory,
                //   items: _categories
                //       .map(
                //         (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                //       )
                //       .toList(),
                //   onChanged: (val) => setState(() => selectedCategory = val!),
                // ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty) {
                  _addTask(
                    titleController.text.trim(),
                    categoryVal,
                    selectedDate,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTaskDialog(Task task) {
    TextEditingController titleController = TextEditingController(
      text: task.title,
    );
    DateTime? selectedDate = task.dueDate;
    String selectedCategory = task.categoryId;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text('Edit Task'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: 'Task Title'),
                  ),

                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() => selectedDate = pickedDate);
                      }
                    },
                    child: Text(
                      selectedDate == null
                          ? 'Pick Due Date (optional)'
                          : 'Due: ${selectedDate!.toLocal().toString().split(' ')[0]}',
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Text(
                        'Category: ',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      DropdownButton<String>(
                        value: selectedCategory,
                        items: _categories.keys
                            .map(
                              (cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => selectedCategory = val!),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.trim().isNotEmpty) {
                    _editTask(
                      task,
                      titleController.text.trim(),
                      selectedCategory,
                      selectedDate,
                    );
                    Navigator.of(context).pop();
                  }
                  // Navigator.pop(context);
                },
                child: Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addTask(String title, String categoryId, DateTime? dueDate) async {
    final task = Task(
      title: title,
      createdTime: DateTime.now(),
      updatedTime: DateTime.now(),
      categoryId: categoryId,
      isDone: false,
      dueDate: dueDate,
    );
    setState(() {
      _categories[categoryId]?.taskList.add(task);
    });
    TaskStorage.saveTasks(_categories);
  }

  void _editTask(
    Task oldTask,
    String title,
    String selectedCategory,
    DateTime? dueDate,
  ) async {
    String oldCategory = oldTask.categoryId;
    oldTask.title = title;
    oldTask.categoryId = selectedCategory;
    oldTask.dueDate = dueDate;
    oldTask.updatedTime = DateTime.now();

    // If the category of the task is changed, need to update that
    if (oldCategory != selectedCategory) {
      var removingCategory = _categories[oldCategory];
      var insertingCategory = _categories[selectedCategory];

      removingCategory?.updatedTime = DateTime.now(); // Update time
      insertingCategory?.updatedTime = DateTime.now(); // Update time

      // Remove the task from the removing category
      removingCategory?.taskList.remove(oldTask);

      // Insert the task to the inserting category
      insertingCategory?.taskList.add(oldTask);

      // Update the overall category map
      _categories[oldCategory] = removingCategory!;
      _categories[selectedCategory] = insertingCategory!;
    }
    setState(() {});
    TaskStorage.saveTasks(_categories);
  }

  void _deleteTask(String key, int taskIndex) {
    setState(() {
      _categories[key]!.taskList.removeAt(taskIndex);
    });
    TaskStorage.saveTasks(_categories);
  }

  void _toggleTask(Task task) {
    setState(() {
      task.isDone = !task.isDone;
      task.updatedTime = DateTime.now();
    });
    TaskStorage.saveTasks(_categories);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  // @override
  // Widget build(BuildContext context) {
  _buildTabPage(BuildContext context, Map<String, Category> categoriesMap) {
    if (_categories.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Tab View")),
        body: Center(
          child: Column(
            children: [
              buildMsgCard(
                context,
                Icons.info,
                brightOrange,
                'No Tasks Yet!',
                'You have not added any tasks or categories yet! Please add a category to get started.',
              ),
              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      _showCategoryNameDialog(
                        onSubmit: (name) => _addCategory(name),
                      );
                    },
                    child: Text('New Category'),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _categories = sampleCategories;
                        _createTabController();
                      });
                      TaskStorage.saveTasks(_categories);
                      // Navigator.pushAndRemoveUntil(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) =>
                      //         AppScreen(childPage: HomePage()),
                      //   ),
                      //   (Route<dynamic> route) =>
                      //       false, // This predicate ensures all previous routes are removed
                      // );
                    },
                    child: Text('Load sample tasks'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      // _createTabController();
      return Scaffold(
        appBar: AppBar(
          title: Text("Tab View"),
          bottom: _isControllerReady
              ? PreferredSize(
                  preferredSize: Size.fromHeight(48.0),
                  child: _buildTabBar(),
                )
              : null,
        ),
        body: _isControllerReady
            ? TabBarView(
                controller: _tabController,
                children: _categories.entries.map((entry) {
                  return _buildReorderableList(entry.key);
                }).toList(),
              )
            : Center(child: CircularProgressIndicator()),
        floatingActionButton: FloatingActionButton(
          backgroundColor: brightYellow,
          onPressed: () {
            int currentTab = _tabController?.index ?? 0;
            _showAddTaskDialog(_categories.keys.toList()[currentTab]);
            // _addListItem(currentTab, (fn) => setState(fn)); // call add item
          },
          tooltip: "Add New Task",
          child: Icon(Icons.add),
        ),
      );
    }
  }

  // }

  @override
  Widget build(BuildContext context) {
    // Run future and return results
    return FutureBuilder(
      future: _asyncDataFetch,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _buildTabPage(context, snapshot.data);
        } else {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }
}
