import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/data_struct/post.dart';
import 'package:kvk_app/data_struct/topic.dart';
import 'package:kvk_app/services/database_service.dart';
import 'package:kvk_app/services/internal_profile_service.dart';
import 'package:kvk_app/services/navBar_Service.dart';
import 'package:kvk_app/services/posts_service.dart';
import 'package:kvk_app/services/topic_service.dart';
import 'package:kvk_app/ui/smart_widgets/screen_arguments.dart';
import 'package:kvk_app/ui/templates/kvk_viewmodel.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:video_player/video_player.dart';

class ProfileViewModel extends KVKViewModel {
  final InternalProfileService _internalProfileService =
      locator<InternalProfileService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final PostsService _postsService = locator<PostsService>();
  final log = getLogger("Profile View Model");
  final DatabaseService _databaseService = locator<DatabaseService>();
  final TopicService _topicService = locator<TopicService>();

  bool getUserHasProfile() {
    return _internalProfileService.getHasProfile();
  }

  String getUserName() {
    if (_internalProfileService.getName() != null) {
      return _internalProfileService.getName();
    }
    return "";
  }

  void editProfile() {
    _navigationService.navigateTo(Routes.editProfileView);
  }

  String getUserRole() {
    switch (_internalProfileService.getRole()) {
      case 0:
        return lang().userType[0];
      case 1:
        return lang().userType[1];
      case 2:
        return lang().userType[2];
      default:
        return lang().userType[3];
    }
  }

  Image getPic() {
    if (_internalProfileService.getProfilePic() != null) {
      return _internalProfileService.getProfilePic();
    }
    return new Image.asset(
      "assets/img/blank_profile.png",
    );
  }

  Topic getTopicByPost({@required Post post}) {
    for (int i = 0; i < _topicService.getTopics().length; i++) {
      if (_topicService.getTopics()[i].id == post.categoryId) {
        return _topicService.getTopics()[i];
      }
    }
    return _topicService.getTopics()[0];
  }

  List<Post> getMyPosts() {
    return _postsService.getMyPosts();
  }

  Future loadData() async {
    if (_postsService.getMyPosts() == null)
      await _postsService.getMyPostsData();
  }

  void viewPost(int index) {
    _navigationService.navigateTo(Routes.viewPostView,
        arguments: ScreenArguments(
            account: _internalProfileService.getAccount(),
            post: _postsService.getMyPosts()[index],
            routeFrom: Routes.profileView));
  }

  String getPostTime(int index) {
    DateTime timestamp = _postsService.getMyPosts()[index].time.toDate();
    String postTime = timestamp.day.toString() + " ";
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
    log.d(postTime);
    return postTime;
  }

  void loadMore() async {
    await _postsService.loadMoreMyPosts().whenComplete(() {
      rebuild();
    });
  }

  void refreshProfile({@required BuildContext context}) async {
    await _databaseService
        .refreshRole(
            userId: _internalProfileService.getAccountDatabaseID(),
            context: context)
        .whenComplete(() => rebuild());
  }

  Future<bool> onBackPressed() async {
    NavBarService _navBarService = locator<NavBarService>();
    _navBarService.setCurrentIndex(0);
    await _navigationService
        .pushNamedAndRemoveUntil(Routes.homeView)
        .whenComplete(() {
      return true;
    });
    return false;
  }
}
