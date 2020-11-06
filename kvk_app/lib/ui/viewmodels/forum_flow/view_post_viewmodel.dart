import 'package:async/async.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/data_struct/attachedVideo.dart';
import 'package:kvk_app/data_struct/post.dart';
import 'package:kvk_app/data_struct/reply.dart';
import 'package:kvk_app/data_struct/internalUser.dart';
import 'package:kvk_app/data_struct/topic.dart';
import 'package:kvk_app/services/database_service.dart';
import 'package:kvk_app/services/internal_profile_service.dart';
import 'package:kvk_app/services/posts_service.dart';
import 'package:kvk_app/services/topic_service.dart';
import 'package:kvk_app/ui/smart_widgets/screen_arguments.dart';
import 'package:kvk_app/ui/templates/kvk_viewmodel.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:video_player/video_player.dart';

class ViewPostViewModel extends KVKViewModel {
  final log = getLogger("View Post Viewmodel");
  final DatabaseService _databaseService = locator<DatabaseService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final InternalProfileService _internalProfileService =
      locator<InternalProfileService>();
  final PostsService _postsService = locator<PostsService>();
  final TopicService _topicService = locator<TopicService>();
  AsyncMemoizer _memoizer = AsyncMemoizer();

  List<VideoPlayerController> _videoPlayerControllers =
      List<VideoPlayerController>();
  List<Future<void>> _initialiseVideoPlayerFutures = List<Future<void>>();

  bool loaded = false;

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

  void subscribe({@required Post post}) async {
    log.d("Attempting to subscribe");
    await _databaseService
        .subscribeToPost(
            _internalProfileService.getAccount().databaseID, post.postID)
        .then((value) => rebuild());
    post.subscribed = true;
  }

  void unsubscribe({@required Post post}) async {
    log.d("Attempting to subscribe");
    await _databaseService
        .unsubscribeFromPost(
            _internalProfileService.getAccount().databaseID, post.postID)
        .then((value) => rebuild());
    post.subscribed = false;
  }

  bool subscribed({@required ScreenArguments args}) {
    if (_internalProfileService
        .getSubscribedPostsIds()
        .contains(args.post.postID)) {
      return true;
    }
    return false;
  }

  bool isMyPost({@required ScreenArguments args}) {
    return args.post.userId != _internalProfileService.getAccountDatabaseID();
  }

  Future createReply({
    @required String body,
    @required ScreenArguments args,
    @required BuildContext context,
  }) async {
    await _databaseService
        .createReplyToPost(
            routeFrom: Routes.viewPostView,
            screenArguments: args,
            //TODO: Unsure
            isLongReply: false,
            body: body,
            context: context,
            post: args.post)
        .whenComplete(() => rebuild());
  }

  InternalUser getUser({@required String userId}) {
    return _postsService.getUser(userId: userId);
  }

  Future loadReplies({@required Post post}) async {
    return this._memoizer.runOnce(() async {
      log.d("Replies");
      await _databaseService.getReplies(post: post).then((value) async {
        value.sort((a, b) {
          return a.time.compareTo(b.time);
        });

        post.replies = value;
      });
    });
  }

  
  Topic getTopicByPost({@required Post post}){
    for(int i=0; i<_topicService.getTopics().length; i++){
      if(_topicService.getTopics()[i].id==post.categoryId){
        return _topicService.getTopics()[i];
      }
    }
    return _topicService.getTopics()[0];
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

  void viewAttachments({@required ScreenArguments args, Reply reply}) {
    _navigationService.navigateTo(Routes.viewAttachmentsView,
        arguments: ScreenArguments(
            reply: reply,
            routeFrom: Routes.viewPostView,
            post: args.post,
            oldArgs: args));
  }

  List<VideoPlayerController> getControllers() {
    return _videoPlayerControllers;
  }

  List<Future<void>> getVideoFutures() {
    return _initialiseVideoPlayerFutures;
  }

  void loadArgs({@required ScreenArguments args}) async {
    for (int i = 0; i < args.post.vids.length; i++) {
      _videoPlayerControllers
          .add(VideoPlayerController.network(args.post.vids[i].path));
      _initialiseVideoPlayerFutures.add(
          _videoPlayerControllers.last.initialize().then((value) => rebuild()));
    }

    loaded = true;
  }

  bool canIEdit({Post post, Reply reply}) {
    if (_internalProfileService.getRole() == 2) {
      return true;
    }

    if (reply != null) {
      log.d(reply.userId);
      if (reply.userId == _internalProfileService.getAccountDatabaseID()) {
        return true;
      } else {
        return false;
      }
    }

    if (post != null) {
      if (post.userId == _internalProfileService.getAccountDatabaseID()) {
        return true;
      }
    }
    
    return false;
  }

  void edit({Post post, Reply reply, @required ScreenArguments args}) {
    reply != null
        ? _navigationService.navigateTo(Routes.editReplyView,
            arguments: ScreenArguments(
                reply: reply,
                post: post,
                routeFrom: Routes.viewPostView,
                oldArgs: args))
        : _navigationService.navigateTo(Routes.editPostView,
            arguments: ScreenArguments(
                post: post, routeFrom: Routes.viewPostView, oldArgs: args));
  }

  void navigateToLongReply({@required ScreenArguments screenArguments}) {
    _navigationService.navigateTo(Routes.createReplyView,
        arguments: ScreenArguments(
            routeFrom: Routes.viewPostView,
            post: screenArguments.post,
            oldArgs: screenArguments));
  }

  Future deletePost(
      {@required BuildContext context, @required Post post}) async {
    await _databaseService.deletePost(context: context, post: post);
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

  Future<bool> onBackPressed({@required String routeFrom}) async {
    log.d(routeFrom);
    await _navigationService
        .pushNamedAndRemoveUntil(routeFrom)
        .whenComplete(() {
      return true;
    });
    return false;
  }
}
