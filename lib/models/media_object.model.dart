// ignore_for_file: public_member_api_docs, sort_constructors_first

typedef MediaObjects = List<MediaObject>;

class MediaObject {
  late String id;
  late String bucket;
  late String contentType;
  late String fullPath;
  late String mediaHref;
  late String mediaType;
  late String name;
  int? size;
  Duration? duration;

  MediaObject({
    required this.id,
    required this.bucket,
    required this.contentType,
    required this.fullPath,
    required this.mediaHref,
    required this.mediaType,
    required this.name,
    this.size,
    this.duration,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'bucket': bucket,
      'contentType': contentType,
      'fullPath': fullPath,
      'mediaHref': mediaHref,
      'mediaType': mediaType,
      'name': name,
      'size': size,
      'duration': duration?.inMilliseconds,
    };
  }

  factory MediaObject.fromMap(Map<String, dynamic> map) {
    return MediaObject(
      id: map['id'],
      bucket: map['bucket'],
      contentType: map['contentType'],
      fullPath: map['fullPath'],
      mediaHref: map['mediaHref'],
      mediaType: map['mediaType'],
      name: map['name'],
      size: map['size'],
      duration: map['duration'] != null
          ? Duration(milliseconds: map['duration'])
          : null,
    );
  }
}
