import 'dart:async';

import 'package:flutter/material.dart';
import 'package:happiness_team_app/components/win_form/win_form_container.widget.dart';
import 'package:happiness_team_app/models/win.model.dart';
import 'package:happiness_team_app/services/wins.service.dart';
import 'package:rxdart/subjects.dart';

class WinsProvider with ChangeNotifier {
  final ValueNotifier<Wins> _wins = ValueNotifier([]);
  final ValueNotifier<Map<String, Wins>> _yearWins = ValueNotifier({});
  final ValueNotifier<Map<String, Wins>> _yearMonthWins = ValueNotifier({});
  final ValueNotifier<Map<String, Wins>> _yearMonthDayWins = ValueNotifier({});
  final ValueNotifier<Map<String, List<String>>> _yearMonthMap =
      ValueNotifier({});
  final ValueNotifier<List<String>> _tabs = ValueNotifier([]);
  final ValueNotifier<int> _selectedTab = ValueNotifier(0);

  final StreamController<String?> _triggerRandomWin = BehaviorSubject();
  final StreamController<String?> _triggerAddWin = BehaviorSubject();

  initializeWins() {
    WinsService.streamUserWins().listen((event) {
      _wins.value = event;

      _groupWinsByYear(event);
      _groupWinsByYearMonth(event);
      _yearMonthDayWins.value = WinsProvider.groupWinsByYearMonthDay(event);

      _tabs.value = [];

      if (_yearWins.value.keys.length > 1) {
        _tabs.value.add("Years");
      }

      if (_yearMonthWins.value.keys.length > 1) {
        _tabs.value.add("Months");
      }

      if (_yearMonthDayWins.value.keys.length > 1) {
        _tabs.value.add("Days");
      }

      _tabs.notifyListeners();
    });
  }

  _groupWinsByYear(Wins wins) {
    Map<String, Wins> yearWins = {};
    for (var win in wins) {
      if (yearWins[win.date.year.toString()] == null) {
        yearWins[win.date.year.toString()] = [];
      }
      yearWins[win.date.year.toString()]!.add(win);
    }
    _yearWins.value = yearWins;
  }

  _groupWinsByYearMonth(Wins wins) {
    Map<String, Wins> yearMonthWins = {};
    for (var win in wins) {
      if (yearMonthWins[
              '${win.date.year}-${win.date.month.toString().padLeft(2, '0')}'] ==
          null) {
        yearMonthWins[
            '${win.date.year}-${win.date.month.toString().padLeft(2, '0')}'] = [];
      }
      yearMonthWins[
              '${win.date.year}-${win.date.month.toString().padLeft(2, '0')}']!
          .add(win);

      if (_yearMonthMap.value['${win.date.year}'] == null) {
        _yearMonthMap.value['${win.date.year}'] = [];
      }

      if (!_yearMonthMap.value['${win.date.year}']!
          .contains(win.date.month.toString().padLeft(2, '0'))) {
        _yearMonthMap.value['${win.date.year}']!
            .add(win.date.month.toString().padLeft(2, '0'));
      }

      _yearMonthMap.value[win.date.year.toString()]!.sort();
    }
    _yearMonthWins.value = yearMonthWins;
  }

  static groupWinsByYearMonthDay(Wins wins) {
    Map<String, Wins> yearMonthDayWins = {};
    for (var win in wins) {
      // Two digit month:
      // if (yearMonthDayWins[
      //         '${win.date.year}-${win.date.month.toString().padLeft(2, '0')}-${win.date.day.toString().padLeft(2, '0')}'] ==

      if (yearMonthDayWins[
              '${win.date.year}-${win.date.month.toString().padLeft(2, '0')}-${win.date.day.toString().padLeft(2, '0')}'] ==
          null) {
        yearMonthDayWins[
            '${win.date.year}-${win.date.month.toString().padLeft(2, '0')}-${win.date.day.toString().padLeft(2, '0')}'] = [];
      }
      yearMonthDayWins[
              '${win.date.year}-${win.date.month.toString().padLeft(2, '0')}-${win.date.day.toString().padLeft(2, '0')}']!
          .add(win);
    }
    return yearMonthDayWins;
  }

  ValueNotifier<Wins> get wins => _wins;

  ValueNotifier<Map<String, Wins>> get yearWins => _yearWins;
  ValueNotifier<Map<String, Wins>> get yearMonthWins => _yearMonthWins;
  ValueNotifier<Map<String, Wins>> get yearMonthDayWins => _yearMonthDayWins;
  ValueNotifier<Map<String, List<String>>> get yearMonthMap => _yearMonthMap;
  ValueNotifier<List<String>> get tabs => _tabs;
  ValueNotifier<int> get selectedTab => _selectedTab;

  setSelectedTab(int value) {
    _selectedTab.value = value;
    notifyListeners();
  }

  static showWinForm(BuildContext context, Win win) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: WinFormContainer(
            win: win,
          ),
        );
      },
    );
  }

  Stream<String?> get streamRandomWinTriggers => _triggerRandomWin.stream;

  triggerRandomWin() {
    _triggerRandomWin.add("trigger");
  }

  clearRandomWinEvents() {
    _triggerRandomWin.add(null);
  }

  Stream<String?> get streamAddWinTriggers => _triggerAddWin.stream;

  triggerAddWin() {
    _triggerAddWin.add("trigger");
  }

  clearAddWinEvents() {
    _triggerAddWin.add(null);
  }
}
