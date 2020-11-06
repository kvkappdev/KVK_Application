import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/data_struct/announcement.dart';
import 'package:kvk_app/data_struct/attachedImage.dart';
import 'package:kvk_app/data_struct/attachedVideo.dart';
import 'package:kvk_app/data_struct/attachedFile.dart';
import 'package:kvk_app/data_struct/post.dart';
import 'package:kvk_app/data_struct/internalUser.dart';
import 'package:kvk_app/data_struct/topic.dart';
import 'package:kvk_app/services/database_service.dart';
import 'package:kvk_app/services/topic_service.dart';
import 'package:video_player/video_player.dart';

class PostsService {
  final log = getLogger("Posts Service");
  final DatabaseService _databaseService = locator<DatabaseService>();
  TopicService _topicService = locator<TopicService>();

  List<Post> _posts = new List<Post>();

  List<InternalUser> _users = new List<InternalUser>();
  List<Announcement> _announcements = new List<Announcement>();

  Future loadLatestPosts() async {
    await _databaseService.getPosts().then((value) {
      cacheLatestPost(value: value);
    });
    log.d("Document Count: " + _posts.length.toString());
  }

  List<Post> getPosts() {
    return _posts;
  }

  Future loadMoreLatestPosts() async {
    await _databaseService.loadMoreLatestPosts().then((value) {
      cacheLatestPost(value: value);
    });
    log.d("Document Count: " + _posts.length.toString());
  }

  void cacheLatestPost({@required QuerySnapshot value}) {
    for (int i = 0; i < value.docs.length; i++) {
      bool fileExists = false;
      for (int j = 0; j < _posts.length; j++) {
        if (_posts[j].postID == value.docs[i].get("postID")) {
          fileExists = true;
        }
      }
      if (!fileExists) {
        Post _newPost = new Post();
        _newPost.body = value.docs[i].get("body");
        _newPost.categoryId = value.docs[i].get("category");
        _newPost.postID = value.docs[i].get("postID");
        _newPost.time = value.docs[i].get("time");
        _newPost.title = value.docs[i].get("title");
        _newPost.size = value.docs[i].get("size");
        _newPost.userId = value.docs[i].get("user");
        _newPost.edited = value.docs[i].get("edited");

        List<AttachedImage> _imageList = List<AttachedImage>();

        Map<String, dynamic> _imgs = value.docs[i].get("imgs");
        _imgs.forEach((k, v) {
          List<dynamic> temp = v;
          List<String> result = temp.cast<String>();

          AttachedImage _newImage = AttachedImage();
          _newImage.imgId = k.toString();
          _newImage.path = result[0];
          _newImage.size = result[1];
          _imageList.add(_newImage);
        });

        List<AttachedVideo> _videoList = List<AttachedVideo>();

        Map<String, dynamic> _vids = value.docs[i].get("vids");
        _vids.forEach((k, v) {
          List<dynamic> temp = v;
          List<String> result = temp.cast<String>();

          AttachedVideo _newVideo = AttachedVideo();
          _newVideo.vidId = k.toString();
          _newVideo.path = result[0];
          _newVideo.size = result[1];
          _newVideo.videoPlayerController =
              VideoPlayerController.network(_newVideo.path);
          _newVideo.videoPlayerControllerFuture =
              _newVideo.videoPlayerController.initialize();
          _videoList.add(_newVideo);
        });

        List<AttachedFile> _filesList = List<AttachedFile>();

        Map<String, dynamic> files = value.docs[i].get("files");
        files.forEach((k, v) {
          List<dynamic> temp = v;
          List<String> result = temp.cast<String>();

          AttachedFile _newFile = AttachedFile();
          _newFile.fileId = k.toString();
          _newFile.name = result[0];
          _newFile.fileSize = result[1];
          _newFile.fileURL = result[2];
          _newFile.filetype = result[3];
          _filesList.add(_newFile);
        });

        _newPost.files = _filesList;
        _newPost.vids = _videoList;
        _newPost.imgs = _imageList;
        addPost(_newPost);
      }
    }
  }

