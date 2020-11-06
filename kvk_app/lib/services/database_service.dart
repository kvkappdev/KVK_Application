import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/data_struct/announcement.dart';
import 'package:kvk_app/data_struct/attachedImage.dart';
import 'package:kvk_app/data_struct/attachedVideo.dart';
import 'package:kvk_app/data_struct/attachedFile.dart';
import 'package:kvk_app/data_struct/post.dart';
import 'package:kvk_app/data_struct/internalUser.dart';
import 'package:kvk_app/data_struct/topic.dart';
import 'package:kvk_app/icons/kvk_icons.dart';
import 'package:kvk_app/services/language_service.dart';
import 'package:kvk_app/services/navBar_Service.dart';
import 'package:kvk_app/services/internal_profile_service.dart';
import 'package:kvk_app/services/posts_service.dart';
import 'package:kvk_app/services/topic_service.dart';
import 'package:kvk_app/ui/coloursheet.dart';
import 'package:kvk_app/ui/smart_widgets/alert_builder.dart';
import 'package:kvk_app/ui/smart_widgets/screen_arguments.dart';
import 'package:kvk_app/ui/text_interface.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/services/authentication_service.dart';
import 'package:kvk_app/data_struct/reply.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class DatabaseService {
  final log = getLogger('Database Service');
  final NavigationService _navigationService = locator<NavigationService>();
  final LanguageService _languageService = locator<LanguageService>();
  final InternalProfileService _internalProfileService =
      locator<InternalProfileService>();

  AlertBuilder _successAlert,
      _deletedProfileSuccess,
      _errorAlert,
      _loadingAlert;
  bool _defaultProfilePic = false;
  String downloadUrl;
  DocumentSnapshot _accountData;
  int _totalUsers, _totalPosts, _totalAnnouncements;

  final firestoreInstance = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  Future createTopic({@required Topic topic}) async {
    await firestoreInstance.collection('Posts').doc("*TotalPosts").update({
      "topics": FieldValue.arrayUnion([topic.engName, topic.marName])
    });
    log.i("New Topic added: " + topic.engName + "/" + topic.marName);
  }

  Future removeTopic({@required String name}) async {
    await firestoreInstance.collection('Posts').doc("*TotalPosts").update({
      "topics": FieldValue.arrayRemove([name])
    });
    log.i("Topic removed: " + name);
  }

  Future setTotalUsers() async {
    await firestoreInstance
        .collection('Accounts')
        .doc("*TotalUsers")
        .get()
        .then((value) {
      _totalUsers = value.get("total_users");
    }).catchError((error) {
      _totalUsers = 0;
    });
  }

  Future setTotalPosts() async {
    await firestoreInstance
        .collection('Posts')
        .doc("*TotalPosts")
        .get()
        .then((value) {
      _totalPosts = value.get("total_posts");
    }).catchError((error) {
      _totalPosts = 0;
    });
    log.i("Total Posts set: " + _totalPosts.toString());
  }

  Future<int> getTotalReplies({@required String postId}) async {
    int _totalReplies;
    await firestoreInstance
        .collection('Posts')
        .doc(postId)
        .collection("Replies")
        .doc("*TotalReplies")
        .get()
        .then((value) => _totalReplies = value.get("total_replies"));
    log.i("Total Replies set: " + _totalReplies.toString());
    return _totalReplies;
  }

  Future<int> getTotalRepliesToReplies(
      {@required String postId, @required String replyId}) async {
    int _totalReplies;
    await firestoreInstance
        .collection('Posts')
        .doc(postId)
        .collection('Replies')
        .doc(replyId)
        .collection('Replies')
        .doc("*TotalReplies")
        .get()
        .then((value) => _totalReplies = value.get("total_replies"));
    log.i("Total Replies set: " + _totalReplies.toString());
    return _totalReplies;
  }

  Future<String> getDatabaseID() async {
    if (getAccountData().get("databaseID") != null) {
      return getAccountData().get("databaseID");
    } else {
      log.i("Mobile data not found");
      return "";
    }
  }

  /// Get a passed users mobile
  ///
  /// param:
  /// return: Future<String>[name]
  /// initial creation: 06/10/2020
  /// last updated: 06/10/2020
  Future<String> getMobileNumber() async {
    if (getAccountData().get("mobile") != null) {
      return getAccountData().get("mobile");
    } else {
      log.i("Mobile data not found");
      return "";
    }
  }

  /// Get subscribed posts
  ///
  /// param:
  /// return: Future<String>[name]
  /// initial creation: 16/10/2020
  /// last updated: 16/10/2020
  Future<List<String>> getSubscribedPostsIDS() async {
    if (getAccountData().get("subscribed_posts") != null) {
      List<dynamic> dynamicPosts =
          await getAccountData().get("subscribed_posts");
      List<String> posts = dynamicPosts.cast<String>();
      return posts;
    } else {
      log.i("Subscribed Posts wasnt found");
      return {""}.toList();
    }
  }

  /// Get my posts
  ///
  /// param:
  /// return: Future<String>[name]
  /// initial creation: 16/10/2020
  /// last updated: 16/10/2020
  Future<QuerySnapshot> getMyPosts() async {
    log.d("Retrieving Posts for " +
        _internalProfileService.getAccountDatabaseID());
    QuerySnapshot snapshot = await firestoreInstance
        .collection('Posts')
        .where("user",
            isEqualTo: _internalProfileService.getAccountDatabaseID())
        .orderBy("time", descending: true)
        .limit(10)
        .get();
    log.d("My posts retrieved");
    return snapshot;
  }

  Future<QuerySnapshot> getMoreMyPosts() async {
    PostsService _postsService = locator<PostsService>();

    log.d("Retrieving Posts for " +
        _internalProfileService.getAccountDatabaseID());
    QuerySnapshot snapshot = await firestoreInstance
        .collection('Posts')
        .where("user",
            isEqualTo: _internalProfileService.getAccountDatabaseID())
        .orderBy("time", descending: true)
        .startAfter({_postsService.getMyPosts().last.time}.toList())
        .limit(10)
        .get();
    log.d("My posts retrieved");
    return snapshot;
  }

  /// Get subscribed posts
  ///
  /// param:
  /// return: Future<String>[name]
  /// initial creation: 16/10/2020
  /// last updated: 16/10/2020
  Future<QuerySnapshot> getSubscribedPosts() async {
    log.d("Retrieving Subscribed Posts for " +
        _internalProfileService.getAccountDatabaseID());

    QuerySnapshot snapshot;
    if (_internalProfileService.getSubscribedPostsIds().length > 0) {
      snapshot = await firestoreInstance
          .collection('Posts')
          .where("postID",
              whereIn: _internalProfileService.getSubscribedPostsIds())
          .orderBy("time", descending: true)
          .limit(10)
          .get();
    } else {
      snapshot = await firestoreInstance
          .collection('Posts')
          .where("postId", isEqualTo: "empty")
          .get();
    }
    log.d("Subscribed posts retrieved");
    return snapshot;
  }

  Future<QuerySnapshot> getMoreSubscribedPosts() async {
    PostsService _postsService = locator<PostsService>();

    log.d("Retrieving Subscribed Posts for " +
        _internalProfileService.getAccountDatabaseID());

    QuerySnapshot snapshot;
    if (_internalProfileService.getSubscribedPostsIds().length > 0) {
      snapshot = await firestoreInstance
          .collection('Posts')
          .where("postID",
              whereIn: _internalProfileService.getSubscribedPostsIds())
          .orderBy("time", descending: true)
          .startAfter({_postsService.getSubscribedPosts().last.time}.toList())
          .limit(10)
          .get();
    } else {
      snapshot = await firestoreInstance
          .collection('Posts')
          .where("postId", isEqualTo: "empty")
          .get();
    }
    log.d("Subscribed posts retrieved");
    return snapshot;
  }

  /// Get my posts
  ///
  /// param:
  /// return: Future<String>[name]
  /// initial creation: 16/10/2020
  /// last updated: 16/10/2020
  Future<QuerySnapshot> getAnnouncements() async {
    log.d("Retrieving announcements ");
    QuerySnapshot snapshot = await firestoreInstance
        .collection('Announcements')
        .orderBy("time", descending: true)
        .limit(10)
        .get();
    log.d("Announcements retrieved");
    return snapshot;
  }

  Future<QuerySnapshot> getMoreAnnouncements() async {
    PostsService _postsService = locator<PostsService>();

    log.d("Retrieving announcements ");
    QuerySnapshot snapshot = await firestoreInstance
        .collection('Announcements')
        .orderBy("time", descending: true)
        .startAfter({_postsService.getAnnouncements().last.time}.toList())
        .limit(10)
        .get();
    log.d("Announcements retrieved");
    return snapshot;
  }

  /// Get a passed users name
  ///
  /// param:
  /// return: Future<String>[name]
  /// initial creation: 7/09/2020
  /// last updated: 7/09/2020
  Future<String> getAccountName() async {
    if (getAccountData().get("name") != null) {
      return getAccountData().get("name");
    } else {
      log.i("Name data not found");
      return "";
    }
  }

  /// Get the passed users profile picture
  ///
  /// param:
  /// return: Future<String>[pictureUrl]
  /// initial creation: 7/09/2020
  /// last updated: 7/09/2020
  Future<String> getAccountPic() async {
    if (getAccountData().get("profilePic") != null) {
      return getAccountData().get("profilePic");
    } else {
      log.i("Profile picture not found");
      return "";
    }
  }

  /// Confirms that a profile exists for the user
  ///
  /// param:
  /// return: Future<bool>
  /// initial creation: 24/09/2020
  /// last updated: 25/09/2020
  Future<bool> profileExists() async {
    if (getAccountData() != null) {
      return true;
    }
    return false;
  }

  /// Get the user data
  ///
  /// param: User[user]
  /// return: Future<DocumentSnapshot>[userdata]
  /// initial creation: 7/09/2020
  /// last updated: 7/09/2020
  Future setAccountData(User user) async {
    if (user == null) {
      _accountData = null;
      return null;
    }
    await firestoreInstance
        .collection("Accounts")
        .where("uid", isEqualTo: user.uid)
        .get()
        .then((value) {
      if (value.size != 0) {
        _accountData = value.docs[0];
        _internalProfileService.setAccount(_accountData);
      }
    }).catchError((error) => log.d("Database ERROR " + error.toString()));
  }

  DocumentSnapshot getAccountData() {
    return _accountData;
  }

  /// Create User
  ///
  /// param: String[uid], String[name], int[role], String[mobile], String[profilePic]
  /// return:
  /// initial creation: 7/09/2020
  /// last updated: 06/10/2020
  void createAccount(
      {@required String uid,
      @required BuildContext context,
      @required String name,
      @required String mobile,
      @required int role,
      @required PickedFile profilePic}) async {
    final PostsService _postsService = locator<PostsService>();
    createDialogs(context: context, profileComplete: true);

    _loadingAlert.showDialog();

    await setTotalUsers();
    String newAccountID = (_totalUsers + 1).toString();

    if (profilePic == null) {
      _defaultProfilePic = true;
    } else {
      _defaultProfilePic = false;
      final snapshot =
          await _storeImage(pic: profilePic, databaseID: newAccountID);
      if (snapshot != null) {
        if (snapshot.error == null) {
          downloadUrl = await snapshot.ref.getDownloadURL();
        } else {
          _errorAlert.setErrorState(true);
          _loadingAlert.dismissDialog();
          _errorAlert.showDialog();
        }
      } else {
        _errorAlert.setErrorState(true);
        _loadingAlert.dismissDialog();
        _errorAlert.showDialog();
      }
    }

    if (!_errorAlert.getErrorState()) {
      firestoreInstance
          .collection('Accounts')
          .doc("*TotalUsers")
          .set({"total_users": _totalUsers + 1});
      firestoreInstance.collection('Accounts').doc(newAccountID).set({
        "databaseID": newAccountID,
        "uid": uid,
        "name": name,
        "role": role,
        "notificationStatus": true,
        "profilePic": _defaultProfilePic ? "default" : downloadUrl,
        "mobile": mobile,
        "subscribed_posts": [],
        "my_posts": [],
      }).catchError((error) {
        _errorAlert.setErrorState(true);
      }).whenComplete(() {
        _loadingAlert.dismissDialog();
        if (!_errorAlert.getErrorState()) {
          _internalProfileService.setHasProfile(true);
          _internalProfileService.setUID(uid);
          _internalProfileService.setAccountDatabaseID(newAccountID);
          _internalProfileService.setUserName(name);
          _internalProfileService
              .setProfilePic(_defaultProfilePic ? "default" : downloadUrl);
          _internalProfileService.setRole(role);
          _internalProfileService.setMobile(mobile);

          InternalUser newUser = InternalUser();
          newUser.databaseID = newAccountID;
          newUser.uid = uid;
          newUser.name = name;
          newUser.role = role;
          newUser.mobile = mobile;
          newUser.profilePic = _defaultProfilePic ? "default" : downloadUrl;
          newUser.subscribed_posts = List<Post>();
          newUser.my_posts = List<Post>();
          _postsService.addUser(newUser);

          _successAlert.showDialog();
          log.i('Account created in database');
        } else {
          _errorAlert.showDialog();
        }
      }).timeout(Duration(seconds: 5), onTimeout: () {
        log.d("timeout");
        _errorAlert.setErrorState(true);
        _loadingAlert.dismissDialog();
        _errorAlert.showDialog();
      });
    }
  }

  /// Subscribe to Post
  ///
  /// param: String[uid], int[role]
  /// return:
  /// initial creation: 16/10/2020
  /// last updated: 16/10/2020
  Future subscribeToPost(String accountID, String postId) async {
    await firestoreInstance.collection('Accounts').doc(accountID).update({
      'subscribed_posts': FieldValue.arrayUnion([postId]),
    }).then((value) {
      _internalProfileService.addSubscribedPostId(postId);
      log.i(accountID + ' subscribed to Post: ' + postId);
    });
  }

  /// Unsubscribe from Post
  ///
  /// param: String[uid], int[role]
  /// return:
  /// initial creation: 16/10/2020
  /// last updated: 16/10/2020
  Future unsubscribeFromPost(String accountID, String postId) async {
    await firestoreInstance.collection('Accounts').doc(accountID).update({
      'subscribed_posts': FieldValue.arrayRemove([postId]),
    }).then((value) {
      _internalProfileService.removeSubscribedPostId(postId);
      log.i(accountID + ' unsubscribed from post: ' + postId);
    });
  }

  /// Update Users Role
  ///
  /// param: String[databaseID], int[role]
  /// return:
  /// initial creation: 8/09/2020
  /// last updated: 01/11/2020
  Future updateRole(
      {@required BuildContext context,
      @required String databaseID,
      @required int role}) async {
    PostsService _postsServices = locator<PostsService>();
    createDialogs(context: context, update: true);
    _loadingAlert.showDialog();
    await firestoreInstance
        .collection('Accounts')
        .doc(databaseID)
        .update({
          'role': role,
        })
        .catchError((error) => _errorAlert.setErrorState(true))
        .whenComplete(() {
          _loadingAlert.dismissDialog();
          if (!_errorAlert.getErrorState()) {
            _postsServices.getUser(userId: databaseID).role = role;
            _successAlert.showDialog();
          } else {
            _errorAlert.showDialog();
          }
        });
  }

  Future<StorageTaskSnapshot> _storeImage(
      {@required PickedFile pic, @required String databaseID}) async {
    log.d("Starting Image Storing Process");
    final savedImage = File(pic.path);

    //Store Image to Storage
    StorageTaskSnapshot snapshot = await storage
        .ref()
        .child("Accounts/$databaseID")
        .putFile(savedImage)
        .onComplete
        .timeout(Duration(seconds: 5), onTimeout: () {
      log.d("timeout");
      return null;
    });
    return snapshot;
  }

  /// Update User
  ///
  /// Any parameter that is not populated with 'null' will be updated.
  ///
  /// param: String[uid], String[name], int[role], String[mobile], String[profilePic]
  /// return:
  /// initial creation: 8/09/2020
  /// last updated: 06/10/2020
  Future updateAccount(
      {@required String databaseID,
      @required BuildContext context,
      @required String name,
      @required PickedFile pic}) async {
    PostsService _postsService = locator<PostsService>();
    createDialogs(context: context);
    _loadingAlert.showDialog();
    if (pic == null) {
      _defaultProfilePic = true;
    } else {
      _defaultProfilePic = false;
      final snapshot = await _storeImage(pic: pic, databaseID: databaseID);
      if (snapshot != null) {
        if (snapshot.error == null) {
          downloadUrl = await snapshot.ref.getDownloadURL();
        } else {
          _errorAlert.setErrorState(true);
          _loadingAlert.dismissDialog();
          _errorAlert.showDialog();
        }
      } else {
        _errorAlert.setErrorState(true);
        _loadingAlert.dismissDialog();
        _errorAlert.showDialog();
      }
    }
    //Add Reference to user object
    firestoreInstance.collection('Accounts').doc(databaseID).update({
      "profilePic": _defaultProfilePic ? "default" : downloadUrl,
      "name": name,
    }).catchError((error) {
      _errorAlert.setErrorState(true);
    }).whenComplete(() {
      _loadingAlert.dismissDialog();
      if (!_errorAlert.getErrorState()) {
        _internalProfileService.setUserName(name);
        _defaultProfilePic
            ? _internalProfileService.setProfilePic("default")
            : _internalProfileService.setProfilePic(downloadUrl);
        _internalProfileService.setUserName(name);
        _defaultProfilePic
            ? _postsService.getUser(userId: databaseID).profilePic = "default"
            : _postsService.getUser(userId: databaseID).profilePic =
                downloadUrl;
        _postsService.getUser(userId: databaseID).name = name;
        _successAlert.showDialog();
        log.i('Profile Pic Updated Successfully');
      } else {
        _errorAlert.showDialog();
      }
    });
  }

  /// Delete Users Profile
  ///
  /// param: String[uid]
  /// return:
  /// initial creation: 8/09/2020
  /// last updated: 8/09/2020
  void deleteProfile(
      {@required String databaseID, @required BuildContext context}) {
    PostsService _postsService = locator<PostsService>();
    createDialogs(context: context, deleteAccount: true);
    _loadingAlert.showDialog();
    firestoreInstance.collection('Accounts').doc(databaseID).update({
      "uid": null,
      "name": "Deleted",
      "role": -1,
      "profilePic": "default",
      "mobile": null,
    }).catchError((error) {
      _errorAlert.setErrorState(true);
    }).whenComplete(() {
      if (!_errorAlert.getErrorState()) {
        final AuthenticationService _authenticationService =
            locator<AuthenticationService>();
        _authenticationService.logoutUser().whenComplete(() {
          _internalProfileService.clearUserDetails();
          _postsService.logoutCleanUp();
          _loadingAlert.dismissDialog();
          _deletedProfileSuccess.showDialog();
        });
      }
    });
  }

  void createNavigatingDialogs({
    @required BuildContext context,
    @required ScreenArguments oldArguments,
    Post post,
    Reply reply,
    Reply childReply,
  }) {
    TextInterface lang = _languageService.getLanguage();
    PostsService _postsService = locator<PostsService>();
    InternalProfileService _internalProfileService =
        locator<InternalProfileService>();

    if (childReply != null) {
      _successAlert = AlertBuilder(
          context: context,
          title: lang.popupMessages[0].toUpperCase(),
          titleColour: Colour.kvk_success_green,
          message: lang.popupMessages[14],
          icon: Icons.check_circle_outline,
          iconColour: Colour.kvk_success_green,
          buttonText: lang.ok,
          onPress: () async {
            _navigationService.navigateTo(Routes.viewReplyView,
                arguments: ScreenArguments(
                    account: _postsService.getUser(
                        userId: _internalProfileService.getAccountDatabaseID()),
                    post: post,
                    reply: reply,
                    childReply: childReply,
                    routeFrom: Routes.viewReplyView,
                    oldArgs: oldArguments.oldArgs));
          });
    } else if (reply != null) {
      //TODO: Error with navigation of edit reply in reply to reply page going to reply to reply page twice
      _successAlert = AlertBuilder(
          context: context,
          title: lang.popupMessages[0].toUpperCase(),
          titleColour: Colour.kvk_success_green,
          message: lang.popupMessages[14],
          icon: Icons.check_circle_outline,
          iconColour: Colour.kvk_success_green,
          buttonText: lang.ok,
          onPress: () async {
            _navigationService.pushNamedAndRemoveUntil(Routes.viewReplyView,
                arguments: ScreenArguments(
                    account: _postsService.getUser(
                        userId: _internalProfileService.getAccountDatabaseID()),
                    post: post,
                    reply: reply,
                    routeFrom: oldArguments.routeFrom,
                    oldArgs: oldArguments.oldArgs));
          });
    } else if (post != null) {
      _successAlert = AlertBuilder(
          context: context,
          title: lang.popupMessages[0].toUpperCase(),
          titleColour: Colour.kvk_success_green,
          message: lang.popupMessages[10],
          icon: KVKIcons.accept_original,
          iconColour: Colour.kvk_success_green,
          buttonText: lang.ok,
          onPress: () async {
            _successAlert.dismissDialog();
            _navigationService.navigateTo(Routes.viewPostView,
                arguments: ScreenArguments(
                    account: _postsService.getUser(
                        userId: _internalProfileService.getAccountDatabaseID()),
                    post: post,
                    routeFrom: oldArguments.routeFrom));
          });
    }
  }

  /// Creates success, error and loading popups
  ///
  /// param: BuildContext [context]
  /// returns:
  /// Initial creation: 30/09/2020
  /// Last Updated: 04/10/2020
  void createDialogs(
      {@required BuildContext context,
      bool profileComplete = false,
      bool deleteAccount = false,
      bool reply = false,
      bool longReply = false,
      bool deletePost = false,
      bool deleteReply = false,
      bool update = false,
      bool announcement = false,
      bool deleteAnnouncement = false,
      bool updateAnnouncement = false,
      ScreenArguments screenArguments,
      String routeFrom}) {
    TextInterface lang = _languageService.getLanguage();
    final NavBarService _kvkNavBarService = locator<NavBarService>();
    if (profileComplete) {
      _successAlert = AlertBuilder(
          context: context,
          title: lang.popupMessages[0].toUpperCase(),
          titleColour: Colour.kvk_success_green,
          message: lang.popupMessages[5],
          icon: KVKIcons.accept_original,
          iconColour: Colour.kvk_success_green,
          buttonText: lang.popupMessages[6].toUpperCase(),
          onPress: () async {
            _successAlert.dismissDialog();
            _kvkNavBarService.setCurrentIndex(0);
            _navigationService.navigateTo(Routes.homeView);
          });
    } else if (reply) {
      _successAlert = AlertBuilder(
          context: context,
          title: lang.popupMessages[0].toUpperCase(),
          titleColour: Colour.kvk_success_green,
          message: lang.popupMessages[11],
          icon: KVKIcons.accept_original,
          iconColour: Colour.kvk_success_green,
          buttonText: lang.ok,
          onPress: () async {
            _successAlert.dismissDialog();

            if (longReply) {
              _navigationService.navigateTo(routeFrom,
                  arguments: screenArguments);
            }
          });
    } else if (deletePost) {
      _successAlert = AlertBuilder(
          context: context,
          title: lang.popupMessages[0].toUpperCase(),
          titleColour: Colour.kvk_success_green,
          message: lang.popupMessages[12],
          icon: KVKIcons.accept_original,
          iconColour: Colour.kvk_success_green,
          buttonText: lang.ok,
          onPress: () async {
            _successAlert.dismissDialog();

            //TODO: Probably goes to view they came from
            _kvkNavBarService.setCurrentIndex(0);
            _navigationService.navigateTo(Routes.homeView);
          });
    } else if (deleteReply) {
      _successAlert = AlertBuilder(
          context: context,
          title: lang.popupMessages[0].toUpperCase(),
          titleColour: Colour.kvk_success_green,
          message: lang.popupMessages[13],
          icon: KVKIcons.accept_original,
          iconColour: Colour.kvk_success_green,
          buttonText: lang.ok,
          onPress: () async {
            _successAlert.dismissDialog();
          });
    } else if (update) {
      _successAlert = AlertBuilder(
          context: context,
          title: lang.popupMessages[0].toUpperCase(),
          titleColour: Colour.kvk_success_green,
          message: lang.popupMessages[14],
          icon: KVKIcons.accept_original,
          iconColour: Colour.kvk_success_green,
          buttonText: lang.ok,
          onPress: () async {
            _successAlert.dismissDialog();
          });
    } else if (updateAnnouncement) {
      _successAlert = AlertBuilder(
          context: context,
          title: lang.popupMessages[0].toUpperCase(),
          titleColour: Colour.kvk_success_green,
          message: lang.popupMessages[14],
          icon: KVKIcons.accept_original,
          iconColour: Colour.kvk_success_green,
          buttonText: lang.ok,
          onPress: () async {
            _successAlert.dismissDialog();
            _navigationService
                .pushNamedAndRemoveUntil(Routes.viewAnnouncementView);
          });
    } else if (announcement) {
      _successAlert = AlertBuilder(
          context: context,
          title: lang.popupMessages[0].toUpperCase(),
          titleColour: Colour.kvk_success_green,
          message: "Announcement Created",
          icon: KVKIcons.accept_original,
          iconColour: Colour.kvk_success_green,
          buttonText: lang.ok,
          onPress: () async {
            _successAlert.dismissDialog();
            _navigationService
                .pushNamedAndRemoveUntil(Routes.viewAnnouncementView);
          });
    } else if (deleteAnnouncement) {
      _successAlert = AlertBuilder(
          context: context,
          title: lang.popupMessages[0].toUpperCase(),
          titleColour: Colour.kvk_success_green,
          message: "Announcement Deleted",
          icon: KVKIcons.accept_original,
          iconColour: Colour.kvk_success_green,
          buttonText: lang.ok,
          onPress: () async {
            _successAlert.dismissDialog();
          });
    } else {
      _successAlert = AlertBuilder(
          context: context,
          title: lang.popupMessages[0].toUpperCase(),
          titleColour: Colour.kvk_success_green,
          message: lang.popupMessages[7],
          icon: KVKIcons.accept_original,
          iconColour: Colour.kvk_success_green,
          buttonText: lang.ok,
          onPress: () async {
            _successAlert.dismissDialog();
            _kvkNavBarService.setCurrentIndex(2);
            _navigationService.pushNamedAndRemoveUntil(Routes.profileView);
            _internalProfileService.setChangeNumberRequest(false);
          });
    }
    _successAlert.createAlert();

    _errorAlert = AlertBuilder(
        context: context,
        title: lang.popupMessages[1].toUpperCase(),
        titleColour: Colour.kvk_error_red,
        message: lang.popupMessages[3],
        icon: KVKIcons.cancel_original,
        iconColour: Colour.kvk_error_red,
        buttonText: lang.back.toUpperCase(),
        onPress: () async {
          _errorAlert.dismissDialog();
          _errorAlert.setErrorState(false);
        });
    _errorAlert.createAlert();

    _loadingAlert = AlertBuilder(
      context: context,
      loadingAlert: true,
      title: lang.popupMessages[2],
      titleColour: Colour.kvk_grey,
    );
    _loadingAlert.createAlert();

    if (deleteAccount) {
      _deletedProfileSuccess = AlertBuilder(
          context: context,
          title: lang.popupMessages[0].toUpperCase(),
          titleColour: Colour.kvk_success_green,
          message: lang.popupMessages[8],
          icon: KVKIcons.accept_original,
          iconColour: Colour.kvk_success_green,
          buttonText: lang.ok,
          onPress: () async {
            _deletedProfileSuccess.dismissDialog();
            _internalProfileService.clearUserDetails();
            _kvkNavBarService.setCurrentIndex(0);
            _navigationService.navigateTo(Routes.homeView);
          });
      _deletedProfileSuccess.createAlert();
    }
  }

  Future changeAccount({
    @required String databaseID,
    @required BuildContext context,
    @required String uid,
    @required String mobile,
  }) async {
    createDialogs(context: context);
    firestoreInstance.collection('Accounts').doc(databaseID).update({
      'mobile': mobile,
      'uid': uid,
    }).catchError((error) {
      _errorAlert.setErrorState(true);
    }).whenComplete(() {
      final AuthenticationService _authenticationService =
          locator<AuthenticationService>();
      if (!_errorAlert.getErrorState()) {
        log.i('Account Updated Successfully');
        _authenticationService.getLoadingDialog().dismissDialog();
        _successAlert.showDialog();
      } else {
        _authenticationService.getLoadingDialog().dismissDialog();
        _errorAlert.showDialog();
      }
      return true;
    });
  }

  Future updateAccountName({
    @required String databaseID,
    @required context,
    @required String name,
  }) async {
    createDialogs(context: context);
    _loadingAlert.showDialog();
    //Add Reference to user object
    firestoreInstance.collection('Accounts').doc(databaseID).update({
      "name": name,
    }).catchError((error) {
      _errorAlert.setErrorState(true);
    }).whenComplete(() {
      _loadingAlert.dismissDialog();
      if (!_errorAlert.getErrorState()) {
        _internalProfileService.setUserName(name);
        _successAlert.showDialog();
        log.i('Name Updated Successfully');
      } else {
        _errorAlert.showDialog();
      }
    });
  }

  Future deletePost(
      {@required BuildContext context, @required Post post}) async {
    final PostsService _postsService = locator<PostsService>();
    createDialogs(context: context, deletePost: true);
    _loadingAlert.showDialog();

    if (post.replies.length == 0) {
      await firestoreInstance
          .collection('Posts')
          .doc(post.postID)
          .collection("Replies")
          .doc("*TotalReplies")
          .delete()
          .catchError((error) {
        _errorAlert.setErrorState(true);
      }).whenComplete(() async {
        await firestoreInstance
            .collection('Posts')
            .doc(post.postID)
            .delete()
            .catchError((error) {
          _errorAlert.setErrorState(true);
        }).whenComplete(() async {
          await firestoreInstance
              .collection('Accounts')
              .doc(post.userId)
              .update({
            "my_posts": FieldValue.arrayRemove({post.postID}.toList())
          }).catchError((error) {
            _errorAlert.setErrorState(true);
          }).whenComplete(() {
            _loadingAlert.dismissDialog();
            if (!_errorAlert.getErrorState()) {
              _postsService.removePost(post);
              _successAlert.showDialog();
            } else {
              _errorAlert.showDialog();
            }
          });
        });
      });
    } else {
      await firestoreInstance.collection('Posts').doc(post.postID).update({
        "body": "[Deleted Post]",
        "title": "[Deleted Post]",
        "files": {},
        "imgs": {},
        "vids": {},
        "user": "0",
      }).catchError((error) {
        _errorAlert.setErrorState(true);
      }).whenComplete(() {
        _loadingAlert.dismissDialog();
        if (!_errorAlert.getErrorState()) {
          post.userId = "0";
          post.title = "[Deleted Post]";
          post.body = "[Deleted Post]";
          post.files = new List<AttachedFile>();
          post.imgs = new List<AttachedImage>();
          post.vids = new List<AttachedVideo>();

          post.mine = false;
          _successAlert.showDialog();
        } else {
          _errorAlert.showDialog();
        }
      });
    }
  }

  Future refreshRole(
      {@required String userId, @required BuildContext context}) async {
    final PostsService _postsService = locator<PostsService>();
    log.d("Get Users");
    createDialogs(context: context);

    _loadingAlert.showDialog();
    await firestoreInstance
        .collection('Accounts')
        .doc(userId)
        .get()
        .then((value) {
          if (value.exists) {
            int role = value.get("role");
            _postsService.getUser(userId: userId).role = role;
            _internalProfileService.setRole(role);
          } // log.d("Retrieving Accounts - Count: " + users.length.toString());
        })
        .catchError((error) => _errorAlert.setErrorState(true))
        .whenComplete(() {
          _loadingAlert.dismissDialog();
          if (_errorAlert.getErrorState()) {
            _errorAlert.showDialog();
          }
        });
  }

  Future deleteAnnouncement(
      {@required BuildContext context,
      @required Announcement announcement}) async {
    final PostsService _postsService = locator<PostsService>();
    createDialogs(context: context, deleteAnnouncement: true);
    _loadingAlert.showDialog();
    await firestoreInstance
        .collection('Announcements')
        .doc(announcement.announcementId)
        .delete()
        .catchError((error) {
      _errorAlert.setErrorState(true);
    }).whenComplete(() async {
      _loadingAlert.dismissDialog();
      if (!_errorAlert.getErrorState()) {
        _postsService.removeAnnouncement(announcement);
        _successAlert.showDialog();
      } else {
        _errorAlert.showDialog();
      }
    });
  }

  Future<int> getFileSize(String path) async {
    var bytes = new File(path);
    if (await bytes.exists()) {
      var size = await bytes.readAsBytes();
      return size.length;
    }
    return -1;
  }

  Future createPost({
    @required String title,
    @required String body,
    @required String category,
    @required List<PickedFile> imgs,
    @required List<PickedFile> vids,
    @required List<AttachedFile> files,
    @required int size,
    @required BuildContext context,
    @required ScreenArguments arguments,
  }) async {
    final PostsService _postsService = locator<PostsService>();

    createDialogs(context: context);

    _loadingAlert.showDialog();

    await setTotalPosts();
    String postId = (_totalPosts + 1).toString();

    List<AttachedFile> fileList = new List();
    for (int i = 0; i < files.length; i++) {
      await _storePostFiles(file: files[i], linkedPost: postId, itemIndex: i)
          .catchError((error) {
        _errorAlert.setErrorState(true);
      }).then(
        (value) async {
          if (!_errorAlert.getErrorState()) {
            AttachedFile newFile = new AttachedFile();

            newFile.fileId = i.toString();
            newFile.name = files[i].name;
            newFile.fileSize = files[i].fileSize.toString();
            newFile.filetype = files[i].filetype;
            newFile.fileURL = value;
            fileList.add(newFile);
          }
        },
      );
    }

    Map<String, List<String>> fileObjects = {};
    for (AttachedFile item in fileList) {
      fileObjects.putIfAbsent(item.fileId,
          () => [item.name, item.fileSize, item.fileURL, item.filetype]);
    }

    List<AttachedImage> _imgList = new List();
    for (int i = 0; i < imgs.length; i++) {
      await _storePostImgs(img: imgs[i], linkedPost: postId, itemIndex: i)
          .catchError((error) {
        _errorAlert.setErrorState(true);
      }).then(
        (value) async {
          if (!_errorAlert.getErrorState()) {
            AttachedImage newImage = new AttachedImage();
            newImage.imgId = i.toString();
            newImage.size =
                ((await getFileSize(imgs[i].path)) / 1000).toString();
            newImage.path = value;
            newImage.local = true;
            _imgList.add(newImage);
          }
        },
      );
    }

    Map<String, List<String>> imgObjects = {};
    for (AttachedImage item in _imgList) {
      imgObjects.putIfAbsent(item.imgId, () => [item.path, item.size]);
    }

    List<AttachedVideo> vidDetails = new List();
    for (int i = 0; i < vids.length; i++) {
      await _storePostVids(vid: vids[i], linkedPost: postId, itemIndex: i)
          .catchError((error) {
        _errorAlert.setErrorState(true);
      }).then(
        (value) async {
          if (!_errorAlert.getErrorState()) {
            AttachedVideo video = new AttachedVideo();
            video.vidId = i.toString();
            video.size = ((await getFileSize(vids[i].path)) / 1000).toString();
            video.path = value;
            video.videoPlayerController =
                VideoPlayerController.network(video.path);
            video.videoPlayerControllerFuture =
                video.videoPlayerController.initialize();
            vidDetails.add(video);
          }
        },
      );
    }

    Map<String, List<String>> vidObjects = {};
    for (AttachedVideo item in vidDetails) {
      vidObjects.putIfAbsent(item.vidId, () => [item.path, item.size]);
    }

    if (!_errorAlert.getErrorState()) {
      firestoreInstance
          .collection("Posts")
          .doc("*TotalPosts")
          .update({"total_posts": _totalPosts + 1});
      log.d("Total Posts count updated");
      firestoreInstance.collection('Posts').doc(postId).set(
        {
          "postID": postId,
          "user": _internalProfileService.getAccountDatabaseID(),
          "title": title,
          "body": body,
          "category": category,
          "files": fileObjects,
          "imgs": imgObjects,
          "vids": vidObjects,
          "time": new Timestamp.now(),
          "size": size / 1000,
          "edited": false
        },
      ).catchError((error) {
        _errorAlert.setErrorState(true);
      }).whenComplete(() {
        if (!_errorAlert.getErrorState()) {
          firestoreInstance
              .collection("Posts")
              .doc(postId)
              .collection("Replies")
              .doc("*TotalReplies")
              .set({"total_replies": 0}).catchError((error) {
            _errorAlert.setErrorState(true);
          }).whenComplete(() {
            if (!_errorAlert.getErrorState()) {
              firestoreInstance
                  .collection("Accounts")
                  .doc(_internalProfileService.getAccountDatabaseID())
                  .update({
                "my_posts": FieldValue.arrayUnion([postId])
              }).catchError((error) {
                _errorAlert.setErrorState(true);
              }).whenComplete(() {
                _loadingAlert.dismissDialog();
                if (!_errorAlert.getErrorState()) {
                  Post newPost = new Post();
                  newPost.userId =
                      _internalProfileService.getAccountDatabaseID();
                  newPost.postID = postId;
                  newPost.body = body;
                  newPost.categoryId = category;
                  newPost.title = title;
                  newPost.mine = true;
                  newPost.time = new Timestamp.now();
                  newPost.size = size / 1000;

                  for (int i = 0; i < _imgList.length; i++) {
                    newPost.imgs.add(_imgList[i]);
                  }
                  for (int i = 0; i < vidDetails.length; i++) {
                    newPost.vids.add(vidDetails[i]);
                  }

                  for (int i = 0; i < fileList.length; i++) {
                    newPost.files.add(fileList[i]);
                  }
                  _postsService.addPost(newPost);

                  createNavigatingDialogs(
                      context: context, oldArguments: arguments, post: newPost);
                  _successAlert.createAlert();

                  _successAlert.showDialog();
                  log.i('Post created in database');
                } else {
                  _errorAlert.showDialog();
                }
              });
            } else {
              _loadingAlert.dismissDialog();
              _errorAlert.showDialog();
            }
          });
        } else {
          _loadingAlert.dismissDialog();
          _errorAlert.showDialog();
        }
      }).timeout(Duration(seconds: 5), onTimeout: () {
        log.d("timeout");
        _errorAlert.setErrorState(true);
        _loadingAlert.dismissDialog();
        _errorAlert.showDialog();
      });
    } else {
      _loadingAlert.dismissDialog();
      _errorAlert.showDialog();
    }
  }

  void updatePost({
    @required Post post,
    @required BuildContext context,
    @required String title,
    @required String body,
    @required String category,
    @required List<PickedFile> imgs,
    @required List<PickedFile> vids,
    @required List<AttachedFile> files,
    @required double size,
    @required ScreenArguments screenArguments,
  }) async {
    Map<String, List<String>> vidObjects = {};
    Map<String, List<String>> fileObjects = {};
    Map<String, List<String>> imgObjects = {};
    List<AttachedFile> filesList = new List();
    List<AttachedImage> imgList = new List();
    List<AttachedVideo> vidList = new List();
    final PostsService _postsService = locator<PostsService>();

    Timestamp time = new Timestamp.now();

    createDialogs(context: context);

    _loadingAlert.showDialog();

    log.d("Updating Stored Files");
    for (int i = 0; i < files.length; i++) {
      await _storePostFiles(
              file: files[i], linkedPost: post.postID, itemIndex: i)
          .catchError((error) {
        _errorAlert.setErrorState(true);
      }).then(
        (value) async {
          if (!_errorAlert.getErrorState()) {
            AttachedFile newFile = new AttachedFile();

            newFile.fileId = i.toString();
            newFile.name = files[i].name;
            newFile.fileSize = files[i].fileSize.toString();
            newFile.filetype = files[i].filetype;
            newFile.fileURL = value;

            filesList.add(newFile);
          }
        },
      );
      for (AttachedFile item in filesList) {
        fileObjects.putIfAbsent(item.fileId,
            () => [item.name, item.fileSize, item.fileURL, item.filetype]);
      }
    }

    log.d("Updating Stored Imgs");
    for (int i = 0; i < imgs.length; i++) {
      await _storePostImgs(img: imgs[i], linkedPost: post.postID, itemIndex: i)
          .catchError((error) {
        _errorAlert.setErrorState(true);
      }).then(
        (value) async {
          if (!_errorAlert.getErrorState()) {
            AttachedImage image = new AttachedImage();
            image.imgId = i.toString();
            image.size = await getFileSize(imgs[i].path) != -1
                ? ((await getFileSize(imgs[i].path)) / 1000).toString()
                : _postsService.getPostImg(path: imgs[i].path, post: post).size;
            image.path = value;
            image.local = true;
            imgList.add(image);
          }
        },
      );
    }
    for (AttachedImage item in imgList) {
      imgObjects.putIfAbsent(item.imgId, () => [item.path, item.size]);
    }

    log.d("Updating Stored Vids");
    for (int i = 0; i < vids.length; i++) {
      await _storePostVids(vid: vids[i], linkedPost: post.postID, itemIndex: i)
          .catchError((error) {
        _errorAlert.setErrorState(true);
      }).then(
        (value) async {
          if (!_errorAlert.getErrorState()) {
            AttachedVideo video = new AttachedVideo();
            video.vidId = i.toString();
            video.size = await getFileSize(vids[i].path) != -1
                ? ((await getFileSize(vids[i].path)) / 1000).toString()
                : _postsService.getPostVid(path: vids[i].path, post: post).size;
            video.path = value;
            vidList.add(video);
          }
        },
      );
    }
    for (AttachedVideo item in vidList) {
      vidObjects.putIfAbsent(item.vidId, () => [item.path, item.size]);
    }

    if (!_errorAlert.getErrorState()) {
      log.d("Update Post");
      await firestoreInstance.collection('Posts').doc(post.postID).update(
        {
          "title": title,
          "body": body,
          "category": category,
          "time": time,
          "size": size,
          "edited": true
        },
      ).catchError((error) {
        _errorAlert.setErrorState(true);
      }).whenComplete(() async {
        log.d("Update post files");
        await firestoreInstance.collection('Posts').doc(post.postID).update({
          "files": fileObjects,
        }).catchError((error) {
          _errorAlert.setErrorState(true);
        }).whenComplete(() async {
          log.d("Update post imgs");
          await firestoreInstance.collection('Posts').doc(post.postID).update({
            "imgs": imgObjects,
          }).catchError((error) {
            _errorAlert.setErrorState(true);
          }).whenComplete(() async {
            log.d("Update post vids");
            await firestoreInstance
                .collection('Posts')
                .doc(post.postID)
                .update({
              "vids": vidObjects,
            }).catchError((error) {
              _errorAlert.setErrorState(true);
            });

            post.body = body;
            post.categoryId = category;
            post.title = title;
            post.time = time;
            post.size = size;
            post.files = filesList;
            post.imgs = imgList;
            post.vids = vidList;
            post.edited = true;

            _loadingAlert.dismissDialog();
            if (!_errorAlert.getErrorState()) {
              createNavigatingDialogs(
                  context: context,
                  oldArguments: screenArguments.oldArgs,
                  post: post);
              _successAlert.createAlert();

              _successAlert.showDialog();
              log.i('Post updated in database');
            } else {
              _errorAlert.setErrorState(true);
            }
          }).timeout(Duration(seconds: 5), onTimeout: () {
            log.d("timeout");
            _errorAlert.setErrorState(true);
            _loadingAlert.dismissDialog();
            _errorAlert.showDialog();
          });
        });
      });
    } else {
      _loadingAlert.dismissDialog();
      _errorAlert.showDialog();
    }
  }

  void updateAnnouncement({
    @required Announcement announcement,
    @required BuildContext context,
    @required String text,
    @required List<PickedFile> imgs,
    @required List<PickedFile> vids,
    @required List<AttachedFile> files,
    @required double size,
  }) async {
    Map<String, List<String>> fileObjects = {};
    List<AttachedFile> filesList = List<AttachedFile>();
    List<AttachedImage> imgList = List<AttachedImage>();
    List<AttachedVideo> vidList = List<AttachedVideo>();

    Timestamp time = new Timestamp.now();

    createDialogs(context: context, updateAnnouncement: true);

    _loadingAlert.showDialog();

    log.d("Updating Stored Files");
    for (int i = 0; i < files.length; i++) {
      await _storeAnnouncementFiles(
              file: files[i],
              linkedAnnouncement: announcement.announcementId,
              itemIndex: i)
          .catchError((error) {
        _errorAlert.setErrorState(true);
      }).then(
        (value) async {
          if (!_errorAlert.getErrorState()) {
            AttachedFile newFile = new AttachedFile();

            newFile.fileId = i.toString();
            newFile.name = files[i].name;
            newFile.fileSize = files[i].fileSize.toString();
            newFile.filetype = files[i].filetype;
            newFile.fileURL = value;

            filesList.add(newFile);
          }
        },
      );
      for (AttachedFile item in filesList) {
        fileObjects.putIfAbsent(item.fileId,
            () => [item.name, item.fileSize, item.fileURL, item.filetype]);
      }
    }

    log.d("Updating Stored Imgs");
    for (int i = 0; i < imgs.length; i++) {
      await _storeAnnouncementImage(
              img: imgs[i], linkedAnnouncement: announcement.announcementId)
          .catchError((error) {
        _errorAlert.setErrorState(true);
      }).then(
        (value) async {
          if (!_errorAlert.getErrorState()) {
            AttachedImage image = new AttachedImage();
            image.imgId = i.toString();
            image.size = await getFileSize(imgs[i].path) != -1
                ? ((await getFileSize(imgs[i].path)) / 1000).toString()
                : announcement.img.size;
            image.path = value;
            image.local = true;
            imgList.add(image);
          }
        },
      );
    }

    log.d("Updating Stored Vids");
    for (int i = 0; i < vids.length; i++) {
      await _storeAnnouncementVideo(
              vid: vids[i], linkedAnnouncement: announcement.announcementId)
          .catchError((error) {
        _errorAlert.setErrorState(true);
      }).then(
        (value) async {
          if (!_errorAlert.getErrorState()) {
            AttachedVideo video = new AttachedVideo();
            video.vidId = i.toString();
            video.size = await getFileSize(vids[i].path) != -1
                ? ((await getFileSize(vids[i].path)) / 1000).toString()
                : announcement.vid.size;
            video.path = value;
            vidList.add(video);
          }
        },
      );
    }

    if (!_errorAlert.getErrorState()) {
      log.d("Update Announcement");
      await firestoreInstance
          .collection('Announcements')
          .doc(announcement.announcementId)
          .update(
        {
          "body": text,
          "time": time,
          "size": size,
          "edited": true,
          "userId": _internalProfileService.getAccount().databaseID,
        },
      ).catchError((error) {
        _errorAlert.setErrorState(true);
      }).whenComplete(() async {
        log.d("Update announcement files");
        await firestoreInstance
            .collection('Announcements')
            .doc(announcement.announcementId)
            .update({
          "files": fileObjects,
        }).catchError((error) {
          _errorAlert.setErrorState(true);
        }).whenComplete(() async {
          log.d("Update announcement imgs");
          await firestoreInstance
              .collection('Announcements')
              .doc(announcement.announcementId)
              .update({
            "img": imgList.length > 0 ? [imgList[0].path, imgList[0].size] : [],
          }).catchError((error) {
            _errorAlert.setErrorState(true);
          }).whenComplete(() async {
            log.d("Update announcement vids");
            await firestoreInstance
                .collection('Announcements')
                .doc(announcement.announcementId)
                .update({
              "vid":
                  vidList.length > 0 ? [vidList[0].path, vidList[0].size] : [],
            }).catchError((error) {
              _errorAlert.setErrorState(true);
            });

            announcement.text = text;
            announcement.time = time;
            announcement.size = size;
            announcement.files = filesList;

            if (imgList.length > 0) {
              announcement.img = imgList[0];
            }
            if (vidList.length > 0) {
              announcement.vid = vidList[0];
            }
            announcement.edited = true;

            _loadingAlert.dismissDialog();
            if (!_errorAlert.getErrorState()) {
              _successAlert.showDialog();
              log.i('Announcement updated in database');
            } else {
              _errorAlert.setErrorState(true);
            }
          }).timeout(Duration(seconds: 5), onTimeout: () {
            log.d("timeout");
            _errorAlert.setErrorState(true);
            _loadingAlert.dismissDialog();
            _errorAlert.showDialog();
          });
        });
      });
    } else {
      _loadingAlert.dismissDialog();
      _errorAlert.showDialog();
    }
  }

  void updateReply({
    @required Post post,
    @required Reply reply,
    @required BuildContext context,
    @required String body,
    @required List<PickedFile> imgs,
    @required List<PickedFile> vids,
    @required List<AttachedFile> files,
    @required ScreenArguments args,
  }) async {
    Map<String, List<String>> vidObjects = {};
    Map<String, List<String>> fileObjects = {};
    Map<String, List<String>> imgObjects = {};
    List<AttachedFile> filesList = new List();
    List<AttachedImage> imgList = new List();
    List<AttachedVideo> vidList = new List();
    final PostsService _postsService = locator<PostsService>();

    Timestamp time = new Timestamp.now();

    createDialogs(context: context, update: true);

    _loadingAlert.showDialog();

    log.d("Updating Stored Files");
    for (int i = 0; i < files.length; i++) {
      await _storeReplyFiles(
              file: files[i],
              linkedPost: post.postID,
              linkedReply: reply.replyId,
              itemIndex: i)
          .catchError((error) {
        _errorAlert.setErrorState(true);
      }).then(
        (value) async {
          if (!_errorAlert.getErrorState()) {
            AttachedFile newFile = new AttachedFile();

            newFile.fileId = i.toString();
            newFile.name = files[i].name;
            newFile.fileSize = files[i].fileSize.toString();
            newFile.filetype = files[i].filetype;
            newFile.fileURL = value;

            filesList.add(newFile);
          }
        },
      );
      for (AttachedFile item in filesList) {
        fileObjects.putIfAbsent(item.fileId,
            () => [item.name, item.fileSize, item.fileURL, item.filetype]);
      }
    }

    log.d("Updating Stored Imgs");
    for (int i = 0; i < imgs.length; i++) {
      await _storeReplyImgs(
              img: imgs[i],
              linkedPost: post.postID,
              itemIndex: i,
              linkedReply: reply.replyId)
          .catchError((error) {
        _errorAlert.setErrorState(true);
      }).then(
        (value) async {
          if (!_errorAlert.getErrorState()) {
            AttachedImage image = new AttachedImage();
            image.imgId = i.toString();
            image.size = await getFileSize(imgs[i].path) != -1
                ? ((await getFileSize(imgs[i].path)) / 1000).toString()
                : _postsService.getPostImg(path: imgs[i].path, post: post).size;
            image.path = await value.ref.getDownloadURL().catchError(
              (error) {
                _errorAlert.setErrorState(true);
              },
            );
            image.local = true;
            imgList.add(image);
          }
        },
      );
    }
    for (AttachedImage item in imgList) {
      imgObjects.putIfAbsent(item.imgId, () => [item.path, item.size]);
    }

    log.d("Updating Stored Vids");
    for (int i = 0; i < vids.length; i++) {
      await _storeReplyVids(
              vid: vids[i],
              linkedPost: post.postID,
              itemIndex: i,
              linkedReply: reply.replyId)
          .catchError((error) {
        _errorAlert.setErrorState(true);
      }).then(
        (value) async {
          if (!_errorAlert.getErrorState()) {
            AttachedVideo video = new AttachedVideo();
            video.vidId = i.toString();
            video.size = await getFileSize(vids[i].path) != -1
                ? ((await getFileSize(vids[i].path)) / 1000).toString()
                : _postsService.getPostVid(path: vids[i].path, post: post).size;
            video.path = await value.ref.getDownloadURL().catchError(
              (error) {
                _errorAlert.setErrorState(true);
              },
            );
            vidList.add(video);
          }
        },
      );
    }
    for (AttachedVideo item in vidList) {
      vidObjects.putIfAbsent(item.vidId, () => [item.path, item.size]);
    }

    if (!_errorAlert.getErrorState()) {
      log.d("Update Reply");
      await firestoreInstance
          .collection('Posts')
          .doc(post.postID)
          .collection("Replies")
          .doc(reply.replyId)
          .update(
        {"body": body, "time": time, "edited": true},
      ).catchError((error) {
        _errorAlert.setErrorState(true);
      }).whenComplete(() async {
        log.d("Update reply files");
        await firestoreInstance
            .collection('Posts')
            .doc(post.postID)
            .collection("Replies")
            .doc(reply.replyId)
            .update({
          "files": fileObjects,
        }).catchError((error) {
          _errorAlert.setErrorState(true);
        }).whenComplete(() async {
          log.d("Update reply imgs");
          await firestoreInstance
              .collection('Posts')
              .doc(post.postID)
              .collection("Replies")
              .doc(reply.replyId)
              .update({
            "imgs": imgObjects,
          }).catchError((error) {
            _errorAlert.setErrorState(true);
          }).catchError((error) {
            _errorAlert.setErrorState(true);
          }).whenComplete(() async {
            log.d("Update reply vids");
            await firestoreInstance
                .collection('Posts')
                .doc(post.postID)
                .collection("Replies")
                .doc(reply.replyId)
                .update({
              "vids": vidObjects,
            }).catchError((error) {
              _errorAlert.setErrorState(true);
            });

            reply.body = body;
            reply.time = time;
            reply.files = filesList;
            reply.imgs = imgList;
            reply.vids = vidList;
            reply.edited = true;

            _loadingAlert.dismissDialog();
            if (!_errorAlert.getErrorState()) {
              createNavigatingDialogs(
                  context: context,
                  oldArguments: args,
                  reply: reply,
                  post: post);
              _successAlert.createAlert();

              _successAlert.showDialog();
              log.i('Reply updated in database');
            } else {
              _errorAlert.setErrorState(true);
            }
          }).timeout(Duration(seconds: 5), onTimeout: () {
            log.d("timeout");
            _errorAlert.setErrorState(true);
            _loadingAlert.dismissDialog();
            _errorAlert.showDialog();
          });
        });
      });
    } else {
      _loadingAlert.dismissDialog();
      _errorAlert.showDialog();
    }
  }

  void updateReplyToReply(
      {@required Post post,
      @required Reply mainReply,
      @required BuildContext context,
      @required String body,
      @required Reply childReply,
      @required ScreenArguments args}) async {
    final PostsService _postsService = locator<PostsService>();

    Timestamp time = new Timestamp.now();

    createDialogs(context: context, update: true);

    _loadingAlert.showDialog();

    if (!_errorAlert.getErrorState()) {
      log.d("Update Reply to Reply");
      await firestoreInstance
          .collection('Posts')
          .doc(post.postID)
          .collection("Replies")
          .doc(mainReply.replyId)
          .collection("Replies")
          .doc(childReply.replyId)
          .update(
        {
          "body": body,
          "time": time,
          "edited": true,
        },
      ).catchError((error) {
        _errorAlert.setErrorState(true);
      }).whenComplete(() {
        childReply.body = body;
        childReply.time = time;
        childReply.edited = true;

        _loadingAlert.dismissDialog();
        if (!_errorAlert.getErrorState()) {
          log.d(args.oldArgs);

          createNavigatingDialogs(
              context: context,
              oldArguments: args.oldArgs,
              reply: mainReply,
              childReply: childReply,
              post: post);
          _successAlert.createAlert();

          _successAlert.showDialog();
          log.i('Reply to reply updated in database');
        } else {
          _errorAlert.setErrorState(true);
        }
      }).timeout(Duration(seconds: 5), onTimeout: () {
        log.d("timeout");
        _errorAlert.setErrorState(true);
        _loadingAlert.dismissDialog();
        _errorAlert.showDialog();
      });
    } else {
      _loadingAlert.dismissDialog();
      _errorAlert.showDialog();
    }
  }

  Future<String> _storePostFiles(
      {@required AttachedFile file,
      @required String linkedPost,
      @required int itemIndex}) async {
    log.d("Starting File Storing Process");
    final savedFile = File(file.fileURL);
    if (await savedFile.exists()) {
      //Store File to Storage
      StorageTaskSnapshot snapshot = await storage
          .ref()
          .child("Posts/Files/" +
              file.name +
              "_$linkedPost" +
              "($itemIndex)." +
              file.filetype)
          .putFile(savedFile)
          .onComplete
          .timeout(Duration(seconds: 10), onTimeout: () {
        log.d("timeout");
        return null;
      });
      log.d("File stored");
      return await snapshot.ref.getDownloadURL();
    } else {
      log.d("File already in db");
      return file.fileURL;
    }
  }

  Future<String> _storeReplyFiles(
      {@required AttachedFile file,
      @required String linkedPost,
      @required String linkedReply,
      @required int itemIndex}) async {
    log.d("Starting File Storing Process");
    final savedFile = File(file.fileURL);

    if (await savedFile.exists()) {
      //Store File to Storage
      StorageTaskSnapshot snapshot = await storage
          .ref()
          .child("Posts/Files/" +
              file.name +
              "_$linkedPost" +
              "_$linkedReply" +
              "($itemIndex)." +
              file.filetype)
          .putFile(savedFile)
          .onComplete
          .timeout(Duration(seconds: 10), onTimeout: () {
        log.d("timeout");
        return null;
      });
      log.d("File stored");
      return await snapshot.ref.getDownloadURL();
    } else {
      log.d("File already in db");
    }
    return file.fileURL;
  }

  Future<String> _storePostImgs(
      {@required PickedFile img,
      @required String linkedPost,
      @required int itemIndex}) async {
    log.d("Starting Image Storing Process");

    final savedFile = File(img.path);

    if (await savedFile.exists()) {
      //Store Image to Storage
      StorageTaskSnapshot snapshot = await storage
          .ref()
          .child("Posts/Media/Imgs/$linkedPost" + "($itemIndex)")
          .putFile(savedFile)
          .onComplete
          .timeout(Duration(seconds: 10), onTimeout: () {
        log.d("timeout");
        return null;
      });
      log.d("Image stored");
      return await snapshot.ref.getDownloadURL();
    } else {
      log.d("Image already exists in DB");
      return img.path;
    }
  }

  Future<StorageTaskSnapshot> _storeReplyImgs(
      {@required PickedFile img,
      @required String linkedPost,
      @required String linkedReply,
      @required int itemIndex}) async {
    log.d("Starting Image Storing Process");
    final savedFile = File(img.path);

    //Store Image to Storage
    StorageTaskSnapshot snapshot = await storage
        .ref()
        .child(
            "Posts/Media/Imgs/$linkedPost" + "_$linkedReply" + "($itemIndex)")
        .putFile(savedFile)
        .onComplete
        .timeout(Duration(seconds: 10), onTimeout: () {
      log.d("timeout");
      return null;
    });
    log.d("Image stored");
    return snapshot;
  }

  Future _storePostVids(
      {@required PickedFile vid,
      @required String linkedPost,
      @required int itemIndex}) async {
    log.d("Starting File Storing Process");
    final savedFile = File(vid.path);

    if (await savedFile.exists()) {
      //Store Video to Storage
      StorageTaskSnapshot snapshot = await storage
          .ref()
          .child("Posts/Media/Vids/$linkedPost" + "($itemIndex)")
          .putFile(savedFile)
          .onComplete
          .timeout(Duration(seconds: 10), onTimeout: () {
        log.d("timeout");
        return null;
      });
      log.d("Video stored");
      return await snapshot.ref.getDownloadURL();
    } else {
      log.d("Video already in DB");
      return vid.path;
    }
  }

  Future<StorageTaskSnapshot> _storeReplyVids(
      {@required PickedFile vid,
      @required String linkedPost,
      @required String linkedReply,
      @required int itemIndex}) async {
    log.d("Starting File Storing Process");
    final savedFile = File(vid.path);

    //Store Video to Storage
    StorageTaskSnapshot snapshot = await storage
        .ref()
        .child(
            "Posts/Media/Vids/$linkedPost" + "_$linkedReply" + "($itemIndex)")
        .putFile(savedFile)
        .onComplete
        .timeout(Duration(seconds: 10), onTimeout: () {
      log.d("timeout");
      return null;
    });
    log.d("File stored");
    return snapshot;
  }

  Future<List<Topic>> getTopics() async {
    List<Topic> _topics = List<Topic>();
    DocumentSnapshot snapshot =
        await firestoreInstance.collection('Posts').doc("*TotalPosts").get();

    Map<String, dynamic> t = snapshot.get("topics");
    t.forEach((k, v) {
      List<dynamic> temp = v;
      List<String> result = temp.cast<String>();

      Topic newTopic = Topic();
      newTopic.id = k;
      newTopic.engName = result[0];
      newTopic.marName = result[1];
      _topics.add(newTopic);
    });
    return _topics;
  }

  Future<QuerySnapshot> getPosts() async {
    QuerySnapshot snapshot = await firestoreInstance
        .collection('Posts')
        .orderBy("time", descending: true)
        .limit(10)
        .get();
    log.d("Last " + snapshot.size.toString() + "posts retrieved");
    return snapshot;
  }

  Future<QuerySnapshot> loadMoreLatestPosts() async {
    PostsService _postsService = locator<PostsService>();
    QuerySnapshot snapshot = await firestoreInstance
        .collection('Posts')
        .orderBy("time", descending: true)
        .startAfter({_postsService.getLatestPosts().last.time}.toList())
        .limit(10)
        .get();
    log.d("Loading " + snapshot.size.toString() + " more posts");
    return snapshot;
  }

  Future<QuerySnapshot> loadTopicData() async {
    TopicService _topicService = locator<TopicService>();
    QuerySnapshot snapshot = await firestoreInstance
        .collection('Posts')
        .orderBy("time", descending: true)
        .where("category", isEqualTo: _topicService.getSelectedTopic().id)
        .limit(10)
        .get();
    log.d("Loading " + snapshot.size.toString() + " posts");
    return snapshot;
  }

  Future<QuerySnapshot> loadMoreTopicData() async {
    PostsService _postsService = locator<PostsService>();
    TopicService _topicService = locator<TopicService>();
    QuerySnapshot snapshot = await firestoreInstance
        .collection('Posts')
        .orderBy("time", descending: true)
        .where("category", isEqualTo: _topicService.getSelectedTopic().id)
        .startAfter({
          _postsService
              .getTopicPosts(topicId: _topicService.getSelectedTopic().id)
              .last
              .time
        }.toList())
        .limit(10)
        .get();
    log.d("Loading " + snapshot.size.toString() + " posts");
    return snapshot;
  }

  Future<List<Reply>> getReplies({@required Post post}) async {
    List<Reply> replies = List<Reply>();
    if (post.replies.length == 0) {
      QuerySnapshot snapshot = await firestoreInstance
          .collection('Posts')
          .doc(post.postID)
          .collection("Replies")
          .orderBy("time", descending: true)
          .limit(10)
          .get();
      log.d("Last " + snapshot.docs.length.toString() + " replies retrieved");

      for (int i = 0; i < snapshot.docs.length; i++) {
        Reply newReply = Reply();
        newReply.body = snapshot.docs[i].get("body");
        newReply.replyId = snapshot.docs[i].get("replyId");
        newReply.time = snapshot.docs[i].get("time");
        newReply.userId = snapshot.docs[i].get("userId");
        newReply.edited = snapshot.docs[i].get("edited");
        newReply.totalReplies = snapshot.docs[i].get("total_replies");

        List<AttachedImage> _imageDetails = List<AttachedImage>();

        Map<String, dynamic> imgs = snapshot.docs[i].get("imgs");
        imgs.forEach((k, v) {
          List<dynamic> temp = v;
          List<String> result = temp.cast<String>();

          AttachedImage imageDetails = AttachedImage();
          imageDetails.imgId = k.toString();
          imageDetails.path = result[0];
          imageDetails.size = result[1];
          _imageDetails.add(imageDetails);
        });

        List<AttachedVideo> _videoDetails = List<AttachedVideo>();

        Map<String, dynamic> vids = snapshot.docs[i].get("vids");
        vids.forEach((k, v) {
          List<dynamic> temp = v;
          List<String> result = temp.cast<String>();

          AttachedVideo videoDetails = AttachedVideo();
          videoDetails.vidId = k.toString();
          videoDetails.path = result[0];
          videoDetails.size = result[1];
          videoDetails.videoPlayerController =
              VideoPlayerController.network(videoDetails.path);
          videoDetails.videoPlayerControllerFuture =
              videoDetails.videoPlayerController.initialize();
          _videoDetails.add(videoDetails);
        });

        List<AttachedFile> _filesList = List<AttachedFile>();

        Map<String, dynamic> result = snapshot.docs[i].get("files");
        result.forEach((k, v) {
          List<dynamic> temp = v;
          List<String> result = temp.cast<String>();

          AttachedFile newFile = AttachedFile();
          newFile.fileId = k.toString();
          newFile.name = result[0];
          newFile.fileSize = result[1];
          newFile.fileURL = result[2];
          newFile.filetype = result[3];
          _filesList.add(newFile);
        });

        newReply.imgs = _imageDetails;
        newReply.vids = _videoDetails;
        newReply.files = _filesList;

        replies.add(newReply);
      }
      return replies;
    } else {
      return post.replies;
    }
  }

  Future<List<Reply>> getRepliesToReplies(
      {@required Post post, @required Reply reply}) async {
    List<Reply> replies = List<Reply>();
    if (reply.replies.length == 0) {
      QuerySnapshot snapshot = await firestoreInstance
          .collection('Posts')
          .doc(post.postID)
          .collection("Replies")
          .doc(reply.replyId)
          .collection("Replies")
          .orderBy("time", descending: true)
          .limit(10)
          .get();
      log.d("Last " +
          snapshot.docs.length.toString() +
          " replies to replies retrieved");

      for (int i = 0; i < snapshot.docs.length; i++) {
        Reply newReply = Reply();
        newReply.body = snapshot.docs[i].get("body");
        newReply.replyId = snapshot.docs[i].get("replyId");
        newReply.time = snapshot.docs[i].get("time");
        newReply.userId = snapshot.docs[i].get("userId");
        newReply.edited = snapshot.docs[i].get("edited");

        replies.add(newReply);
      }
      return replies;
    } else {
      return reply.replies;
    }
  }

  Future<List<InternalUser>> getUsers() async {
    log.d("Get Users");
    List<InternalUser> users = List<InternalUser>();

    await firestoreInstance.collection('Accounts').get().then((value) {
      for (int i = 1; i < value.docs.length; i++) {
        InternalUser newUser = InternalUser();
        newUser.databaseID = value.docs[i].get("databaseID");
        newUser.name = value.docs[i].get("name");
        newUser.profilePic = value.docs[i].get("profilePic");
        newUser.role = value.docs[i].get("role");

        users.add(newUser);
      }
      log.d("Retrieving Accounts - Count: " + users.length.toString());
    });
    return users;
  }

  Future createReplyToPost({
    @required String body,
    @required BuildContext context,
    @required Post post,
    @required ScreenArguments screenArguments,
    @required String routeFrom,
    @required bool isLongReply,
    List<PickedFile> imgs,
    List<PickedFile> vids,
    List<AttachedFile> files,
  }) async {
    Map<String, List<String>> imgObjects = {};
    Map<String, List<String>> fileObjects = {};
    Map<String, List<String>> vidObjects = {};
    List<AttachedFile> filesList = new List();
    List<AttachedImage> imgList = new List();
    List<AttachedVideo> vidList = new List();

    createDialogs(
        context: context,
        reply: true,
        longReply: isLongReply,
        routeFrom: routeFrom,
        screenArguments: screenArguments);

    _loadingAlert.showDialog();

    Timestamp _time = new Timestamp.now();

    int _totalReplies = await getTotalReplies(postId: post.postID);
    String replyId = (_totalReplies + 1).toString();

    if (files != null) {
      for (int i = 0; i < files.length; i++) {
        await _storeReplyFiles(
                file: files[i],
                linkedPost: post.postID,
                linkedReply: replyId,
                itemIndex: i)
            .catchError((error) {
          _errorAlert.setErrorState(true);
        }).then(
          (value) async {
            if (!_errorAlert.getErrorState()) {
              AttachedFile newFile = new AttachedFile();

              newFile.fileId = i.toString();
              newFile.name = files[i].name;
              newFile.fileSize = files[i].fileSize.toString();
              newFile.filetype = files[i].filetype;
              newFile.fileURL = value;

              filesList.add(newFile);
            }
          },
        );
      }
      for (AttachedFile item in filesList) {
        fileObjects.putIfAbsent(item.fileId,
            () => [item.name, item.fileSize, item.fileURL, item.filetype]);
      }
    }

    if (imgs != null) {
      for (int i = 0; i < imgs.length; i++) {
        await _storeReplyImgs(
                img: imgs[i],
                linkedReply: replyId,
                linkedPost: post.postID,
                itemIndex: i)
            .catchError((error) {
          _errorAlert.setErrorState(true);
        }).then(
          (value) async {
            if (!_errorAlert.getErrorState()) {
              AttachedImage image = new AttachedImage();
              image.imgId = i.toString();
              image.size = (await getFileSize(imgs[i].path) / 1000).toString();
              image.path = await value.ref.getDownloadURL().catchError(
                (error) {
                  _errorAlert.setErrorState(true);
                },
              );
              image.local = true;
              imgList.add(image);
            }
          },
        );
      }

      for (AttachedImage item in imgList) {
        imgObjects.putIfAbsent(item.imgId, () => [item.path, item.size]);
      }
    }

    if (vids != null) {
      for (int i = 0; i < vids.length; i++) {
        await _storeReplyVids(
                vid: vids[i],
                linkedPost: post.postID,
                linkedReply: replyId,
                itemIndex: i)
            .catchError((error) {
          _errorAlert.setErrorState(true);
        }).then(
          (value) async {
            if (!_errorAlert.getErrorState()) {
              AttachedVideo video = new AttachedVideo();
              video.vidId = i.toString();
              video.size = (await getFileSize(vids[i].path) / 1000).toString();
              video.path = await value.ref.getDownloadURL().catchError(
                (error) {
                  _errorAlert.setErrorState(true);
                },
              );
              vidList.add(video);
            }
          },
        );
      }
      for (AttachedVideo item in vidList) {
        vidObjects.putIfAbsent(item.vidId, () => [item.path, item.size]);
      }
    }
    if (!_errorAlert.getErrorState()) {
      await firestoreInstance
          .collection("Posts")
          .doc(post.postID)
          .collection("Replies")
          .doc("*TotalReplies")
          .set({"total_replies": _totalReplies + 1}).catchError((error) {
        _errorAlert.setErrorState(true);
      }).whenComplete(
        () async {
          if (!_errorAlert.getErrorState()) {
            log.d("Total Replies count updated");
            await firestoreInstance
                .collection('Posts')
                .doc(post.postID)
                .collection("Replies")
                .doc(replyId)
                .set({
              "replyId": replyId,
              "userId": _internalProfileService.getAccountDatabaseID(),
              "body": body,
              "files": fileObjects,
              "imgs": imgObjects,
              "vids": vidObjects,
              "time": _time,
              "total_replies": 0,
              "edited": false,
            }).catchError((error) {
              _errorAlert.setErrorState(true);
            }).whenComplete(
              () async {
                if (!_errorAlert.getErrorState()) {
                  await firestoreInstance
                      .collection('Posts')
                      .doc(post.postID)
                      .collection("Replies")
                      .doc(replyId)
                      .collection("Replies")
                      .doc("*TotalReplies")
                      .set(
                    {"total_replies": 0},
                  ).catchError((error) {
                    _errorAlert.setErrorState(true);
                  }).whenComplete(() {
                    if (!_errorAlert.getErrorState()) {
                      Reply newReply = Reply();
                      newReply.body = body;
                      newReply.userId =
                          _internalProfileService.getAccount().databaseID;
                      newReply.replyId = replyId;
                      newReply.time = _time;

                      newReply.replies = List<Reply>();
                      for (int i = 0; i < imgList.length; i++) {
                        newReply.imgs.add(imgList[i]);
                      }
                      for (int i = 0; i < vidList.length; i++) {
                        newReply.vids.add(vidList[i]);
                      }
                      for (int i = 0; i < filesList.length; i++) {
                        newReply.files.add(filesList[i]);
                      }
                      log.d("Adding reply to post");
                      post.replies.add(newReply);

                      _loadingAlert.dismissDialog();
                      _successAlert.showDialog();
                      log.i('Reply created in database');
                    } else {
                      _loadingAlert.dismissDialog();
                      _errorAlert.showDialog();
                    }
                  }).timeout(Duration(seconds: 5), onTimeout: () {
                    log.d("timeout");
                    _errorAlert.setErrorState(true);
                    _loadingAlert.dismissDialog();
                    _errorAlert.showDialog();
                  });
                } else {
                  _loadingAlert.dismissDialog();
                  _errorAlert.showDialog();
                }
              },
            );
          } else {
            _loadingAlert.dismissDialog();
            _errorAlert.showDialog();
          }
        },
      );
    }
  }

  Future createReplyToReply({
    @required String body,
    @required BuildContext context,
    @required Reply reply,
    @required Post post,
    List<PickedFile> imgs,
    List<PickedFile> vids,
    List<PlatformFile> files,
  }) async {
    createDialogs(context: context, reply: true);

    _loadingAlert.showDialog();

    Timestamp _time = new Timestamp.now();

    int _totalReplies = await getTotalRepliesToReplies(
        postId: post.postID, replyId: reply.replyId);
    String replyId = (_totalReplies + 1).toString();

    if (!_errorAlert.getErrorState()) {
      await firestoreInstance
          .collection("Posts")
          .doc(post.postID)
          .collection("Replies")
          .doc(reply.replyId)
          .collection("Replies")
          .doc("*TotalReplies")
          .set({"total_replies": _totalReplies + 1}).catchError((error) {
        _errorAlert.setErrorState(true);
      }).whenComplete(
        () async {
          if (!_errorAlert.getErrorState()) {
            log.d("Total Replies count updated");
            await firestoreInstance
                .collection('Posts')
                .doc(post.postID)
                .collection("Replies")
                .doc(reply.replyId)
                .collection("Replies")
                .doc(replyId)
                .set({
              "replyId": replyId,
              "userId": _internalProfileService.getAccountDatabaseID(),
              "body": body,
              "time": _time,
              "edited": false,
            }).catchError((error) {
              _errorAlert.setErrorState(true);
            }).whenComplete(() async {
              if (!_errorAlert.getErrorState()) {
                await firestoreInstance
                    .collection('Posts')
                    .doc(post.postID)
                    .collection("Replies")
                    .doc(reply.replyId)
                    .update({
                  "total_replies": _totalReplies + 1,
                }).catchError((error) {
                  _errorAlert.setErrorState(true);
                }).whenComplete(() {
                  if (!_errorAlert.getErrorState()) {
                    reply.totalReplies += 1;

                    Reply newReply = Reply();
                    newReply.body = body;
                    newReply.userId =
                        _internalProfileService.getAccount().databaseID;
                    newReply.replyId = replyId;
                    newReply.time = _time;

                    log.d("Adding reply to reply");
                    reply.replies.add(newReply);

                    _loadingAlert.dismissDialog();
                    _successAlert.showDialog();
                    log.i('Reply created in database');
                  } else {
                    _loadingAlert.dismissDialog();
                    _errorAlert.showDialog();
                  }
                });
              } else {
                _loadingAlert.dismissDialog();
                _errorAlert.showDialog();
              }
            }).timeout(Duration(seconds: 5), onTimeout: () {
              log.d("timeout");
              _errorAlert.setErrorState(true);
              _loadingAlert.dismissDialog();
              _errorAlert.showDialog();
            });
          } else {
            _loadingAlert.dismissDialog();
            _errorAlert.showDialog();
          }
        },
      );
    } else {
      _loadingAlert.dismissDialog();
      _errorAlert.showDialog();
    }
  }

  Future launchURL(
      {@required String url, @required BuildContext context}) async {
    createDialogs(context: context, reply: true);

    _loadingAlert.showDialog();
    if (await canLaunch(url)) {
      await launch(url);
      _loadingAlert.dismissDialog();
    } else {
      _loadingAlert.dismissDialog();
      _errorAlert.showDialog();
      throw 'Could not launch $url';
    }
  }

  Future<InternalUser> getUserByPhoneNumber(
      {@required String mobile, @required BuildContext context}) async {
    log.d("Get Users");
    createDialogs(context: context);
    InternalUser user = InternalUser();

    _loadingAlert.showDialog();
    await firestoreInstance
        .collection('Accounts')
        .where("mobile", isEqualTo: mobile)
        .get()
        .then((value) {
          if (value.size > 0) {
            if (value.docs[0].get("databaseID") !=
                _internalProfileService.getAccountDatabaseID()) {
              user.databaseID = value.docs[0].get("databaseID");
              user.name = value.docs[0].get("name");
              user.profilePic = value.docs[0].get("profilePic");
              user.role = value.docs[0].get("role");
              user.mobile = value.docs[0].get("mobile");
            }
          } // log.d("Retrieving Accounts - Count: " + users.length.toString());
        })
        .catchError((error) => _errorAlert.setErrorState(true))
        .whenComplete(() {
          _loadingAlert.dismissDialog();
          if (_errorAlert.getErrorState()) {
            _errorAlert.showDialog();
          }
        });
    return user;
  }

  Future createAnnouncement({
    @required String body,
    @required BuildContext context,
    PickedFile img,
    PickedFile vid,
    List<AttachedFile> files,
    double size,
  }) async {
    PostsService _postsService = locator<PostsService>();
    Map<String, List<String>> fileObjects = {};
    List<AttachedFile> filesList = new List();
    AttachedImage image;
    AttachedVideo video;

    createDialogs(context: context, announcement: true);

    _loadingAlert.showDialog();

    Timestamp _time = new Timestamp.now();

    await setTotalAnnouncements();
    String announcementId = (_totalAnnouncements + 1).toString();

    log.d(announcementId);

    if (files != null) {
      for (int i = 0; i < files.length; i++) {
        await _storeAnnouncementFiles(
                file: files[i],
                linkedAnnouncement: announcementId,
                itemIndex: i)
            .catchError((error) {
          _errorAlert.setErrorState(true);
        }).then(
          (value) async {
            if (!_errorAlert.getErrorState()) {
              AttachedFile newFile = new AttachedFile();

              newFile.fileId = i.toString();
              newFile.name = files[i].name;
              newFile.fileSize = files[i].fileSize.toString();
              newFile.filetype = files[i].filetype;
              newFile.fileURL = value;
              filesList.add(newFile);
            }
          },
        );
      }

      for (AttachedFile item in filesList) {
        fileObjects.putIfAbsent(item.fileId,
            () => [item.name, item.fileSize, item.fileURL, item.filetype]);
      }
    }
    if (img != null) {
      await _storeAnnouncementImage(
              img: img, linkedAnnouncement: announcementId)
          .catchError((error) {
        _errorAlert.setErrorState(true);
      }).then(
        (value) async {
          if (!_errorAlert.getErrorState()) {
            image = new AttachedImage();
            image.imgId = "0";
            image.size = ((await getFileSize(img.path)) / 1000).toString();
            image.path = value;
            image.local = true;
          }
        },
      );
    }

    if (vid != null) {
      await _storeAnnouncementVideo(
        vid: vid,
        linkedAnnouncement: announcementId,
      ).catchError((error) {
        _errorAlert.setErrorState(true);
      }).then(
        (value) async {
          if (!_errorAlert.getErrorState()) {
            video = new AttachedVideo();
            video.vidId = "0";
            video.size = (await getFileSize(vid.path) / 1000).toString();
            video.path = value;
          }
        },
      );
    }
    if (!_errorAlert.getErrorState()) {
      await firestoreInstance
          .collection("Announcements")
          .doc("*TotalAnnouncements")
          .set({"total_announcements": _totalAnnouncements + 1}).catchError(
              (error) {
        _errorAlert.setErrorState(true);
      }).whenComplete(
        () async {
          if (!_errorAlert.getErrorState()) {
            log.d("Total Announcement count updated");
            await firestoreInstance
                .collection('Announcements')
                .doc(announcementId)
                .set({
              "announcementId": announcementId,
              "userId": _internalProfileService.getAccountDatabaseID(),
              "body": body,
              "files": fileObjects,
              "img": image != null ? [image.path, image.size] : [],
              "vid": video != null ? [video.path, video.size] : [],
              "time": _time,
              "size": size,
              "edited": false,
            }).catchError((error) {
              _errorAlert.setErrorState(true);
            }).whenComplete(() async {
              if (!_errorAlert.getErrorState()) {
                Announcement newAnnouncement = Announcement();
                newAnnouncement.announcementId = announcementId;
                newAnnouncement.text = body;
                newAnnouncement.userId =
                    _internalProfileService.getAccount().databaseID;
                newAnnouncement.files = filesList;
                newAnnouncement.time = _time;
                newAnnouncement.img = image;
                newAnnouncement.vid = video;

                log.d("Adding Announcement");

                _postsService.addAnnouncement(newAnnouncement);

                _loadingAlert.dismissDialog();
                _successAlert.showDialog();
                log.i('Announcement created in database');
              } else {
                _loadingAlert.dismissDialog();
                _errorAlert.showDialog();
              }
            }).timeout(Duration(seconds: 5), onTimeout: () {
              log.d("timeout");
              _errorAlert.setErrorState(true);
              _loadingAlert.dismissDialog();
              _errorAlert.showDialog();
            });
          } else {
            _loadingAlert.dismissDialog();
            _errorAlert.showDialog();
          }
        },
      );
    } else {
      _loadingAlert.dismissDialog();
      _errorAlert.showDialog();
    }
  }

  Future<String> _storeAnnouncementFiles(
      {@required AttachedFile file,
      @required String linkedAnnouncement,
      @required int itemIndex}) async {
    log.d("Starting File Storing Process");
    final savedFile = File(file.fileURL);
    if (await savedFile.exists()) {
      //Store File to Storage
      StorageTaskSnapshot snapshot = await storage
          .ref()
          .child("Announcements/Files/" +
              file.name +
              "_$linkedAnnouncement" +
              "($itemIndex)." +
              file.filetype)
          .putFile(savedFile)
          .onComplete
          .timeout(Duration(seconds: 10), onTimeout: () {
        log.d("timeout");
        return null;
      });
      log.d("File stored");
      return await snapshot.ref.getDownloadURL();
    } else {
      log.d("File already in db");
      return file.fileURL;
    }
  }

  Future<String> _storeAnnouncementImage({
    @required PickedFile img,
    @required String linkedAnnouncement,
  }) async {
    log.d("Starting Image Storing Process");

    final savedFile = File(img.path);

    if (await savedFile.exists()) {
      //Store Image to Storage
      StorageTaskSnapshot snapshot = await storage
          .ref()
          .child("Announcements/Media/Imgs/$linkedAnnouncement")
          .putFile(savedFile)
          .onComplete
          .timeout(Duration(seconds: 10), onTimeout: () {
        log.d("timeout");
        return null;
      });
      log.d("Image stored");
      return await snapshot.ref.getDownloadURL();
    } else {
      log.d("Image already exists in DB");
      return img.path;
    }
  }

  Future _storeAnnouncementVideo({
    @required PickedFile vid,
    @required String linkedAnnouncement,
  }) async {
    log.d("Starting File Storing Process");
    final savedFile = File(vid.path);

    if (await savedFile.exists()) {
      //Store Video to Storage
      StorageTaskSnapshot snapshot = await storage
          .ref()
          .child("Announcements/Media/Vids/$linkedAnnouncement")
          .putFile(savedFile)
          .onComplete
          .timeout(Duration(seconds: 10), onTimeout: () {
        log.d("timeout");
        return null;
      });
      log.d("Video stored");
      return await snapshot.ref.getDownloadURL();
    } else {
      log.d("Video already in DB");
      return vid.path;
    }
  }

  Future setTotalAnnouncements() async {
    await firestoreInstance
        .collection('Announcements')
        .doc("*TotalAnnouncements")
        .get()
        .then((value) {
      _totalAnnouncements = value.get("total_announcements");
      log.d(_totalAnnouncements);
    }).catchError((error) {
      _totalAnnouncements = 0;
    });
    log.d("Total Posts set: " + _totalAnnouncements.toString());
  }

  Future deleteReplyToPost(
      {@required BuildContext context,
      @required Post post,
      @required Reply reply}) async {
    final PostsService _postsService = locator<PostsService>();
    createDialogs(context: context, deleteReply: true);
    _loadingAlert.showDialog();

    if (reply.replies.length == 0) {
      await firestoreInstance
          .collection('Posts')
          .doc(post.postID)
          .collection("Replies")
          .doc(reply.replyId)
          .collection("Replies")
          .doc("*TotalReplies")
          .delete()
          .catchError((error) {
        _errorAlert.setErrorState(true);
      }).whenComplete(() async {
        await firestoreInstance
            .collection('Posts')
            .doc(post.postID)
            .collection("Replies")
            .doc(reply.replyId)
            .delete()
            .catchError((error) {
          _errorAlert.setErrorState(true);
        }).whenComplete(() async {
          _loadingAlert.dismissDialog();
          if (!_errorAlert.getErrorState()) {
            _postsService.getPost(postId: post.postID).replies.remove(reply);
            _successAlert.showDialog();
          } else {
            _errorAlert.showDialog();
          }
        });
      });
    } else {
      await firestoreInstance
          .collection('Posts')
          .doc(post.postID)
          .collection("Replies")
          .doc(reply.replyId)
          .update({
        "body": "[Deleted Reply]",
        "files": {},
        "imgs": {},
        "vids": {},
        "user": "0",
      }).catchError((error) {
        _errorAlert.setErrorState(true);
      }).whenComplete(() {
        _loadingAlert.dismissDialog();
        if (!_errorAlert.getErrorState()) {
          reply.body = "[Deleted Reply]";
          reply.userId = "0";
          _successAlert.showDialog();
        } else {
          _errorAlert.showDialog();
        }
      });
    }
  }

  Future deleteReplyToReply(
      {@required BuildContext context,
      @required Post post,
      @required Reply mainReply,
      @required Reply childReply}) async {
    createDialogs(context: context, deleteReply: true);
    _loadingAlert.showDialog();
    await firestoreInstance
        .collection('Posts')
        .doc(post.postID)
        .collection("Replies")
        .doc(mainReply.replyId)
        .collection("Replies")
        .doc(childReply.replyId)
        .delete()
        .catchError((error) {
      _errorAlert.setErrorState(true);
    }).whenComplete(() async {
      if (!_errorAlert.getErrorState()) {
        await firestoreInstance
            .collection('Posts')
            .doc(post.postID)
            .collection("Replies")
            .doc(mainReply.replyId)
            .update({"total_replies": mainReply.totalReplies - 1}).catchError(
                (error) {
          _errorAlert.setErrorState(true);
        }).whenComplete(() {
          _loadingAlert.dismissDialog();
          if (!_errorAlert.getErrorState()) {
            mainReply.replies.remove(childReply);
            mainReply.totalReplies -= 1;
            _successAlert.showDialog();
          } else {
            _errorAlert.showDialog();
          }
        });
      }
    });
  }
}
