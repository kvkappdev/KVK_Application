import 'package:kvk_app/data_struct/post.dart';

class InternalUser {
  String databaseID = "-1";
  String mobile;
  List<Post> my_posts = new List<Post>();
  String name;
  String profilePic;
  int role = -1;
  List<Post> subscribed_posts = new List<Post>();
  String uid;
  bool notificationStatus = false;
}
