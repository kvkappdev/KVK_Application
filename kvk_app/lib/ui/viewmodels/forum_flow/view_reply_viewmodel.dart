import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/data_struct/post.dart';
import 'package:kvk_app/data_struct/reply.dart';
import 'package:kvk_app/data_struct/internalUser.dart';
import 'package:kvk_app/services/database_service.dart';
import 'package:kvk_app/services/internal_profile_service.dart';
import 'package:kvk_app/services/posts_service.dart';
import 'package:kvk_app/ui/smart_widgets/screen_arguments.dart';
import 'package:kvk_app/ui/templates/kvk_viewmodel.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:video_player/video_player.dart';

class ViewReplyViewModel extends KVKViewModel {
  final log = getLogger("View Post Viewmodel");
  final DatabaseService _databaseService = locator<DatabaseService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final InternalProfileService _internalProfileService =
      locator<InternalProfileService>();
  final PostsService _postsService = locator<PostsService>();

  List<VideoPlayerController> _videoPlayerControllers =
      List<VideoPlayerController>();
  List<Future<void>> _initialiseVideoPlayerFutures = List<Future<void>>();

  bool loaded = false;

  String getPostTime(Timestamp timestamp) {
    DateTime _timestamp = timestamp.toDate();
    String postTime = _timestamp.day.toString() + " ";
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
    log.d(postTime);
    return postTime;
  }

  bool isMyPost({@required ScreenArguments args}) {
    return args.reply.userId != _internalProfileService.getAccountDatabaseID();
  }

  Future createReplyToReply(
      {@required String body,
      @required ScreenArguments args,
      @required BuildContext context}) async {
    await _databaseService.createReplyToReply(
        body: body, context: context, reply: args.reply, post: args.post);
  }

  InternalUser getUser({@required String userId}) {
    return _postsService.getUser(userId: userId);
  }

  Future loadRepliesToReplies(
      {@required Reply reply, @required Post post}) async {
    log.d("Replies to Replies");
    await _databaseService
        .getRepliesToReplies(post: post, reply: reply)
        .then((value) {
      value.sort((a, b) {
        return a.time.compareTo(b.time);
      });

      reply.replies = value;
    });
  }

  void viewAttachments({@required ScreenArguments args, Reply reply}) {
    // log.d(args.post.files.length);
    _navigationService.navigateTo(Routes.viewAttachmentsView,
        arguments: ScreenArguments(
            reply: reply,
            routeFrom: Routes.viewReplyView,
            post: args.post,
            oldArgs: args));
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

  List<VideoPlayerController> getControllers() {
    return _videoPlayerControllers;
  }

  List<Future<void>> getVideoFutures() {
    return _initialiseVideoPlayerFutures;
  }

  void loadArgs({@required ScreenArguments args}) async {
    for (int i = 0; i < args.post.replies.length; i++) {
      for (int j = 0; j < args.post.replies[i].vids.length; j++) {
        _videoPlayerControllers.add(
            VideoPlayerController.network(args.post.replies[i].vids[j].path));
        _initialiseVideoPlayerFutures.add(_videoPlayerControllers.last
            .initialize()
            .then((value) => rebuild()));
      }
    }

    loaded = true;
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
            ScreenArguments(routeFrom: Routes.viewReplyView, oldArgs: args));
  }

  bool canIEdit({Reply mainReply, Reply childReply}) {
    if (_internalProfileService.getRole() == 2) {
      return true;
    }

    if (childReply != null) {
      log.d(childReply.userId);
      if (childReply.userId == _internalProfileService.getAccountDatabaseID()) {
        return true;
      }
    } else {
      if (mainReply.userId == _internalProfileService.getAccountDatabaseID()) {
        return true;
      }
    }
    return false;
  }

  void edit(
      {Post post, Reply mainReply, Reply childReply, ScreenArguments args}) {
    if(childReply != null){
    log.d(mainReply);
         _navigationService.navigateTo(Routes.editReplyToReplyView,
            arguments: ScreenArguments(
                reply: mainReply,
                childReply: childReply,
                post: post,
                oldArgs: args));
     }else{ _navigationService.navigateTo(Routes.editReplyView,
            arguments: ScreenArguments(
                reply: mainReply,
                routeFrom: Routes.viewReplyView,
                post: post,
                oldArgs: args));
     }
  }

  Future deleteReply(
      {@required BuildContext context,
      @required Post post,
      @required Reply reply}) async {
    await _databaseService
        .deleteReplyToPost(context: context, post: post, reply: reply)
        .whenComplete(() {
      rebuild();
    });
  }

  Future deleteReplytoReply(
      {@required BuildContext context,
      @required Post post,
      @required Reply reply,
      @required Reply childReply}) async {
    await _databaseService
        .deleteReplyToReply(
            context: context,
            post: post,
            mainReply: reply,
            childReply: childReply)
        .whenComplete(() {
      rebuild();
    });
  }
}
