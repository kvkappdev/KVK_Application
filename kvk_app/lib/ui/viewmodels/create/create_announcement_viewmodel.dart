import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/data_struct/attachedFile.dart';
import 'package:kvk_app/data_struct/post.dart';
import 'package:kvk_app/data_struct/reply.dart';
import 'package:kvk_app/icons/kvk_icons.dart';
import 'package:kvk_app/services/database_service.dart';
import 'package:kvk_app/services/internal_profile_service.dart';
import 'package:kvk_app/services/language_service.dart';
import 'package:kvk_app/services/posts_service.dart';
import 'package:kvk_app/ui/coloursheet.dart';
import 'package:kvk_app/ui/smart_widgets/alert_builder.dart';
import 'package:kvk_app/ui/templates/kvk_viewmodel.dart';
import 'package:kvk_app/ui/text_interface.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:video_player/video_player.dart';

final log = getLogger("Create Announcement View Model");

class CreateAnnouncementViewModel extends KVKViewModel {
  ImagePicker _imagePicker = new ImagePicker();
  List<PickedFile> _attachedImgs = <PickedFile>[];
  List<PickedFile> _attachedVids = <PickedFile>[];
  List<PlatformFile> _attachedFiles = <PlatformFile>[];
  List<VideoPlayerController> _videoPlayerControllers =
      <VideoPlayerController>[];
  List<Future<void>> _initialiseVideoPlayerFutures = <Future<void>>[];
  AlertBuilder _mediaQuantityErrorAlert;
  final LanguageService _languageService = locator<LanguageService>();

  final NavigationService _navigationService = locator<NavigationService>();

  final PanelController pc = new PanelController();
  final TextEditingController announcementText = new TextEditingController();

  int mediaQuantity = 0;

  double postSize = 0;
  int maxPostSize = 10000000;

  InternalProfileService _internalProfileService =
      locator<InternalProfileService>();
  DatabaseService _databaseService = locator<DatabaseService>();
  PostsService _postsService = locator<PostsService>();

  void reset() {
    _attachedImgs = <PickedFile>[];
    _attachedVids = <PickedFile>[];
    _attachedFiles = <PlatformFile>[];
    _videoPlayerControllers = <VideoPlayerController>[];
    _initialiseVideoPlayerFutures = <Future<void>>[];
  }

  Image getProfilePic() {
    return _internalProfileService.getProfilePic();
  }

  String getName() {
    return _internalProfileService.getName();
  }

  List<PickedFile> getImgs() {
    return _attachedImgs;
  }

  List<PickedFile> getVids() {
    return _attachedVids;
  }

  List<PlatformFile> getFiles() {
    return _attachedFiles;
  }

  List<Future> getVidFuture() {
    return _initialiseVideoPlayerFutures;
  }

  List<VideoPlayerController> getVidController() {
    return _videoPlayerControllers;
  }

  Duration getDuration(int index) {
    return _videoPlayerControllers[index].value.duration;
  }

  void removeImage({@required int index}) async {
    postSize -= await getFileSize(_attachedImgs[index].path);
    _attachedImgs.remove(_attachedImgs[index]);
    decreaseMediaQuantity();
    rebuild();
  }

  void removeVideo({@required int index}) async {
    postSize -= await getFileSize(_attachedVids[index].path);
    _attachedVids.remove(_attachedVids[index]);
    _videoPlayerControllers.removeAt(index);
    _initialiseVideoPlayerFutures.removeAt(index);
    decreaseMediaQuantity();
    rebuild();
  }

  void removeFile({@required int index}) async {
    postSize -= await getFileSize(_attachedFiles[index].path);
    _attachedFiles.removeAt(index);
    rebuild();
  }

  /// Creates an image picker, and allows the user to take a photo. Then sets the photo as image.
  ///
  /// param:
  /// returns:
  /// Initial creation: 10/09/2020
  /// Last Updated: 10/09/2020
  void imgFromCamera(PanelController pc) async {
    pc.close();
    PickedFile image = await _imagePicker.getImage(
        source: ImageSource.camera, imageQuality: 50);
    if (image != null) {
      int fileSize = await getFileSize(image.path);
      if (postSize + fileSize < maxPostSize) {
        _attachedImgs.add(image);
        postSize += fileSize;
        increaseMediaQuantity();
      } else {
        log.w("File too big to add");
      }
    }
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
  void videoFromCamera(PanelController pc) async {
    pc.close();
    PickedFile video = await _imagePicker.getVideo(source: ImageSource.camera);
    if (video != null) {
      int fileSize = await getFileSize(video.path);
      if (postSize + fileSize < maxPostSize) {
        postSize += fileSize;
        _attachedVids.add(video);
        increaseMediaQuantity();
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

  /// Creates an File picker, and allows the user to pick a photo or video from their library
  /// Then sets the media as Platform File.
  ///
  /// param:
  /// returns:
  /// Initial creation: 10/09/2020
  /// Last Updated: 10/09/2020
  void fromGallery(PanelController pc) async {
    pc.close();
    FilePickerResult result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
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
        if (postSize + fileSize < maxPostSize) {
          increaseMediaQuantity();
          postSize += fileSize;
          if (files[i].extension == "jpg" ||
              files[i].extension == "jpeg" ||
              files[i].extension == "png" ||
              files[i].extension == "raw" ||
              files[i].extension == "gif") {
            log.d("Image");
            _attachedImgs.add(PickedFile(files[i].path));
          } else {
            log.d("Video");
            _attachedVids.add(PickedFile(files[i].path));
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
    rebuild();
  }

  /// Creates a file picker and allows the user to select one or more files from their library
  ///
  /// param:
  /// returns:
  /// Initial creation: 13/10/2020
  /// Last Updated:13/10/2020
  void filesFromLibrary(PanelController pc) async {
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
      List<PlatformFile> files = <PlatformFile>[];
      for (int i = 0; i < result.files.length; i++) {
        PlatformFile file = result.files[i];
        files.add(file);
      }

      for (int i = 0; i < files.length; i++) {
        int fileSize = await getFileSize(files[i].path);
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

  Future submitAnnouncment(
      {@required String body, @required BuildContext context}) async {
    List<AttachedFile> filesList = List<AttachedFile>();
    for (int i = 0; i < _attachedFiles.length; i++) {
      AttachedFile newFile = AttachedFile();
      newFile.name = _attachedFiles[i].name;
      newFile.fileURL = _attachedFiles[i].path;
      newFile.fileSize = _attachedFiles[i].size.toString();
      newFile.filetype = _attachedFiles[i].extension;
      filesList.add(newFile);
      log.d(newFile);
    }
    await _databaseService.createAnnouncement(
        body: body,
        img: _attachedImgs.length == 1 ? _attachedImgs[0] : null,
        vid: _attachedVids.length == 1 ? _attachedVids[0] : null,
        files: filesList,
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

  Future<bool> onBackPressed({@required String routeFrom}) async {
    await _navigationService
        .pushNamedAndRemoveUntil(routeFrom)
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
