import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/data_struct/post.dart';
import 'package:kvk_app/icons/kvk_icons.dart';
import 'package:kvk_app/ui/coloursheet.dart';
import 'package:kvk_app/ui/smart_widgets/cancelCrossButtonResizable.dart';
import 'package:kvk_app/ui/smart_widgets/screen_arguments.dart';
import 'package:kvk_app/ui/templates/kvk_plain_background.dart';
import 'package:kvk_app/ui/templates/kvk_box.dart';
import 'package:kvk_app/ui/viewmodels/create/create_reply_viewmodel.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:stacked/stacked.dart';
import 'package:video_player/video_player.dart';

final log = getLogger("Create Reply View");
final fileExtensionRegex = new RegExp(r"\.(?:.(?!\.))+$");

class CreateReplyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final ScreenArguments screenArguments =
        ModalRoute.of(context).settings.arguments;

    return ViewModelBuilder<CreateReplyViewModel>.reactive(
      builder: (context, model, child) => WillPopScope(
        onWillPop: () {
          return model.onBackPressed(args: screenArguments);
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
                          height: screenHeight),
                      replyDetails(
                          model: model,
                          width: screenWidth,
                          height: screenHeight),
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
                  screenArguments: screenArguments,
                  height: screenHeight,
                  width: screenWidth,
                  model: model,
                  context: context),
              attachmentPanel(
                model: model,
                width: screenWidth,
                height: screenHeight,
                context: context,
              )
            ],
          ),
        ),
      ),
      viewModelBuilder: () => CreateReplyViewModel(),
    );
  }
}

Widget attachedFiles(
    {@required CreateReplyViewModel model,
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
    {@required CreateReplyViewModel model,
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
              model.getFiles()[index].size.toString() + " KB",
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

Widget fileType({@required CreateReplyViewModel model, @required int index}) {
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
    {@required CreateReplyViewModel model,
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
                    imgPath: model.getImgs()[index].path,
                    width: width,
                    model: model,
                    index: index)
                : attachedVideo(
                    vidPath:
                        model.getVids()[index - model.getImgs().length].path,
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
    {@required CreateReplyViewModel model,
    @required String vidPath,
    @required double width,
    @required int index}) {
  return Stack(
    children: <Widget>[
      FutureBuilder(
          future: model.getVidFuture()[index],
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Container(
                child: FittedBox(
                  child: SizedBox(
                    width: model.getVidController()[index].value.aspectRatio,
                    height: 1,
                    child: VideoPlayer(model.getVidController()[index]),
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
              color: Colour.kvk_white,
              size: 16,
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
    {@required CreateReplyViewModel model,
    @required String imgPath,
    @required double width,
    @required int index}) {
  return Stack(
    children: <Widget>[
      Container(
        child: FittedBox(
            child: Image.file(
              File(imgPath),
            ),
            fit: BoxFit.cover),
        width: width * 0.25,
        height: width * 0.25,
      ),
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
            log.i("Removing image from attachments");
            model.removeImage(index: index);
          },
        ),
      ),
    ],
  );
}

Widget attachmentPanel(
    {@required CreateReplyViewModel model,
    @required double width,
    @required double height,
    @required BuildContext context}) {
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
                      onTap: () async {
                        if (model.getMediaQuantity() < 3) {
                          model.imgFromCamera(model.pc);
                        } else {
                          model.createDialogs(pc: model.pc, context: context);
                          model.showmediaQuantityError();
                        }
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
                        if (model.getMediaQuantity() < 3) {
                          model.videoFromCamera(model.pc);
                        } else {
                          model.createDialogs(pc: model.pc, context: context);
                          model.showmediaQuantityError();
                        }
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
                        if (model.getMediaQuantity() < 3) {
                          model.fromGallery(model.pc);
                        } else {
                          model.createDialogs(pc: model.pc, context: context);
                          model.showmediaQuantityError();
                        }
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
                        model.filesFromLibrary(model.pc);
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

Widget replyDetails(
    {@required CreateReplyViewModel model,
    @required double width,
    @required double height}) {
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
    {@required CreateReplyViewModel model, @required double width}) {
  return Container(
    padding: new EdgeInsets.only(right: width * 0.1),
    child: TextField(
      onChanged: (_) {
        model.rebuild();
      },
      controller: model.replyText,
      style: TextStyle(
        color: Colour.kvk_black,
        fontFamily: "Lato",
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      maxLines: 14,
      minLines: 1,
      decoration: InputDecoration(
          border: InputBorder.none,
          hintText: model.lang().replyInputPrompt,
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
    {@required CreateReplyViewModel model,
    @required double width,
    @required double height}) {
  return Container(
    padding: new EdgeInsets.only(top: height * 0.15, left: width * 0.05),
    child: Row(
      children: <Widget>[
        model.getProfilePic() != null
            ? CircleAvatar(
                backgroundColor: Colors.transparent,
                backgroundImage: model.getProfilePic().image,
                radius: width * 0.1,
              )
            : CircleAvatar(
                backgroundColor: Colors.transparent,
                backgroundImage: new AssetImage(
                  "assets/img/blank_profile.png",
                ),
                radius: width * 0.1,
              ),
        Container(
          padding: new EdgeInsets.only(left: width * 0.05),
          child: Text(
            model.getName() != "" ? model.getName() : model.lang().anonymous,
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
    @required CreateReplyViewModel model,
    @required BuildContext context,
    @required ScreenArguments screenArguments}) {
  return Container(
    height: height * 0.125,
    margin: new EdgeInsets.only(top: width * 0.05),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        crossButton(args: screenArguments, width: width, model: model),
        Container(
          margin: new EdgeInsets.only(right: width * 0.25),
          child: Text(
            model.lang().replyToPost,
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
            context: context,
            height: height,
            model: model,
            post: screenArguments.post,
            screenArguments: screenArguments),
      ],
    ),
  );
}

Widget crossButton(
    {@required double width,
    @required ScreenArguments args,
    @required CreateReplyViewModel model}) {
  return Container(
    child: RCrossButton(
      size: width * 0.1,
      color: Colour.kvk_white,
      onPressed: () {
        model.replyText.clear();
        model.reset();
        model.back(routeName: args.routeFrom, args: args.oldArgs);
      },
    ),
  );
}

Widget submitButton({
  @required BuildContext context,
  @required double height,
  @required CreateReplyViewModel model,
  @required ScreenArguments screenArguments,
  @required Post post,
}) {
  return Container(
    height: height * 0.125,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            FlatButton(
              child: Text(
                model.lang().send,
                style: TextStyle(
                  height: 0.76,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: "Lato",
                  color: model.replyText.text != ""
                      ? Colour.kvk_white
                      : Colour.kvk_white.withOpacity(0.5),
                ),
              ),
              onPressed: () async {
                if (model.replyText.text != "") {
                  await model
                      .submitReply(
                          args: screenArguments.oldArgs,
                          routeFrom: screenArguments.routeFrom,
                          body: model.replyText.text,
                          context: context,
                          post: post)
                      .then((value) {
                    model.replyText.clear();
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
