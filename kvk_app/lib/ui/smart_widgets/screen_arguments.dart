import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:kvk_app/data_struct/announcement.dart';
import 'package:kvk_app/data_struct/post.dart';
import 'package:kvk_app/data_struct/reply.dart';
import 'package:kvk_app/data_struct/internalUser.dart';

class ScreenArguments {
  String routeFrom;
  InternalUser account = InternalUser();
  Post post;
  Reply reply;
  Reply childReply;
  Announcement announcement;
  ScreenArguments oldArgs;
  int scrollIndex;

  ScreenArguments(
      {this.routeFrom, this.account, this.post, this.reply, this.childReply, this.oldArgs, this.announcement, this.scrollIndex});

  void resetScreenArgument() {
    this.routeFrom = null;
    this.account = null;
    this.post = null;
    this.reply = null;
    this.childReply = null;
    this.announcement = null;
    this.oldArgs = null;
    this.scrollIndex = null;
  }
}
