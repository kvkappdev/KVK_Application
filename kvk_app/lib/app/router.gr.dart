// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../splash_screen.dart';
import '../ui/views/contact_view.dart';
import '../ui/views/create/create_announcement_view.dart';
import '../ui/views/create/create_post_view.dart';
import '../ui/views/create/create_reply_view.dart';
import '../ui/views/edit/edit_announcement_view.dart';
import '../ui/views/edit/edit_post_view.dart';
import '../ui/views/edit/edit_reply_to_reply_view.dart';
import '../ui/views/edit/edit_reply_view.dart';
import '../ui/views/feature_locked_view.dart';
import '../ui/views/forum_flow/forum_view.dart';
import '../ui/views/forum_flow/view_announcement_view.dart';
import '../ui/views/forum_flow/view_attachments_view.dart';
import '../ui/views/forum_flow/view_post_view.dart';
import '../ui/views/forum_flow/view_reply_view.dart';
import '../ui/views/forum_flow/view_subscribed_posts_view.dart';
import '../ui/views/home_view.dart';
import '../ui/views/login_flow/registration_finalise_view.dart';
import '../ui/views/login_flow/registration_name_view.dart';
import '../ui/views/login_flow/registration_pic_view.dart';
import '../ui/views/login_flow/verification_code_view.dart';
import '../ui/views/login_flow/verification_view.dart';
import '../ui/views/more/administrator_view.dart';
import '../ui/views/more/data_justice_view.dart';
import '../ui/views/more/more_view.dart';
import '../ui/views/profile_flow/change_number_code_view.dart';
import '../ui/views/profile_flow/change_number_view.dart';
import '../ui/views/profile_flow/edit_profile_view.dart';
import '../ui/views/profile_flow/profile_view.dart';

class Routes {
  static const String verificationView = '/verification-view';
  static const String verificationCodeView = '/verification-code-view';
  static const String registrationNameView = '/registration-name-view';
  static const String registrationPicView = '/registration-pic-view';
  static const String registrationFinaliseView = '/registration-finalise-view';
  static const String moreView = '/more-view';
  static const String dataJusticeView = '/data-justice-view';
  static const String createPostView = '/create-post-view';
  static const String forumView = '/forum-view';
  static const String profileView = '/profile-view';
  static const String editProfileView = '/edit-profile-view';
  static const String changeNumberView = '/change-number-view';
  static const String changeNumberCodeView = '/change-number-code-view';
  static const String homeView = '/home-view';
  static const String subscribedPostsView = '/subscribed-posts-view';
  static const String contactView = '/contact-view';
  static const String viewAttachmentsView = '/view-attachments-view';
  static const String viewPostView = '/view-post-view';
  static const String editPostView = '/edit-post-view';
  static const String viewReplyView = '/view-reply-view';
  static const String editReplyView = '/edit-reply-view';
  static const String editReplyToReplyView = '/edit-reply-to-reply-view';
  static const String createReplyView = '/create-reply-view';
  static const String featureLockedView = '/feature-locked-view';
  static const String administratorView = '/administrator-view';
  static const String createAnnouncementView = '/create-announcement-view';
  static const String viewAnnouncementView = '/view-announcement-view';
  static const String editAnnouncementView = '/edit-announcement-view';
  static const String splashScreen = '/';
  static const all = <String>{
    verificationView,
    verificationCodeView,
    registrationNameView,
    registrationPicView,
    registrationFinaliseView,
    moreView,
    dataJusticeView,
    createPostView,
    forumView,
    profileView,
    editProfileView,
    changeNumberView,
    changeNumberCodeView,
    homeView,
    subscribedPostsView,
    contactView,
    viewAttachmentsView,
    viewPostView,
    editPostView,
    viewReplyView,
    editReplyView,
    editReplyToReplyView,
    createReplyView,
    featureLockedView,
    administratorView,
    createAnnouncementView,
    viewAnnouncementView,
    editAnnouncementView,
    splashScreen,
  };
}

