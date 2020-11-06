import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kvk_app/data_struct/attachedImage.dart';
import 'package:kvk_app/data_struct/attachedVideo.dart';
import 'package:kvk_app/data_struct/attachedFile.dart';
import 'package:kvk_app/data_struct/reply.dart';

class Post {
  String body;
  String categoryId;
  String postID;
  String title;
  String userId;
  Timestamp time;
  double size;
  List<AttachedFile> files = new List<AttachedFile>();
  List<AttachedImage> imgs = new List<AttachedImage>();
  List<AttachedVideo> vids = new List<AttachedVideo>();
  List<Reply> replies = new List<Reply>();
  bool latest = false;
  bool mine = false;
  bool subscribed = false;
  bool edited = false;
}
