import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/data_struct/attachedImage.dart';
import 'package:kvk_app/data_struct/attachedVideo.dart';
import 'package:kvk_app/data_struct/attachedFile.dart';
import 'package:kvk_app/icons/kvk_icons.dart';
import 'package:kvk_app/services/database_service.dart';
import 'package:kvk_app/services/posts_service.dart';
import 'package:kvk_app/ui/coloursheet.dart';
import 'package:kvk_app/ui/smart_widgets/alert_builder.dart';
import 'package:kvk_app/ui/smart_widgets/screen_arguments.dart';
import 'package:kvk_app/ui/templates/kvk_viewmodel.dart';
import 'package:kvk_app/ui/text_interface.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:video_player/video_player.dart';

final log = getLogger("Edit Announcement Viewmodel");

class EditAnnouncementViewModel extends KVKViewModel {
  ImagePicker _imagePicker = new ImagePicker();
  List<AttachedImage> _attachedImg = List<AttachedImage>();
  List<AttachedVideo> _attachedVid = List<AttachedVideo>();
  List<AttachedFile> _attachedFiles = List<AttachedFile>();
  List<VideoPlayerController> _videoPlayerControllers =
      List<VideoPlayerController>();
  List<Future<void>> _initialiseVideoPlayerFutures = List<Future<void>>();

  NavigationService _navigationService = locator<NavigationService>();

  final PanelController pc = new PanelController();
  final TextEditingController announcementText = new TextEditingController();

  AlertBuilder _mediaQuantityErrorAlert;
  int mediaQuantity = 0;

  bool loaded = false;

  double postSize = 0;
  int maxPostSize = 50000000;

  DatabaseService _databaseService = locator<DatabaseService>();
  PostsService _postsService = locator<PostsService>();

  void reset() {
    announcementText.clear();
    _attachedImg = List<AttachedImage>();
    _attachedVid = List<AttachedVideo>();
    _videoPlayerControllers = <VideoPlayerController>[];
    _initialiseVideoPlayerFutures = <Future<void>>[];
  }

  void loadArgs({@required ScreenArguments args}) async {
    announcementText.text = args.announcement.text;

    if (args.announcement.img != null) {
      _attachedImg.add(args.announcement.img);
    }

    if (args.announcement.vid != null) {
      AttachedVideo vid = AttachedVideo();
      vid.path = args.announcement.vid.path;
      vid.size = args.announcement.vid.size;
      _attachedVid.add(vid);

      _videoPlayerControllers
          .add(VideoPlayerController.network(args.announcement.vid.path));
      _initialiseVideoPlayerFutures.add(
          _videoPlayerControllers.last.initialize().then((value) => rebuild()));
    }

    for (int i = 0; i < args.announcement.files.length; i++) {
      AttachedFile file = AttachedFile();
      file.fileURL = args.announcement.files[i].fileURL;
      file.local = false;
      file.fileSize = args.announcement.files[i].fileSize;
      file.filetype = args.announcement.files[i].filetype;
      file.name = args.announcement.files[i].name;
      _attachedFiles.add(file);
    }

    loaded = true;
  }

  VideoPlayerController getVideoControllers({@required int index}) {
    return _videoPlayerControllers[index];
  }

  Future<void> getVideoFutures({@required int index}) {
    return _initialiseVideoPlayerFutures[index];
  }

  Image getProfilePic({@required String userId}) {
    if (_postsService.getUser(userId: userId).profilePic == "default") {
      return Image.asset("assets/img/blank_profile.png");
    }
    return Image.network(_postsService.getUser(userId: userId).profilePic);
  }

  String getName({@required String userId}) {
    return _postsService.getUser(userId: userId).name;
  }

  List<AttachedImage> getImgs() {
    return _attachedImg;
  }

  List<AttachedVideo> getVids() {
    return _attachedVid;
  }

  List<AttachedFile> getFiles() {
    return _attachedFiles;
  }

  Duration getDuration(int index) {
    return _videoPlayerControllers[index].value.duration;
  }

  void removeImage({@required int index}) async {
    postSize -= double.parse(_attachedImg[index].size);
    _attachedImg.remove(_attachedImg[index]);
    decreaseMediaQuantity();

    rebuild();
  }

  void removeVideo({@required int index}) async {
    postSize -= double.parse(_attachedVid[index].size);
    _attachedVid.remove(_attachedVid[index]);
    _videoPlayerControllers.removeAt(index);
    _initialiseVideoPlayerFutures.removeAt(index);
    decreaseMediaQuantity();

    rebuild();
  }

