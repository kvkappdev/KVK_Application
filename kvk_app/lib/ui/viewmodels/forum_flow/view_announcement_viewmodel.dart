import 'package:async/async.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/data_struct/announcement.dart';
import 'package:kvk_app/data_struct/attachedVideo.dart';
import 'package:kvk_app/data_struct/post.dart';
import 'package:kvk_app/data_struct/reply.dart';
import 'package:kvk_app/data_struct/internalUser.dart';
import 'package:kvk_app/services/database_service.dart';
import 'package:kvk_app/services/internal_profile_service.dart';
import 'package:kvk_app/services/navBar_Service.dart';
import 'package:kvk_app/services/posts_service.dart';
import 'package:kvk_app/ui/smart_widgets/screen_arguments.dart';
import 'package:kvk_app/ui/templates/kvk_viewmodel.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:video_player/video_player.dart';

class ViewAnnouncementViewModel extends KVKViewModel {
  final log = getLogger("View Post Viewmodel");
  final DatabaseService _databaseService = locator<DatabaseService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final InternalProfileService _internalProfileService =
      locator<InternalProfileService>();
  final PostsService _postsService = locator<PostsService>();
  AsyncMemoizer _memoizer = AsyncMemoizer();

  List<VideoPlayerController> _videoPlayerControllers =
      List<VideoPlayerController>();
  List<Future<void>> _initialiseVideoPlayerFutures = List<Future<void>>();

  bool loaded = false;

  List<Announcement> getAnnouncements() {
    return _postsService.getAnnouncements();
  }

  Announcement getAnnouncement({@required int index}) {
    return _postsService.getAnnouncement(index: index);
  }

  String getPostTime(Timestamp timestamp) {
    DateTime _timestamp = timestamp.toDate();
    String postTime = _timestamp.day.toString().padLeft(2, "0") + " ";
    switch (_timestamp.month) {
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
    postTime += " " + _timestamp.year.toString();

    postTime += ", " +
        _timestamp.hour.toString().padLeft(2, "0") +
        ":" +
        _timestamp.minute.toString().padLeft(2, "0");
    return postTime;
  }

  void viewImage() {}

  InternalUser getUser({@required String userId}) {
    return _postsService.getUser(userId: userId);
  }

  void viewReply(
      {@required Reply reply,
      @required InternalUser user,
      @required ScreenArguments args}) {
    loaded = false;
    _navigationService.navigateTo(Routes.viewReplyView,
        arguments: ScreenArguments(
            reply: reply,
            account: user,
            routeFrom: Routes.viewPostView,
            post: args.post,
            oldArgs: args));
  }

  void viewAttachments(
      {@required ScreenArguments args, Announcement announcement}) {
    _navigationService.navigateTo(Routes.viewAttachmentsView,
        arguments: ScreenArguments(
            announcement: announcement,
            routeFrom: Routes.viewAnnouncementView,
            oldArgs: args));
  }

  List<VideoPlayerController> getControllers() {
    return _videoPlayerControllers;
  }

  List<Future<void>> getVideoFutures() {
    return _initialiseVideoPlayerFutures;
  }

  void loadArgs() async {
    for (int i = 0; i < _postsService.getAnnouncements().length; i++) {
      if (_postsService.getAnnouncement(index: i).vid != null) {
        _videoPlayerControllers.add(VideoPlayerController.network(
            _postsService.getAnnouncement(index: i).vid.path));
        _initialiseVideoPlayerFutures.add(_videoPlayerControllers.last
            .initialize()
            .then((value) => rebuild()));
      }
    }
    loaded = true;
  }

  bool canIEdit({@required Announcement announcement}) {
    if (_internalProfileService.getRole() == 2) {
      return true;
    }
    if (announcement.userId == _internalProfileService.getAccountDatabaseID()) {
      return true;
    }

    return false;
  }

  void edit({@required Announcement announcement}) {
    _navigationService.navigateTo(Routes.editAnnouncementView,
        arguments: ScreenArguments(announcement: announcement));
  }

  void navigateToLongReply({@required ScreenArguments screenArguments}) {
    _navigationService.navigateTo(Routes.createReplyView,
        arguments: ScreenArguments(
            routeFrom: Routes.viewPostView,
            post: screenArguments.post,
            oldArgs: screenArguments));
  }

  Future deleteAnnouncement(
      {@required BuildContext context,
      @required Announcement announcement}) async {
    await _databaseService
        .deleteAnnouncement(context: context, announcement: announcement)
        .whenComplete(() => rebuild());
  }

  void togglePlay({@required VideoPlayerController controller}) {
    if (controller.value.position == controller.value.duration) {
      controller.seekTo(Duration.zero);
      controller.pause();
    }
    if (controller.value.isPlaying) {
      log.d("Pause video");
      controller.pause();
    } else {
      log.d("Play video");
      controller.play();
    }
  }

  void loadMore() async {
    await _postsService.loadMoreAnnouncements().whenComplete(() {
      loaded = false;
      rebuild();
    });
  }

  bool getHasProfile() {
    if (_internalProfileService.getHasProfile()) {
      return true;
    }
    return false;
  }

  void navigateToFeatureLocked({@required ScreenArguments args}) {
    _navigationService.navigateTo(Routes.featureLockedView,
        arguments:
            ScreenArguments(routeFrom: Routes.viewPostView, oldArgs: args));
  }

   Future<bool> onBackPressed() async {
    NavBarService _navBarService = locator<NavBarService>();
    _navBarService.setCurrentIndex(0);
    await _navigationService.pushNamedAndRemoveUntil(Routes.homeView).whenComplete(() {
      return true;
    });
    return false;
  }
}
