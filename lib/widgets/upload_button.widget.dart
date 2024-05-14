import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:happiness_team_app/helpers/functions.helpers.dart';
import 'package:happiness_team_app/models/media_object.model.dart';
import 'package:happiness_team_app/services/upload.service.dart';
import 'package:happiness_team_app/widgets/my_button.widget.dart';
import 'package:happiness_team_app/widgets/my_text.widget.dart';
import 'package:image_picker/image_picker.dart';

class UploadButton extends StatefulWidget {
  final String label;
  final FileType fileType;
  final ImageSource? imageSource;
  final String? filePath;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final Function(MediaObject) onUploadComplete;

  const UploadButton({
    required this.label,
    required this.fileType,
    this.imageSource = ImageSource.gallery,
    this.filePath,
    required this.onUploadComplete,
    this.backgroundColor,
    this.textColor,
    this.icon,
    Key? key,
  }) : super(key: key);

  @override
  State<UploadButton> createState() => _UploadButtonState();
}

class _UploadButtonState extends State<UploadButton> {
  List<String> supportedFileTypes = [];

  bool _isUploading = false;
  int _uploadProgress = 0;

  _chooseFileToUpload() async {
    if (_isUploading) {
      return;
    }

    _pickImageFile();
  }

  _pickImageFile() async {
    var picker = ImagePicker();
    XFile? image;

    if (widget.imageSource == null) return;

    if (widget.imageSource == ImageSource.camera) {
      image = await picker.pickImage(source: ImageSource.camera);
    } else {
      image = await picker.pickImage(source: ImageSource.gallery);
    }

    if (image == null) return;

    // convert xFile to platform file?
    _uploadFile(image.path, image.name);
  }

  _uploadFile(String filePath, String fileName) {
    var uploadTask = UploadService.uploadFileWithPath(
      filePath,
      fileName,
      filePath: widget.filePath,
    );

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });

    uploadTask.snapshotEvents.listen(_updateUploadProgress);
    uploadTask.then(_uploadComplete);
  }

  _updateUploadProgress(TaskSnapshot event) {
    var progress = ((event.bytesTransferred / event.totalBytes) * 100).round();
    setState(() {
      _uploadProgress = progress;
    });
  }

  _uploadComplete(TaskSnapshot event) async {
    var downloadUrl = await event.ref.getDownloadURL();
    var metadata = await event.ref.getMetadata();

    var mediaItem = MediaObject(
      id: generateUuid(),
      bucket: metadata.bucket ?? '',
      fullPath: metadata.fullPath,
      mediaType: metadata.contentType ?? '',
      size: metadata.size,
      mediaHref: downloadUrl,
      name: metadata.name,
      contentType: metadata.contentType!,
    );

    setState(() {
      _isUploading = false;
      _uploadProgress = 0;
    });

    widget.onUploadComplete(mediaItem);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MyButton(
      color: MyButtonColor.secondary,
      onTap: _chooseFileToUpload,
      child: _isUploading
          ? Text("Uploading $_uploadProgress%")
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null)
                  Row(
                    children: [
                      Icon(widget.icon),
                      const SizedBox(
                        width: 4.0,
                      ),
                    ],
                  ),
                Text(widget.label),
              ],
            ),
    );
  }
}
