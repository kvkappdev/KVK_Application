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
import 'package:kvk_app/ui/viewmodels/edit/edit_post_viewmodel.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:stacked/stacked.dart';
import 'package:video_player/video_player.dart';

final log = getLogger("Edit Post View");
final fileExtensionRegex = new RegExp(r"\.(?:.(?!\.))+$");

class EditPostView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final ScreenArguments screenArguments =
        ModalRoute.of(context).settings.arguments;
    return ViewModelBuilder<EditPostViewModel>.reactive(
      builder: (context, model, child) => WillPopScope(
        onWillPop: () {
          return model.onBackPressed(screenArguments: screenArguments.oldArgs);
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
                      postDetails(
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
      viewModelBuilder: () => EditPostViewModel(),
    );
  }
}

Widget attachedFiles(
    {@required EditPostViewModel model,
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
    {@required EditPostViewModel model,
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

Widget fileType({@required EditPostViewModel model, @required int index}) {
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
    {@required EditPostViewModel model,
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
    {@required EditPostViewModel model,
    @required AttachedVideo vid,
    @required double width,
    @required int index}) {
  return Stack(
    children: <Widget>[
      FutureBuilder(
          future: vid.videoPlayerControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Container(
                child: FittedBox(
                  child: SizedBox(
                    width: vid.videoPlayerController.value.aspectRatio,
                    height: 1,
                    child: VideoPlayer(vid.videoPlayerController),
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
            Icon(KVKIcons.video_camera_figma_exported_custom,
                color: Colour.kvk_white, size: 16),
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
    {@required EditPostViewModel model,
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
    {@required EditPostViewModel model,
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

Widget postDetails(
    {@required EditPostViewModel model,
    @required double width,
    @required double height,
    @required ScreenArguments args}) {
  return Container(
    padding: new EdgeInsets.only(top: height * 0.27, left: width * 0.1),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        titleInput(model: model, width: width),
        category(model: model, width: width),
        bodyInput(model: model, width: width),
      ],
    ),
  );
}

Widget bodyInput({@required EditPostViewModel model, @required double width}) {
  return Container(
    padding: new EdgeInsets.only(right: width * 0.1),
    child: TextField(
      onChanged: (_) {
        model.rebuild();
      },
      controller: model.postText,
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

Widget titleInput({@required EditPostViewModel model, @required double width}) {
  return Container(
    padding: new EdgeInsets.only(right: width * 0.1),
    child: TextField(
      onChanged: (_) {
        model.rebuild();
      },
      controller: model.titleText,
      style: TextStyle(
        color: Colour.kvk_black,
        fontFamily: "Lato",
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      maxLines: null,
      decoration: InputDecoration(
          border: InputBorder.none,
          hintText: model.lang().title,
          hintStyle: TextStyle(
            color: Colour.kvk_grey,
            fontFamily: "Lato",
            fontWeight: FontWeight.w700,
            fontSize: 16,
          )),
    ),
  );
}

Widget category({@required EditPostViewModel model, @required double width}) {
  return Container(
    padding: new EdgeInsets.only(right: width * 0.1),
    child: DropdownButton(
      value: 0,
      isExpanded: true,
      onChanged: (int value) {},
      iconEnabledColor: Colour.kvk_orange,
      style: TextStyle(color: Colour.kvk_black),
      selectedItemBuilder: (BuildContext context) {
        return model.getOptions().map((String value) {
          return Text(
            model.getOptions()[0],
            style: TextStyle(
              color: Colour.kvk_orange,
              height: 2.5,
            ),
          );
        }).toList();
      },
      items: model.getOptions().map<DropdownMenuItem<int>>((String value) {
        return DropdownMenuItem<int>(
          value: model.getOptions().indexOf(value),
          child: Text(value),
        );
      }).toList(),
    ),
  );
}

Widget userDetails(
    {@required EditPostViewModel model,
    @required double width,
    @required double height,
    @required ScreenArguments args}) {
  if (!model.loaded) model.loadArgs(args: args);
  return Container(
    padding: new EdgeInsets.only(top: height * 0.15, left: width * 0.05),
    child: Row(
      children: <Widget>[
        model.getProfilePic(userId: args.post.userId) != null
            ? CircleAvatar(
                backgroundColor: Colors.transparent,
                backgroundImage:
                    model.getProfilePic(userId: args.post.userId).image,
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
            model.getName(userId: args.post.userId) != ""
                ? model.getName(userId: args.post.userId)
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
    @required EditPostViewModel model,
    @required BuildContext context,
    @required ScreenArguments args}) {
  return Container(
    height: height * 0.125,
    margin: new EdgeInsets.only(top: width * 0.05),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        crossButton(width: width, model: model, screenArguments: args),
        Container(
          margin: new EdgeInsets.only(right: width * 0.3),
          child: Text(
            model.lang().editOptions[0],
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
    {@required double width,
    @required EditPostViewModel model,
    @required ScreenArguments screenArguments}) {
  return Container(
    child: RCrossButton(
      size: width * 0.1,
      color: Colour.kvk_white,
      onPressed: () {
        model.reset();
        model.onBackPressed(screenArguments: screenArguments.oldArgs);
      },
    ),
  );
}

Widget submitButton(
    {@required BuildContext context,
    @required double height,
    @required EditPostViewModel model,
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
                  color: model.titleText.text != "" && model.postText.text != ""
                      ? Colour.kvk_white
                      : Colour.kvk_white.withOpacity(0.5),
                ),
              ),
              onPressed: () {
                if (model.titleText.text != "" && model.postText.text != "") {
                  model
                      .updatePost(
                          title: model.titleText.text,
                          body: model.postText.text,
                          context: context,
                          args: args)
                      .then((value) {
                    model.titleText.clear();
                    model.postText.clear();
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
