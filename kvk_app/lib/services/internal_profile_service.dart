import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/data_struct/post.dart';
import 'package:kvk_app/data_struct/internalUser.dart';
import 'package:kvk_app/services/posts_service.dart';
import 'package:kvk_app/services/pushNotification_service.dart';

final log = getLogger("Internal Profile Service");

class InternalProfileService {
  InternalUser _user = new InternalUser();
  Image _profilePicture = Image.asset("assets/img/blank_profile.png");
  PushNotificationService _pushNotificationService =
      locator<PushNotificationService>();

  bool _changeNumberRequest = false;

  bool _hasProfile = false;
  bool _isLoggedIn = false;

  List<String> _subscribedPostIds = List<String>();

  void setAccountDatabaseID(String id) {
    _user.databaseID = id;
  }

  String getAccountDatabaseID() {
    log.d(_user.databaseID);
    return _user.databaseID;
  }

  Future setNotificationStatus() async {
    if (_hasProfile) {
      _user.notificationStatus = !_user.notificationStatus;

      if (_user.notificationStatus) {
        await _pushNotificationService.subscribeToAnnouncements();
      } else {
        await _pushNotificationService.unSubscribeToAnnouncements();
      }
    }
  }

  bool getNotificationStatus() {
    return _user.notificationStatus;
  }

  void setUID(String uid) {
    _user.uid = uid;
  }

  String getUID() {
    return _user.uid;
  }

  void setChangeNumberRequest(bool input) {
    _changeNumberRequest = input;
  }

  bool getChangeNumberRequest() {
    return _changeNumberRequest;
  }

  void setMobile(String mobile) {
    _user.mobile = mobile;
  }

  String getMobile() {
    return _user.mobile;
  }

  void setIsLoggedIn(bool input) {
    _isLoggedIn = input;
  }

  bool getIsLoggedIn() {
    return _isLoggedIn;
  }

  void setHasProfile(bool hasProfile) {
    _hasProfile = hasProfile;
  }

  bool getHasProfile() {
    return _hasProfile;
  }

  void setUserName(String name) {
    _user.name = name;
  }

  String getName() {
    return _user.name;
  }

  void setRole(int role) {
    _user.role = role;
  }

  int getRole() {
    return _user.role;
  }

  void setProfilePic(String pic) {
    if (pic != "default") {
      _profilePicture = Image.network(pic);
    } else {
      _profilePicture = Image.asset("assets/img/blank_profile.png");
    }
    _user.profilePic = pic;
  }

  Image getProfilePic() {
    return _profilePicture;
  }

  String getPictureURL() {
    return _user.profilePic;
  }

  void clearUserDetails() {
    _isLoggedIn = false;
    _hasProfile = false;
    _profilePicture = Image.asset("assets/img/blank_profile.png");
    _subscribedPostIds = new List<String>();
    _user = new InternalUser();
  }

  List<String> getSubscribedPostsIds() {
    log.d(_subscribedPostIds);
    return _subscribedPostIds;
  }

  void addSubscribedPostId(String postId) {
    _subscribedPostIds.add(postId);
  }

  void removeSubscribedPostId(String postId) {
    _subscribedPostIds.remove(postId);
  }

  void setSubscribedPostsIds(List<String> postIds) {
    _subscribedPostIds = postIds;
  }

  List<Post> getSubscribedPosts() {
    return _user.subscribed_posts;
  }

  void addSubscribedPost(Post post) {
    _user.subscribed_posts.add(post);
  }

  void removeSubscribedPost(Post post) {
    _user.subscribed_posts.remove(post);
  }

  void setAccount(QueryDocumentSnapshot snapshot) {
    final PostsService _postsService = locator<PostsService>();

    _user.databaseID = snapshot.get("databaseID");
    _user.mobile = snapshot.get("mobile");
    _user.my_posts = _postsService.getMyPosts();
    _user.name = snapshot.get("name");
    setProfilePic(snapshot.get("profilePic"));
    setRole(snapshot.get("role"));
    _user.notificationStatus = snapshot.get("notificationStatus");
    _user.subscribed_posts = _postsService.getSubscribedPosts();
    _user.uid = snapshot.get("uid");
  }

  InternalUser getAccount() {
    return _user;
  }
}
