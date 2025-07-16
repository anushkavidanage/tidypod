/// Status of the data sync
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

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DataSyncState {
  final bool networkConnected;
  final bool hasData;
  final bool isSynching;
  final bool isSynched;

  const DataSyncState({
    this.networkConnected = true,
    this.hasData = true,
    this.isSynching = false,
    this.isSynched = false,
  });

  DataSyncState copyWith({
    bool? networkConnected,
    bool? hasData,
    bool? isSynching,
    bool? isSynched,
  }) {
    return DataSyncState(
      networkConnected: networkConnected ?? this.networkConnected,
      hasData: hasData ?? this.hasData,
      isSynching: isSynching ?? this.isSynching,
      isSynched: isSynched ?? this.isSynched,
    );
  }
}

class DataSyncStateNotifier extends StateNotifier<DataSyncState> {
  BuildContext? context;

  DataSyncStateNotifier() : super(const DataSyncState());

  void setContext(BuildContext ctx) {
    context = ctx;
  }

  void setNetworkConnected(bool connected) {
    state = state.copyWith(networkConnected: connected);
  }

  void setHasData(bool hasData) {
    state = state.copyWith(hasData: hasData);
  }

  void setIsSynching(bool synching) {
    state = state.copyWith(isSynching: synching);
  }

  void setIsSynched(bool synched) {
    state = state.copyWith(isSynched: synched);
  }
}

final dataSyncStateProvider =
    StateNotifierProvider<DataSyncStateNotifier, DataSyncState>(
      (ref) => DataSyncStateNotifier(),
    );
