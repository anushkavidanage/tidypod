import 'package:appflowy_board/appflowy_board.dart';

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

// class Task {
//   String title;
//   String category;
//   DateTime dueDate;
//   bool isDone;

//   Task({
//     required this.title,
//     required this.category,
//     required this.dueDate,
//     this.isDone = false,
//   });

//   Map<String, dynamic> toJson() => {
//     'title': title,
//     'category': category,
//     'dueDate': dueDate.toIso8601String(),
//     'isDone': isDone,
//   };

//   factory Task.fromJson(Map<String, dynamic> json) => Task(
//     title: json['title'],
//     category: json['category'],
//     dueDate: DateTime.parse(json['dueDate']),
//     isDone: json['isDone'],
//   );
// }

// class TaskList {
//   final String id;
//   String name;
//   List<Task> tasks;

//   TaskList({required this.id, required this.name, required this.tasks});
// }

// class TextItem extends AppFlowyGroupItem {
//   final String s;
//   TextItem(this.s);

//   @override
//   String get id => s;
// }

// class RichTextItem extends AppFlowyGroupItem {
//   final String title;
//   final String subtitle;

//   RichTextItem({required this.title, required this.subtitle});

//   @override
//   String get id => title;
// }

class Task extends AppFlowyGroupItem {
  String title;
  DateTime createdTime;
  DateTime updatedTime;
  String categoryId;
  bool isDone;
  DateTime? dueDate;

  Task({
    required this.title,
    required this.createdTime,
    required this.updatedTime,
    required this.categoryId,
    required this.isDone,
    this.dueDate,
  });

  @override
  String get id => title;

  Map<String, dynamic> toJson() => {
    'title': title,
    'createdTime': createdTime.toString(),
    'updatedTime': updatedTime.toString(),
    'categoryId': categoryId,
    'dueDate': dueDate?.toIso8601String(),
    'isDone': isDone,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    title: json['title'],
    createdTime: DateTime.parse(json['createdTime']),
    updatedTime: DateTime.parse(json['updatedTime']),
    categoryId: json['categoryId'],
    dueDate: json['dueDate'] == null ? null : DateTime.parse(json['dueDate']),
    isDone: json['isDone'],
  );
}
