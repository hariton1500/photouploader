import 'package:image_picker/image_picker.dart';

enum GroupStatus { created, uploading, uploaded }

class Photo {
  double? long, lat;
  XFile? photo;
  Photo({this.long, this.lat, this.photo});
}

class Group {
  int index;
  GroupStatus status = GroupStatus.created;
  String? description;
  List<Photo>? photos = [];
  Group(
      {required this.index,
      this.description = '',
      this.status = GroupStatus.created,
      required this.photos});
}
