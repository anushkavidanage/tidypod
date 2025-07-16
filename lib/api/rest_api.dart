// API for managing data at POD level
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

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:solidpod/solidpod.dart';
import 'package:tidypod/constants/app.dart';
import 'package:tidypod/constants/turtle_structures.dart';
import 'package:tidypod/models/category.dart';
import 'package:tidypod/utils/task_storage.dart';

// Get the list of notes created by the user.

// At the first instance save the task data as json string into a single file
// inside the data directory. Also keep track of last change time so that
// local and server data can be synced.

Future<LoadedTasks> loadServerTaskData(
  BuildContext context,
  Widget childPage,
) async {
  final loggedIn = await loginIfRequired(context);
  String webId = await getWebId() as String;
  webId = webId.replaceAll(profCard, '');

  String taskJsonStr = '';

  if (loggedIn) {
    final dataDirPath = await getDataDirPath();
    final dataDirUrl = await getDirUrl(dataDirPath);
    final taskFileUrl = dataDirUrl + myTasksFile;

    bool resExist = await checkResourceStatus(taskFileUrl);

    if (resExist) {
      taskJsonStr = await readPod(
        taskFileUrl.replaceAll(webId, ''),
        context,
        childPage,
      );
    }
  }

  String updatedTimeStr = '';
  var categories = <String, Category>{};

  if (taskJsonStr.isEmpty) return LoadedTasks({}, {});

  final decodedCategories = json.decode(taskJsonStr);

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

Future<bool> saveServerTaskData(
  String taskJsonStr,
  BuildContext context,
  Widget childPage,
) async {
  final loggedIn = await loginIfRequired(context);
  String webId = await getWebId() as String;
  webId = webId.replaceAll(profCard, '');

  // Map taskMap = {};

  if (loggedIn) {
    // final dataDirPath = await getDataDirPath();
    // final dataDirUrl = await getDirUrl(dataDirPath);
    // final taskFileUrl = dataDirUrl + myTasksFile;

    final writeDataStatus = await writePod(
      myTasksFile,
      taskJsonStr,
      context,
      childPage,
      // encrypted: false, // save in plain text for now
    );

    if (writeDataStatus != SolidFunctionCallStatus.success) {
      // throw Exception('Error occured. Please try again!');
      return false;
    } else {
      return true;
    }
  } else {
    return false;
  }
}

// Check if a resource exists in the POD
Future<bool> checkResourceStatus(String resUrl, {bool fileFlag = true}) async {
  final (:accessToken, :dPopToken) = await getTokensForResource(resUrl, 'GET');
  final response = await http.get(
    Uri.parse(resUrl),
    headers: <String, String>{
      'Content-Type': fileFlag ? '*/*' : 'application/octet-stream',
      'Authorization': 'DPoP $accessToken',
      'Link': fileFlag
          ? '<http://www.w3.org/ns/ldp#Resource>; rel="type"'
          : '<http://www.w3.org/ns/ldp#BasicContainer>; rel="type"',
      'DPoP': dPopToken,
    },
  );

  if (response.statusCode == 200 || response.statusCode == 204) {
    return true;
  } else if (response.statusCode == 404) {
    return false;
  } else {
    debugPrint(
      'Failed to check resource status.\n'
      'URL: $resUrl\n'
      'ERR: ${response.body}',
    );
    return false;
  }
}
