// Task model
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

import 'package:appflowy_board/appflowy_board.dart';

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
