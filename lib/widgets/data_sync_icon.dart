// Data sync icon.
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

library;

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animated_icon/animated_icon.dart';

import 'package:tidypod/constants/color_theme.dart';
import 'package:tidypod/utils/data_sync_state.dart';
import 'package:tidypod/utils/data_sync_process.dart';

// import 'package:riopod/utils/device_status.dart';

class DataSyncIcon extends ConsumerStatefulWidget {
  const DataSyncIcon({super.key});

  @override
  DataSyncIconState createState() => DataSyncIconState();
}

class DataSyncIconState extends ConsumerState<DataSyncIcon> {
  bool showSyncStatus = false;

  @override
  void initState() {
    super.initState();
    _syncTasksLoop();
  }

  void _syncTasksLoop() async {
    // Simulate a network call or delay
    // Wait for three seconds so the widget tree is fully build
    await Future.delayed(Duration(seconds: 3));
    setState(() {
      showSyncStatus = true;
    });
    Timer.periodic(Duration(seconds: waitSeconds), (Timer timer) {
      syncTaskDataProcess(context, DataSyncIcon(), ref);
      print('running');
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataSyncState = ref.watch(dataSyncStateProvider);

    return Container(
      padding: EdgeInsets.only(right: 20),
      child: Row(
        children: [
          (showSyncStatus && dataSyncState.hasData)
              ? dataSyncState.networkConnected
                    ? dataSyncState.isSynching
                          ? RichText(
                              text: TextSpan(
                                children: [
                                  WidgetSpan(
                                    child: AnimateIcon(
                                      key: UniqueKey(),
                                      onTap: () {},
                                      iconType: IconType.continueAnimation,
                                      height: 24,
                                      // width: 70,
                                      color: darkOrange,
                                      animateIcon: AnimateIcons.refresh,
                                    ),
                                  ),
                                  TextSpan(
                                    text: " Synching...",
                                    style: TextStyle(color: darkOrange),
                                  ),
                                ],
                              ),
                            )
                          : dataSyncState.isSynched
                          ? RichText(
                              text: TextSpan(
                                children: [
                                  WidgetSpan(
                                    child: Icon(Icons.sync, color: darkGreen),
                                  ),
                                  TextSpan(
                                    text: " Data synched",
                                    style: TextStyle(color: darkGreen),
                                  ),
                                ],
                              ),
                            )
                          : RichText(
                              text: TextSpan(
                                children: [
                                  WidgetSpan(
                                    child: Icon(
                                      Icons.sync_disabled,
                                      color: darkRed,
                                    ),
                                  ),
                                  TextSpan(
                                    text: " Out of sync!",
                                    style: TextStyle(color: darkRed),
                                  ),
                                ],
                              ),
                            )
                    : RichText(
                        text: TextSpan(
                          children: [
                            WidgetSpan(
                              child: Icon(
                                Icons.signal_wifi_bad_rounded,
                                color: darkRed,
                              ),
                            ),
                            TextSpan(
                              text: " No internet connection",
                              style: TextStyle(color: darkRed),
                            ),
                          ],
                        ),
                      )
              : RichText(
                  text: TextSpan(
                    children: [
                      WidgetSpan(child: Icon(Icons.sync, color: lightGrey)),
                    ],
                  ),
                ),

          // IconButton(
          //   tooltip: 'Create a new note',
          //   icon: const Icon(Icons.cloud_sync, color: Colors.black),
          //   onPressed: () {
          //     // Navigator.pushAndRemoveUntil(
          //     //   context,
          //     //   MaterialPageRoute(
          //     //       builder: (context) => AppScreen(
          //     //             childPage: HomePage(),
          //     //           )),
          //     //   (Route<dynamic> route) =>
          //     //       false, // This predicate ensures all previous routes are removed
          //     // );
          //   },
          // ),
        ],
      ),
    );
  }
}
