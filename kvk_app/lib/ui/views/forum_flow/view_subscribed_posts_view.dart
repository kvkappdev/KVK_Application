import 'package:flutter/material.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/data_struct/post.dart';
import 'package:kvk_app/icons/kvk_icons.dart';
import 'package:kvk_app/services/internal_profile_service.dart';
import 'package:kvk_app/ui/coloursheet.dart';
import 'package:kvk_app/ui/smart_widgets/backButtonResizable.dart';
import 'package:kvk_app/ui/smart_widgets/screen_arguments.dart';
import 'package:kvk_app/ui/templates/kvk_box.dart';
import 'package:kvk_app/ui/templates/kvk_plain_background.dart';
import 'package:kvk_app/ui/viewmodels/forum_flow/subscribed_posts_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:video_player/video_player.dart';

class SubscribedPostsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final ScreenArguments screenArguments =
        ModalRoute.of(context).settings.arguments;

    return ViewModelBuilder<SubscribedPostsViewModel>.reactive(
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
                    Container(
                      margin: new EdgeInsets.only(top: screenHeight * 0.125),
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            subscribedPosts(
                                context: context,
                                args: screenArguments,
                                height: screenHeight,
                                model: model,
                                width: screenWidth),
                          ],
                        ),
                      ),
                    ),
                    topBar(
                        height: screenHeight,
                        width: screenWidth,
                        model: model,
                        context: context,
                        args: screenArguments),
                  ],
                ),
              ),
            ),
        viewModelBuilder: () => SubscribedPostsViewModel());
  }
}

