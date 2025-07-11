/// Individual's POD content variables.
///
/// Copyright (C) 2025, Anushka Vidanage
///
/// License: GNU General Public License, Version 3 (the "License")
/// https://www.gnu.org/licenses/gpl-3.0.en.html
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
library;

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tidypod/api/rest_api.dart';
import 'package:tidypod/models/task.dart';
import 'package:tidypod/utils/check_network.dart';
import 'package:tidypod/utils/data_sync_status.dart';
import 'package:tidypod/utils/task_storage.dart';

Queue<Task> _pendingSaves = Queue();

void _queueTaskSave(Task task) {
  _pendingSaves.add(task);
  _processQueue();
}

void _processQueue() async {
  while (_pendingSaves.isNotEmpty) {
    final task = _pendingSaves.first;
    try {
      // await TaskApiService.saveTask(task);
      _pendingSaves.removeFirst();
    } catch (_) {
      await Future.delayed(Duration(seconds: 5));
    }
  }
}

Future<void> syncTaskDataLoop(
  BuildContext context,
  Widget childPage,
  WidgetRef ref,
) async {
  var isInternetConnected = await isConnectedToInternet();

  final dataSyncStateNotifier = ref.read(dataSyncStateProvider.notifier);

  // while (true) {
  if (isInternetConnected) {
    dataSyncStateNotifier.setNetworkConnected(true);
    final taskJsonStr = await TaskStorage.loadTasksJson();
    dataSyncStateNotifier.setIsSynching(true);
    bool status = await saveServerTaskData(taskJsonStr, context, childPage);
    if (status) {
      dataSyncStateNotifier.setIsSynching(false);
      dataSyncStateNotifier.setIsSynched(true);
    } else {
      dataSyncStateNotifier.setIsSynched(false);
      dataSyncStateNotifier.setIsSynching(false);
    }
  } else {
    dataSyncStateNotifier.setNetworkConnected(false);
  }
  // }
}
