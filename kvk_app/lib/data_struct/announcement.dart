import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kvk_app/data_struct/attachedImage.dart';
import 'package:kvk_app/data_struct/attachedVideo.dart';
import 'package:kvk_app/data_struct/attachedFile.dart';

class Announcement {
  String announcementId;
  List<AttachedFile> files = new List<AttachedFile>();
  AttachedImage img;
  AttachedVideo vid;
  String text;
  Timestamp time;
  String userId;
  double size;
  bool edited = false;
}
