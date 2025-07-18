// Kanban view
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

import 'package:appflowy_board/appflowy_board.dart';
import 'package:tidypod/models/responsive.dart';

import 'package:tidypod/models/task.dart';
import 'package:tidypod/models/kanban_board.dart';
import 'package:tidypod/models/category.dart';
import 'package:tidypod/utils/data_sync_process.dart';
import 'package:tidypod/utils/task_storage.dart';
import 'package:tidypod/widgets/category_header.dart';
import 'package:tidypod/widgets/msg_card.dart';
import 'package:tidypod/widgets/task_card.dart';
import 'package:tidypod/constants/app.dart';
import 'package:tidypod/constants/color_theme.dart';
import 'package:tidypod/api/rest_api.dart';

class KanbanView extends StatefulWidget {
  const KanbanView({super.key});

  @override
  KanbanViewState createState() => KanbanViewState();
}

class KanbanViewState extends State<KanbanView> {
  late AppFlowyBoardScrollController _boardScrollController;
  late ScrollController _scrollController;
  AppFlowyBoardController? _boardController;
  var _categories = <String, Category>{};
  static Future? _asyncDataFetch;

  @override
  void initState() {
    super.initState();
    _boardController?.dispose();
    _boardController = createBoardController();
    _boardScrollController = AppFlowyBoardScrollController();
    _scrollController = ScrollController();
    _asyncDataFetch = _loadTasks();
  }

  Future<Map<String, Category>> _loadTasks() async {
    LoadedTasks loadedTasks = LoadedTasks({
      updateTimeLabel: '',
    }, <String, Category>{});

    /// av: Why below commented code is not working?
    // print('here0');
    // final dataSyncState = ref.watch(dataSyncStateProvider);
    // print(dataSyncState);
    // if (dataSyncState.isSynched) {
    //   print('here1');
    //   loadedTasks = await TaskStorage.loadTasks();
    // } else {
    //   print('here2');
    //   var dataSyncStaus = await checkDataInSync(context, HomePage());
    //   if (dataSyncStaus == DataSyncStatus.insync ||
    //       dataSyncStaus == DataSyncStatus.clientahead) {
    //     print('here3');
    //     loadedTasks = await TaskStorage.loadTasks();
    //   } else if (dataSyncStaus == DataSyncStatus.serverahead) {
    //     print('here4');
    //     loadedTasks = await loadServerTaskData(context, HomePage());
    //   }
    // }
    var dataSyncStaus = await checkDataInSync(context, KanbanView());
    if (dataSyncStaus == DataSyncStatus.insync ||
        dataSyncStaus == DataSyncStatus.clientahead) {
      loadedTasks = await TaskStorage.loadTasks();
    } else if (dataSyncStaus == DataSyncStatus.serverahead) {
      loadedTasks = await loadServerTaskData(context, KanbanView());
    }
    for (Category category in loadedTasks.categories.values) {
      _boardController!.addGroup(
        AppFlowyGroupData(
          id: category.id,
          name: category.id,
          items: List<AppFlowyGroupItem>.from(category.taskList),
        ),
      );
    }
    _categories = loadedTasks.categories;

    return loadedTasks.categories;
  }

