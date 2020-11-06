import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/data_struct/announcement.dart';
import 'package:kvk_app/data_struct/post.dart';
import 'package:kvk_app/icons/kvk_icons.dart';
import 'package:kvk_app/services/internal_profile_service.dart';
import 'package:kvk_app/ui/coloursheet.dart';
import 'package:kvk_app/ui/smart_widgets/logos/logos.dart';
import 'package:kvk_app/ui/smart_widgets/navBar/navBar.dart';
import 'package:kvk_app/ui/templates/kvk_plain_background.dart';
import 'package:kvk_app/ui/templates/kvk_box.dart';
import 'package:kvk_app/ui/viewmodels/home_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:video_player/video_player.dart';

final log = getLogger("Home View");

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final NavigationService _navigationService = locator<NavigationService>();
    final InternalProfileService _internalProfileService =
        locator<InternalProfileService>();

    return ViewModelBuilder<HomeViewModel>.reactive(
        builder: (context, model, child) => Scaffold(
              body: Stack(
                children: <Widget>[
                  CustomPaint(
                    painter: PlainBackground(),
                    size: Size(screenWidth, screenHeight),
                  ),
                  CustomPaint(
                    painter: Box(0, 0.125, colour: Colour.kvk_background_grey),
                    size: Size(screenWidth, screenHeight),
                  ),
                  Logos(),
                  Container(
                    margin: new EdgeInsets.only(top: screenHeight * 0.125),
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          announcements(
                              model: model,
                              height: screenHeight,
                              width: screenWidth),
                          subscribedPosts(
                              model: model,
                              height: screenHeight,
                              width: screenWidth),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomRight,
                    margin: new EdgeInsets.all(30),
                    child: Container(
                      width: 55,
                      height: 55,
                      child: FloatingActionButton.extended(
                        heroTag: null,
                        backgroundColor: Colour.kvk_orange,
                        shape: CircleBorder(),
                        label: Icon(
                          KVKIcons.phone_call_original,
                          size: 30,
                          color: Colour.kvk_white,
                        ),
                        onPressed: () {
                          _navigationService.navigateTo(Routes.contactView);
                        },
                      ),
                    ),
                  )
                ],
              ),
              bottomNavigationBar: KVKBottomNavBar(
                routeFrom: Routes.homeView,
                model: model,
              ),
              floatingActionButton: KVKPostNavButton(
                routeFrom: Routes.homeView,
                isBasicUser: _internalProfileService.getRole() < 1,
                screenWidth: screenWidth,
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,

              // floatingActionButtonLocation:
              //     FloatingActionButtonLocation.centerDocked,
              // floatingActionButton: KVKPostNavButton(routeFrom: Routes.homeView,),
            ),
        viewModelBuilder: () => HomeViewModel());
  }
}