  Post getPost({@required String postId}) {
    for (int i = 0; i < _posts.length; i++) {
      if (_posts[i].postID == postId) {
        return _posts[i];
      }
    }
    return Post();
  }

  List<InternalUser> getUsers() {
    return _users;
  }

  List<Post> getLatestPosts() {
    _posts.sort((a, b) {
      return b.time.compareTo(a.time);
    });
    return _posts;
  }

  List<Post> getTopicPosts({@required String topicId}) {
    List<Post> _topicPosts = List<Post>();
    for (int i = 0; i < _posts.length; i++) {
      if (getTopic(_posts[i].categoryId).id == topicId) {
        _topicPosts.add(_posts[i]);
      }
    }
    _topicPosts.sort((a, b) {
      return b.time.compareTo(a.time);
    });
    return _topicPosts;
  }

  Announcement getAnnouncement({@required int index}) {
    return _announcements[index];
  }

  Topic getTopic(String index) {
    for (int i = 0; i < _topicService.getTopics().length; i++) {
      if (_topicService.getTopics()[i].id == index) {
        return _topicService.getTopics()[i];
      }
    }
    return null;
  }

  Post getSubscribedPost({@required int index}) {
    List<Post> _subPosts = List<Post>();
    for (int i = 0; i < _posts.length; i++) {
      if (_posts[i].subscribed) {
        _subPosts.add(_posts[i]);
      }
    }
    return _subPosts[index];
  }

  List<Announcement> getAnnouncements() {
    _announcements.sort((a, b) {
      return b.time.compareTo(a.time);
    });

    return _announcements;
  }

  List<InternalUser> get names {
    return _users;
  }

  Future loadUsers() async {
    _users = await _databaseService.getUsers();
  }

  Future getData() async {
    await loadLatestPosts().whenComplete(() async {
      // await getLatestPostVideos();
      await loadUsers();
    });
  }

  void addAnnouncement(Announcement announcement) {
    if (announcement != null) _announcements.add(announcement);
  }

  void removeAnnouncement(Announcement announcement) {
    _announcements.remove(announcement);
  }

  void addPost(Post newPost) {
    if (newPost != null) _posts.add(newPost);
  }

  void addUser(InternalUser newUser) {
    if (newUser != null) _users.add(newUser);
  }

  void removePost(Post post) {
    _posts.remove(post);
  }

  InternalUser getUser({@required String userId}) {
    InternalUser _u;
    for (int i = 0; i < _users.length; i++) {
      if (_users[i].databaseID == userId) {
        _u = _users[i];
      }
    }
    return _u != null ? _u : new InternalUser();
  }

  Future getMyPostsData() async {
    await loadMyPosts().whenComplete(() async {
      // await getMyPostsVideos();
    });
  }

  Future getSubscribedPostsData() async {
    await loadSubscribedPosts().whenComplete(() async {
      // await getSubscribedPostsVideos();
    });
  }

  List<Post> getMyPosts() {
    List<Post> _myPosts = List<Post>();
    for (int i = 0; i < _posts.length; i++) {
      if (_posts[i].mine) {
        _myPosts.add(_posts[i]);
      }
    }
    _myPosts.sort((a, b) {
      return b.time.compareTo(a.time);
    });
    return _myPosts;
  }

  List<Post> getSubscribedPosts() {
    List<Post> _subscribedPosts = List<Post>();
    for (int i = 0; i < _posts.length; i++) {
      if (_posts[i].subscribed) {
        _subscribedPosts.add(_posts[i]);
      }
    }
    _subscribedPosts.sort((a, b) {
      return b.time.compareTo(a.time);
    });
    return _subscribedPosts;
  }

  void logoutCleanUp() {
    for (int i = 0; i < _posts.length; i++) {
      if (_posts[i].subscribed) {
        _posts[i].subscribed = false;
      }
      if (_posts[i].mine) {
        _posts[i].mine = false;
      }
    }
  }

