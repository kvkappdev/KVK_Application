import 'package:flutter/material.dart';
import 'package:kvk_app/data_struct/announcement.dart';

import 'package:kvk_app/data_struct/post.dart';
import 'package:kvk_app/data_struct/reply.dart';

import 'package:kvk_app/ui/coloursheet.dart';
import 'package:kvk_app/ui/smart_widgets/backButtonResizable.dart';
import 'package:kvk_app/ui/smart_widgets/screen_arguments.dart';
import 'package:kvk_app/ui/templates/kvk_box.dart';
import 'package:kvk_app/ui/templates/kvk_plain_background.dart';
import 'package:kvk_app/ui/viewmodels/forum_flow/view_attachments_viewmodel.dart';
import 'package:stacked/stacked.dart';

class ViewAttachmentsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final ScreenArguments screenArguments =
        ModalRoute.of(context).settings.arguments;

    return ViewModelBuilder<ViewAttachmentViewModel>.reactive(
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
                        colour: Colour.kvk_white,
                      ),
                    ),
                    Container(
                      margin: new EdgeInsets.only(top: screenHeight * 0.125),
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: <Widget>[
                                  files(
                                      context: context,
                                      args: screenArguments,
                                      height: screenHeight,
                                      model: model,
                                      width: screenWidth),
                                ],
                              ),
                            ),
                          ),
                        ],
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
        viewModelBuilder: () => ViewAttachmentViewModel());
  }

  Widget files(
      {@required ScreenArguments args,
      @required ViewAttachmentViewModel model,
      @required BuildContext context,
      @required double width,
      @required double height}) {
    return Container(
      child: Row(
        children: <Widget>[
          new Expanded(
            child: ListView(
              primary: false,
              shrinkWrap: true,
              children: List.generate(
                  args.reply != null
                      ? args.reply.files.length
                      : args.post != null
                          ? args.post.files.length
                          : args.announcement.files.length,
                  (index) => attachedFile(
                      context: context,
                      index: index,
                      model: model,
                      width: width,
                      post: args.post,
                      reply: args.reply,
                      announcement: args.announcement)),
            ),
          ),
        ],
      ),
    );
  }

  Widget attachedFile(
      {@required ViewAttachmentViewModel model,
      @required int index,
      @required double width,
      @required BuildContext context,
      Post post,
      Reply reply,
      Announcement announcement}) {
    return GestureDetector(
      onTap: () {
        model.launchURL(
            context: context,
            file: model.getFiles(
                reply: reply, post: post, announcement: announcement)[index]);
      },
      child: Container(
        child: Row(
          children: <Widget>[
            Container(
              height: width * 0.15,
              width: width * 0.15,
              margin: new EdgeInsets.only(
                  bottom: 10, left: width * 0.05, right: width * 0.01),
              child: fileType(
                model: model,
                index: index,
                post: post,
                reply: reply,
                announcement: announcement,
              ),
            ),
            Container(
              width: width * 0.75,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    model
                        .getFiles(
                            reply: reply,
                            post: post,
                            announcement: announcement)[index]
                        .name,
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
                    model
                            .getFiles(
                                reply: reply,
                                post: post,
                                announcement: announcement)[index]
                            .fileSize +
                        " KB",
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
          ],
        ),
      ),
    );
  }

  Widget fileType({
    @required ViewAttachmentViewModel model,
    @required int index,
    Post post,
    Reply reply,
    Announcement announcement,
  }) {
    return model
                .getFiles(
                    reply: reply, post: post, announcement: announcement)[index]
                .filetype ==
            "pdf"
        ? Image(
            image: AssetImage("assets/img/pdf_icon.png"),
          )
        : model
                        .getFiles(
                            reply: reply,
                            post: post,
                            announcement: announcement)[index]
                        .filetype ==
                    "doc" ||
                model
                        .getFiles(
                            reply: reply,
                            post: post,
                            announcement: announcement)[index]
                        .filetype ==
                    "docx"
            ? Image(
                image: AssetImage("assets/img/doc_icon.png"),
              )
            : model
                            .getFiles(
                                reply: reply,
                                post: post,
                                announcement: announcement)[index]
                            .filetype ==
                        "ppt" ||
                    model
                            .getFiles(
                                reply: reply,
                                post: post,
                                announcement: announcement)[index]
                            .filetype ==
                        "pptx"
                ? Image(
                    image: AssetImage("assets/img/ppt_icon.png"),
                  )
                : Image(
                    image: AssetImage("assets/img/excel_icon.png"),
                  );
  }

  Widget topBar(
      {@required double height,
      @required double width,
      @required ViewAttachmentViewModel model,
      @required BuildContext context,
      @required ScreenArguments args}) {
    return Container(
      height: height * 0.125,
      margin: new EdgeInsets.only(top: width * 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          backButton(width: width, model: model),
          Container(
            margin: new EdgeInsets.only(right: width * 0.3),
            child: Text(
              model.lang().viewFiles,
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
      @required ViewAttachmentViewModel model,}) {
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
}
