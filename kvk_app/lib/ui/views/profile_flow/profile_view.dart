import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/icons/kvk_icons.dart';
import 'package:kvk_app/services/internal_profile_service.dart';
import 'package:kvk_app/ui/coloursheet.dart';
import 'package:kvk_app/ui/smart_widgets/navBar/navBar.dart';
import 'package:kvk_app/ui/templates/kvk_background_painter.dart';
import 'package:kvk_app/ui/templates/kvk_box.dart';
import 'package:kvk_app/ui/viewmodels/profile_flow/profile_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:video_player/video_player.dart';

final log = getLogger("Profile View");

class ProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final InternalProfileService _internalProfileService =
        locator<InternalProfileService>();

    return ViewModelBuilder<ProfileViewModel>.reactive(
        builder: (context, model, child) => WillPopScope(
              onWillPop: () {
                return model.onBackPressed();
              },
              child: Scaffold(
                body: Stack(
                  children: <Widget>[
                    CustomPaint(
                      painter: BackgroundPainter(),
                      size: Size(screenWidth, screenHeight),
                    ),
                    CustomPaint(
                      size: Size(screenWidth, screenHeight),
                      painter: Box(
                        0,
                        0.25,
                        colour: Colour.kvk_white,
                        requiresShadow: false,
                      ),
                    ),
                    logo(screenWidth: screenWidth, screenHeight: screenHeight),
                    Container(
                      alignment: Alignment.center,
                      child: Stack(
                        children: <Widget>[
                          Container(
                            alignment: Alignment.topLeft,
                            margin: new EdgeInsets.only(
                                top: screenHeight * 0.25,
                                left: screenWidth * 0.02),
                            child: InkWell(
                                onTap: () {
                                  model.refreshProfile(context: context);
                                },
                                child: Icon(
                                  KVKIcons.sync_figma_exported_custom,
                                  color: Colour.kvk_orange,
                                )),
                          ),
                          Container(
                            alignment: Alignment.topRight,
                            margin: new EdgeInsets.only(
                                top: screenHeight * 0.25,
                                right: screenWidth * 0.02),
                            child: InkWell(
                              onTap: () {
                                model.editProfile();
                              },
                              child: Text(model.lang().editProfile,
                                  style: TextStyle(
                                      fontSize: 14, color: Colour.kvk_orange)),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  margin: new EdgeInsets.only(
                                    top: screenHeight * 0.25 -
                                        screenWidth * 0.185,
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    backgroundImage: model.getPic().image,
                                    radius: screenWidth * 0.185,
                                  ),
                                  decoration: new BoxDecoration(
                                    border: Border.all(
                                      color: Colour.kvk_white,
                                      width: 3,
                                    ),
                                    color: Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Container(
                                  padding: new EdgeInsets.only(
                                      top: screenHeight * 0.01,
                                      bottom: screenHeight * 0.005),
                                  child: Text(model.getUserName(),
                                      style: TextStyle(fontSize: 18)),
                                ),
                                Text(model.getUserRole()),
                                Container(
                                  alignment: Alignment.topLeft,
                                  width: screenWidth * 0.9,
                                  child: Text(
                                    model.lang().myPosts,
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colour.kvk_background_green,
                                        fontFamily: "Lato"),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    margin: new EdgeInsets.only(
                                      top: screenHeight * 0.01,
                                    ),
                                    width: screenWidth,
                                    height: screenHeight,
                                    decoration: BoxDecoration(
                                      color: Colour.kvk_background_grey,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(-5, 0),
                                        ),
                                      ],
                                    ),
                                    child: FutureBuilder(
                                      future: model.loadData(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.done) {
                                          return myPosts(
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
                  routeFrom: Routes.profileView,
                  model: model,
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                floatingActionButton: KVKPostNavButton(
                    routeFrom: Routes.profileView,
                    isBasicUser: _internalProfileService.getRole() < 1,
                    screenWidth: screenWidth),
              ),
            ),
        viewModelBuilder: () => ProfileViewModel());
  }

  Widget myPosts(
      {@required ProfileViewModel model,
      @required double width,
      @required double height}) {
    return model.getMyPosts().length > 0
        ? SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ListView(
                  padding: new EdgeInsets.all(0),
                  primary: false,
                  shrinkWrap: true,
                  children: List.generate(
                    model.getMyPosts().length,
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
                                      name(model: model, index: index),
                                      Container(
                                        width: model
                                                        .getMyPosts()[index]
                                                        .imgs
                                                        .length ==
                                                    0 &&
                                                model
                                                        .getMyPosts()[index]
                                                        .vids
                                                        .length ==
                                                    0
                                            ? width - 28
                                            : (width * 0.85) - 39,
                                        child: Text(
                                          model.getMyPosts()[index].title,
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
                                                  post:
                                                      model.getMyPosts()[index])
                                              .engName
                                          : model
                                              .getTopicByPost(
                                                  post:
                                                      model.getMyPosts()[index])
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
                                      model.getPostTime(index),
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
                model.getMyPosts().length >= 10
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

  Widget img(
      {@required ProfileViewModel model,
      @required int index,
      @required double width}) {
    return Container(
      decoration: BoxDecoration(
          border: new Border.all(width: 1, color: Colour.kvk_grey)),
      child: FittedBox(
          child: Image.network(
            model.getMyPosts()[index].imgs[0].path,
          ),
          fit: BoxFit.cover),
      width: 65,
      height: 65,
    );
  }

  Widget video(
      {@required ProfileViewModel model,
      @required int index,
      @required double width}) {
    return Stack(
      children: <Widget>[
        FutureBuilder(
          future: model.getMyPosts()[index].vids[0].videoPlayerControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Container(
                decoration: BoxDecoration(
                  border: new Border.all(width: 1, color: Colour.kvk_grey),
                ),
                child: FittedBox(
                  child: SizedBox(
                    width: model
                        .getMyPosts()[index]
                        .vids[0]
                        .videoPlayerController
                        .value
                        .aspectRatio,
                    height: model
                        .getMyPosts()[index]
                        .vids[0]
                        .videoPlayerController
                        .value
                        .aspectRatio,
                    child: VideoPlayer(model
                        .getMyPosts()[index]
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
          },
        ),
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
      {@required ProfileViewModel model,
      @required int index,
      @required double width,
      @required double height}) {
    return model.getMyPosts()[index].imgs.length > 0
        ? img(index: index, model: model, width: width)
        : model.getMyPosts()[index].vids.length > 0
            ? video(
                index: index - model.getMyPosts()[index].imgs.length,
                model: model,
                width: width)
            : Container();
  }

  Widget name({@required ProfileViewModel model, @required int index}) {
    return Container(
      margin: new EdgeInsets.only(top: 5),
      child: Text(
        model.getUserName(),
        style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            fontFamily: "Lato",
            color: Colour.kvk_post_grey),
      ),
    );
  }

  /// Creates the logos on the right of the page
  ///
  /// param: double [screenWidth], double [screenHeight]
  /// returns: Row
  /// Initial creation: 05/10/2020
  /// Last Updated: 05/10/2020
  Widget logo({@required double screenWidth, @required double screenHeight}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: new EdgeInsets.only(
            left: screenWidth * 0.02,
            top: screenHeight * 0.05,
          ),
          child: Image(
            image: new AssetImage("assets/img/svm_logo.png"),
            height: screenHeight * 0.07,
          ),
        ),
        Container(
          padding: new EdgeInsets.only(
            left: screenWidth * 0.02,
            // right: screenWidth * 0.02,
            top: screenHeight * 0.05,
          ),
          child: Image(
            image: new AssetImage("assets/img/icar_logo.png"),
            height: screenHeight * 0.07,
          ),
        ),
      ],
    );
  }
}
