import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kvk_app/data_struct/announcement.dart';
import 'package:kvk_app/data_struct/attachedImage.dart';
import 'package:kvk_app/data_struct/attachedVideo.dart';
import 'package:kvk_app/icons/kvk_icons.dart';
import 'package:kvk_app/ui/coloursheet.dart';
import 'package:kvk_app/ui/smart_widgets/backButtonResizable.dart';
import 'package:kvk_app/ui/smart_widgets/screen_arguments.dart';
import 'package:kvk_app/ui/templates/kvk_box.dart';
import 'package:kvk_app/ui/templates/kvk_plain_background.dart';
import 'package:kvk_app/ui/viewmodels/forum_flow/view_announcement_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:video_player/video_player.dart';

class ViewAnnouncementView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final ScreenArguments screenArguments =
        ModalRoute.of(context).settings.arguments;

    return ViewModelBuilder<ViewAnnouncementViewModel>.reactive(
        builder: (context, model, child) => WillPopScope(
              onWillPop: () {
                return model.onBackPressed();
              },
              child: Scaffold(
                resizeToAvoidBottomInset: false,
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
                        requiresShadow: false,
                      ),
                    ),
                    Container(
                      margin: new EdgeInsets.only(top: screenHeight * 0.125),
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            announcements(
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
        viewModelBuilder: () => ViewAnnouncementViewModel());
  }
}

