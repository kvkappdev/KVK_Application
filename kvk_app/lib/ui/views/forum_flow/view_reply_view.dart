import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/data_struct/attachedImage.dart';
import 'package:kvk_app/data_struct/attachedVideo.dart';
import 'package:kvk_app/data_struct/post.dart';
import 'package:kvk_app/data_struct/reply.dart';
import 'package:kvk_app/icons/kvk_icons.dart';
import 'package:kvk_app/ui/coloursheet.dart';
import 'package:kvk_app/ui/smart_widgets/backButtonResizable.dart';
import 'package:kvk_app/ui/smart_widgets/screen_arguments.dart';
import 'package:kvk_app/ui/templates/kvk_box.dart';
import 'package:kvk_app/ui/templates/kvk_plain_background.dart';
import 'package:kvk_app/ui/viewmodels/forum_flow/view_reply_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:video_player/video_player.dart';

final log = getLogger("View Reply View");
final TextEditingController _replyTextController = new TextEditingController();

class ViewReplyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final ScreenArguments screenArguments =
        ModalRoute.of(context).settings.arguments;
    return ViewModelBuilder<ViewReplyViewModel>.reactive(
        builder: (context, model, child) => Scaffold(
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
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: <Widget>[
                                reply(
                                    args: screenArguments,
                                    height: screenHeight,
                                    model: model,
                                    width: screenWidth,
                                    context: context),
                                repliesToReply(
                                    args: screenArguments,
                                    height: screenHeight,
                                    model: model,
                                    width: screenWidth),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: new EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          alignment: Alignment.bottomCenter,
                          child: quickReplyToReply(
                              model: model,
                              args: screenArguments,
                              context: context),
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
        viewModelBuilder: () => ViewReplyViewModel());
  }
}