Widget topBar(
    {@required double height,
    @required double width,
    @required SubscribedPostsViewModel model,
    @required BuildContext context,
    @required ScreenArguments args}) {
  return Container(
    height: height * 0.125,
    margin: new EdgeInsets.only(top: width * 0.05),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        backButton(width: width, model: model, args: args),
        Container(
          margin: new EdgeInsets.only(right: width * 0.3),
          child: Text(
            "Subscribed Posts",
            style: TextStyle(
              fontFamily: "Lato",
              fontSize: 20,
              height: 0.83,
              fontWeight: FontWeight.w600,
              color: Colour.kvk_white,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget backButton(
    {@required double width,
    @required SubscribedPostsViewModel model,
    @required ScreenArguments args}) {
  return Container(
    child: RBackButton(
      size: width * 0.1,
      color: Colour.kvk_white,
      onPressed: () {
        model.onBackPressed();
      },
    ),
  );
}

Widget subscribedPosts(
    {@required BuildContext context,
    @required ScreenArguments args,
    @required SubscribedPostsViewModel model,
    @required double width,
    @required double height}) {
  return model.getSubscribedPosts().length > 0
      ? Container(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ListView(
                  padding: new EdgeInsets.all(0),
                  primary: false,
                  shrinkWrap: true,
                  children: List.generate(
                    model.getSubscribedPosts().length,
                    (index) => GestureDetector(
                      onTap: () {
                        model.viewPost(index);
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      name(
                                          name: model.getPostName(
                                              userId: model
                                                  .getSubscribedPosts()[index]
                                                  .userId),
                                          index: index),
                                      Container(
                                        width: model
                                                        .getSubscribedPosts()[
                                                            index]
                                                        .imgs
                                                        .length ==
                                                    0 &&
                                                model
                                                        .getSubscribedPosts()[
                                                            index]
                                                        .vids
                                                        .length ==
                                                    0
                                            ? width - 28
                                            : (width * 0.85) - 39,
                                        child: Text(
                                          model
                                              .getSubscribedPosts()[index]
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
                                      width: width),
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
                                                  post: model.getSubscribedPost(
                                                      index: index))
                                              .engName
                                          : model
                                              .getTopicByPost(
                                                  post: model.getSubscribedPost(
                                                      index: index))
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
                                      model.getPostTime(model
                                          .getSubscribedPosts()[index]
                                          .time),
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
                model.getSubscribedPosts().length >= 10
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
        );
}

Widget name({@required String name, @required int index}) {
  return Container(
    margin: new EdgeInsets.only(top: 5),
    child: Text(
      name,
      style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          fontFamily: "Lato",
          color: Colour.kvk_post_grey),
    ),
  );
}

Widget attachedFiles(
    {@required SubscribedPostsViewModel model,
    @required ScreenArguments args,
    @required Post post}) {
  return InkWell(
    onTap: () {
      if (post.files.length > 0) {
        model.viewAttachments(post: post, args: args);
      }
    },
    child: Container(
      child: Row(
        children: <Widget>[
          Icon(
            KVKIcons.file_figma_exported_custom,
            color: Colour.kvk_orange,
          ),
          Container(
            margin: new EdgeInsets.only(left: 10),
            child: Text(
              post.files.length.toString(),
              style: TextStyle(
                color: Colour.kvk_orange,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget subscribedPostDetails(
    {@required double width,
    @required Post post,
    @required SubscribedPostsViewModel model,
    @required BuildContext context}) {
  return Row(
    children: <Widget>[
      Container(
        margin: new EdgeInsets.only(right: 10),
        decoration: new BoxDecoration(
          border: Border.all(
            color: Colour.kvk_nav_grey,
          ),
          color: Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Stack(alignment: Alignment.bottomRight, children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.transparent,
            backgroundImage:
                model.getUser(userId: post.userId).profilePic != "default"
                    ? NetworkImage(
                        model.getUser(userId: post.userId).profilePic,
                      )
                    : AssetImage("assets/img/blank_profile.png"),
            radius: width * 0.075,
          ),
          model.getUser(userId: post.userId).role > 0
              ? Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colour.kvk_grey),
                      shape: BoxShape.circle,
                      color: Colour.kvk_white),
                  child: Icon(
                    KVKIcons.leaf_figma_exported_custom,
                    color: Colour.kvk_leaf_green,
                    size: 16,
                  ))
              : Container(),
        ]),
      ),
      Container(
        // color: Colour.kvk_nav_grey,
        width:
            width * 0.85 - 42, //8 padding +10 margin +8 container +8 contaienr?
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  model.getUser(userId: post.userId).name,
                  style: TextStyle(
                      color: Colour.kvk_post_grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Lato"),
                ),
                Text(
                  model.getPostTime(post.time),
                  style: TextStyle(
                      color: Colour.kvk_post_grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Lato"),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

Widget attachedMedia(
    {@required SubscribedPostsViewModel model,
    @required int index,
    @required double width,
    @required double height}) {
  return model.getSubscribedPosts()[index].imgs.length > 0
      ? postImg(posts: model.getSubscribedPosts()[index], width: width)
      : model.getSubscribedPosts()[index].vids.length > 0
          ? video(index: index, model: model, width: width)
          : Container();
}

Widget video(
    {@required SubscribedPostsViewModel model,
    @required int index,
    @required double width}) {
  return Stack(
    alignment: Alignment.bottomLeft,
    children: <Widget>[
      FutureBuilder(
          future: model
              .getSubscribedPosts()[index]
              .vids[0]
              .videoPlayerControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Container(
                decoration: BoxDecoration(
                  border: new Border.all(width: 1, color: Colour.kvk_grey),
                ),
                child: FittedBox(
                  child: SizedBox(
                    width: model
                        .getSubscribedPosts()[index]
                        .vids[0]
                        .videoPlayerController
                        .value
                        .aspectRatio,
                    height: model
                        .getSubscribedPosts()[index]
                        .vids[0]
                        .videoPlayerController
                        .value
                        .aspectRatio,
                    child: VideoPlayer(model
                        .getSubscribedPosts()[index]
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

Widget postImg({@required Post posts, @required double width}) {
  return Container(
    decoration:
        BoxDecoration(border: new Border.all(width: 1, color: Colour.kvk_grey)),
    child: FittedBox(
        child: Image.network(
          posts.imgs[0].path,
        ),
        fit: BoxFit.cover),
    width: 65,
    height: 65,
  );
}

Widget body({@required double width, @required String body}) {
  return Container(
    child: Text(
      body,
      style: TextStyle(
          color: Colour.kvk_black,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontFamily: "Lato"),
    ),
    width: width - 28,
  );
}