  _buildKanbanPage(BuildContext context, Map<String, Category> categoriesMap) {
    final config = AppFlowyBoardConfig(
      groupBackgroundColor: bgOffWhite,
      groupCornerRadius: 20,
      stretchGroupHeight: false,
    );
    _categories = categoriesMap;
    return Scaffold(
      appBar: AppBar(
        title: Text('Kanban board', style: TextStyle(fontSize: 20)),
        // actions: <Widget>[DataSyncIcon()],
      ),
      body: _categories.isEmpty
          ? Center(
              child: Column(
                children: [
                  buildMsgCard(
                    context,
                    Icons.info,
                    brightOrange,
                    'No Tasks Yet!',
                    'You have not added any tasks or categories yet! Please add a category or load sample tasks to get started.',
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      for (Category category in sampleCategories.values) {
                        _boardController!.addGroup(
                          AppFlowyGroupData(
                            id: category.id,
                            name: category.id,
                            items: List<AppFlowyGroupItem>.from(
                              category.taskList,
                            ),
                          ),
                        );
                      }
                      setState(() {
                        _categories = sampleCategories;
                      });
                      TaskStorage.saveTasks(_categories);
                    },
                    child: Text('Load sample tasks'),
                  ),
                ],
              ),
            )
          : Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: Container(
                padding: EdgeInsets.all(10),
                child: AppFlowyBoard(
                  controller: _boardController!,
                  cardBuilder: (context, group, groupItem) {
                    return AppFlowyGroupCard(
                      key: ValueKey(groupItem.id),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: lightGrey2, // Border color
                          width: 0.5,
                        ),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildCard(groupItem),
                    );
                  },
                  scrollController: _scrollController,
                  boardScrollController: _boardScrollController,
                  footerBuilder: (context, group) {
                    return AppFlowyGroupFooter(
                      icon: const Icon(Icons.add, size: 20, color: darkBlue),
                      title: const Text('New Task'),
                      height: 50,
                      margin: config.groupBodyPadding,
                      onAddButtonClick: () {
                        _showAddTaskDialog(group.id);
                      },
                    );
                  },
                  headerBuilder: (context, group) {
                    return AppFlowyGroupHeader(
                      icon: const Icon(
                        Icons.lightbulb_circle_rounded,
                        color: darkBlue,
                      ),
                      title: Flexible(
                        // width: 150,
                        child: EditableTextWidget(
                          initialText: group.headerData.groupName,
                          onSubmit: _editCategory,
                        ),
                        // TextField(
                        //   controller: TextEditingController()
                        //     ..text = group.headerData.groupName,
                        //   onSubmitted: (val) {
                        //     boardController
                        //         .getGroupController(
                        //           group.headerData.groupId,
                        //         )!
                        //         .updateGroupName(val);
                        //   },
                        // ),
                      ),
                      //addIcon: const Icon(Icons.add, size: 20),
                      moreIcon: const Icon(
                        Icons.delete,
                        size: 20,
                        color: darkRed,
                      ),
                      height: 50,
                      margin: config.groupBodyPadding,
                      onMoreButtonClick: () {
                        _showDeleteCategoryDialog(group.id);
                      },
                    );
                  },
                  groupConstraints: Responsive.isLargeDesktop(context)
                      ? BoxConstraints.tightFor(
                          width: screenWidth(context) / 4,
                          height: screenHeight(context),
                        )
                      : Responsive.isDesktop(context)
                      ? BoxConstraints.tightFor(
                          width: screenWidth(context) / 3,
                          height: screenHeight(context),
                        )
                      : Responsive.isTablet(context)
                      ? BoxConstraints.tightFor(
                          width: screenWidth(context) / 2,
                          height: screenHeight(context),
                        )
                      : BoxConstraints.tightFor(
                          width: 300,
                          height: screenHeight(context),
                        ),
                  config: config,
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: brightYellow,
        tooltip: 'Add a new category',
        onPressed: _showAddCategoryDialog,
        child: Icon(Icons.add),
      ),
    );
  }
  // @override
  // Widget build(BuildContext context) {

  // }

  Widget _buildCard(AppFlowyGroupItem item) {
    if (item is Task) {
      return TaskCard(
        task: item,
        deleteTask: _deleteTask,
        toggleTask: _toggleTask,
        editTaskDialog: _showEditTaskDialog,
      );
    }
    throw UnimplementedError();
  }

  void _showAddCategoryDialog() {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('New Category'),
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
                  controller: titleController,
                  decoration: InputDecoration(hintText: 'Enter category name'),
                ),
                SizedBox(height: 15),
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
                  _addCategory(titleController.text.trim());
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

  void _showDeleteCategoryDialog(String name) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Please Confirm'),
          content: Text(
            'Are you sure you want to delete the category $name? \nDeleting this category will also delete all the tasks inside the category!',
          ),
          actions: [
            // The "Yes" button
            TextButton(
              onPressed: () {
                _deleteCategory(name);
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
          ],
        );
      },
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
                  Text(
                    'Category: ${task.categoryId}',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'To change the category please move the task between categories.',
                    style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
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
                    _editTask(task, titleController.text.trim(), selectedDate);
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

  void _addCategory(String name) async {
    final category = AppFlowyGroupData(
      id: name,
      name: name,
      items: <AppFlowyGroupItem>[],
    );
    final localCategory = Category(
      id: name,
      createdTime: DateTime.now(),
      updatedTime: DateTime.now(),
      taskList: [],
    );

    setState(() {
      _boardController!.addGroup(category);
      _categories[name] = localCategory;
    });
    await TaskStorage.saveTasks(_categories);
  }

  void _editCategory(String name, String newName) {
    _categories = updateMapKeyPreserveOrder(_categories, name, newName);

    // Update the board conroller
    _boardController!.removeGroup(name);
    _boardController!.insertGroup(
      _categories.keys.toList().indexOf(newName),
      AppFlowyGroupData(
        id: newName,
        name: newName,
        items: List<AppFlowyGroupItem>.from(_categories[newName]!.taskList),
      ),
    );

    // Save tasks
    TaskStorage.saveTasks(_categories);
  }

  // Update map while preserving the order of categories
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

  void _deleteCategory(String name) {
    // Delete the category as well as the associated tasks
    setState(() {
      _boardController!.removeGroup(name);
      _categories.remove(name);
    });
    // Update the task storage
    TaskStorage.saveTasks(_categories);
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
    _boardController!.addGroupItem(categoryId, task);
    await TaskStorage.saveTasks(_categories);
  }

  void _editTask(Task oldTask, String title, DateTime? dueDate) async {
    setState(() {
      oldTask.title = title;
      oldTask.dueDate = dueDate;
      oldTask.updatedTime = DateTime.now();
    });
    await TaskStorage.saveTasks(_categories);
  }

  void _toggleTask(Task task) {
    setState(() {
      task.isDone = !task.isDone;
      task.updatedTime = DateTime.now();
    });
    TaskStorage.saveTasks(_categories);
  }

  void _deleteTask(Task task) {
    setState(() {
      _categories[task.categoryId]?.taskList.remove(task);
    });
    _boardController!.removeGroupItem(task.categoryId, task.id);
    TaskStorage.saveTasks(_categories);
    // flutterLocalNotificationsPlugin.cancel(
    //   task.title.hashCode,
    // ); // Cancel notification
  }

  @override
  void dispose() {
    _boardController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Run future and return results
    return FutureBuilder(
      future: _asyncDataFetch,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _buildKanbanPage(context, snapshot.data);
        } else {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }
}
