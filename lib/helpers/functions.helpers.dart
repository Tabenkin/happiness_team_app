import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:happiness_team_app/providers/app.provider.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
  if (doc.exists != true) {
    return {};
  }

  var docData = doc.data()!;
  docData['id'] = doc.id;

  return docData;
}

double maxTextScaleFactor(BuildContext context, double maxScale) {
  return min(MediaQuery.of(context).textScaleFactor, maxScale);
}

bool isLargeBreakpoint(BuildContext context) {
  return MediaQuery.of(context).size.width > 864;
}

DateTime get currentDate {
  var now = DateTime.now();
  // var now = DateTime(2023, 5, 14);
  return DateTime(now.year, now.month, now.day);
}

String get currentDateString {
  return convertDateToYYYYMMDDString(currentDate);
}

String convertDateToYYYYMMDDString(DateTime date) {
  return "${date.year}-${date.month}-${date.day}";
}

String convertDurationToLabel(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");

  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  String twoDigitHours = duration.inHours.toString();

  if (duration.inHours > 0) {
    return "$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds";
  }

  return "$twoDigitMinutes:$twoDigitSeconds";
}

String generateUuid() {
  return const Uuid().v4();
}

double convertDegreesToRadians(double degrees) {
  return degrees * (pi / 180);
}

String convertOriginalFilename(String filename) {
  var pattern = RegExp(r'\[(.*[0-9])\]_');
  var newFileName = filename.replaceAll(pattern, "");
  var lastPeriod = newFileName.lastIndexOf(".");

  return newFileName.substring(0, lastPeriod);
}

String getDayAbbreviation(int dayOfWeek) {
  const List<String> abbreviations = ['Su', 'M', 'T', 'W', 'Th', 'F', 'Sa'];

  if (dayOfWeek < 0 || dayOfWeek > 6) {
    throw ArgumentError('Day of week must be between 0 and 6');
  }

  return abbreviations[dayOfWeek];
}

Duration timeUntil3amNextDay() {
  final now = DateTime.now();

  // Construct a DateTime object for 3 am today.
  DateTime threeAMToday = DateTime(now.year, now.month, now.day, 3);

  // If the current time is after 3 am today, calculate the duration until 3 am the next day.
  if (now.isAfter(threeAMToday)) {
    // Construct a DateTime object for 3 am tomorrow.
    DateTime threeAMTomorrow = threeAMToday.add(const Duration(days: 1));
    return threeAMTomorrow.difference(now);
  } else {
    // If the current time is before 3 am today, calculate the duration until 3 am today.
    return threeAMToday.difference(now);
  }
}

String convertToMonthName(String dateString) {
  // Parse the string to a DateTime object.
  DateTime dateTime = DateTime.parse("$dateString-01");

  // Format the DateTime object to get the full month name.
  String monthName = DateFormat.MMMM().format(dateTime);

  return monthName;
}
