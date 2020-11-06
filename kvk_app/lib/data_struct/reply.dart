import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kvk_app/data_struct/attachedImage.dart';
import 'package:kvk_app/data_struct/attachedVideo.dart';
import 'package:kvk_app/data_struct/attachedFile.dart';

class Reply {
  String body;
  int totalReplies = 0;
  List<AttachedImage> imgs = new List<AttachedImage>();
  List<AttachedVideo> vids = new List<AttachedVideo>();
  List<AttachedFile> files = new List<AttachedFile>();
  String userId;
  List<Reply> replies = new List<Reply>();
  String replyId;
  Timestamp time;
  bool edited = false;
}
