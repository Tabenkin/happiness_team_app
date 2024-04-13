import 'package:flutter/material.dart';
import 'package:happiness_team_app/helpers/dialog.helpers.dart';
import 'package:happiness_team_app/models/win.model.dart';
import 'package:happiness_team_app/widgets/my_button.widget.dart';
import 'package:happiness_team_app/widgets/my_datepicker.widget.dart';
import 'package:happiness_team_app/widgets/my_text.widget.dart';
import 'package:happiness_team_app/widgets/my_textarea.widget.dart';

class WinFormContainer extends StatefulWidget {
  final Win win;

  const WinFormContainer({
    required this.win,
    Key? key,
  }) : super(key: key);

  @override
  State<WinFormContainer> createState() => _WinFormContainerState();
}

class _WinFormContainerState extends State<WinFormContainer> {
  bool _isSaving = false;

  void _save() async {
    if (widget.win.notes.isEmpty) {
      DialogHelper.showSimpleErrorToast(
        context,
        "Please enter some notes",
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });
    await widget.win.save();
    setState(() {
      _isSaving = false;
    });

    _doneSaving();
  }

  void _doneSaving() {
    DialogHelper.showSimpleSuccessToast(context, "Win Saved!", margin: 8);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: kToolbarHeight * 1.5,
          backgroundColor: Theme.of(context).colorScheme.background,
          surfaceTintColor: Theme.of(context).colorScheme.background,
          leading: IconButton(
            icon: const Icon(Icons.close),
            color: Theme.of(context).colorScheme.primary,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0),
            child: Divider(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: MyText(
              widget.win.id != null ? "Edit Win" : "Add Win",
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MyText("When did you win?"),
                const SizedBox(
                  height: 8.0,
                ),
                SizedBox(
                  width: double.infinity,
                  child: MyDatePicker(
                    initialValue: widget.win.date,
                    onChanged: (value) {
                      widget.win.date = value;
                    },
                  ),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                MyTextArea(
                  labelText: "Notes",
                  onChanged: (value) {
                    widget.win.notes = value;
                  },
                  initialValue: widget.win.notes,
                ),
                const SizedBox(height: 16.0),
                SizedBox(
                  width: double.infinity,
                  child: MyButton(
                    showSpinner: _isSaving,
                    onTap: _save,
                    child: MyText(
                      "Save",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