  Future loadMyPosts() async {
    log.d("Retriving my posts");
    await _databaseService.getMyPosts().then((value) {
      cacheMyPosts(value: value);
    });
  }

  Future loadMoreMyPosts() async {
    log.d("Retriving my posts");
    await _databaseService.getMoreMyPosts().then((value) {
      cacheMyPosts(value: value);
    });
  }

  void cacheMyPosts({@required QuerySnapshot value}) {
    for (int i = 0; i < value.docs.length; i++) {
      bool _postExists = false;
      for (int j = 0; j < _posts.length; j++) {
        if (_posts[j].postID == value.docs[i].get("postID")) {
          _posts[j].mine = true;
          _postExists = true;
        }
      }

      if (!_postExists) {
        Post _newPost = new Post();
        _newPost.body = value.docs[i].get("body");
        _newPost.categoryId = value.docs[i].get("category");
        _newPost.postID = value.docs[i].get("postID");
        _newPost.time = value.docs[i].get("time");
        _newPost.title = value.docs[i].get("title");
        _newPost.size = value.docs[i].get("size");
        _newPost.edited = value.docs[i].get("edited");

        _newPost.userId = value.docs[i].get("user");
        _newPost.mine = true;

        List<AttachedImage> _imageList = List<AttachedImage>();

        Map<String, dynamic> imgs = value.docs[i].get("imgs");
        imgs.forEach((k, v) {
          List<dynamic> temp = v;
          List<String> result = temp.cast<String>();

          AttachedImage _newImage = AttachedImage();
          _newImage.imgId = k.toString();
          _newImage.path = result[0];
          _newImage.size = result[1];
          _imageList.add(_newImage);
        });

        List<AttachedVideo> _videoList = List<AttachedVideo>();

        Map<String, dynamic> vids = value.docs[i].get("vids");
        vids.forEach((k, v) {
          List<dynamic> temp = v;
          List<String> result = temp.cast<String>();

          AttachedVideo _newVideo = AttachedVideo();
          _newVideo.vidId = k.toString();
          _newVideo.path = result[0];
          _newVideo.size = result[1];
          _newVideo.videoPlayerController =
              VideoPlayerController.network(_newVideo.path);
          _newVideo.videoPlayerControllerFuture =
              _newVideo.videoPlayerController.initialize();
          _videoList.add(_newVideo);
        });

        List<AttachedFile> _filesList = List<AttachedFile>();

        Map<String, dynamic> files = value.docs[i].get("files");
        files.forEach((k, v) {
          List<dynamic> temp = v;
          List<String> result = temp.cast<String>();

          AttachedFile _newFile = AttachedFile();
          _newFile.fileId = k.toString();
          _newFile.name = result[0];
          _newFile.fileSize = result[1];
          _newFile.fileURL = result[2];
          _newFile.filetype = result[3];
          _filesList.add(_newFile);
        });

        _newPost.files = _filesList;
        _newPost.vids = _videoList;
        _newPost.imgs = _imageList;
        addPost(_newPost);
      }
      _postExists = false;
    }
  }

  Future loadTopicPosts() async {
    await _databaseService.loadTopicData().then((value) {
      cacheTopicPosts(snapshot: value);
    });
  }

  Future loadMoreTopicPosts() async {
    await _databaseService.loadMoreTopicData().then((value) {
      cacheTopicPosts(snapshot: value);
    });
  }

