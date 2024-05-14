import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:happiness_team_app/happiness_theme.dart';
import 'package:happiness_team_app/helpers/dialog.helpers.dart';
import 'package:happiness_team_app/models/media_object.model.dart';
import 'package:happiness_team_app/models/win.model.dart';
import 'package:happiness_team_app/services/auth.service.dart';
import 'package:happiness_team_app/widgets/image_full_screen_wrapper.widget.dart';
import 'package:happiness_team_app/widgets/my_button.widget.dart';
import 'package:happiness_team_app/widgets/my_datepicker.widget.dart';
import 'package:happiness_team_app/widgets/my_text.widget.dart';
import 'package:happiness_team_app/widgets/my_textarea.widget.dart';
import 'package:happiness_team_app/widgets/upload_button.widget.dart';
import 'package:image_picker/image_picker.dart';

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

  _onUploadComplete(MediaObject mediaObject) {
    setState(() {
      widget.win.image = mediaObject;
    });
  }

  _removeImage() {
    setState(() {
      widget.win.image = null;
    });
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
                MyText(
                  "When did you win?",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
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
                MyText(
                  "Notes",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(
                  height: 8.0,
                ),
                MyTextArea(
                  onChanged: (value) {
                    widget.win.notes = value;
                  },
                  initialValue: widget.win.notes,
                ),
                const SizedBox(height: 16.0),
                MyText(
                  "Add an image?",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Row(
                  children: [
                    Expanded(
                      child: UploadButton(
                        label: "Photos",
                        icon: Icons.image_search,
                        fileType: FileType.image,
                        onUploadComplete: _onUploadComplete,
                        imageSource: ImageSource.gallery,
                        filePath: "/user-uploads/${AuthService.currentUid}",
                      ),
                    ),
                    const SizedBox(
                      width: 4.0,
                    ),
                    Expanded(
                      child: UploadButton(
                        label: "Camera",
                        icon: Icons.camera_alt,
                        fileType: FileType.image,
                        onUploadComplete: _onUploadComplete,
                        imageSource: ImageSource.camera,
                        filePath: "/user-uploads/${AuthService.currentUid}",
                      ),
                    ),
                  ],
                ),
                if (widget.win.image != null)
                  Column(
                    children: [
                      const SizedBox(
                        height: 16.0,
                      ),
                      Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 1.5,
                            child: PhysicalModel(
                              elevation: 1.0,
                              borderRadius: Theme.of(context).borderRadius,
                              color: Theme.of(context).colorScheme.background,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: Theme.of(context).borderRadius,
                                ),
                                child: ClipRRect(
                                  borderRadius: Theme.of(context).borderRadius,
                                  child: ImageFullScreenWrapperWidget(
                                    child: Image.network(
                                      widget.win.image!.mediaHref,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              onPressed: _removeImage,
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                  Theme.of(context).colorScheme.error,
                                ),
                              ),
                              color: Theme.of(context).colorScheme.onError,
                              icon: const Icon(
                                Icons.delete_rounded,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                const SizedBox(
                  height: 16.0,
                ),
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
