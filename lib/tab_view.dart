import 'package:flutter/material.dart';
import 'package:tidypod/constants/color_theme.dart';
import 'package:tidypod/models/category.dart';
import 'package:tidypod/models/task.dart';
import 'package:tidypod/utils/misc.dart';
import 'package:tidypod/utils/task_storage.dart';

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
  bool _isControllerReady = false;

  @override
  void initState() {
    _loadTasks();
    super.initState();
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
    _categories = taskCatMap;
    _createTabController(initialIndex: 0);
    setState(() {
      // _categories = taskCatMap;
    });
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
    //await TaskStorage.saveTasks(_categories);
    if (!init) setState(() {});
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
        title: Text(
          initial == null ? 'New Category Name' : 'Edit Category Name',
        ),
        content: TextField(
          autofocus: true,
          controller: controller,
          onChanged: (value) => tabName = value,
          decoration: InputDecoration(hintText: 'Enter category name'),
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

  void _handleEdit(String key) {
    _showTabNameDialog(
      initial: _categories[key]!.id,
      onSubmit: (newName) {
        setState(() {
          _categories[key]!.id = newName;
        });
      },
    );
  }

  void _handleDelete(String key) {
    int currentIndex = _tabController?.index ?? 0;
    _categories.remove(key);

    if (_categories.isEmpty) {
      _addCategory("Default Category");
      return;
    }

    _createTabController(
      initialIndex: currentIndex >= _categories.length
          ? _categories.length - 1
          : currentIndex,
    );

    setState(() {});
  }

  void _reorderTabs(int fromIndex, int toIndex) {
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
  }

  Widget _buildCustomTab(int index) {
    return DragTarget<int>(
      onAccept: (fromIndex) => _reorderTabs(fromIndex, index),
      builder: (context, candidateData, rejectedData) {
        return LongPressDraggable<int>(
          data: index,
          feedback: Material(
            color: Colors.transparent,
            child: _buildTabContent(
              _categories.keys.toList()[index],
              isDragging: true,
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: _buildTabContent(_categories.keys.toList()[index]),
          ),
          child: _buildTabContent(_categories.keys.toList()[index]),
        );
      },
    );
  }

  Widget _buildTabContent(String key, {bool isDragging = false}) {
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
                    _handleEdit(key);
                  } else if (value == 'delete') {
                    _handleDelete(key);
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
              _categories.length,
              (index) => _buildCustomTab(index),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.add),
          tooltip: "Add New Category",
          onPressed: () {
            _showTabNameDialog(onSubmit: (name) => _addCategory(name));
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
                                _editListItem(key, taskIndex);
                              } else if (value == 'delete') {
                                _deleteListItem(key, taskIndex);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
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

  void _editListItem(String key, int taskIndex) async {
    final currentTask = _categories[key]!.taskList[taskIndex];
    Task editedItem = currentTask;

    await showDialog(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController(
          text: currentTask.title,
        );
        return AlertDialog(
          title: Text('Edit Item'),
          content: TextField(
            controller: controller,
            onChanged: (val) => editedItem.title = val,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (editedItem.title.trim().isNotEmpty) {
                  setState(() {
                    _categories[key]!.taskList[taskIndex] = editedItem;
                  });
                  Navigator.pop(context);
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _deleteListItem(String key, int taskIndex) {
    setState(() {
      _categories[key]!.taskList.removeAt(taskIndex);
    });
  }

  void _toggleTask(Task task) {
    setState(() {
      task.isDone = !task.isDone;
      task.updatedTime = DateTime.now();
    });
    // TaskStorage.saveTasks(_categories);
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
          print(currentTab);
          // _addListItem(currentTab, (fn) => setState(fn)); // call add item
        },
        tooltip: "Add New Task",
        child: Icon(Icons.add),
      ),
    );
  }
}
