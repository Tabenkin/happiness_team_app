import 'package:flutter/material.dart';
import 'package:happiness_team_app/models/win.model.dart';
import 'package:happiness_team_app/services/wins.service.dart';

class WinsProvider with ChangeNotifier {
  final ValueNotifier<Wins> _wins = ValueNotifier([]);

  initializeWins() {
    WinsService.streamUserWins().listen((event) {
      _wins.value = event;
    });
  }

  ValueNotifier<Wins> get wins => _wins;
}