Widget announcements(
    {@required BuildContext context,
    @required ScreenArguments args,
    @required ViewAnnouncementViewModel model,
    @required double width,
    @required double height}) {
  return model.getAnnouncements().length > 0
      ? Container(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ListView(
                  padding: new EdgeInsets.all(0),
                  primary: false,
                  shrinkWrap: true,
                  children: List.generate(
                    model.getAnnouncements().length,
                    (index) => Card(
                      child: Container(
                        padding: new EdgeInsets.all(10),
                        child: Row(
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                announcementDetails(
                                    announcement:
                                        model.getAnnouncement(index: index),
                                    model: model,
                                    width: width,
                                    context: context),
                                Container(
                                    margin: new EdgeInsets.only(top: 10),
                                    child: body(
                                      width: width,
                                      body: model
                                          .getAnnouncement(index: index)
                                          .text,
                                    )),
                                media(
                                  img: model.getAnnouncement(index: index).img,
                                  vid: model.getAnnouncement(index: index).vid,
                                  args: args,
                                  width: width,
                                  model: model,
                                ),
                                Container(
                                  margin:
                                      new EdgeInsets.only(top: height * 0.01),
                                  child: attachedFiles(
                                      args: args,
                                      model: model,
                                      announcement:
                                          model.getAnnouncement(index: index)),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                model.getAnnouncements().length >= 10
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

Widget attachedFiles(
    {@required ViewAnnouncementViewModel model,
    @required ScreenArguments args,
    @required Announcement announcement}) {
  return InkWell(
    onTap: () {
      if (announcement.files.length > 0) {
        model.viewAttachments(announcement: announcement, args: args);
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
              announcement.files.length.toString(),
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

Widget announcementDetails(
    {@required double width,
    @required Announcement announcement,
    @required ViewAnnouncementViewModel model,
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
                model.getUser(userId: announcement.userId).profilePic !=
                        "default"
                    ? NetworkImage(
                        model.getUser(userId: announcement.userId).profilePic,
                      )
                    : AssetImage("assets/img/blank_profile.png"),
            radius: width * 0.075,
          ),
          model.getUser(userId: announcement.userId).role > 0
              ? Container(
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
                )
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
                  model.getUser(userId: announcement.userId).name,
                  style: TextStyle(
                      color: Colour.kvk_post_grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Lato"),
                ),
                Text(
                  announcement.edited
                      ? model.getPostTime(announcement.time) +
                          " (" +
                          model.lang().edited.toLowerCase() +
                          ")"
                      : model.getPostTime(announcement.time),
                  style: TextStyle(
                      color: Colour.kvk_post_grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Lato"),
                ),
              ],
            ),
            moreButton(
                context: context, model: model, announcement: announcement),
          ],
        ),
      ),
    ],
  );
}

Widget media(
    {@required AttachedImage img,
    @required AttachedVideo vid,
    @required ScreenArguments args,
    @required double width,
    @required ViewAnnouncementViewModel model}) {
  if (!model.loaded) model.loadArgs();
  return Container(
      height: img != null || vid != null ? width * 0.75 : 0,
      width: img != null || vid != null ? width - 28 : 0,
      child: img != null
          ? GestureDetector(
              child: Container(
                padding: new EdgeInsets.all(5),
                child: FittedBox(
                    child: Image.network(img.path), fit: BoxFit.cover),
                width: width * 0.75,
                height: width * 0.75,
              ),
              onTap: model.viewImage,
            )
          : vid != null
              ? GestureDetector(
                  child: Container(
                    child: FutureBuilder(
                        future: model.getVideoFutures()[0],
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return Container(
                                child: FittedBox(
                              child: SizedBox(
                                width:
                                    model.getControllers()[0].value.aspectRatio,
                                height:
                                    model.getControllers()[0].value.aspectRatio,
                                child: VideoPlayer(model.getControllers()[0]),
                              ),
                              fit: BoxFit.cover,
                            ));
                          } else {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        }),
                    width: width * 0.75,
                    height: width * 0.75,
                  ),
                  onTap: () =>
                      model.togglePlay(controller: model.getControllers()[0]))
              : Container());
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

Widget moreButton(
    {@required ViewAnnouncementViewModel model,
    @required BuildContext context,
    @required Announcement announcement}) {
  return Container(
    margin: new EdgeInsets.only(bottom: 20),
    child: model.canIEdit(announcement: announcement)
        ? InkWell(
            onTap: () {
              _showPicker(
                  context: context, model: model, announcement: announcement);
            },
            child: Icon(
              KVKIcons.show_more_button_with_three_dots_original,
              color: Colour.kvk_orange,
            ),
          )
        : Container(),
  );
}

void _showPicker(
    {@required BuildContext context,
    @required ViewAnnouncementViewModel model,
    @required Announcement announcement}) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
            child: Container(
                child: Wrap(children: <Widget>[
          ListTile(
            leading: Icon(KVKIcons.edit2_original),
            title: Text("Edit Announcement"),
            onTap: () {
              model.edit(announcement: announcement);
            },
          ),
          ListTile(
              leading: Icon(KVKIcons.delete_original),
              title: Text("Delete Announcement"),
              onTap: () {
                _deleteAnnouncementConfirmation(
                    context: context, model: model, announcement: announcement);
              }),
        ])));
      });
}

_deleteAnnouncementConfirmation(
    {@required BuildContext context,
    @required ViewAnnouncementViewModel model,
    @required Announcement announcement}) {
  // set up the buttons
  Widget cancelButton = FlatButton(
    child: Text(model.lang().deleteDialog[0].toUpperCase(),
        style: TextStyle(fontFamily: "Lato", color: Colour.kvk_orange)),
    onPressed: () {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    },
  );
  Widget deleteButton = FlatButton(
    child: Text(model.lang().deleteDialog[1].toUpperCase(),
        style: TextStyle(fontFamily: "Lato", color: Colour.kvk_error_red)),
    onPressed: () async {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      await model.deleteAnnouncement(
          context: context, announcement: announcement);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    content: Text("Are you sure you want to delete the announcement?",
        style: TextStyle(fontFamily: "Lato")),
    actions: [
      cancelButton,
      deleteButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

Widget topBar(
    {@required double height,
    @required double width,
    @required ViewAnnouncementViewModel model,
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
            "Announcements",
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
    @required ViewAnnouncementViewModel model,
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
