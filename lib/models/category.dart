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

import 'package:tidypod/models/task.dart';

class Category {
  String id;
  DateTime createdTime;
  DateTime updatedTime;
  List<Task> taskList;

  Category({
    required this.id,
    required this.createdTime,
    required this.updatedTime,
    required this.taskList,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdTime': createdTime.toString(),
    'updatedTime': updatedTime.toString(),
    'taskList': taskList.map((task) => task.toJson()).toList(),
  };

  factory Category.fromJson(Map<String, dynamic> json) {
    List<Task> taskList = [];
    for (var taskMap in json['taskList']) {
      var task = Task.fromJson(taskMap);
      taskList.add(task);
    }
    var category = Category(
      id: json['id'],
      createdTime: DateTime.parse(json['createdTime']),
      updatedTime: DateTime.parse(json['updatedTime']),
      taskList: taskList,
    );
    return category;
  }
}

final Map<String, Category> initialCategories = {
  'Work': Category(
    id: 'Work',
    createdTime: DateTime.now(),
    updatedTime: DateTime.now(),
    taskList: [
      Task(
        title: "Compile ideas for new research",
        createdTime: DateTime.now(),
        updatedTime: DateTime.now(),
        categoryId: 'Work',
        isDone: false,
      ),
      Task(
        title: "Meeting with boss",
        createdTime: DateTime.now(),
        updatedTime: DateTime.now(),
        categoryId: 'Work',
        isDone: false,
        dueDate: DateTime.parse('2025-07-27'),
      ),
    ],
  ),
  'Personal': Category(
    id: 'Personal',
    createdTime: DateTime.now(),
    updatedTime: DateTime.now(),
    taskList: [
      Task(
        title: "Pay utiliy bills",
        createdTime: DateTime.now(),
        updatedTime: DateTime.now(),
        categoryId: 'Personal',
        isDone: false,
      ),

      Task(
        title: "Schedule dentist appointment",
        createdTime: DateTime.now(),
        updatedTime: DateTime.now(),
        categoryId: 'Personal',
        isDone: false,
        dueDate: DateTime.parse('2025-12-07'),
      ),
    ],
  ),
  'Shopping': Category(
    id: 'Shopping',
    createdTime: DateTime.now(),
    updatedTime: DateTime.now(),
    taskList: [
      Task(
        title: "Bread",
        createdTime: DateTime.now(),
        updatedTime: DateTime.now(),
        categoryId: 'Shopping',
        isDone: false,
      ),
      Task(
        title: "Milk",
        createdTime: DateTime.now(),
        updatedTime: DateTime.now(),
        categoryId: 'Shopping',
        isDone: false,
        dueDate: DateTime.parse('2025-09-15'),
      ),
    ],
  ),
  'Other': Category(
    id: 'Other',
    createdTime: DateTime.now(),
    updatedTime: DateTime.now(),
    taskList: [
      Task(
        title: "Learn a new skill",
        createdTime: DateTime.now(),
        updatedTime: DateTime.now(),
        categoryId: 'Other',
        isDone: false,
      ),
    ],
  ),
};
