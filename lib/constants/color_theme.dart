// Colors used in the app
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

const brightOrange = Color(0xFFf59a48);
const lightOrange = Color(0xFFfbd6b6);
const darkRed = Color(0xFF901930);
const brightRed = Color(0xFFe50000);
const brightYellow = Color(0xFFf8d23a);
const lightBlue = Color(0xFF5dbfcf);
const darkBlue = Color(0xFF30465d);
const darkOrange = Color(0xFFd97931);
const darkGreen = Color(0xFF679436);
const lightGreen = Color(0xFFAFC97E);
// const backgroundWhite = Color(0xFFF5F6FC);
const lightGrey = Color(0xFF8793B2);
const lightGrey2 = Color(0xFFd0d5e1);
const lighterGrey = Color.fromARGB(255, 243, 243, 243);
const bgOffWhite = Color(0xFFF2F4FC);
// const kTitleTextColor = Color(0xFF30384D);
// const warningRed = Colors.red;

extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
