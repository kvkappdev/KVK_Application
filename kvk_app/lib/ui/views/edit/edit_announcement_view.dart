import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/data_struct/attachedImage.dart';
import 'package:kvk_app/data_struct/attachedVideo.dart';
import 'package:kvk_app/icons/kvk_icons.dart';
import 'package:kvk_app/ui/coloursheet.dart';
import 'package:kvk_app/ui/smart_widgets/cancelCrossButtonResizable.dart';
import 'package:kvk_app/ui/smart_widgets/screen_arguments.dart';
import 'package:kvk_app/ui/templates/kvk_plain_background.dart';
import 'package:kvk_app/ui/templates/kvk_box.dart';
import 'package:kvk_app/ui/viewmodels/edit/edit_announcement_viewmodel.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:stacked/stacked.dart';
import 'package:video_player/video_player.dart';

final log = getLogger("Edit Announcement View");
final fileExtensionRegex = new RegExp(r"\.(?:.(?!\.))+$");

class EditAnnouncementView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final ScreenArguments screenArguments =
        ModalRoute.of(context).settings.arguments;
    return ViewModelBuilder<EditAnnouncementViewModel>.reactive(
      builder: (context, model, child) => WillPopScope(
        onWillPop: () {
          return model.onBackPressed();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: <Widget>[
              CustomPaint(
                painter: Box(0, 0.125, colour: Colour.kvk_white),
                size: Size(screenWidth, screenHeight),
              ),
              Container(
                height: screenHeight * 0.92,
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  primary: true,
                  scrollDirection: Axis.vertical,
                  child: Stack(
                    overflow: Overflow.clip,
                    children: <Widget>[
                      userDetails(
                          model: model,
                          width: screenWidth,
                          height: screenHeight,
                          args: screenArguments),
                      announcementDetails(
                          model: model,
                          width: screenWidth,
                          height: screenHeight,
                          args: screenArguments),
                      Container(
                        margin: new EdgeInsets.only(
                            top: screenHeight * 0.6,
                            left: screenWidth * 0.05,
                            right: screenWidth * 0.05),
                        child: Column(
                          children: <Widget>[
                            model.getImgs().length + model.getVids().length > 0
                                ? attachedMedia(
                                    model: model,
                                    width: screenWidth,
                                    height: screenHeight)
                                : Container(),
                            model.getFiles().length > 0
                                ? attachedFiles(
                                    model: model,
                                    width: screenWidth,
                                    height: screenHeight)
                                : Container(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              CustomPaint(
                painter: PlainBackground(),
                size: Size(screenWidth, screenHeight * 0.125),
              ),
              topBar(
                  height: screenHeight,
                  width: screenWidth,
                  model: model,
                  context: context,
                  args: screenArguments),
              attachmentPanel(
                  model: model, width: screenWidth, height: screenHeight),
            ],
          ),
        ),
      ),
      viewModelBuilder: () => EditAnnouncementViewModel(),
    );
  }
}

Widget attachedFiles(
    {@required EditAnnouncementViewModel model,
    @required double height,
    @required double width}) {
  return Row(
    children: <Widget>[
      new Expanded(
        child: ListView(
          primary: false,
          shrinkWrap: true,
          children: List.generate(
            model.getFiles().length,
            (index) => attachedFile(model: model, index: index, width: width),
          ),
        ),
      ),
    ],
  );
}

Widget attachedFile(
    {@required EditAnnouncementViewModel model,
    @required int index,
    @required double width}) {
  return Container(
      child: Row(
    children: <Widget>[
      Container(
        height: width * 0.1,
        width: width * 0.1,
        margin: new EdgeInsets.only(right: width * 0.01),
        child: fileType(model: model, index: index),
      ),
      Container(
        width: width * 0.65,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              model.getFiles()[index].name,
              style: TextStyle(
                fontFamily: "Lato",
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colour.kvk_black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
            Text(
              model.getFiles()[index].fileSize.toString() + " KB",
              style: TextStyle(
                fontFamily: "Lato",
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colour.kvk_black.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
      Container(
        width: width * 0.14,
        alignment: Alignment.centerRight,
        child: IconButton(
          icon: Icon(
            KVKIcons.cancel_original,
            color: Colour.kvk_orange,
          ),
          onPressed: () {
            model.removeFile(index: index);
          },
        ),
      ),
    ],
  ));
}

Widget fileType(
    {@required EditAnnouncementViewModel model, @required int index}) {
  return model.getFiles()[index].name.substring(
              model.getFiles()[index].name.indexOf(fileExtensionRegex) + 1) ==
          "pdf"
      ? Image(
          image: AssetImage("assets/img/pdf_icon.png"),
        )
      : model.getFiles()[index].name.substring(
                  model.getFiles()[index].name.indexOf(fileExtensionRegex) + 1,
                  model.getFiles()[index].name.indexOf(fileExtensionRegex) +
                      4) ==
              "doc"
          ? Image(
              image: AssetImage("assets/img/doc_icon.png"),
            )
          : model.getFiles()[index].name.substring(
                      model.getFiles()[index].name.indexOf(fileExtensionRegex) +
                          1,
                      model.getFiles()[index].name.indexOf(fileExtensionRegex) +
                          4) ==
                  "ppt"
              ? Image(
                  image: AssetImage("assets/img/ppt_icon.png"),
                )
              : Image(
                  image: AssetImage("assets/img/excel_icon.png"),
                );
}

Widget attachedMedia(
    {@required EditAnnouncementViewModel model,
    @required double height,
    @required double width}) {
  return Row(
    children: <Widget>[
      new Expanded(
        child: GridView.count(
          primary: false,
          shrinkWrap: true,
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: List.generate(
              model.getImgs().length + model.getVids().length, (index) {
            return index < model.getImgs().length
                ? attachedImage(
                    img: model.getImgs()[index],
                    width: width,
                    model: model,
                    index: index)
                : attachedVideo(
                    vid: model.getVids()[index - model.getImgs().length],
                    width: width,
                    model: model,
                    index: index - model.getImgs().length);
          }),
        ),
      ),
    ],
  );
}

Widget attachedVideo(
    {@required EditAnnouncementViewModel model,
    @required AttachedVideo vid,
    @required double width,
    @required int index}) {
  return Stack(
    children: <Widget>[
      FutureBuilder(
          future: model.getVideoFutures(index: index),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Container(
                child: FittedBox(
                  child: SizedBox(
                    width: model
                        .getVideoControllers(index: index)
                        .value
                        .aspectRatio,
                    height: model
                        .getVideoControllers(index: index)
                        .value
                        .aspectRatio,
                    child: VideoPlayer(model.getVideoControllers(index: index)),
                  ),
                  fit: BoxFit.cover,
                ),
                width: width * 0.25,
                height: width * 0.25,
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
      Container(
        width: width * 0.25,
        height: width * 0.25,
        alignment: Alignment.topRight,
        margin: new EdgeInsets.only(top: width * 0.01, right: width * 0.05),
        child: GestureDetector(
          child: Container(
            padding: new EdgeInsets.all(0),
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Colour.kvk_white),
            child: Icon(
              KVKIcons.cancel_original,
              color: Colour.kvk_orange,
            ),
          ),
          onTap: () {
            log.i("Removing video from attachments");
            model.removeVideo(index: index);
          },
        ),
      ),
      Container(
        alignment: Alignment.bottomLeft,
        margin: new EdgeInsets.only(bottom: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Icon(
              KVKIcons.video_camera_figma_exported_custom,
              size: 16,
              color: Colour.kvk_white,
            ),
            Text(
              model.getDuration(index) != null
                  ? model.formatDuration(model.getDuration(index)).toString()
                  : "",
              style: TextStyle(
                fontFamily: "Lato",
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colour.kvk_white,
              ),
            ),
          ],
        ),
      )
    ],
  );
}

Widget attachedImage(
    {@required EditAnnouncementViewModel model,
    @required AttachedImage img,
    @required double width,
    @required int index}) {
  return Stack(
    children: <Widget>[
      Container(
        child: FittedBox(
            child: img.local
                ? Image.file(
                    File(img.path),
                  )
                : Image.network(img.path),
            fit: BoxFit.cover),
        width: width * 0.25,
        height: width * 0.25,
      ),
      Container(
        color: Colour.kvk_white,
        width: width * 0.25,
        height: width * 0.25,
        alignment: Alignment.topRight,
        margin: new EdgeInsets.only(top: width * 0.01, right: width * 0.05),
        child: GestureDetector(
          child: Container(
            padding: new EdgeInsets.all(0),
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Colour.kvk_white),
            child: Icon(
              KVKIcons.cancel_original,
              color: Colour.kvk_orange,
            ),
          ),
          onTap: () {
            log.i("Removing image from attachments");
            model.removeImage(index: index);
          },
        ),
      ),
    ],
  );
}

Widget attachmentPanel(
    {@required EditAnnouncementViewModel model,
    @required double width,
    @required double height}) {
  return SlidingUpPanel(
    controller: model.pc,
    minHeight: 70,
    maxHeight: 310,
    panel: Center(
      child: InkWell(
        onTap: () {
          model.togglePanel();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
                margin: new EdgeInsets.only(top: 10),
                height: height * 0.005,
                width: width * 0.075,
                decoration: BoxDecoration(
                  color: Colour.kvk_nav_grey,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                )),
            Container(
              margin: new EdgeInsets.only(top: 15),
              child: Text(
                model.lang().slidingPanel[0],
                style: TextStyle(
                  fontFamily: "Lato",
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colour.kvk_dark_grey,
                ),
              ),
            ),
            SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      width: 1,
                      color: Colour.kvk_background_grey,
                    ),
                  ),
                ),
                child: new Wrap(
                  children: <Widget>[
                    new ListTile(
                      leading: new Icon(KVKIcons.photo_camera_original),
                      title: new Text(
                        model.lang().slidingPanel[1],
                        style: TextStyle(
                          fontFamily: "Lato",
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      onTap: () {
                        model.imgFromCamera();
                      },
                    ),
                    new ListTile(
                      leading:
                          new Icon(KVKIcons.video_camera_figma_exported_custom),
                      title: new Text(
                        model.lang().slidingPanel[2],
                        style: TextStyle(
                          fontFamily: "Lato",
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      onTap: () {
                        model.videoFromCamera();
                      },
                    ),
                    new ListTile(
                      leading: new Icon(KVKIcons.gallery_original),
                      title: new Text(
                        model.lang().slidingPanel[3],
                        style: TextStyle(
                          fontFamily: "Lato",
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      onTap: () {
                        model.fromGallery();
                      },
                    ),
                    new ListTile(
                      leading: new Icon(KVKIcons.paperclip_original),
                      title: new Text(
                        model.lang().slidingPanel[4],
                        style: TextStyle(
                          fontFamily: "Lato",
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      onTap: () {
                        model.filesFromLibrary();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(10.0),
      topRight: Radius.circular(10.0),
    ),
  );
}

Widget announcementDetails(
    {@required EditAnnouncementViewModel model,
    @required double width,
    @required double height,
    @required ScreenArguments args}) {
  return Container(
    padding: new EdgeInsets.only(top: height * 0.27, left: width * 0.1),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        bodyInput(model: model, width: width),
      ],
    ),
  );
}

Widget bodyInput(
    {@required EditAnnouncementViewModel model, @required double width}) {
  return Container(
    padding: new EdgeInsets.only(right: width * 0.1),
    child: TextField(
      onChanged: (_) {
        model.rebuild();
      },
      controller: model.announcementText,
      style: TextStyle(
        color: Colour.kvk_black,
        fontFamily: "Lato",
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      maxLines: null,
      decoration: InputDecoration(
          border: InputBorder.none,
          hintText: model.lang().postInputPrompt,
          hintStyle: TextStyle(
            color: Colour.kvk_grey,
            fontFamily: "Lato",
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 0.71,
          )),
    ),
  );
}

Widget userDetails(
    {@required EditAnnouncementViewModel model,
    @required double width,
    @required double height,
    @required ScreenArguments args}) {
  if (!model.loaded) model.loadArgs(args: args);
  return Container(
    padding: new EdgeInsets.only(top: height * 0.15, left: width * 0.05),
    child: Row(
      children: <Widget>[
        CircleAvatar(
          backgroundColor: Colors.transparent,
          backgroundImage:
              model.getProfilePic(userId: args.announcement.userId).image,
          radius: width * 0.1,
        ),
        Container(
          padding: new EdgeInsets.only(left: width * 0.05),
          child: Text(
            model.getName(userId: args.announcement.userId) != ""
                ? model.getName(userId: args.announcement.userId)
                : model.lang().anonymous,
            style: TextStyle(
              fontSize: 14,
              fontFamily: "Lato",
              height: 0.83,
              color: Colour.kvk_nav_dark_grey,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget topBar(
    {@required double height,
    @required double width,
    @required EditAnnouncementViewModel model,
    @required BuildContext context,
    @required ScreenArguments args}) {
  return Container(
    height: height * 0.125,
    margin: new EdgeInsets.only(top: width * 0.05),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        crossButton(width: width, model: model),
        Container(
          margin: new EdgeInsets.only(right: width * 0.10),
          child: Text(
            model.lang().editOptions[4],
            style: TextStyle(
              fontFamily: "Lato",
              fontSize: 20,
              height: 0.83,
              fontWeight: FontWeight.w600,
              color: Colour.kvk_white,
            ),
          ),
        ),
        submitButton(
            context: context, height: height, model: model, args: args),
      ],
    ),
  );
}

Widget crossButton(
    {@required double width, @required EditAnnouncementViewModel model}) {
  return Container(
    child: RCrossButton(
      size: width * 0.1,
      color: Colour.kvk_white,
      onPressed: () {
        model.reset();
        model.onBackPressed();
      },
    ),
  );
}

Widget submitButton(
    {@required BuildContext context,
    @required double height,
    @required EditAnnouncementViewModel model,
    @required ScreenArguments args}) {
  return Container(
    height: height * 0.125,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            FlatButton(
              child: Text(
                model.lang().save,
                style: TextStyle(
                  height: 0.76,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: "Lato",
                  color: model.announcementText.text != ""
                      ? Colour.kvk_white
                      : Colour.kvk_white.withOpacity(0.5),
                ),
              ),
              onPressed: () {
                if (model.announcementText.text != "") {
                  model
                      .updateAnnouncement(
                          body: model.announcementText.text,
                          context: context,
                          args: args)
                      .then((value) {
                    model.announcementText.clear();
                  });
                }
              },
            ),
          ],
        ),
      ],
    ),
  );
}
