// Main function
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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solidpod/solidpod.dart';

import 'package:tidypod/app_screen.dart';
import 'package:tidypod/constants/app.dart';
import 'package:tidypod/constants/color_theme.dart';
import 'package:tidypod/kanban_view.dart';
import 'package:tidypod/models/responsive.dart';
import 'package:tidypod/tab_view.dart';

void main() {
  runApp(const ProviderScope(child: TidyPod()));
}

class TidyPod extends StatelessWidget {
  const TidyPod({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: brightOrange),
        // scrollbarTheme: ScrollbarThemeData(
        //   thumbVisibility: WidgetStateProperty.all<bool>(true),
        // ),
        // scaffoldBackgroundColor: bgOffWhite,
      ),
      debugShowCheckedModeBanner: false,
      home: buildSolidLogin(),
    );
  }
}

// Build the normal login widget.

Widget buildSolidLogin() {
  return Builder(
    builder: (context) {
      return SolidLogin(
        required: true,
        title: 'TIDY POD',
        appDirectory: 'tidypod',
        webID: serverUrl,
        image: const AssetImage('assets/images/tidypod_image.jpg'),
        logo: const AssetImage('assets/images/tidypod_logo.png'),
        link: 'https://github.com/anushkavidanage/tidypod/blob/main/README.md',
        loginButtonStyle: LoginButtonStyle(background: brightYellow),
        infoButtonStyle: InfoButtonStyle(background: lightBlue),
        child: AppScreen(
          title: topbarText,
          childPage: Responsive.isMobile(context) ? TabView() : KanbanView(),
        ),
      );
    },
  );
}
