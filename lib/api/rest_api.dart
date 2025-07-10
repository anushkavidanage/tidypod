/// API for managing data at POD level
///
/// Copyright (C) 2023-2025, Software Innovation Institute
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
//
// Time-stamp: <Wednesday 2023-11-01 08:26:39 +1100 Graham Williams>
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

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:solidpod/solidpod.dart';
import 'package:tidypod/constants/turtle_structures.dart';

// Get the list of notes created by the user.

Future<Map> getCategoryList(BuildContext context, Widget childPage) async {
  final loggedIn = await loginIfRequired(context);
  String webId = await getWebId() as String;
  webId = webId.replaceAll(profCard, '');

  if (loggedIn) {
    final dataDirPath = await getDataDirPath();
    final dataDirUrl = await getDirUrl(dataDirPath);

    final categoriesDirUrl = '$dataDirUrl/';

    // Check if the directory exists.

    bool resExist = await checkResourceStatus(
      categoriesDirUrl,
      fileFlag: false,
    );

    if (resExist) {
      debugPrint(
        'Checking data directory for the categories: $categoriesDirUrl.',
      );
      final res = await getResourcesInContainer(categoriesDirUrl);
      debugPrint(res.toString());

      Map notesMap = {};
      // Loop through the list of files to get the file names
      for (final fileName in res.files) {
        // Read file content
        debugPrint('About to read from $fileName');
        String noteContent = await readPod(
          fileName.replaceAll(webId, ''),
          context,
          childPage,
        );
        debugPrint('About to call noteInfoMap $fileName');
        // notesMap[fileName] = noteInfoMap(noteContent);
        debugPrint('$fileName => ${notesMap[fileName]}');
      }
      // final filteredMap = filterTreatments(treatmentMap, type);
      return notesMap;
    } else {
      debugPrint('No data directory for the notes: $categoriesDirUrl.');
      return {};
    }
  } else {
    debugPrint('Not logged in in finding the list of notes.');
    return {};
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
