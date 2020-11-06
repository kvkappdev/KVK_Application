import 'package:auto_route/auto_route_annotations.dart';
import 'package:kvk_app/splash_screen.dart';
import 'package:kvk_app/ui/views/contact_view.dart';
import 'package:kvk_app/ui/views/create/create_announcement_view.dart';
import 'package:kvk_app/ui/views/create/create_post_view.dart';
import 'package:kvk_app/ui/views/create/create_reply_view.dart';
import 'package:kvk_app/ui/views/edit/edit_announcement_view.dart';
import 'package:kvk_app/ui/views/edit/edit_post_view.dart';
import 'package:kvk_app/ui/views/edit/edit_reply_to_reply_view.dart';
import 'package:kvk_app/ui/views/edit/edit_reply_view.dart';
import 'package:kvk_app/ui/views/feature_locked_view.dart';
import 'package:kvk_app/ui/views/forum_flow/forum_view.dart';
import 'package:kvk_app/ui/views/forum_flow/view_announcement_view.dart';
import 'package:kvk_app/ui/views/forum_flow/view_attachments_view.dart';
import 'package:kvk_app/ui/views/forum_flow/view_post_view.dart';
import 'package:kvk_app/ui/views/forum_flow/view_reply_view.dart';
import 'package:kvk_app/ui/views/forum_flow/view_subscribed_posts_view.dart';
import 'package:kvk_app/ui/views/home_view.dart';
import 'package:kvk_app/ui/views/login_flow/registration_finalise_view.dart';
import 'package:kvk_app/ui/views/login_flow/registration_name_view.dart';
import 'package:kvk_app/ui/views/login_flow/registration_pic_view.dart';
import 'package:kvk_app/ui/views/login_flow/verification_code_view.dart';
import 'package:kvk_app/ui/views/login_flow/verification_view.dart';
import 'package:kvk_app/ui/views/more/administrator_view.dart';
import 'package:kvk_app/ui/views/more/data_justice_view.dart';
import 'package:kvk_app/ui/views/more/more_view.dart';
import 'package:kvk_app/ui/views/profile_flow/change_number_code_view.dart';
import 'package:kvk_app/ui/views/profile_flow/change_number_view.dart';
import 'package:kvk_app/ui/views/profile_flow/edit_profile_view.dart';
import 'package:kvk_app/ui/views/profile_flow/profile_view.dart';

@MaterialAutoRouter(routes: [
  //Login Flow
  MaterialRoute(page: VerificationView, initial: false),
  MaterialRoute(page: VerificationCodeView, initial: false),
  MaterialRoute(page: RegistrationNameView, initial: false),
  MaterialRoute(page: RegistrationPicView, initial: false),
  MaterialRoute(page: RegistrationFinaliseView, initial: false),

  MaterialRoute(page: MoreView, initial: false),
  MaterialRoute(page: DataJusticeView, initial: false),

  MaterialRoute(page: CreatePostView, initial: false),

  MaterialRoute(page: ForumView, initial: false),

  MaterialRoute(page: ProfileView, initial: false),
  MaterialRoute(page: EditProfileView, initial: false),
  MaterialRoute(page: ChangeNumberView, initial: false),
  MaterialRoute(page: ChangeNumberCodeView, initial: false),

  MaterialRoute(page: HomeView, initial: false),
  MaterialRoute(page: SubscribedPostsView, initial: false),

  MaterialRoute(page: ContactView, initial: false),

  MaterialRoute(page: ViewAttachmentsView, initial: false),

  MaterialRoute(page: ViewPostView, initial: false),
  MaterialRoute(page: EditPostView, initial: false),
  MaterialRoute(page: ViewReplyView, initial: false),
  MaterialRoute(page: EditReplyView, initial: false),
  MaterialRoute(page: EditReplyToReplyView, initial: false),

  MaterialRoute(page: CreateReplyView, initial: false),
  MaterialRoute(page: FeatureLockedView, initial: false),
  MaterialRoute(page: AdministratorView, initial: false),
  MaterialRoute(page: CreateAnnouncementView, initial: false),
  MaterialRoute(page: ViewAnnouncementView, initial: false),
  MaterialRoute(page: EditAnnouncementView, initial: false),

  MaterialRoute(page: SplashScreen, initial: true),
])
class $Router {}
