// Responsive design
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

import 'package:flutter/material.dart';

import 'package:tidypod/constants/app.dart';

const double desktopWidthThreshold = 1280;
const double tabletWidthThreshold = 760;
const double mobileWidthThreshold = 480;

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;
  final Widget largeDesktop;

  const Responsive({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
    required this.largeDesktop,
  });

  static bool isMobile(BuildContext context) =>
      screenWidth(context) < mobileWidthThreshold;

  static bool isTablet(BuildContext context) =>
      screenWidth(context) < tabletWidthThreshold &&
      screenWidth(context) >= mobileWidthThreshold;

  static bool isDesktop(BuildContext context) =>
      screenWidth(context) < desktopWidthThreshold &&
      screenWidth(context) >= tabletWidthThreshold;

  static bool isLargeDesktop(BuildContext context) =>
      screenWidth(context) >= desktopWidthThreshold;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return constraints.maxWidth >= desktopWidthThreshold ? desktop : mobile;
      },
    );
  }
}