class Router extends RouterBase {
  @override
  List<RouteDef> get routes => _routes;
  final _routes = <RouteDef>[
    RouteDef(Routes.verificationView, page: VerificationView),
    RouteDef(Routes.verificationCodeView, page: VerificationCodeView),
    RouteDef(Routes.registrationNameView, page: RegistrationNameView),
    RouteDef(Routes.registrationPicView, page: RegistrationPicView),
    RouteDef(Routes.registrationFinaliseView, page: RegistrationFinaliseView),
    RouteDef(Routes.moreView, page: MoreView),
    RouteDef(Routes.dataJusticeView, page: DataJusticeView),
    RouteDef(Routes.createPostView, page: CreatePostView),
    RouteDef(Routes.forumView, page: ForumView),
    RouteDef(Routes.profileView, page: ProfileView),
    RouteDef(Routes.editProfileView, page: EditProfileView),
    RouteDef(Routes.changeNumberView, page: ChangeNumberView),
    RouteDef(Routes.changeNumberCodeView, page: ChangeNumberCodeView),
    RouteDef(Routes.homeView, page: HomeView),
    RouteDef(Routes.subscribedPostsView, page: SubscribedPostsView),
    RouteDef(Routes.contactView, page: ContactView),
    RouteDef(Routes.viewAttachmentsView, page: ViewAttachmentsView),
    RouteDef(Routes.viewPostView, page: ViewPostView),
    RouteDef(Routes.editPostView, page: EditPostView),
    RouteDef(Routes.viewReplyView, page: ViewReplyView),
    RouteDef(Routes.editReplyView, page: EditReplyView),
    RouteDef(Routes.editReplyToReplyView, page: EditReplyToReplyView),
    RouteDef(Routes.createReplyView, page: CreateReplyView),
    RouteDef(Routes.featureLockedView, page: FeatureLockedView),
    RouteDef(Routes.administratorView, page: AdministratorView),
    RouteDef(Routes.createAnnouncementView, page: CreateAnnouncementView),
    RouteDef(Routes.viewAnnouncementView, page: ViewAnnouncementView),
    RouteDef(Routes.editAnnouncementView, page: EditAnnouncementView),
    RouteDef(Routes.splashScreen, page: SplashScreen),
  ];
  @override
  Map<Type, AutoRouteFactory> get pagesMap => _pagesMap;
  final _pagesMap = <Type, AutoRouteFactory>{
    VerificationView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => VerificationView(),
        settings: data,
      );
    },
    VerificationCodeView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => VerificationCodeView(),
        settings: data,
      );
    },
    RegistrationNameView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => RegistrationNameView(),
        settings: data,
      );
    },
    RegistrationPicView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => RegistrationPicView(),
        settings: data,
      );
    },
    RegistrationFinaliseView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => RegistrationFinaliseView(),
        settings: data,
      );
    },
    MoreView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => MoreView(),
        settings: data,
      );
    },
    DataJusticeView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => DataJusticeView(),
        settings: data,
      );
    },
    CreatePostView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => CreatePostView(),
        settings: data,
      );
    },
    ForumView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => ForumView(),
        settings: data,
      );
    },
    ProfileView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => ProfileView(),
        settings: data,
      );
    },
    EditProfileView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => EditProfileView(),
        settings: data,
      );
    },
    ChangeNumberView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => ChangeNumberView(),
        settings: data,
      );
    },
    ChangeNumberCodeView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => ChangeNumberCodeView(),
        settings: data,
      );
    },
    HomeView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => HomeView(),
        settings: data,
      );
    },
    SubscribedPostsView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => SubscribedPostsView(),
        settings: data,
      );
    },
    ContactView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => ContactView(),
        settings: data,
      );
    },
    ViewAttachmentsView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => ViewAttachmentsView(),
        settings: data,
      );
    },
    ViewPostView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => ViewPostView(),
        settings: data,
      );
    },
    EditPostView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => EditPostView(),
        settings: data,
      );
    },
    ViewReplyView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => ViewReplyView(),
        settings: data,
      );
    },
    EditReplyView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => EditReplyView(),
        settings: data,
      );
    },
    EditReplyToReplyView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => EditReplyToReplyView(),
        settings: data,
      );
    },
    CreateReplyView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => CreateReplyView(),
        settings: data,
      );
    },
    FeatureLockedView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => FeatureLockedView(),
        settings: data,
      );
    },
    AdministratorView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => AdministratorView(),
        settings: data,
      );
    },
    CreateAnnouncementView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => CreateAnnouncementView(),
        settings: data,
      );
    },
    ViewAnnouncementView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => ViewAnnouncementView(),
        settings: data,
      );
    },
    EditAnnouncementView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => EditAnnouncementView(),
        settings: data,
      );
    },
    SplashScreen: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => SplashScreen(),
        settings: data,
      );
    },
  };
}
