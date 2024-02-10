import 'package:flutter/material.dart';
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
    final DateTime? picked = await showOmniDateTimePicker(
      context: context,
      type: OmniDateTimePickerType.date,
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
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.calendar_today, size: 20.0, color: Colors.grey),
            const SizedBox(width: 10),
            Text(
              DateFormat.yMd().format(selectedDate),
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