Widget subscribedPosts(
    {@required HomeViewModel model,
    @required double height,
    @required double width}) {
  return Column(
    children: <Widget>[
      Container(
        alignment: Alignment.center,
        color: Colour.kvk_white,
        height: height * 0.05,
        padding: new EdgeInsets.only(left: width * 0.025, right: width * 0.025),
        child: InkWell(
          onTap: () {
            model.navigateToSubscribedPostsViewAll(routeFrom: Routes.homeView);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                child: Text(
                  "Subscribed Posts",
                  style: TextStyle(
                      color: Colour.kvk_title_green,
                      fontFamily: "Lato",
                      fontWeight: FontWeight.w600,
                      fontSize: 20),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(width: 1, color: Colour.kvk_orange))),
                child: Text(
                  "View All",
                  style: TextStyle(
                    color: Colour.kvk_orange,
                    fontFamily: "Lato",
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      loadSubscribedPosts(model: model, height: height, width: width),
    ],
  );
}

Widget loadSubscribedPosts(
    {@required HomeViewModel model,
    @required double height,
    @required double width}) {
  return FutureBuilder(
    future: model.loadSubscribedPosts(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        return model.getSubscribedPosts().length > 0
            ? ListView(
                padding: new EdgeInsets.all(0),
                primary: false,
                shrinkWrap: true,
                children: List.generate(
                  model.getSubscribedPosts().length <= 5
                      ? model.getSubscribedPosts().length
                      : 5,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        model.getSubscribedPosts()[index].title,
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
                                                post:
                                                    model.getSubscribedPosts()[
                                                        index])
                                            .engName
                                        : model
                                            .getTopicByPost(
                                                post:
                                                    model.getSubscribedPosts()[
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
                                    model.getPostTime(
                                        post:
                                            model.getSubscribedPosts()[index]),
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
              )
            : Container(
                height: height * 0.25,
                alignment: Alignment.center,
                child: Text(
                  "No Posts to Show",
                  style: TextStyle(
                      fontFamily: "Lato",
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colour.kvk_dark_grey),
                ),
              );
      } else {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
    },
  );
}

Widget announcements(
    {@required HomeViewModel model,
    @required double height,
    @required double width}) {
  return Column(
    children: <Widget>[
      Container(
        alignment: Alignment.center,
        color: Colour.kvk_white,
        height: height * 0.05,
        padding: new EdgeInsets.only(left: width * 0.025, right: width * 0.025),
        child: InkWell(
          onTap: () {
            model.navigateToAnnouncementViewAll(routeFrom: Routes.homeView);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                child: Row(
                  children: <Widget>[
                    Text(
                      "Announcements",
                      style: TextStyle(
                          color: Colour.kvk_title_green,
                          fontFamily: "Lato",
                          fontWeight: FontWeight.w600,
                          fontSize: 20),
                    ),
                    Container(
                      margin: new EdgeInsets.only(left: 10),
                      child: Icon(
                        KVKIcons.megaphone_original,
                        color: Colour.kvk_title_green,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(width: 1, color: Colour.kvk_orange))),
                child: Text(
                  "View All",
                  style: TextStyle(
                    color: Colour.kvk_orange,
                    fontFamily: "Lato",
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      loadAnnouncements(model: model, height: height, width: width),
    ],
  );
}

Widget loadAnnouncements(
    {@required HomeViewModel model,
    @required double height,
    @required double width}) {
  return FutureBuilder(
    future: model.loadAnnouncements(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        return model.getAnnouncements().length > 0
            ? ListView(
                padding: new EdgeInsets.all(0),
                primary: false,
                shrinkWrap: true,
                children: List.generate(
                  model.getAnnouncements().length <= 3
                      ? model.getAnnouncements().length
                      : 3,
                  (index) => GestureDetector(
                    onTap: () {
                      model.navigateToAnnouncementViewAll(
                          routeFrom: Routes.homeView);
                    },
                    child: Card(
                      child: Container(
                        padding: new EdgeInsets.all(10),
                        child: Stack(
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    announcementPoster(
                                        announcement:
                                            model.getAnnouncements()[index],
                                        width: width,
                                        height: height,
                                        model: model),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : Container(
                height: height * 0.25,
                alignment: Alignment.center,
                child: Text(
                  "No Announcements",
                  style: TextStyle(
                      fontFamily: "Lato",
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colour.kvk_dark_grey),
                ),
              );
      } else {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
    },
  );
}

Widget announcementPoster(
    {@required Announcement announcement,
    @required double width,
    @required double height,
    @required HomeViewModel model}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Stack(
        alignment: Alignment.bottomRight,
        children: <Widget>[
          announcementImg(
              announcement: announcement, width: width, model: model),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
                border: Border.all(color: Colour.kvk_grey),
                shape: BoxShape.circle,
                color: Colour.kvk_white),
            child: Icon(
              KVKIcons.leaf_figma_exported_custom,
              color: Colour.kvk_leaf_green,
              size: 13,
            ),
          ),
        ],
      ),
      Container(
        margin: new EdgeInsets.only(left: width * 0.02),
        width: width * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              model.getPostName(userId: announcement.userId),
              style: TextStyle(
                  fontFamily: "Lato",
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colour.kvk_black),
            ),
            Text(
              announcement.edited
                  ? model.getPostTime(announcement: announcement) +
                      " (" +
                      model.lang().edited.toLowerCase() +
                      ")"
                  : model.getPostTime(announcement: announcement),
              style: TextStyle(
                  fontFamily: "Lato",
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colour.kvk_post_grey),
            ),
            Text(
              announcement.text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  fontFamily: "Lato",
                  color: Colour.kvk_black),
            ),
          ],
        ),
      ),
    ],
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

Widget announcementImg(
    {@required Announcement announcement,
    @required double width,
    @required HomeViewModel model}) {
  return Container(
    decoration: BoxDecoration(
        border: new Border.all(width: 1, color: Colour.kvk_grey),
        shape: BoxShape.circle),
    child: CircleAvatar(
      backgroundColor: Colors.white,
      backgroundImage:
          model.getAnnouncementProfilePic(userId: announcement.userId) !=
                  "default"
              ? new NetworkImage(
                  model.getAnnouncementProfilePic(userId: announcement.userId))
              : new AssetImage("assets/img/blank_profile.png"),
      radius: width * 0.185,
    ),
    width: 65,
    height: 65,
  );
}

Widget video(
    {@required HomeViewModel model,
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

Widget attachedMedia(
    {@required HomeViewModel model,
    @required int index,
    @required double width,
    @required double height}) {
  return model.getSubscribedPosts()[index].imgs.length > 0
      ? postImg(posts: model.getSubscribedPosts()[index], width: width)
      : model.getSubscribedPosts()[index].vids.length > 0
          ? video(index: index, model: model, width: width)
          : Container();
}
