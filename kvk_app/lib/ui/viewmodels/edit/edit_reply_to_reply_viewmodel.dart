import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/data_struct/attachedImage.dart';
import 'package:kvk_app/data_struct/attachedVideo.dart';
import 'package:kvk_app/data_struct/attachedFile.dart';
import 'package:kvk_app/data_struct/post.dart';
import 'package:kvk_app/data_struct/reply.dart';
import 'package:kvk_app/services/database_service.dart';
import 'package:kvk_app/services/internal_profile_service.dart';
import 'package:kvk_app/services/posts_service.dart';
import 'package:kvk_app/ui/smart_widgets/screen_arguments.dart';
import 'package:kvk_app/ui/templates/kvk_viewmodel.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:video_player/video_player.dart';

final log = getLogger("Edit Reply View Model");

class EditReplyToReplyViewModel extends KVKViewModel {
  ImagePicker _imagePicker = new ImagePicker();
  List<AttachedImage> _attachedImgs = List<AttachedImage>();
  List<AttachedVideo> _attachedVids = List<AttachedVideo>();
  List<AttachedFile> _attachedFiles = List<AttachedFile>();

  InternalProfileService _internalProfileService =
      locator<InternalProfileService>();

  List<VideoPlayerController> _videoPlayerControllers =
      List<VideoPlayerController>();
  List<Future<void>> _initialiseVideoPlayerFutures = List<Future<void>>();

  final PanelController pc = new PanelController();
  final TextEditingController replyText = new TextEditingController();

  NavigationService _navigationService = locator<NavigationService>();

  bool loaded = false;

  DatabaseService _databaseService = locator<DatabaseService>();
  PostsService _postsService = locator<PostsService>();

  void reset() {
    replyText.clear();
    _attachedImgs = List<AttachedImage>();
    _attachedVids = List<AttachedVideo>();
    _attachedFiles = List<AttachedFile>();
  }

  void loadArgs({@required ScreenArguments args}) async {
    replyText.text = args.childReply.body;

    loaded = true;
  }

  Image getProfilePic({@required String userId}) {
    return Image.network(_postsService.getUser(userId: userId).profilePic);
  }

  String getName({@required String userId}) {
    return _postsService.getUser(userId: userId).name;
  }

  List<AttachedImage> getImgs() {
    return _attachedImgs;
  }

  List<AttachedVideo> getVids() {
    return _attachedVids;
  }

  List<AttachedFile> getFiles() {
    return _attachedFiles;
  }

  void removeImage({@required int index}) async {
    _attachedImgs.remove(_attachedImgs[index]);
    rebuild();
  }

  void removeVideo({@required int index}) async {
    _attachedVids.remove(_attachedVids[index]);
    rebuild();
  }

  void removeFile({@required int index}) async {
    _attachedFiles.removeAt(index);
    rebuild();
  }

  /// Creates an image picker, and allows the user to take a photo. Then sets the photo as image.
  ///
  /// param:
  /// returns:
  /// Initial creation: 10/09/2020
  /// Last Updated: 10/09/2020
  void imgFromCamera() async {
    if (_attachedVids.length + _attachedImgs.length < 9) {
      PickedFile image = await _imagePicker.getImage(
          source: ImageSource.camera, imageQuality: 50);
      if (image != null) {
        int fileSize = await getFileSize(image.path);
        AttachedImage img = AttachedImage();
        img.path = image.path;
        img.local = true;
        img.size = (fileSize / 1000).toString();
        _attachedImgs.add(img);
      }
    }
    pc.close();
    rebuild();
  }

  Future<int> getFileSize(String path) async {
    var bytes = new File(path);
    var size = await bytes.readAsBytes();
    return size.length;
  }

  /// Creates an video picker, and allows the user to take a video. Then sets the video as an attachment.
  ///
  /// param:
  /// returns:
  /// Initial creation: 10/09/2020
  /// Last Updated: 8/10/2020
  void videoFromCamera() async {
    if (_attachedVids.length + _attachedImgs.length < 9) {
      PickedFile video =
          await _imagePicker.getVideo(source: ImageSource.camera);
      if (video != null) {
        int fileSize = await getFileSize(video.path);
        AttachedVideo vid = AttachedVideo();
        vid.path = video.path;
        vid.local = true;
        vid.size = (fileSize / 1000).toString();

        _attachedVids.add(vid);
      }
    }
    pc.close();
  }

  /// Creates an File picker, and allows the user to pick a photo or video from their library
  /// Then sets the media as Platform File.
  ///
  /// param:
  /// returns:
  /// Initial creation: 10/09/2020
  /// Last Updated: 10/09/2020
  void fromGallery() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        allowedExtensions: [
          "gif",
          "mp4",
          "mov",
          "wmv",
          "avi",
          "jpg",
          "jpeg",
          "png",
          "raw"
        ]);

    if (result != null) {
      List<PlatformFile> files = <PlatformFile>[];
      for (int i = 0; i < result.files.length; i++) {
        PlatformFile file = result.files[i];
        files.add(file);
      }

      for (int i = 0; i < files.length; i++) {
        int fileSize = await getFileSize(files[i].path);

        if (files[i].extension == "jpg" ||
            files[i].extension == "jpeg" ||
            files[i].extension == "png" ||
            files[i].extension == "raw" ||
            files[i].extension == "gif") {
          log.d("Image");
          AttachedImage img = AttachedImage();
          img.path = files[i].path;
          img.local = true;
          img.size = (fileSize / 1000).toString();
          _attachedImgs.add(img);
        } else {
          log.d("Video");
          AttachedVideo vid = AttachedVideo();
          vid.local = true;
          vid.path = files[i].path;
          vid.size = (fileSize / 1000).toString();
          _attachedVids.add(vid);
        }
      }
    }
    pc.close();
    rebuild();
  }

  /// Creates a file picker and allows the user to select one or more files from their library
  ///
  /// param:
  /// returns:
  /// Initial creation: 13/10/2020
  /// Last Updated:13/10/2020
  void filesFromLibrary() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        allowedExtensions: [
          "pdf",
          "doc",
          "docx",
          "xls",
          "xlsx",
          "ppt",
          "pptx"
        ]);

    if (result != null) {
      List<AttachedFile> files = <AttachedFile>[];
      for (int i = 0; i < result.files.length; i++) {
        AttachedFile file = AttachedFile();
        file.fileURL = result.files[i].path;
        file.name = result.files[i].name;
        file.fileSize = result.files[i].size.toString();
        file.filetype = result.files[i].extension;
        files.add(file);
      }

      for (int i = 0; i < files.length; i++) {
        int fileSize = result.files[i].size;

        _attachedFiles.add(files[i]);
      }
    }
    pc.close();
    rebuild();
  }

  Duration getDuration(int index) {
    return _videoPlayerControllers[index].value.duration;
  }

  Future updateReplyToReply({
    @required Reply mainReply,
    @required Post post,
    @required Reply childReply,
    @required String body,
    @required BuildContext context,
    @required ScreenArguments args,
  }) async {
    _databaseService.updateReplyToReply(
        post: post,
        mainReply: mainReply,
        childReply: childReply,
        body: body,
        context: context,
        args: args);
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<bool> onBackPressed(
      {@required ScreenArguments screenArguments}) async {
//TODO: FIX THIS NAVIGATION
    await popBack().whenComplete(() {
      return true;
    });

    return false;
  }

  void togglePanel() {
    if (pc.isPanelClosed) {
      pc.open();
    } else if (pc.isPanelOpen) {
      pc.close();
    }
  }
}
