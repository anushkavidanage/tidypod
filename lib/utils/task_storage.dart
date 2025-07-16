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

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:solidpod/solidpod.dart';
import 'package:tidypod/constants/app.dart';
import 'package:tidypod/models/category.dart';
import 'package:tidypod/utils/data_sync_process.dart';
// import 'package:tidypod/models/task.dart';

// Local storage class for tasks and categories
class TaskStorage {
  // Save tasks to local storage
  static Future<void> saveTasks(
    Map<String, Category> categories, {
    DateTime? updatedTime,
  }) async {
    // Get the time of the update
    updatedTime ??= DateTime.now();
    final dataKey = (await getWebId() as String) + appName;
    final prefs = await SharedPreferences.getInstance();
    final jsonTasks = categories.values
        .map((category) => category.toJson())
        .toList();

    // Add update time to the json list
    jsonTasks.add({updateTimeLabel: updatedTime.toString()});

    prefs.setString(dataKey, json.encode(jsonTasks));

    isLocalChanged = true;
  }

  // Load tasks and categories
  static Future<LoadedTasks> loadTasks() async {
    final dataKey = (await getWebId() as String) + appName;
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(dataKey);

    if (jsonString == null) return LoadedTasks({}, {});

    String updatedTimeStr = '';

    final List decodedCategories = json.decode(jsonString);

    var categories = <String, Category>{};

    for (var json in decodedCategories) {
      if (json.containsKey(updateTimeLabel)) {
        updatedTimeStr = json[updateTimeLabel];
        continue;
      }
      var category = Category.fromJson(json);
      String id = json['id'];
      categories[id] = category;
    }

    // Return a LoadedTasks object
    return LoadedTasks({updateTimeLabel: updatedTimeStr}, categories);
  }

  // Load tasks and categories json string only
  static Future<String> loadTasksJson() async {
    final dataKey = (await getWebId() as String) + appName;
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(dataKey);

    if (jsonStr == null) {
      return '';
    } else {
      return jsonStr;
    }
  }
}

// Custom class for loading tasks
class LoadedTasks {
  Map<String, String> updatedTime;
  Map<String, Category> categories;

  LoadedTasks(this.updatedTime, this.categories);
}
