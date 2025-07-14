import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: DynamicTabsScreen());
  }
}

class TabItem {
  String title;
  IconData icon;
  List<String> items;

  TabItem({required this.title, this.icon = Icons.star, required this.items});
}

class DynamicTabsScreen extends StatefulWidget {
  @override
  _DynamicTabsScreenState createState() => _DynamicTabsScreenState();
}

class _DynamicTabsScreenState extends State<DynamicTabsScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;
  final List<TabItem> _tabItems = [];

  @override
  void initState() {
    super.initState();
    _addTabWithTitle("Home", init: true);
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
    _tabItems.add(
      TabItem(
        title: title,
        items: List.generate(5, (i) => "$title Item ${i + 1}"),
      ),
    );
    _createTabController(initialIndex: _tabItems.length - 1);
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
        });
      },
    );
  }

  void _handleDelete(int index) {
    int currentIndex = _tabController?.index ?? 0;
    _tabItems.removeAt(index);

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
      _tabItems.insert(newIndex, tabItem);
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

  Widget _buildReorderableList(int index) {
    final tab = _tabItems[index];
    return ReorderableListView.builder(
      itemCount: tab.items.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex--;
          final item = tab.items.removeAt(oldIndex);
          tab.items.insert(newIndex, item);
        });
      },
      padding: EdgeInsets.all(16),
      itemBuilder: (context, itemIndex) {
        final item = tab.items[itemIndex];
        return ListTile(
          key: ValueKey(item),
          title: Text(item),
          tileColor: Colors.grey.shade100,
        );
      },
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
        title: Text("Tabs with Draggable Lists"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: _buildTabBar(),
        ),
      ),
      body: _tabController != null
          ? TabBarView(
              controller: _tabController,
              children: List.generate(
                _tabItems.length,
                (index) => _buildReorderableList(index),
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
