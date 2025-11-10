import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:happiness_team_app/components/win_list/win_media_preview.widget.dart';
import 'package:happiness_team_app/helpers/dialog.helpers.dart';
import 'package:happiness_team_app/models/media_object.model.dart';
import 'package:happiness_team_app/models/win.model.dart';
import 'package:happiness_team_app/services/auth.service.dart';
import 'package:happiness_team_app/widgets/Base/base_button.widget.dart';
import 'package:happiness_team_app/widgets/Base/base_text.widget.dart';
import 'package:happiness_team_app/widgets/my_datepicker.widget.dart';
import 'package:happiness_team_app/widgets/my_textarea.widget.dart';
import 'package:happiness_team_app/widgets/upload_button.widget.dart';
import 'package:image_picker/image_picker.dart';

class WinFormContainer extends StatefulWidget {
  final Win win;

  const WinFormContainer({
    required this.win,
    super.key,
  });

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
      widget.win.images.add(mediaObject);
    });
  }

  _removeImage(MediaObject image) {
    setState(() {
      widget.win.images.removeWhere((element) => element.id == image.id);
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
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Theme.of(context).colorScheme.surface,
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
            child: BaseText(
              widget.win.id != null ? "Edit Win" : "Add Win",
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
              maxTextScale: 1.0,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BaseText(
                  "When did you win?",
                  style: Theme.of(context).textTheme.headlineSmall,
                  maxTextScale: 1.0,
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
                BaseText(
                  "Notes",
                  style: Theme.of(context).textTheme.headlineSmall,
                  maxTextScale: 1.0,
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
                BaseText(
                  "Add an image or video?",
                  maxTextScale: 1.0,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Row(
                  children: [
                    Expanded(
                      child: UploadButton(
                        label: "Upload Photo",
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
                        label: "Upload Video",
                        icon: Icons.image_search,
                        fileType: FileType.video,
                        onUploadComplete: _onUploadComplete,
                        imageSource: ImageSource.gallery,
                        filePath: "/user-uploads/${AuthService.currentUid}",
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16.0,
                ),
                Row(
                  children: [
                    Expanded(
                      child: UploadButton(
                        label: "Take Photo",
                        icon: Icons.camera_alt,
                        fileType: FileType.image,
                        onUploadComplete: _onUploadComplete,
                        imageSource: ImageSource.camera,
                        filePath: "/user-uploads/${AuthService.currentUid}",
                      ),
                    ),
                    const SizedBox(
                      width: 4.0,
                    ),
                    Expanded(
                      child: UploadButton(
                        label: "Take Video",
                        icon: Icons.video_call,
                        fileType: FileType.video,
                        onUploadComplete: _onUploadComplete,
                        imageSource: ImageSource.camera,
                        filePath: "/user-uploads/${AuthService.currentUid}",
                      ),
                    ),
                  ],
                ),
                for (var image in widget.win.images)
                  Column(
                    key: ValueKey(image.id),
                    children: [
                      const SizedBox(
                        height: 16.0,
                      ),
                      Stack(
                        children: [
                          WinMediaPreview(
                            mediaObject: image,
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              onPressed: () => _removeImage(image),
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
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
                  child: BaseButton(
                    showSpinner: _isSaving,
                    width: double.infinity,
                    onPressed: _save,
                    child: BaseText(
                      "Save",
                      maxTextScale: 1.0,
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