Widget repliesToReply(
    {@required ScreenArguments args,
    @required ViewReplyViewModel model,
    @required double width,
    @required double height}) {
  return FutureBuilder(
    future: model.loadRepliesToReplies(post: args.post, reply: args.reply),
    builder: (context, snapshot) {
      return Container(
        child: ListView(
          padding: new EdgeInsets.all(0),
          primary: false,
          shrinkWrap: true,
          children: List.generate(
            args.reply.replies.length,
            (index) => Container(
              decoration: BoxDecoration(
                color: Colour.kvk_white,
              ),
              padding:
                  new EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 25),
              child: Container(
                padding: new EdgeInsets.only(left: 20, bottom: 20),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(width: 1, color: Colour.kvk_grey))),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          replyToReplyDetails(
                              childReply: args.reply.replies[index],
                              mainReply: args.reply,
                              args: args,
                              post: args.post,
                              context: context,
                              model: model,
                              width: width),
                          Container(
                            margin: new EdgeInsets.only(top: 10),
                            child: body(
                                width: width,
                                body: args.reply.replies[index].body),
                          ),
                          media(
                              imgs: args.reply.replies[index].imgs,
                              vids: args.reply.replies[index].vids,
                              width: width,
                              model: model,
                              args: args),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget reply(
    {@required ScreenArguments args,
    @required ViewReplyViewModel model,
    @required double width,
    @required double height,
    @required BuildContext context}) {
  return Card(
    child: Container(
      padding: new EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                replyUserDetails(
                    args: args, model: model, width: width, context: context),
                body(width: width, body: args.reply.body),
                media(
                    imgs: args.reply.imgs,
                    vids: args.reply.vids,
                    width: width,
                    model: model,
                    args: args),
                Container(
                  margin: new EdgeInsets.only(top: height * 0.01),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      attachedFiles(
                          model: model, reply: args.reply, args: args),
                    ],
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

Widget quickReplyToReply(
    {@required ViewReplyViewModel model,
    @required ScreenArguments args,
    @required BuildContext context}) {
  return Container(
    decoration: BoxDecoration(
      color: Colour.kvk_white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey,
          spreadRadius: 0,
          blurRadius: 20,
          offset: Offset(0, 5),
        ),
      ],
    ),
    padding: new EdgeInsets.all(15.0),
    child: Container(
      decoration: BoxDecoration(
          borderRadius: new BorderRadius.all(Radius.circular(30)),
          border: Border.all(width: 1, color: Colour.kvk_grey)),
      child: Row(
        children: <Widget>[
          Expanded(
            child: model.getHasProfile()
                ? Container(
                    padding: new EdgeInsets.only(left: 15),
                    child: TextField(
                      controller: _replyTextController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Quick Reply',
                      ),
                      maxLines: 3,
                      minLines: 1,
                      onChanged: (_) => model.rebuild(),
                    ))
                : Container(
                    padding: new EdgeInsets.only(left: 15),
                    child: InkWell(
                      onTap: () {
                        model.navigateToFeatureLocked(args: args);
                      },
                      child: Text(
                        'Quick Reply',
                        style: TextStyle(color: Colour.kvk_grey),
                      ),
                    ),
                  ),
          ),
          Container(
            child: model.getHasProfile()
                ? IconButton(
                    icon: Icon(
                      KVKIcons.paper_plane_figma_exported_custom,
                      color: _replyTextController.text != ""
                          ? Colour.kvk_orange
                          : Colour.kvk_grey,
                    ),
                    onPressed: () async {
                      if (_replyTextController.text != "") {
                        await model
                            .createReplyToReply(
                                body: _replyTextController.text,
                                args: args,
                                context: context)
                            .whenComplete(() => model.rebuild());
                        _replyTextController.clear();
                      }
                    },
                  )
                : IconButton(
                    icon: Icon(
                      KVKIcons.lock_figma_exported_custom,
                      color: Colour.kvk_grey,
                    ),
                    onPressed: () {
                      model.navigateToFeatureLocked(args: args);
                    },
                  ),
          ),
        ],
      ),
    ),
  );
}

Widget attachedFiles(
    {@required ViewReplyViewModel model,
    @required Reply reply,
    @required ScreenArguments args}) {
  return InkWell(
    onTap: () {
      if (reply.files.length > 0) {
        model.viewAttachments(reply: reply, args: args);
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
              reply.files.length.toString(),
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

Widget media(
    {@required List<AttachedImage> imgs,
    @required List<AttachedVideo> vids,
    @required double width,
    @required ViewReplyViewModel model,
    @required ScreenArguments args}) {
  if (!model.loaded) model.loadArgs(args: args);

  return imgs.length + vids.length > 0
      ? Container(
          // height: imgs.length > 0 || vids.length > 0 ? width * 0.75 : 0,
          width: imgs.length > 0 || vids.length > 0 ? width - 28 : 0,
          child: GridView.count(
            primary: false,
            shrinkWrap: true,
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: List.generate(
              imgs.length + vids.length,
              (index) {
                //Videos need to be displayed
                return index < imgs.length
                    ? GestureDetector(
                        child: Container(
                          padding: new EdgeInsets.all(5),
                          child: FittedBox(
                              child: Image.network(imgs[index].path),
                              fit: BoxFit.cover),
                          width: width * 0.75,
                          height: width * 0.75,
                        ),
                        onTap: () {},
                      )
                    : GestureDetector(
                        child: Container(
                          child: FutureBuilder(
                              future:
                                  model.getVideoFutures()[index - imgs.length],
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return Container(
                                      child: FittedBox(
                                    child: SizedBox(
                                      width: model
                                          .getControllers()[index - imgs.length]
                                          .value
                                          .aspectRatio,
                                      height: model
                                          .getControllers()[index - imgs.length]
                                          .value
                                          .aspectRatio,
                                      child: VideoPlayer(model.getControllers()[
                                          index - imgs.length]),
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
                        onTap: () => model.togglePlay(
                            controller:
                                model.getControllers()[index - imgs.length]));
              },
            ),
          ),
        )
      : Container();
}

Widget body({@required double width, @required String body}) {
  return Container(
    padding: new EdgeInsets.only(top: 10),
    child: Text(
      body,
      style: TextStyle(
          color: Colour.kvk_black,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontFamily: "Lato"),
    ),
  );
}

Widget replyToReplyDetails(
    {@required double width,
    @required Reply childReply,
    @required Reply mainReply,
    @required Post post,
    @required ScreenArguments args,
    @required BuildContext context,
    @required ViewReplyViewModel model}) {
  return Row(children: <Widget>[
    Container(
      margin: new EdgeInsets.only(right: 10),
      decoration: new BoxDecoration(
        border: Border.all(
          color: Colour.kvk_nav_grey,
        ),
        color: Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.transparent,
            backgroundImage:
                model.getUser(userId: childReply.userId).profilePic != "default"
                    ? NetworkImage(
                        model.getUser(userId: childReply.userId).profilePic,
                      )
                    : AssetImage("assets/img/blank_profile.png"),
            radius: width * 0.06,
          ),
          model.getUser(userId: childReply.userId).role > 0
              ? Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colour.kvk_grey),
                      shape: BoxShape.circle,
                      color: Colour.kvk_white),
                  child: Icon(
                    KVKIcons.leaf_figma_exported_custom,
                    color: Colour.kvk_leaf_green,
                    size: 12,
                  ))
              : Container(),
        ],
      ),
    ),
    Container(
      width:
          width * 0.85 - 100, //8 padding +10 margin +8 container +8 contaienr?
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                model.getUser(userId: childReply.userId).name,
                style: TextStyle(
                    color: Colour.kvk_post_grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Lato"),
              ),
              Text(
                childReply.edited
                    ? model.getPostTime(childReply.time) +
                        " (" +
                        model.lang().edited.toLowerCase() +
                        ")"
                    : model.getPostTime(childReply.time),
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
    moreButton(
        args: args,
        context: context,
        model: model,
        mainReply: mainReply,
        childReply: childReply,
        post: post),
  ]);
}

Widget replyUserDetails(
    {@required double width,
    @required ScreenArguments args,
    @required ViewReplyViewModel model,
    @required BuildContext context}) {
  return Row(children: <Widget>[
    Container(
      margin: new EdgeInsets.only(right: 10),
      decoration: new BoxDecoration(
        border: Border.all(
          color: Colour.kvk_nav_grey,
        ),
        color: Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.transparent,
            backgroundImage:
                model.getUser(userId: args.reply.userId).profilePic != "default"
                    ? NetworkImage(
                        model.getUser(userId: args.reply.userId).profilePic,
                      )
                    : AssetImage("assets/img/blank_profile.png"),
            radius: width * 0.075,
          ),
          model.getUser(userId: args.reply.userId).role > 0
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
        ],
      ),
    ),
    Container(
        width:
            width * 0.85 - 50, //8 padding +10 margin +8 container +8 contaienr?
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  model.getUser(userId: args.reply.userId).name,
                  style: TextStyle(
                      color: Colour.kvk_post_grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Lato"),
                ),
                Text(
                  args.reply.edited
                      ? model.getPostTime(args.reply.time) +
                          " (" +
                          model.lang().edited.toLowerCase() +
                          ")"
                      : model.getPostTime(args.reply.time),
                  style: TextStyle(
                      color: Colour.kvk_post_grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Lato"),
                ),
              ],
            ),
            moreButton(
                args: args,
                context: context,
                model: model,
                mainReply: args.reply,
                post: args.post),
          ],
        ))
  ]);
}

Widget topBar(
    {@required double height,
    @required double width,
    @required ViewReplyViewModel model,
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
            model.lang().viewReply,
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

Widget moreButton({
  @required ViewReplyViewModel model,
  @required BuildContext context,
  @required ScreenArguments args,
  Reply mainReply,
  Reply childReply,
  Post post,
}) {
  return Container(
    margin: new EdgeInsets.only(bottom: 20),
    child: model.canIEdit(mainReply: mainReply, childReply: childReply)
        ? InkWell(
            onTap: () {
              _showPicker(
                  context: context,
                  model: model,
                  mainReply: mainReply,
                  childReply: childReply,
                  post: post,
                  args: args);
            },
            child: Icon(
              KVKIcons.show_more_button_with_three_dots_original,
              color: Colour.kvk_orange,
            ),
          )
        : Container(),
  );
}

void _showPicker({
  @required BuildContext context,
  @required ViewReplyViewModel model,
  @required Post post,
  @required Reply mainReply,
  @required Reply childReply,
  @required ScreenArguments args,
}) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            child: childReply != null
                //Edit child Reply
                ? new Wrap(
                    children: <Widget>[
                      ListTile(
                        leading: Icon(KVKIcons.edit2_original),
                        title: Text(model.lang().editOptions[2]),
                        onTap: () {
                          model.edit(
                              post: post,
                              mainReply: mainReply,
                              childReply: childReply,
                              args: args);
                        },
                      ),
                      ListTile(
                          leading: Icon(KVKIcons.delete_original),
                          title: Text(model.lang().editOptions[3]),
                          onTap: () {
                            _deleteReplyConfirmation(
                                context: context,
                                model: model,
                                mainReply: mainReply,
                                childReply: childReply,
                                post: post);
                          }),
                    ],
                  )
                : new Wrap(
                    children: <Widget>[
                      ListTile(
                        leading: Icon(KVKIcons.edit2_original),
                        title: Text(model.lang().editOptions[2]),
                        onTap: () {
                          model.edit(
                              post: post, mainReply: mainReply, args: args);
                        },
                      ),
                      ListTile(
                          leading: Icon(KVKIcons.delete_original),
                          title: Text(model.lang().editOptions[3]),
                          onTap: () {
                            _deleteReplyConfirmation(
                                context: context,
                                model: model,
                                mainReply: mainReply,
                                post: post);
                          }),
                    ],
                  ),
          ),
        );
      });
}

_deleteReplyConfirmation(
    {@required BuildContext context,
    @required ViewReplyViewModel model,
    @required Post post,
    Reply mainReply,
    Reply childReply}) {
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

      if (childReply != null) {
        model.deleteReplytoReply(
            context: context,
            post: post,
            reply: mainReply,
            childReply: childReply);
      } else {
        model.deleteReply(context: context, post: post, reply: mainReply);
      }
    },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    content: Text(
        reply != null
            ? model.lang().deleteDialog[3]
            : model.lang().deleteDialog[2],
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

Widget backButton(
    {@required double width,
    @required ViewReplyViewModel model,
    @required ScreenArguments args}) {
  return Container(
    child: RBackButton(
      size: width * 0.1,
      color: Colour.kvk_white,
      onPressed: () {
        model.back(routeName: args.routeFrom, args: args.oldArgs);
      },
    ),
  );
}
