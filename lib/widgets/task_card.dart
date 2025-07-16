// Task card
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

import 'package:flutter/material.dart';

import 'package:tidypod/models/task.dart';
import 'package:tidypod/utils/misc.dart';
import 'package:tidypod/constants/color_theme.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final Function deleteTask;
  final Function toggleTask;
  final Function editTaskDialog;
  const TaskCard({
    required this.task,
    required this.deleteTask,
    required this.toggleTask,
    required this.editTaskDialog,
    super.key,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  activeColor: brightOrange,
                  value: widget.task.isDone,
                  onChanged: (_) => widget.toggleTask(widget.task),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      widget.toggleTask(widget.task);
                    },
                    child: Text(
                      widget.task.title,
                      style: TextStyle(
                        // fontWeight: FontWeight.w500,
                        // fontSize: 16,
                        decoration: widget.task.isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: widget.task.isDone ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'edit') {
                      widget.editTaskDialog(widget.task);
                    } else if (value == 'delete') {
                      widget.deleteTask(widget.task);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: const [
                          Icon(Icons.edit, color: darkBlue),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: const [
                          Icon(Icons.delete, color: darkRed),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (widget.task.dueDate != null) ...[
              /// Second Row: Due Date
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 4.0),
                child: Text(
                  'Due: ${getDateTimeStr(widget.task.dueDate!, formatType: DateFormatType.longDate)}',
                  // style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.task.isDone ? Colors.grey : Colors.grey[600],
                    decoration: widget.task.isDone
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
