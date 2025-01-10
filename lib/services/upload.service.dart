import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class UploadService {
  static UploadTask uploadFile(PlatformFile file, {String? filePath = "/tmp"}) {
    String fileName = file.name;
    int timestamp = DateTime.now().millisecondsSinceEpoch;

    var fileRef =
        FirebaseStorage.instance.ref("$filePath/[$timestamp]_$fileName");

    if (kIsWeb == true) {
      Uint8List fileBytes = file.bytes!;
      return fileRef.putData(fileBytes);
    } else {
      File uploadFile = File(file.path!);
      return fileRef.putFile(uploadFile);
    }
  }

  static UploadTask uploadFileWithPath(String srcPath, String fileName,
      {String? filePath = "/tmp"}) {
    int timestamp = DateTime.now().millisecondsSinceEpoch;

    var fileRef =
        FirebaseStorage.instance.ref("$filePath/[$timestamp]_$fileName");


    File uploadFile = File(srcPath);
    return fileRef.putFile(uploadFile);
  }
}
