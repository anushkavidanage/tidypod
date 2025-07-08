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

import 'package:flutter/material.dart';

import 'package:appflowy_board/appflowy_board.dart';
import 'package:tidypod/models/category.dart';
import 'package:tidypod/utils/task_storage.dart';

final AppFlowyBoardController boardController = AppFlowyBoardController(
  onMoveGroup: (fromGroupId, fromIndex, toGroupId, toIndex) async {
    var categories = await TaskStorage.loadTasks();

    // Convert to a list
    List categoryList = [];
    categories.forEach((k, v) => categoryList.add([k, v]));

    // Remove and add items from and to list
    final category = categoryList.removeAt(fromIndex);
    categoryList.insert(toIndex, category);

    // Create a new category map
    Map<String, Category> newCategories = {};
    for (var element in categoryList) {
      newCategories[element.first] = element.last;
    }

    // Update the local storage
    await TaskStorage.saveTasks(newCategories);
    debugPrint('Move item from $fromIndex to $toIndex');
  },
  onMoveGroupItem: (groupId, fromIndex, toIndex) async {
    var categories = await TaskStorage.loadTasks();

    // Get the category
    var category = categories[groupId];

    // Update the task list
    final task = category?.taskList.removeAt(fromIndex);
    category?.taskList.insert(toIndex, task!);

    categories[groupId] = category!;

    // Update the local storage
    await TaskStorage.saveTasks(categories);

    debugPrint('Move $groupId:$fromIndex to $groupId:$toIndex');
  },
  onMoveGroupItemToGroup: (fromGroupId, fromIndex, toGroupId, toIndex) async {
    var categories = await TaskStorage.loadTasks();

    // Get the categories
    var removingCategory = categories[fromGroupId];
    var insertingCategory = categories[toGroupId];

    // Remove the task from the removing category
    final task = removingCategory?.taskList.removeAt(fromIndex);

    // Update the task category id
    task?.categoryId = toGroupId;

    // Insert the task to the inserting category
    insertingCategory?.taskList.insert(toIndex, task!);

    // Update the overall category map
    categories[fromGroupId] = removingCategory!;
    categories[toGroupId] = insertingCategory!;

    // Update the local storage
    await TaskStorage.saveTasks(categories);

    debugPrint('Move $fromGroupId:$fromIndex to $toGroupId:$toIndex');
  },
);
