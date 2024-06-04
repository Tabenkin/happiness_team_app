import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:happiness_team_app/helpers/functions.helpers.dart';
import 'package:happiness_team_app/models/media_object.model.dart';
import 'package:happiness_team_app/services/upload.service.dart';
import 'package:happiness_team_app/widgets/my_button.widget.dart';
import 'package:happiness_team_app/widgets/my_text.widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class UploadProgress {
  int totalBytesToUpload = 0;
  int totalBytesUploaded = 0;

  UploadProgress({
    required this.totalBytesToUpload,
    required this.totalBytesUploaded,
  });
}

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

  final Map<String, UploadProgress> _uploadProgressMap = {};

  bool _isUploading = false;

  _chooseFileToUpload() async {
    if (_isUploading) {
      return;
    }

    setState(() {
      _isUploading = true;
    });

    _pickImageFile();
  }

  _pickImageFile() async {
    var picker = ImagePicker();
    XFile? image;

    setState(() {
      _uploadProgressMap.clear();
    });

    if (widget.imageSource == null) {
      setState(() {
        _isUploading = false;
      });
      return;
    }

    if (widget.imageSource == ImageSource.camera) {
      var permission = await Permission.camera.isGranted;

      if (permission == false) {
        await Permission.camera.request();
      }

      image = await picker.pickImage(source: ImageSource.camera);

      if (image == null) {
        setState(() {
          _isUploading = false;
        });
        return;
      }

      _uploadFile(image.path, image.name);
    } else {
      List<XFile> images = await picker.pickMultiImage();

      if (images.isEmpty) {
        setState(() {
          _isUploading = false;
        });
        return;
      }

      setState(() {
        _isUploading = true;
      });

      for (var image in images) {
        _uploadFile(image.path, image.name);
      }
    }
  }

  _uploadFile(String filePath, String fileName) {
    setState(() {
      _isUploading = true;
    });

    var uploadTask = UploadService.uploadFileWithPath(
      filePath,
      fileName,
      filePath: widget.filePath,
    );

    uploadTask.snapshotEvents.listen(_updateUploadProgress);
    uploadTask.then(_uploadComplete);
  }

  _updateUploadProgress(TaskSnapshot event) {
    // var progress = ((event.bytesTransferred / event.totalBytes) * 100).round();
    setState(() {
      _uploadProgressMap[event.ref.fullPath] = UploadProgress(
        totalBytesToUpload: event.totalBytes,
        totalBytesUploaded: event.bytesTransferred,
      );
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

    widget.onUploadComplete(mediaItem);

    _uploadProgressMap.remove(event.ref.fullPath);

    if (_uploadProgressMap.isEmpty) {
      setState(() {
        _isUploading = false;
      });
    }
  }

  int get _uploadProgress {
    if (_uploadProgressMap.isEmpty) return 0;

    var totalBytesToUpload = 0;
    var totalBytesUploaded = 0;

    _uploadProgressMap.forEach((key, value) {
      totalBytesToUpload += value.totalBytesToUpload;
      totalBytesUploaded += value.totalBytesUploaded;
    });

    return ((totalBytesUploaded / totalBytesToUpload) * 100).round();
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
      showSpinner: _isUploading,
      child: _isUploading
          ? Text("Uploading $_uploadProgress%")
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null)
                  Row(
                    children: [
                      Icon(
                        widget.icon,
                        size: 18,
                      ),
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
