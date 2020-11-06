import 'package:video_player/video_player.dart';

class AttachedVideo {
  String vidId;
  String path;
  bool local = false;
  String size;

  VideoPlayerController videoPlayerController;
  Future videoPlayerControllerFuture;
}
