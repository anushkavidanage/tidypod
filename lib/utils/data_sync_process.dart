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

// import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tidypod/api/rest_api.dart';
import 'package:tidypod/constants/app.dart';
// import 'package:tidypod/models/task.dart';
import 'package:tidypod/utils/check_network.dart';
import 'package:tidypod/utils/data_sync_state.dart';
import 'package:tidypod/utils/task_storage.dart';

// Global parameter for keeping the status of local data changes.
// This parameter enables quick changes check without pulling data
// from the server every [waitSeconds] seconds.
// Initially set to true so that upon startup check the changes
// in server with the local data.
bool isLocalChanged = true;

// Globala parameter for the number of seconds to wait until to check
// changes in data
int waitSeconds = 10;

// Enum for data sync status
enum DataSyncStatus {
  insync('In sync'),
  clientahead('Client ahead'),
  serverahead('Server ahead'),
  nodata('No data');

  // Generative enum constructor
  const DataSyncStatus(this.value);

  // String label of data sync status
  final String value;
}

// Function to check if the data instances in server and the local memory are
// in sync
Future<DataSyncStatus> checkDataInSync(
  BuildContext context,
  Widget childPage,
) async {
  // Load local data
  final clientTaskStorage = await TaskStorage.loadTasks();
  final serverTaskStorage = await loadServerTaskData(context, childPage);
  if (clientTaskStorage.updatedTime[updateTimeLabel] == null &&
      serverTaskStorage.updatedTime[updateTimeLabel] == null) {
    return DataSyncStatus.nodata;
  } else {
    if (clientTaskStorage.updatedTime[updateTimeLabel] == null) {
      return DataSyncStatus.serverahead;
    } else if (serverTaskStorage.updatedTime[updateTimeLabel] == null) {
      return DataSyncStatus.clientahead;
    }
  }

  final clientUpdatedTime = DateTime.parse(
    clientTaskStorage.updatedTime[updateTimeLabel] as String,
  );
  final serverUpdatedTime = DateTime.parse(
    serverTaskStorage.updatedTime[updateTimeLabel] as String,
  );

  if (clientUpdatedTime == serverUpdatedTime) {
    return DataSyncStatus.insync;
  } else if (clientUpdatedTime.isAfter(serverUpdatedTime)) {
    return DataSyncStatus.clientahead;
  } else {
    return DataSyncStatus.serverahead;
  }
}

// Data sync process that runs every [waitSeconds] seconds
Future<void> syncTaskDataProcess(
  BuildContext context,
  Widget childPage,
  WidgetRef ref,
) async {
  print(isLocalChanged);
  if (isLocalChanged) {
    // Check if internet is connected or not
    final dataSyncStateNotifier = ref.read(dataSyncStateProvider.notifier);
    final dataSyncState = ref.watch(dataSyncStateProvider);

    if (!dataSyncState.networkConnected) {
      var isInternetConnected = await isInternetAvailable();
      dataSyncStateNotifier.setNetworkConnected(isInternetConnected);
    }

    if (dataSyncState.networkConnected) {
      dataSyncStateNotifier.setIsSynching(true);

      try {
        // Check if data stores are already linked
        DataSyncStatus dataSyncStatus = await checkDataInSync(
          context,
          childPage,
        );

        if (dataSyncStatus != DataSyncStatus.nodata) {
          dataSyncStateNotifier.setHasData(true);

          if (!(dataSyncStatus == DataSyncStatus.insync)) {
            bool status = false;

            if (dataSyncStatus == DataSyncStatus.clientahead) {
              final taskJsonStr = await TaskStorage.loadTasksJson();
              status = await saveServerTaskData(
                taskJsonStr,
                context,
                childPage,
              );
            } else {
              final serverTaskStorage = await loadServerTaskData(
                context,
                childPage,
              );
              final categories = serverTaskStorage.categories;
              String updatedTime =
                  serverTaskStorage.updatedTime[updateTimeLabel] as String;
              await TaskStorage.saveTasks(
                categories,
                updatedTime: DateTime.parse(updatedTime),
              );
              status = true;
            }

            if (status) {
              isLocalChanged = false;
              dataSyncStateNotifier.setIsSynching(false);
              dataSyncStateNotifier.setIsSynched(true);
            } else {
              dataSyncStateNotifier.setIsSynched(false);
              dataSyncStateNotifier.setIsSynching(false);
            }
          } else {
            isLocalChanged = false;
            dataSyncStateNotifier.setIsSynching(false);
            dataSyncStateNotifier.setIsSynched(true);
          }
        } else {
          isLocalChanged = false;
          dataSyncStateNotifier.setHasData(false);
        }
      } catch (_) {
        throw Exception('Failed to sync data!');
      }
    }
  }
}

// AV: Following queue process is currently not needed as we do not
// save task by task. When we decide to do that, we can enable this process

// Queue<Task> _pendingSaves = Queue();

// void _queueTaskSave(Task task) {
//   _pendingSaves.add(task);
//   _processQueue();
// }

// void _processQueue() async {
//   while (_pendingSaves.isNotEmpty) {
//     final task = _pendingSaves.first;
//     try {
//       // await TaskApiService.saveTask(task);
//       _pendingSaves.removeFirst();
//     } catch (_) {
//       await Future.delayed(Duration(seconds: 5));
//     }
//   }
// }
