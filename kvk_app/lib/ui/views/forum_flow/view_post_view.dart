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
import 'package:kvk_app/ui/smart_widgets/button.dart';
import 'package:kvk_app/ui/smart_widgets/screen_arguments.dart';
import 'package:kvk_app/ui/templates/kvk_box.dart';
import 'package:kvk_app/ui/templates/kvk_plain_background.dart';
import 'package:kvk_app/ui/viewmodels/forum_flow/view_post_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:video_player/video_player.dart';

final log = getLogger("View Post View");
final TextEditingController _replyTextController = new TextEditingController();

class ViewPostView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final ScreenArguments screenArguments =
        ModalRoute.of(context).settings.arguments;
    return ViewModelBuilder<ViewPostViewModel>.reactive(
        builder: (context, model, child) => WillPopScope(
              onWillPop: () {
                return model.onBackPressed(
                    routeFrom: screenArguments.routeFrom);
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
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: <Widget>[
                                  post(
                                      context: context,
                                      args: screenArguments,
                                      height: screenHeight,
                                      model: model,
                                      width: screenWidth),
                                  replies(
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
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom),
                            alignment: Alignment.bottomCenter,
                            color: Colour.kvk_white,
                            child: replyToPost(
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
            ),
        viewModelBuilder: () => ViewPostViewModel());
  }
}

Widget replies(
    {@required ScreenArguments args,
    @required ViewPostViewModel model,
    @required double width,
    @required double height}) {
  return FutureBuilder(
      future: model.loadReplies(post: args.post),
      builder: (context, snapshot) {
        return Container(
          child: ListView(
            padding: new EdgeInsets.all(0),
            primary: false,
            shrinkWrap: true,
            children: List.generate(
              args.post.replies.length,
              (index) => InkWell(
                onTap: () {
                  model.viewReply(
                      reply: args.post.replies[index],
                      user: model.getUser(
                          userId: args.post.replies[index].userId),
                      args: args);
                },
                child: Card(
                  child: Container(
                    padding: new EdgeInsets.all(10),
                    child: Row(
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            postReplyDetails(
                              args: args,
                              reply: args.post.replies[index],
                              model: model,
                              width: width,
                              context: context,
                            ),
                            Container(
                              margin: new EdgeInsets.only(top: 10),
                              child: body(
                                  width: width,
                                  body: args.post.replies[index].body),
                            ),
                            media(
                                imgs: args.post.replies[index].imgs,
                                vids: args.post.replies[index].vids,
                                args: args,
                                width: width,
                                model: model,
                                sub: true),
                            Container(
                              margin: new EdgeInsets.only(top: height * 0.01),
                              width: width * 0.9,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  attachedFiles(
                                      args: args,
                                      model: model,
                                      reply: args.post.replies[index]),
                                  viewReplies(
                                      reply: args.post.replies[index],
                                      model: model,
                                      args: args)
                                ],
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
        );
      });
}

Widget post(
    {@required ScreenArguments args,
    @required ViewPostViewModel model,
    @required BuildContext context,
    @required double width,
    @required double height}) {
  return Card(
    child: Container(
      padding: new EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              postUserDetails(
                  args: args, model: model, width: width, context: context),
              title(args: args, width: width),
              category(args: args, model: model),
              body(width: width, body: args.post.body),
              media(
                  imgs: args.post.imgs,
                  vids: args.post.vids,
                  args: args,
                  width: width,
                  model: model),
              Container(
                margin: new EdgeInsets.only(top: height * 0.01),
                width: width * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    attachedFiles(args: args, model: model, post: args.post),
                    model.isMyPost(args: args)
                        ? subscribeButton(model: model, args: args)
                        : Container()
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    ),
  );
}

Widget replyToPost(
    {@required ViewPostViewModel model,
    @required ScreenArguments args,
    @required BuildContext context}) {
  return model.getHasProfile()
      ? Button(
          text: model.lang().reply,
          colour: Colour.kvk_orange,
          onPress: () {
            model.navigateToLongReply(screenArguments: args);
          },
        )
      : Button(
          text: model.lang().featureLockedMessages[0],
          colour: Colour.kvk_grey,
          onPress: () {
            model.navigateToFeatureLocked(args: args);
          },
        );
}

Widget attachedFiles(
    {@required ViewPostViewModel model,
    @required ScreenArguments args,
    Post post,
    Reply reply}) {
  return InkWell(
    onTap: () {
      if (reply != null) {
        if (reply.files.length > 0) {
          model.viewAttachments(reply: reply, args: args);
        }
      } else {
        if (post.files.length > 0) {
          model.viewAttachments(reply: reply, args: args);
        }
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
              post != null
                  ? post.files.length.toString()
                  : reply.files.length.toString(),
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

Widget viewReplies(
    {@required Reply reply,
    @required ViewPostViewModel model,
    @required ScreenArguments args}) {
  return Container(
    child: Row(
      children: <Widget>[
        Icon(
          KVKIcons.reply_original,
          color: Colour.kvk_orange,
        ),
        Text(
          reply.totalReplies.toString(),
          style: TextStyle(
            color: Colour.kvk_orange,
          ),
        )
      ],
    ),
  );
}

Widget subscribeButton(
    {@required ViewPostViewModel model, @required ScreenArguments args}) {
  return Container(
    width: 130,
    child: FlatButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      child: Text(
        model.subscribed(args: args)
            ? model.lang().subscribe[1].toUpperCase()
            : model.lang().subscribe[0].toUpperCase(),
        style: TextStyle(
            fontSize: 14, fontFamily: "Lato", fontWeight: FontWeight.w400),
      ),
      textColor: Colour.kvk_white,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onPressed: () {
        model.getHasProfile()
            ? model.subscribed(args: args)
                ? model.unsubscribe(post: args.post)
                : model.subscribe(post: args.post)
            : model.navigateToFeatureLocked(args: args);
      },
      color: model.subscribed(args: args) ? Colour.kvk_grey : Colour.kvk_orange,
    ),
  );
}

Widget media(
    {@required List<AttachedImage> imgs,
    @required List<AttachedVideo> vids,
    @required ScreenArguments args,
    @required double width,
    @required ViewPostViewModel model,
    sub = false}) {
  if (!model.loaded) model.loadArgs(args: args);
  return sub
      ? imgs.length > 0 || vids.length > 0
          ? Container(
              height: 200,
              width: width - 28,
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
                              width: 100,
                              height: 100,
                            ),
                            onTap: () {},
                          )
                        : Stack(
                            alignment: Alignment.bottomLeft,
                            children: <Widget>[
                              Container(
                                child: FutureBuilder(
                                    future: model
                                        .getVideoFutures()[index - imgs.length],
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        return Container(
                                            child: FittedBox(
                                          child: SizedBox(
                                            width: model
                                                .getControllers()[
                                                    index - imgs.length]
                                                .value
                                                .aspectRatio,
                                            height: model
                                                .getControllers()[
                                                    index - imgs.length]
                                                .value
                                                .aspectRatio,
                                            child: VideoPlayer(
                                                model.getControllers()[
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
                                width: 100,
                                height: 100,
                              ),
                              Container(
                                  width: 100,
                                  height: 100,
                                  alignment: Alignment.bottomLeft,
                                  child: Icon(
                                    KVKIcons.video_camera_figma_exported_custom,
                                    color: Colour.kvk_white,
                                  )),
                            ],
                          );
                  },
                ),
              ),
            )
          : Container()
      : Container(
          height: imgs.length > 0 || vids.length > 0 ? width * 0.75 : 0,
          width: imgs.length > 0 || vids.length > 0 ? width - 28 : 0,
          child: ListView(
            scrollDirection: Axis.horizontal,
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
        );
}

Widget category(
    {@required ViewPostViewModel model, @required ScreenArguments args}) {
  return Container(
    margin: new EdgeInsets.symmetric(vertical: 10),
    padding: new EdgeInsets.symmetric(horizontal: 10, vertical: 2),
    decoration: BoxDecoration(
      color: Colour.kvk_topic_highlight,
      borderRadius: new BorderRadius.all(
        Radius.circular(5),
      ),
    ),
    child: Text(
      model.langVal() == 0
          ? model.getTopicByPost(post: args.post).engName
          : model.getTopicByPost(post: args.post).marName,
      style: TextStyle(
        color: Colour.kvk_dark_grey,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        fontFamily: "Lato",
      ),
    ),
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

Widget title({@required double width, @required ScreenArguments args}) {
  return Container(
    width: width - 28,
    margin: new EdgeInsets.only(top: 15),
    child: Text(
      args.post.title,
      style: TextStyle(
          color: Colour.kvk_black,
          fontWeight: FontWeight.w700,
          fontSize: 16,
          fontFamily: "Lato"),
      overflow: TextOverflow.fade,
    ),
  );
}

Widget postReplyDetails({
  @required double width,
  @required ScreenArguments args,
  @required Reply reply,
  @required ViewPostViewModel model,
  @required BuildContext context,
}) {
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
                model.getUser(userId: reply.userId).profilePic != "default"
                    ? NetworkImage(
                        model.getUser(userId: reply.userId).profilePic,
                      )
                    : AssetImage("assets/img/blank_profile.png"),
            radius: width * 0.075,
          ),
          model.getUser(userId: reply.userId).role > 0
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
        width:
            width * 0.85 - 42, //8 padding +10 margin +8 container +8 contaienr?
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  model.getUser(userId: reply.userId).name,
                  style: TextStyle(
                      color: Colour.kvk_post_grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Lato"),
                ),
                Text(
                  reply.edited
                      ? model.getPostTime(reply.time) +
                          " (" +
                          model.lang().edited.toLowerCase() +
                          ")"
                      : model.getPostTime(reply.time),
                  style: TextStyle(
                      color: Colour.kvk_post_grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Lato"),
                ),
              ],
            ),
            moreButton(
                context: context,
                model: model,
                reply: reply,
                args: args,
                post: args.post),
          ],
        ),
      ),
    ],
  );
}

Widget moreButton({
  @required ViewPostViewModel model,
  @required BuildContext context,
  @required ScreenArguments args,
  Reply reply,
  Post post,
}) {
  return Container(
    margin: new EdgeInsets.only(bottom: 20),
    child: model.canIEdit(reply: reply, post: post)
        ? InkWell(
            onTap: () {
              _showPicker(
                  context: context,
                  model: model,
                  args: args,
                  reply: reply,
                  post: post);
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
    @required ViewPostViewModel model,
    @required ScreenArguments args,
    @required Post post,
    @required Reply reply}) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            child: reply != null
                ? new Wrap(
                    children: <Widget>[
                      ListTile(
                        leading: Icon(KVKIcons.edit2_original),
                        title: Text(model.lang().editOptions[2]),
                        onTap: () {
                          model.edit(post: post, reply: reply, args: args);
                        },
                      ),
                      ListTile(
                          leading: Icon(KVKIcons.delete_original),
                          title: Text(model.lang().editOptions[3]),
                          onTap: () {
                            _deletePostConfirmation(
                                context: context,
                                model: model,
                                reply: reply,
                                post: post);
                          }),
                    ],
                  )
                : new Wrap(
                    children: <Widget>[
                      ListTile(
                        leading: Icon(KVKIcons.edit2_original),
                        title: Text(model.lang().editOptions[0]),
                        onTap: () {
                          model.edit(post: post, args: args);
                        },
                      ),
                      ListTile(
                          leading: Icon(KVKIcons.delete_original),
                          title: Text(model.lang().editOptions[1]),
                          onTap: () {
                            _deletePostConfirmation(
                                context: context, model: model, post: post);
                          }),
                    ],
                  ),
          ),
        );
      });
}

_deletePostConfirmation(
    {@required BuildContext context,
    @required ViewPostViewModel model,
    Post post,
    Reply reply}) {
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

      if (reply != null) {
        model.deleteReply(context: context, post: post, reply: reply);
      } else {
        model.deletePost(context: context, post: post);
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

Widget postUserDetails(
    {@required double width,
    @required ScreenArguments args,
    @required ViewPostViewModel model,
    @required BuildContext context}) {
  log.d(args.post.userId);
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
        child: Stack(
          alignment: Alignment.bottomRight,
          children: <Widget>[
            CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage:
                  model.getUser(userId: args.post.userId).profilePic !=
                          "default"
                      ? NetworkImage(
                          model.getUser(userId: args.post.userId).profilePic,
                        )
                      : AssetImage("assets/img/blank_profile.png"),
              radius: width * 0.075,
            ),
            model.getUser(userId: args.post.userId).role > 0
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
          ],
        ),
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
                  model.getUser(userId: args.post.userId).name,
                  style: TextStyle(
                      color: Colour.kvk_post_grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Lato"),
                ),
                Text(
                  args.post.edited
                      ? model.getPostTime(args.post.time) +
                          " (" +
                          model.lang().edited.toLowerCase() +
                          ")"
                      : model.getPostTime(args.post.time),
                  style: TextStyle(
                      color: Colour.kvk_post_grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Lato"),
                ),
              ],
            ),
            moreButton(
                context: context, model: model, args: args, post: args.post),
          ],
        ),
      ),
    ],
  );
}

Widget topBar(
    {@required double height,
    @required double width,
    @required ViewPostViewModel model,
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
            model.lang().viewPost,
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
    @required ViewPostViewModel model,
    @required ScreenArguments args}) {
  return Container(
    child: RBackButton(
      size: width * 0.1,
      color: Colour.kvk_white,
      onPressed: () {
        model.onBackPressed(routeFrom: args.routeFrom);
      },
    ),
  );
}
