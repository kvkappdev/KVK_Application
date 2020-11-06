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
import 'package:kvk_app/services/database_service.dart';
import 'package:kvk_app/services/posts_service.dart';
import 'package:kvk_app/ui/smart_widgets/screen_arguments.dart';
import 'package:kvk_app/ui/templates/kvk_viewmodel.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:video_player/video_player.dart';

final log = getLogger("Edit Post View Model");

class EditPostViewModel extends KVKViewModel {
  List<String> _options = <String>["Uncategorised"];
  String _category = "Uncategorised";
  ImagePicker _imagePicker = new ImagePicker();
  List<AttachedImage> _attachedImgs = List<AttachedImage>();
  List<AttachedVideo> _attachedVids = List<AttachedVideo>();
  List<AttachedFile> _attachedFiles = List<AttachedFile>();
  List<VideoPlayerController> _videoPlayerControllers =
      List<VideoPlayerController>();
  List<Future<void>> _initialiseVideoPlayerFutures = List<Future<void>>();
  NavigationService _navigationService = locator<NavigationService>();

  final PanelController pc = new PanelController();
  final TextEditingController titleText = new TextEditingController();
  final TextEditingController postText = new TextEditingController();

  bool loaded = false;

  double postSize = 0;
  int maxPostSize = 50000000;

  DatabaseService _databaseService = locator<DatabaseService>();
  PostsService _postsService = locator<PostsService>();

  void reset() {
    postText.clear();
    titleText.clear();
    _attachedImgs = List<AttachedImage>();
    _attachedVids = List<AttachedVideo>();
    _attachedFiles = List<AttachedFile>();
    _videoPlayerControllers = <VideoPlayerController>[];
    _initialiseVideoPlayerFutures = <Future<void>>[];
  }

  void loadArgs({@required ScreenArguments args}) async {
    postText.text = args.post.body;
    titleText.text = args.post.title;
    _category = args.post.categoryId;
    postSize = args.post.size;

    for (int i = 0; i < args.post.imgs.length; i++) {
      AttachedImage img = AttachedImage();
      img.path = args.post.imgs[i].path;
      img.local = false;
      img.size = args.post.imgs[i].size;
      _attachedImgs.add(img);
    }
    for (int i = 0; i < args.post.vids.length; i++) {
      AttachedVideo vid = AttachedVideo();
      vid.path = args.post.vids[i].path;
      vid.size = args.post.vids[i].size;
      _attachedVids.add(vid);

      _videoPlayerControllers
          .add(VideoPlayerController.network(args.post.vids[i].path));
      _initialiseVideoPlayerFutures.add(
          _videoPlayerControllers.last.initialize().then((value) => rebuild()));
    }
    for (int i = 0; i < args.post.files.length; i++) {
      AttachedFile file = AttachedFile();
      file.fileURL = args.post.files[i].fileURL;
      file.local = false;
      file.fileSize = args.post.files[i].fileSize;
      file.filetype = args.post.files[i].filetype;
      file.name = args.post.files[i].name;
      _attachedFiles.add(file);
    }

    loaded = true;
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

  List<String> getOptions() {
    return _options;
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

  Duration getDuration(int index) {
    return _videoPlayerControllers[index].value.duration;
  }

  void setCategory(int index) {
    _category = _options[index];
  }

  void removeImage({@required int index}) async {
    postSize -= double.parse(_attachedImgs[index].size);
    _attachedImgs.remove(_attachedImgs[index]);
    rebuild();
  }

  void removeVideo({@required int index}) async {
    postSize -= double.parse(_attachedVids[index].size);
    _attachedVids.remove(_attachedVids[index]);
    _videoPlayerControllers.removeAt(index);
    _initialiseVideoPlayerFutures.removeAt(index);
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
    if (_attachedVids.length + _attachedImgs.length < 9) {
      PickedFile image = await _imagePicker.getImage(
          source: ImageSource.camera, imageQuality: 50);
      if (image != null) {
        int fileSize = await getFileSize(image.path);
        if (postSize + fileSize < maxPostSize) {
          AttachedImage img = AttachedImage();
          img.path = image.path;
          img.local = true;
          img.size = (fileSize / 1000).toString();
          _attachedImgs.add(img);
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
    if (_attachedVids.length + _attachedImgs.length < 9) {
      PickedFile video =
          await _imagePicker.getVideo(source: ImageSource.camera);
      if (video != null) {
        int fileSize = await getFileSize(video.path);
        if (postSize + fileSize < maxPostSize) {
          postSize += fileSize / 1000;
          AttachedVideo vid = AttachedVideo();
          vid.path = video.path;
          vid.local = true;
          vid.size = (fileSize / 1000).toString();

          _attachedVids.add(vid);
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
        allowMultiple: true,
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
            _attachedImgs.add(img);
          } else {
            log.d("Video");
            AttachedVideo vid = AttachedVideo();
            vid.local = true;
            vid.path = files[i].path;
            vid.size = (fileSize / 1000).toString();
            _attachedVids.add(vid);
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

  Future updatePost(
      {@required String title,
      @required String body,
      @required BuildContext context,
      @required ScreenArguments args}) async {
    List<PickedFile> imgs = new List<PickedFile>();
    List<PickedFile> vids = new List<PickedFile>();
    List<AttachedFile> files = new List<AttachedFile>();

    for (int i = 0; i < _attachedImgs.length; i++) {
      imgs.add(PickedFile(_attachedImgs[i].path));
    }
    for (int i = 0; i < _attachedVids.length; i++) {
      vids.add(PickedFile(_attachedVids[i].path));
    }
    for (int i = 0; i < _attachedFiles.length; i++) {
      files.add(_attachedFiles[i]);
    }

    _databaseService.updatePost(
        post: args.post,
        title: title,
        body: body,
        category: _category,
        imgs: imgs,
        vids: vids,
        files: files,
        size: postSize,
        context: context,
        screenArguments: args);
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<bool> onBackPressed(
      {@required ScreenArguments screenArguments}) async {
    await _navigationService
        .pushNamedAndRemoveUntil(Routes.viewPostView,
            arguments: screenArguments)
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