  void cacheTopicPosts({@required QuerySnapshot snapshot}) {
    for (int i = 0; i < snapshot.docs.length; i++) {
      bool _postExists = false;
      for (int j = 0; j < _posts.length; j++) {
        if (_posts[j].postID == snapshot.docs[i].get("postID")) {
          _postExists = true;
        }
      }

      if (!_postExists) {
        Post _newPost = new Post();
        _newPost.body = snapshot.docs[i].get("body");
        _newPost.categoryId = snapshot.docs[i].get("category");
        _newPost.postID = snapshot.docs[i].get("postID");
        _newPost.time = snapshot.docs[i].get("time");
        _newPost.title = snapshot.docs[i].get("title");
        _newPost.size = snapshot.docs[i].get("size");
        _newPost.edited = snapshot.docs[i].get("edited");

        _newPost.userId = snapshot.docs[i].get("user");

        List<AttachedImage> _imageList = List<AttachedImage>();

        Map<String, dynamic> imgs = snapshot.docs[i].get("imgs");
        imgs.forEach((k, v) {
          List<dynamic> temp = v;
          List<String> result = temp.cast<String>();

          AttachedImage _newImage = AttachedImage();
          _newImage.imgId = k.toString();
          _newImage.path = result[0];
          _newImage.size = result[1];
          _imageList.add(_newImage);
        });

        List<AttachedVideo> _videoList = List<AttachedVideo>();

        Map<String, dynamic> vids = snapshot.docs[i].get("vids");
        vids.forEach((k, v) {
          List<dynamic> temp = v;
          List<String> result = temp.cast<String>();

          AttachedVideo _newVideo = AttachedVideo();
          _newVideo.vidId = k.toString();
          _newVideo.path = result[0];
          _newVideo.size = result[1];
          _newVideo.videoPlayerController =
              VideoPlayerController.network(_newVideo.path);
          _newVideo.videoPlayerControllerFuture =
              _newVideo.videoPlayerController.initialize();
          _videoList.add(_newVideo);
        });

        List<AttachedFile> _filesList = List<AttachedFile>();

        Map<String, dynamic> files = snapshot.docs[i].get("files");
        files.forEach((k, v) {
          List<dynamic> temp = v;
          List<String> result = temp.cast<String>();

          AttachedFile _newFile = AttachedFile();
          _newFile.fileId = k.toString();
          _newFile.name = result[0];
          _newFile.fileSize = result[1];
          _newFile.fileURL = result[2];
          _newFile.filetype = result[3];
          _filesList.add(_newFile);
        });

        _newPost.files = _filesList;
        _newPost.vids = _videoList;
        _newPost.imgs = _imageList;
        addPost(_newPost);
      }
      _postExists = false;
    }
  }

  Future loadSubscribedPosts() async {
    log.d("Retriving subscribed posts");
    await _databaseService.getSubscribedPosts().then((value) {
      cacheSubscribedPosts(value: value);
    });
  }

  Future loadMoreSubscribedPosts() async {
    log.d("Retriving subscribed posts");
    await _databaseService.getMoreSubscribedPosts().then((value) {
      cacheSubscribedPosts(value: value);
    });
  }

  void cacheSubscribedPosts({@required QuerySnapshot value}) {
    for (int i = 0; i < value.docs.length; i++) {
      bool _postExists = false;
      for (int j = 0; j < _posts.length; j++) {
        if (_posts[j].postID == value.docs[i].get("postID")) {
          _posts[j].subscribed = true;
          _postExists = true;
        }
      }
      if (!_postExists) {
        Post _newPost = new Post();
        _newPost.body = value.docs[i].get("body");
        _newPost.categoryId = value.docs[i].get("category");
        _newPost.postID = value.docs[i].get("postID");
        _newPost.time = value.docs[i].get("time");
        _newPost.size = value.docs[i].get("size");
        _newPost.title = value.docs[i].get("title");
        _newPost.userId = value.docs[i].get("user");
        _newPost.edited = value.docs[i].get("edited");
        _newPost.subscribed = true;
        List<AttachedImage> _imageList = List<AttachedImage>();

        Map<String, dynamic> imgs = value.docs[i].get("imgs");
        imgs.forEach((k, v) {
          List<dynamic> temp = v;
          List<String> result = temp.cast<String>();

          AttachedImage _newImage = AttachedImage();
          _newImage.imgId = k.toString();
          _newImage.path = result[0];
          _newImage.size = result[1];
          _imageList.add(_newImage);
        });

        List<AttachedVideo> _videoList = List<AttachedVideo>();

        Map<String, dynamic> vids = value.docs[i].get("vids");
        vids.forEach((k, v) {
          List<dynamic> temp = v;
          List<String> result = temp.cast<String>();

          AttachedVideo _newVideo = AttachedVideo();
          _newVideo.vidId = k.toString();
          _newVideo.path = result[0];
          _newVideo.size = result[1];
          _newVideo.videoPlayerController =
              VideoPlayerController.network(_newVideo.path);
          _newVideo.videoPlayerControllerFuture =
              _newVideo.videoPlayerController.initialize();
          _videoList.add(_newVideo);
        });

        List<AttachedFile> _filesList = List<AttachedFile>();

        Map<String, dynamic> files = value.docs[i].get("files");
        files.forEach((k, v) {
          List<dynamic> temp = v;
          List<String> result = temp.cast<String>();

          AttachedFile _newFile = AttachedFile();
          _newFile.fileId = k.toString();
          _newFile.name = result[0];
          _newFile.fileSize = result[1];
          _newFile.fileURL = result[2];
          _newFile.filetype = result[3];
          _filesList.add(_newFile);
        });

        _newPost.files = _filesList;
        _newPost.vids = _videoList;
        _newPost.imgs = _imageList;
        addPost(_newPost);
      }
      _postExists = false;
    }
  }

