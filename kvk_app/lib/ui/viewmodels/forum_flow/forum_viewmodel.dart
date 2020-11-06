import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/data_struct/post.dart';
import 'package:kvk_app/data_struct/internalUser.dart';
import 'package:kvk_app/data_struct/topic.dart';
import 'package:kvk_app/services/database_service.dart';
import 'package:kvk_app/services/navBar_Service.dart';
import 'package:kvk_app/services/posts_service.dart';
import 'package:kvk_app/services/topic_service.dart';
import 'package:kvk_app/ui/smart_widgets/screen_arguments.dart';
import 'package:kvk_app/ui/templates/kvk_viewmodel.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:kvk_app/services/internal_profile_service.dart';

final log = getLogger("Forum Viewmodel");

class ForumViewModel extends KVKViewModel {
  final PostsService _postsService = locator<PostsService>();
  final DatabaseService _databaseService = locator<DatabaseService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final TopicService _topicService = locator<TopicService>();
  final InternalProfileService _internalProfileService =
      locator<InternalProfileService>();

  String getPostTime(int index, {bool latest = false, bool topic = false}) {
    DateTime timestamp;
    if (latest) {
      timestamp = _postsService.getLatestPosts()[index].time.toDate();
    }
    if (topic) {
      timestamp = getTopicPosts()[index].time.toDate();
    }
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
    return postTime;
  }

  List<Post> getPosts() {
    return _postsService.getLatestPosts();
  }

  Topic getTopic({@required String id}) {
    return _topicService.getTopicById(id: id);
  }

  InternalUser getPostAccount({@required String userId}) {
    return _postsService.getUser(userId: userId);
  }

  void viewLatestPost(int index) {
    _navigationService.navigateTo(Routes.viewPostView,
        arguments: ScreenArguments(
            account: _postsService.getUser(
                userId: _postsService.getLatestPosts()[index].userId),
            post: _postsService.getLatestPosts()[index],
            routeFrom: Routes.forumView));
  }

  void viewTopicPost({@required int index}) {
    _navigationService.navigateTo(Routes.viewPostView,
        arguments: ScreenArguments(
            account: _postsService.getUser(
                userId: _postsService
                    .getTopicPosts(
                        topicId: _topicService.getSelectedTopic().id)[index]
                    .userId),
            post: _postsService.getTopicPosts(
                topicId: _topicService.getSelectedTopic().id)[index],
            routeFrom: Routes.forumView));
  }

  List<String> getTopicNames() {
    List<String> topicNames = List<String>();
    for (int i = 0; i < _topicService.getTopics().length; i++) {
      langVal() == 0
          ? topicNames.add(_topicService.getTopics()[i].engName)
          : topicNames.add(_topicService.getTopics()[i].marName);
    }
    return topicNames;
  }

  Future loadData() async {
    if (_postsService.getLatestPosts() == null) await _postsService.getData();
  }

  void loadMore() async {
    await _postsService.loadMoreLatestPosts().whenComplete(() {
      rebuild();
    });
  }

  void loadMoreTopics() async {
    await _postsService.loadMoreTopicPosts().whenComplete(() {
      rebuild();
    });
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

  void setSelectedTopic({@required String topicName}) {
    _topicService.setSelectedTopic(topicName: topicName);
    rebuild();
  }

  Topic getSelectedTopic() {
    return _topicService.getSelectedTopic();
  }

  Topic getTopicByPost({@required Post post}) {
    for (int i = 0; i < _topicService.getTopics().length; i++) {
      if (_topicService.getTopics()[i].id == post.categoryId) {
        return _topicService.getTopics()[i];
      }
    }
    return _topicService.getTopics()[0];
  }

  Future loadTopicData() async {
    await _postsService.loadTopicPosts();
  }

  List<Post> getTopicPosts() {
    return _postsService.getTopicPosts(
        topicId: _topicService.getSelectedTopic().id);
  }

  bool isUserAdmin() {
    if (_internalProfileService.getRole() == 2) {
      return true;
    }
    return false;
  }
}
