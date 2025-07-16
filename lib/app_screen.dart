// App screen.
///
/// Copyright (C) 2025, Anushka Vidanage.
///
/// Licensed under the GNU General Public License, Version 3 (the "License").
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html.
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solidpod/solidpod.dart';
import 'package:tidypod/home.dart';
import 'package:version_widget/version_widget.dart';

import 'package:tidypod/widgets/data_sync_icon.dart';
import 'package:tidypod/widgets/nav_drawer.dart';

class AppScreen extends ConsumerStatefulWidget {
  /// Initialise widget variables.
  const AppScreen({super.key, required this.childPage, this.title = ''});

  final Widget childPage;
  final String title;

  @override
  AppScreenState createState() => AppScreenState();
}

class AppScreenState extends ConsumerState<AppScreen>
    with SingleTickerProviderStateMixin {
  String? _webId;

  String _appVersion = '';

  Widget _selectedWidget = HomePage(); // default view

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  /// Loads the app name and version from package_info_plus.

  Future<void> _loadAppInfo() async {
    final appInfo = await getAppNameVersion();
    if (mounted) {
      setState(() {
        _appVersion = appInfo.version;
      });
    }
  }

  void _selectWidget(Widget widget) {
    setState(() {
      _selectedWidget = widget;
    });
    Navigator.of(context).pop(); // close the drawer
  }

  Future<({String name, String? webId})> _getInfo() async =>
      (name: await AppInfo.name, webId: await getWebId());

  Widget _build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: lightGreen,
        centerTitle: true,
        title: Text(widget.title),
        actions: <Widget>[
          DataSyncIcon(),
          const SizedBox(width: 20),
          VersionWidget(
            version: _appVersion,
            changelogUrl: 'https://github.com/anushkavidanage/tidypod',
            showDate: true,
          ),
          const SizedBox(width: 20),
          // IconButton(
          //   tooltip: 'Create a new note',
          //   icon: const Icon(Icons.add_circle, color: Colors.black),
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
          // const SizedBox(width: 10),
          // IconButton(
          //   tooltip: 'My Notes',
          //   icon: const Icon(Icons.view_list, color: Colors.black),
          //   onPressed: () {
          //     // Navigator.pushAndRemoveUntil(
          //     //   context,
          //     //   MaterialPageRoute(
          //     //       builder: (context) => AppScreen(
          //     //             childPage: ListNotesScreen(),
          //     //           )),
          //     //   (Route<dynamic> route) =>
          //     //       false, // This predicate ensures all previous routes are removed
          //     // );
          //   },
          // ),
          const SizedBox(width: 10),
        ],
      ),
      drawer: NavDrawer(webId: _webId ?? '', onMenuSelect: _selectWidget),

      body: _selectedWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<({String name, String? webId})>(
      future: _getInfo(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _webId = snapshot.data?.webId;
          return _build(context);
        } else {
          return const Scaffold(body: CircularProgressIndicator());
        }
      },
    );
  }
}
