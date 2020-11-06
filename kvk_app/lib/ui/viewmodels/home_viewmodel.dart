import 'package:flutter/material.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/data_struct/announcement.dart';
import 'package:kvk_app/data_struct/post.dart';
import 'package:kvk_app/data_struct/internalUser.dart';
import 'package:kvk_app/data_struct/topic.dart';
import 'package:kvk_app/services/authentication_service.dart';
import 'package:kvk_app/services/database_service.dart';
import 'package:kvk_app/services/internal_profile_service.dart';
import 'package:kvk_app/services/posts_service.dart';
import 'package:kvk_app/services/topic_service.dart';
import 'package:kvk_app/ui/smart_widgets/screen_arguments.dart';
import 'package:kvk_app/ui/templates/kvk_viewmodel.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:video_player/video_player.dart';

class HomeViewModel extends KVKViewModel {
  final InternalProfileService _internalProfileService =
      locator<InternalProfileService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final PostsService _postsService = locator<PostsService>();
  final DatabaseService _databaseService = locator<DatabaseService>();
  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();
  final TopicService _topicService = locator<TopicService>();
  final log = getLogger("Home View Model");

  bool getUserHasProfile() {
    return _internalProfileService.getHasProfile();
  }

  List<Announcement> getAnnouncements() {
    return _postsService.getAnnouncements();
  }

  List<Post> getSubscribedPosts() {
    return _postsService.getSubscribedPosts();
  }

  Future loadAnnouncements() async {
    if (_postsService.getAnnouncements() == null) {
      await _postsService.loadAnnouncements();
    }
  }

  Future loadSubscribedPosts() async {
    if (_postsService.getSubscribedPosts() == null) {
      await _postsService.getSubscribedPostsData();
    }
  }

  String getPostName({@required String userId}) {
    return _postsService.getUser(userId: userId).name;
  }

  String getAnnouncementProfilePic({@required String userId}) {
    return _postsService.getUser(userId: userId).profilePic;
  }

  void viewPost(int index) {
    _navigationService.navigateTo(Routes.viewPostView,
        arguments: ScreenArguments(
            account: _postsService.getUser(
                userId: _postsService.getSubscribedPosts()[index].userId),
            post: _postsService.getSubscribedPosts()[index],
            routeFrom: Routes.homeView));
  }

  Topic getTopicByPost({@required Post post}) {
    for (int i = 0; i < _topicService.getTopics().length; i++) {
      if (_topicService.getTopics()[i].id == post.categoryId) {
        return _topicService.getTopics()[i];
      }
    }
    return _topicService.getTopics()[0];
  }

  String getPostTime({Post post, Announcement announcement}) {
    DateTime timestamp;
    if (post != null) {
      timestamp = post.time.toDate();
    } else {
      timestamp = announcement.time.toDate();
    }
    String postTime = timestamp.day.toString().padLeft(2, "0") + " ";
    switch (timestamp.month) {
      case 1:
        {
          postTime += "Jan";
        }
        break;
      case 2:
        {
          postTime += "Feb";
        }
        break;
      case 3:
        {
          postTime += "Mar";
        }
        break;
      case 4:
        {
          postTime += "Apr";
        }
        break;
      case 5:
        {
          postTime += "May";
        }
        break;
      case 6:
        {
          postTime += "Jun";
        }
        break;
      case 7:
        {
          postTime += "Jul";
        }
        break;
      case 8:
        {
          postTime += "Aug";
        }
        break;
      case 9:
        {
          postTime += "Sep";
        }
        break;
      case 10:
        {
          postTime += "Oct";
        }
        break;
      case 11:
        {
          postTime += "Nov";
        }
        break;
      case 12:
        {
          postTime += "Dec";
        }
        break;
      default:
        {
          postTime += "Unk";
        }
        break;
    }
    postTime += " " + timestamp.year.toString();
    if (announcement != null) {
      postTime += ", " +
          timestamp.hour.toString().padLeft(2, "0") +
          ":" +
          timestamp.minute.toString().padLeft(2, "0");
    }
    return postTime;
  }

  List<VideoPlayerController> getSubscribedPostsVidController() {
    List<VideoPlayerController> vidControllers = List<VideoPlayerController>();
    for (int i = 0; i < _postsService.getSubscribedPosts().length; i++) {
      for (int j = 0;
          j < _postsService.getSubscribedPosts()[i].vids.length;
          j++) {
        vidControllers.add(_postsService
            .getSubscribedPosts()[i]
            .vids[j]
            .videoPlayerController);
      }
    }
    return vidControllers;
  }

  InternalUser getAccount() {
    return _internalProfileService.getAccount();
  }

  void navigateToAnnouncementViewAll(
      {@required String routeFrom, int scrollIndex = 0}) {
    _navigationService.navigateTo(Routes.viewAnnouncementView,
        arguments:
            ScreenArguments(routeFrom: routeFrom, scrollIndex: scrollIndex));
  }

  void navigateToSubscribedPostsViewAll(
      {@required String routeFrom, int scrollIndex = 0}) {
    _navigationService.navigateTo(Routes.subscribedPostsView,
        arguments:
            ScreenArguments(routeFrom: routeFrom, scrollIndex: scrollIndex));
  }
}
