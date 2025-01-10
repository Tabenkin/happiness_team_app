import 'package:flutter/material.dart';
import 'package:happiness_team_app/widgets/my_text.widget.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

class MyDatePicker extends StatefulWidget {
  final DateTime initialValue;
  final Function(DateTime) onChanged;

  const MyDatePicker(
      {Key? key, required this.initialValue, required this.onChanged})
      : super(key: key);

  @override
  State<MyDatePicker> createState() => _MyDatePickerState();
}

class _MyDatePickerState extends State<MyDatePicker> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialValue;
  }

  void _presentDatePicker() async {
    // Current device text scale factor
    double currentScaleFactor = MediaQuery.of(context).textScaleFactor;

    // Base font size for scale factor 1.0
    double baseFontSize = 16;

    // Calculate adjusted font sizes
    double adjustedFontSize = baseFontSize / currentScaleFactor;

    final DateTime? picked = await showOmniDateTimePicker(
      context: context,
      type: OmniDateTimePickerType.date,
      theme: ThemeData(
        colorScheme: Theme.of(context).colorScheme,
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: adjustedFontSize),
          bodyMedium: TextStyle(fontSize: adjustedFontSize),
          bodySmall: TextStyle(fontSize: adjustedFontSize),
          displayLarge: TextStyle(fontSize: adjustedFontSize),
          displayMedium: TextStyle(fontSize: adjustedFontSize),
          displaySmall: TextStyle(fontSize: adjustedFontSize),
          labelLarge: TextStyle(fontSize: adjustedFontSize),
          labelMedium: TextStyle(fontSize: adjustedFontSize),
          labelSmall: TextStyle(fontSize: adjustedFontSize),
          titleLarge: TextStyle(fontSize: adjustedFontSize),
          titleMedium: TextStyle(fontSize: adjustedFontSize),
          titleSmall: TextStyle(fontSize: adjustedFontSize),
          headlineLarge: TextStyle(fontSize: adjustedFontSize),
          headlineMedium: TextStyle(fontSize: adjustedFontSize),
          headlineSmall: TextStyle(fontSize: adjustedFontSize),
        ),
      ),
      // primaryColor: Theme.of(context).primaryColor,
      // backgroundColor: Colors.grey[100]!,
      // calendarTextColor: Colors.black,
      // tabTextColor: Colors.black,
      // unselectedTabBackgroundColor: Colors.grey[300]!,
      // buttonTextColor: Colors.white,
      // timeSpinnerTextStyle: const TextStyle(color: Colors.black54, fontSize: 18),
      // timeSpinnerHighlightedTextStyle:
      //     const TextStyle(color: Colors.black, fontSize: 24),
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      widget.onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _presentDatePicker,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(25.0),
          color: Theme.of(context).colorScheme.surface
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.calendar_today, size: 20.0, color: Colors.grey),
            const SizedBox(width: 10),
            MyText(
              DateFormat.yMd().format(selectedDate),
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