  void removeFile({@required int index}) async {
    postSize -= double.parse(_attachedFiles[index].fileSize);
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
    if (_attachedVid.length + _attachedImg.length < 9) {
      PickedFile image = await _imagePicker.getImage(
          source: ImageSource.camera, imageQuality: 50);
      if (image != null) {
        int fileSize = await getFileSize(image.path);
        if (postSize + fileSize < maxPostSize) {
          increaseMediaQuantity();

          AttachedImage img = AttachedImage();
          img.path = image.path;
          img.local = true;
          img.size = (fileSize / 1000).toString();
          _attachedImg.add(img);
          postSize += fileSize / 1000;
        } else {
          log.w("File too big to add");
        }
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
    if (_attachedVid.length + _attachedImg.length < 9) {
      PickedFile video =
          await _imagePicker.getVideo(source: ImageSource.camera);
      if (video != null) {
        int fileSize = await getFileSize(video.path);
        if (postSize + fileSize < maxPostSize) {
          increaseMediaQuantity();

          postSize += fileSize / 1000;
          AttachedVideo vid = AttachedVideo();
          vid.path = video.path;
          vid.local = true;
          vid.size = (fileSize / 1000).toString();

          _attachedVid.add(vid);
          _videoPlayerControllers
              .add(VideoPlayerController.file(File(video.path)));
          _initialiseVideoPlayerFutures.add(_videoPlayerControllers.last
              .initialize()
              .then((value) => rebuild()));
        } else {
          log.w("File too big to add");
        }
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
        allowMultiple: false,
        allowedExtensions: [
          "gif",
          "mp4",
          "mov",
          "wmv",
          "avi",
          "png",
          "jpg",
          "jpeg",
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
        if (postSize + fileSize < maxPostSize) {
          increaseMediaQuantity();
          postSize += fileSize / 1000;
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
            _attachedImg.add(img);
          } else {
            log.d("Video");
            AttachedVideo vid = AttachedVideo();
            vid.local = true;
            vid.path = files[i].path;
            vid.size = (fileSize / 1000).toString();
            _attachedVid.add(vid);
            _videoPlayerControllers
                .add(VideoPlayerController.file(File(files[i].path)));
            _initialiseVideoPlayerFutures.add(_videoPlayerControllers.last
                .initialize()
                .then((value) => rebuild()));
          }
        } else {
          log.w("File too big to add");
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
        if (postSize + fileSize < maxPostSize) {
          postSize += fileSize;
          _attachedFiles.add(files[i]);
        } else {
          log.w("File too big to add");
        }
      }
    }
    pc.close();
    rebuild();
  }

  Future updateAnnouncement(
      {@required String body,
      @required BuildContext context,
      @required ScreenArguments args}) async {
    List<PickedFile> imgs = new List<PickedFile>();
    List<PickedFile> vids = new List<PickedFile>();
    List<AttachedFile> files = new List<AttachedFile>();

    for (int i = 0; i < _attachedImg.length; i++) {
      imgs.add(PickedFile(_attachedImg[i].path));
    }
    for (int i = 0; i < _attachedVid.length; i++) {
      vids.add(PickedFile(_attachedVid[i].path));
    }
    for (int i = 0; i < _attachedFiles.length; i++) {
      files.add(_attachedFiles[i]);
    }

    _databaseService.updateAnnouncement(
        announcement: args.announcement,
        text: body,
        imgs: imgs,
        vids: vids,
        files: files,
        size: postSize,
        context: context);
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  void createDialogs(
      {@required BuildContext context, @required PanelController pc}) {
    _mediaQuantityErrorAlert = AlertBuilder(
        context: context,
        title: lang().popupMessages[15],
        titleColour: Colour.kvk_error_red,
        //TODO: Change message to one file
        message: "Cannot upload more than 1 media",
        icon: KVKIcons.cancel_original,
        iconColour: Colour.kvk_error_red,
        buttonText: lang().back.toUpperCase(),
        onPress: () async {
          _mediaQuantityErrorAlert.dismissDialog();
          pc.close();
          rebuild();
        });

    _mediaQuantityErrorAlert.createAlert();
  }

  void showmediaQuantityError() {
    _mediaQuantityErrorAlert.showDialog();
  }

  void increaseMediaQuantity() {
    mediaQuantity += 1;
  }

  void decreaseMediaQuantity() {
    mediaQuantity -= 1;
  }

  int getMediaQuantity() {
    return mediaQuantity;
  }

  Future<bool> onBackPressed() async {
    await _navigationService
        .pushNamedAndRemoveUntil(Routes.viewAnnouncementView)
        .whenComplete(() {
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