  Future loadAnnouncements() async {
    log.d("Retriving announcements");
    await _databaseService.getAnnouncements().then((value) {
      cacheAnnouncements(value: value);
    });
  }

  Future loadMoreAnnouncements() async {
    log.d("Retriving more announcements");
    await _databaseService.getMoreAnnouncements().then((value) {
      cacheAnnouncements(value: value);
    });
  }

  void cacheAnnouncements({@required QuerySnapshot value}) {
    for (int i = 0; i < value.docs.length; i++) {
      Announcement _newAnnouncement = new Announcement();
      _newAnnouncement.time = value.docs[i].get("time");
      _newAnnouncement.text = value.docs[i].get("body");
      _newAnnouncement.announcementId = value.docs[i].get("announcementId");
      _newAnnouncement.userId = value.docs[i].get("userId");
      _newAnnouncement.edited = value.docs[i].get("edited");

      List<dynamic> temp = value.docs[i].get("img");
      if (temp.length > 0) {
        AttachedImage _newImage = AttachedImage();
        _newImage.imgId = "0";
        _newImage.path = value.docs[i].get("img")[0];
        _newImage.size = value.docs[i].get("img")[1];

        _newAnnouncement.img = _newImage;
      }

      temp = value.docs[i].get("vid");
      if (temp.length > 0) {
        AttachedVideo _newVideo = AttachedVideo();
        _newVideo.vidId = "0";
        _newVideo.path = value.docs[i].get("vid")[0];
        _newVideo.size = value.docs[i].get("vid")[1];

        _newAnnouncement.vid = _newVideo;
      }

      List<AttachedFile> _filesList = List<AttachedFile>();

      Map<String, dynamic> files = value.docs[i].get("files");
      files.forEach((k, v) {
        List<dynamic> temp = v;
        List<String> result = temp.cast<String>();

        AttachedFile _newFile = AttachedFile();
        _newFile.fileId = k.toString();
        _newFile.name = result[0];
        _newFile.fileSize = result[1];
        _newFile.fileURL = result[2];
        _newFile.filetype = result[3];
        _filesList.add(_newFile);
      });

      _newAnnouncement.files = _filesList;

      _announcements.add(_newAnnouncement);
    }
  }

  AttachedVideo getPostVid({@required String path, @required Post post}) {
    for (int i = 0; i < post.vids.length; i++) {
      if (post.vids[i].path == path) {
        return post.vids[i];
      }
    }
    return null;
  }

  AttachedImage getPostImg({@required String path, @required Post post}) {
    for (int i = 0; i < post.imgs.length; i++) {
      if (post.imgs[i].path == path) {
        return post.imgs[i];
      }
    }
    return null;
  }
}
