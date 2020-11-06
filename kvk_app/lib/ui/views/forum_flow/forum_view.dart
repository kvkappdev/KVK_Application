import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/icons/kvk_icons.dart';
import 'package:kvk_app/services/internal_profile_service.dart';
import 'package:kvk_app/ui/coloursheet.dart';
import 'package:kvk_app/ui/smart_widgets/button.dart';
import 'package:kvk_app/ui/smart_widgets/logos/logos.dart';
import 'package:kvk_app/ui/smart_widgets/navBar/navBar.dart';
import 'package:kvk_app/ui/templates/kvk_background_painter.dart';
import 'package:kvk_app/ui/templates/kvk_box.dart';
import 'package:kvk_app/ui/templates/kvk_plain_background.dart';
import 'package:kvk_app/ui/viewmodels/forum_flow/forum_viewmodel.dart';
import 'package:kvk_app/ui/views/more/more_view.dart';
import 'package:stacked/stacked.dart';
import 'package:video_player/video_player.dart';

final log = getLogger("Forum View");

class ForumView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final InternalProfileService _internalProfileService =
        locator<InternalProfileService>();

    return ViewModelBuilder<ForumViewModel>.reactive(
        builder: (context, model, child) => WillPopScope(
              onWillPop: () {
                return model.onBackPressed();
              },
              child: Scaffold(
                body: Stack(
                  children: <Widget>[
                    CustomPaint(
                      painter: PlainBackground(),
                      size: Size(screenWidth, screenHeight),
                    ),
                    CustomPaint(
                      size: Size(screenWidth, screenHeight),
                      painter: Box(
                        0,
                        0.125,
                        colour: Colour.kvk_background_grey,
                      ),
                    ),
                    Logos(),
                    DefaultTabController(
                      length: 2,
                      child: Stack(
                        children: <Widget>[
                          Container(
                            margin:
                                new EdgeInsets.only(top: screenHeight * 0.145),
                            child: TabBarView(
                              children: <Widget>[
                                FutureBuilder(
                                  future: model.loadData(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      return latestTab(
                                          height: screenHeight,
                                          model: model,
                                          width: screenWidth);
                                    } else {
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                  },
                                ),
                                topicsTab(
                                    model: model,
                                    width: screenWidth,
                                    height: screenHeight),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colour.kvk_white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colour.kvk_nav_grey,
                                  blurRadius: 2,
                                  spreadRadius: 0,
                                  offset: Offset(0, 3),
                                )
                              ],
                            ),
                            margin:
                                new EdgeInsets.only(top: screenHeight * 0.115),
                            child: TabBar(
                              unselectedLabelColor: Colour.kvk_grey,
                              labelColor: Colour.kvk_orange,
                              indicatorColor: Colour.kvk_orange,
                              labelStyle: TextStyle(
                                fontFamily: "Lato",
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                              tabs: <Tab>[
                                new Tab(
                                  child: Text(
                                    "Latest",
                                  ),
                                ),
                                new Tab(
                                  child: Text(
                                    "Topics",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                bottomNavigationBar: KVKBottomNavBar(
                  routeFrom: Routes.forumView,
                  model: model,
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                floatingActionButton: KVKPostNavButton(
                    routeFrom: Routes.forumView,
                    isBasicUser: _internalProfileService.getRole() < 1,
                    screenWidth: screenWidth),
              ),
            ),
        viewModelBuilder: () => ForumViewModel());
  }
}

Widget topicsTab(
    {@required ForumViewModel model,
    @required double width,
    @required double height}) {
  return Container(
    child: Column(
      children: <Widget>[
        Card(
          child: Container(
            width: width,
            height: 120,
            margin: new EdgeInsets.only(top: height * 0.03),
            padding: new EdgeInsets.fromLTRB(15, 30, 15, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Chosen Topic:",
                  style: TextStyle(
                      fontSize: 18,
                      fontFamily: "Lato",
                      fontWeight: FontWeight.w400,
                      color: Colour.kvk_title_green),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: model.isUserAdmin() ? width * 0.75 : width * 0.85,
                      child: DropdownButton(
                        value: 0,
                        isExpanded: true,
                        onChanged: (int value) {
                          model.setSelectedTopic(
                              topicName: model.getTopicNames()[value]);
                          model.loadTopicData();
                        },
                        iconEnabledColor: Colour.kvk_orange,
                        style: TextStyle(color: Colour.kvk_black),
                        selectedItemBuilder: (BuildContext context) {
                          return model.getTopicNames().map((String value) {
                            return Text(
                              model.langVal() == 0
                                  ? model.getSelectedTopic().engName
                                  : model.getSelectedTopic().marName,
                              style: TextStyle(
                                color: Colour.kvk_orange,
                                height: 2.5,
                              ),
                            );
                          }).toList();
                        },
                        items: model
                            .getTopicNames()
                            .map<DropdownMenuItem<int>>((String value) {
                          return DropdownMenuItem<int>(
                            value: model.getTopicNames().indexOf(value),
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    model.isUserAdmin()
                        ? IconButton(
                            icon: Icon(
                              KVKIcons.edit2_original,
                              size: 22,
                              color: Colour.kvk_orange,
                            ),
                            onPressed: () {},
                          )
                        : Container(),
                  ],
                )
              ],
            ),
          ),
        ),
        model.getTopicPosts().length > 0
            ? Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      ListView(
                        padding: new EdgeInsets.only(top: 0),
                        primary: false,
                        shrinkWrap: true,
                        children: List.generate(
                          model.getTopicPosts().length,
                          (index) => GestureDetector(
                            onTap: () {
                              model.viewTopicPost(index: index);
                            },
                            child: Card(
                              child: Container(
                                padding: new EdgeInsets.all(10),
                                height: 115,
                                child: Stack(
                                  children: <Widget>[
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            name(
                                                model: model,
                                                index: index,
                                                topic: true),
                                            Container(
                                              width: model
                                                              .getTopicPosts()[
                                                                  index]
                                                              .imgs
                                                              .length ==
                                                          0 &&
                                                      model
                                                              .getTopicPosts()[
                                                                  index]
                                                              .vids
                                                              .length ==
                                                          0
                                                  ? width - 28
                                                  : (width * 0.85) - 39,
                                              padding: new EdgeInsets.only(
                                                  right: width * 0.05),
                                              child: Text(
                                                model
                                                    .getTopicPosts()[index]
                                                    .title,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 16,
                                                    fontFamily: "Lato",
                                                    color: Colour.kvk_black),
                                              ),
                                            ),
                                          ],
                                        ),
                                        attachedMedia(
                                          height: height,
                                          index: index,
                                          model: model,
                                          width: width,
                                          topic: true,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Container(
                                          margin: new EdgeInsets.only(top: 70),
                                          padding: new EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colour.kvk_topic_highlight,
                                            borderRadius: new BorderRadius.all(
                                              Radius.circular(5),
                                            ),
                                          ),
                                          child: Text(
                                            model.langVal() == 0
                                                ? model
                                                    .getTopicByPost(
                                                        post: model
                                                                .getTopicPosts()[
                                                            index])
                                                    .engName
                                                : model
                                                    .getTopicByPost(
                                                        post: model
                                                                .getTopicPosts()[
                                                            index])
                                                    .marName,
                                            style: TextStyle(
                                              color: Colour.kvk_dark_grey,
                                              fontFamily: "Lato",
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: new EdgeInsets.only(top: 70),
                                          child: Text(
                                            model.getPostTime(index,
                                                topic: true),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                                fontFamily: "Lato",
                                                color: Colour.kvk_post_grey),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      model.getTopicPosts().length >= 10
                          ? Container(
                              margin: new EdgeInsets.all(20.0),
                              width: width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                shape: BoxShape.rectangle,
                              ),
                              child: FlatButton(
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      color: Colour.kvk_orange,
                                      width: 1,
                                      style: BorderStyle.solid,
                                    ),
                                    borderRadius: BorderRadius.circular(50)),
                                child: Text(
                                  model.lang().loadMore,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: "Lato",
                                      fontWeight: FontWeight.w700),
                                ),
                                textColor: Colour.kvk_orange,
                                padding: EdgeInsets.all(16),
                                onPressed: model.loadMore,
                                color: Colour.kvk_white,
                              ),
                            )
                          : Container()
                    ],
                  ),
                ),
              )
            : Container(
                margin: new EdgeInsets.only(top: height * 0.2),
                alignment: Alignment.center,
                child: Text(
                  model.lang().noPosts,
                  style: TextStyle(
                      color: Colour.kvk_dark_grey,
                      fontFamily: "Lato",
                      fontWeight: FontWeight.w400,
                      fontSize: 18),
                ),
              ),
      ],
    ),
  );
}

Widget latestTab(
    {@required ForumViewModel model,
    @required double width,
    @required double height}) {
  return model.getPosts().length > 0
      ? SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ListView(
                primary: false,
                shrinkWrap: true,
                children: List.generate(
                  model.getPosts().length,
                  (index) => GestureDetector(
                    onTap: () {
                      model.viewLatestPost(index);
                    },
                    child: Card(
                      child: Container(
                        padding: new EdgeInsets.all(10),
                        height: 115,
                        child: Stack(
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    name(model: model, index: index),
                                    Container(
                                      width:
                                          model.getPosts()[index].imgs.length ==
                                                      0 &&
                                                  model
                                                          .getPosts()[index]
                                                          .vids
                                                          .length ==
                                                      0
                                              ? width - 28
                                              : (width * 0.85) - 39,
                                      padding: new EdgeInsets.only(
                                          right: width * 0.05),
                                      child: Text(
                                        model.getPosts()[index].title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            fontFamily: "Lato",
                                            color: Colour.kvk_black),
                                      ),
                                    ),
                                  ],
                                ),
                                attachedMedia(
                                    height: height,
                                    index: index,
                                    model: model,
                                    width: width),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  margin: new EdgeInsets.only(top: 70),
                                  padding: new EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colour.kvk_topic_highlight,
                                    borderRadius: new BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                  child: Text(
                                    model.langVal() == 0
                                        ? model
                                            .getTopicByPost(
                                                post: model.getPosts()[index])
                                            .engName
                                        : model
                                            .getTopicByPost(
                                                post: model.getPosts()[index])
                                            .marName,
                                    style: TextStyle(
                                      color: Colour.kvk_dark_grey,
                                      fontFamily: "Lato",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: new EdgeInsets.only(top: 70),
                                  child: Text(
                                    model.getPostTime(index, latest: true),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        fontFamily: "Lato",
                                        color: Colour.kvk_post_grey),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              model.getPosts().length >= 10
                  ? Container(
                      margin: new EdgeInsets.all(20.0),
                      width: width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        shape: BoxShape.rectangle,
                      ),
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: Colour.kvk_orange,
                              width: 1,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(50)),
                        child: Text(
                          model.lang().loadMore,
                          style: TextStyle(
                              fontSize: 18,
                              fontFamily: "Lato",
                              fontWeight: FontWeight.w700),
                        ),
                        textColor: Colour.kvk_orange,
                        padding: EdgeInsets.all(16),
                        onPressed: model.loadMore,
                        color: Colour.kvk_white,
                      ),
                    )
                  : Container(),
              model.getTopicPosts().length >= 10
                  ? Container(
                      margin: new EdgeInsets.all(20.0),
                      width: width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        shape: BoxShape.rectangle,
                      ),
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: Colour.kvk_orange,
                              width: 1,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(50)),
                        child: Text(
                          model.lang().loadMore,
                          style: TextStyle(
                              fontSize: 18,
                              fontFamily: "Lato",
                              fontWeight: FontWeight.w700),
                        ),
                        textColor: Colour.kvk_orange,
                        padding: EdgeInsets.all(16),
                        onPressed: model.loadMore,
                        color: Colour.kvk_white,
                      ),
                    )
                  : Container()
            ],
          ),
        )
      : Container(
          alignment: Alignment.center,
          child: Text(
            model.lang().noPosts,
            style: TextStyle(
                color: Colour.kvk_dark_grey,
                fontFamily: "Lato",
                fontWeight: FontWeight.w400,
                fontSize: 18),
          ),
        );
}

Widget name(
    {@required ForumViewModel model, @required int index, bool topic = false}) {
  return Container(
    margin: new EdgeInsets.only(top: 5),
    child: Text(
      model
          .getPostAccount(
            userId: !topic
                ? model.getPosts()[index].userId
                : model.getTopicPosts()[index].userId,
          )
          .name,
      style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          fontFamily: "Lato",
          color: Colour.kvk_post_grey),
    ),
  );
}

Widget img(
    {@required ForumViewModel model,
    @required int index,
    @required double width,
    bool topic = false}) {
  return Container(
    decoration:
        BoxDecoration(border: new Border.all(width: 1, color: Colour.kvk_grey)),
    child: FittedBox(
        child: Image.network(
          !topic
              ? model.getPosts()[index].imgs[0].path
              : model.getTopicPosts()[index].imgs[0].path,
        ),
        fit: BoxFit.cover),
    width: 65,
    height: 65,
  );
}

Widget video(
    {@required ForumViewModel model,
    @required int index,
    @required double width,
    bool topic = false}) {
  return !topic
      ? Stack(
          children: <Widget>[
            FutureBuilder(
                future:
                    model.getPosts()[index].vids[0].videoPlayerControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Container(
                      decoration: BoxDecoration(
                        border:
                            new Border.all(width: 1, color: Colour.kvk_grey),
                      ),
                      child: FittedBox(
                        child: SizedBox(
                          width: model
                              .getPosts()[index]
                              .vids[0]
                              .videoPlayerController
                              .value
                              .aspectRatio,
                          height: model
                              .getPosts()[index]
                              .vids[0]
                              .videoPlayerController
                              .value
                              .aspectRatio,
                          child: VideoPlayer(model
                              .getPosts()[index]
                              .vids[0]
                              .videoPlayerController),
                        ),
                        fit: BoxFit.cover,
                      ),
                      width: 65,
                      height: 65,
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
            Container(
                width: width * 0.15,
                height: width * 0.15,
                alignment: Alignment.bottomLeft,
                child: Icon(
                  KVKIcons.video_camera_figma_exported_custom,
                  color: Colour.kvk_white,
                )),
          ],
        )
      : Stack(
          children: <Widget>[
            FutureBuilder(
                future: model
                    .getTopicPosts()[index]
                    .vids[0]
                    .videoPlayerControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Container(
                      decoration: BoxDecoration(
                        border:
                            new Border.all(width: 1, color: Colour.kvk_grey),
                      ),
                      child: FittedBox(
                        child: SizedBox(
                          width: model
                              .getTopicPosts()[index]
                              .vids[0]
                              .videoPlayerController
                              .value
                              .aspectRatio,
                          height: model
                              .getTopicPosts()[index]
                              .vids[0]
                              .videoPlayerController
                              .value
                              .aspectRatio,
                          child: VideoPlayer(model
                              .getTopicPosts()[index]
                              .vids[0]
                              .videoPlayerController),
                        ),
                        fit: BoxFit.cover,
                      ),
                      width: 65,
                      height: 65,
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
            Container(
                width: width * 0.15,
                height: width * 0.15,
                alignment: Alignment.bottomLeft,
                child: Icon(
                  KVKIcons.video_camera_figma_exported_custom,
                  color: Colour.kvk_white,
                )),
          ],
        );
}

Widget attachedMedia(
    {@required ForumViewModel model,
    @required int index,
    @required double width,
    @required double height,
    bool topic = false}) {
  return !topic
      ? model.getPosts()[index].imgs.length > 0
          ? img(index: index, model: model, width: width)
          : model.getPosts()[index].vids.length > 0
              ? video(index: index, model: model, width: width)
              : Container()
      : model.getTopicPosts()[index].imgs.length > 0
          ? img(index: index, model: model, width: width, topic: true)
          : model.getTopicPosts()[index].vids.length > 0
              ? video(index: index, model: model, width: width, topic: true)
              : Container();
}
