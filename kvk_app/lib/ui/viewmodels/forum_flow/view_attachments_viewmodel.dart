import 'package:flutter/material.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/data_struct/announcement.dart';
import 'package:kvk_app/data_struct/attachedFile.dart';
import 'package:kvk_app/data_struct/post.dart';
import 'package:kvk_app/data_struct/reply.dart';
import 'package:kvk_app/services/database_service.dart';
import 'package:kvk_app/ui/smart_widgets/screen_arguments.dart';
import 'package:kvk_app/ui/templates/kvk_viewmodel.dart';
import 'package:stacked_services/stacked_services.dart';

class ViewAttachmentViewModel extends KVKViewModel {
  final log = getLogger("View Attachments Viewmodel");
  final DatabaseService _databaseService = locator<DatabaseService>();
  final NavigationService _navigationService = locator<NavigationService>();

  List<AttachedFile> getFiles(
      {Post post, Reply reply, Announcement announcement}) {
    if (reply != null) {
      return reply.files;
    } else if (post != null) {
      return post.files;
    } else {
      return announcement.files;
    }
  }

  Future launchURL(
      {@required AttachedFile file, @required BuildContext context}) async {
    await _databaseService.launchURL(url: file.fileURL, context: context);
  }

  Future<bool> onBackPressed() async {
    await popBack().whenComplete(() {
      return true;
    });
    return false;
  }
}
