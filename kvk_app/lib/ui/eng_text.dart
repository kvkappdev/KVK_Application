import 'package:kvk_app/ui/text_interface.dart';

import 'smart_widgets/delete_alert.dart';

/// Returns all static text english values for the applciation
///
/// returns: Varries
/// Initial creation: 03/09/2020
/// Last Updated: 03/09/2020
class EngText implements TextInterface {
  String get next => "Next";

  String get enter => "Enter";

  String get title => "Write a title here";

  List<String> get verificationMsg => {
        "Enter your mobile number and we will send a ",
        "one time password",
        " via SMS"
      }.toList();

  List<String> get verificationCodeMsg => {
        "You will get a ",
        "6-digit ",
        "code via SMS.",
        "Sent to ",
        "Code sent"
      }.toList();

  String get verificationTitle => "Verification";

  String get ok => "OK";

  List<String> get moreButtons => {
        "Administrator",
        "Data Justice",
        "Push Notifications",
        "Language",
        "Sign in",
        "Sign out"
      }.toList();

  List<String> get logoutDialog => {
        "Cancel",
        "Sign out",
        "Are you sure?",
        "Are you sure you want to sign out from your account?"
      }.toList();

  String get verificationError => "Invalid phone number.";

  List<String> get countries => {"India", "Australia"}.toList();

  String get login => "Login";

  List<String> get verificationCodeResend =>
      {"Didn't recieve a code? ", "Send again"}.toList();

  String get skip => "Skip";

  String get registrationTitle => "One last thing.";

  String get registrationNameTitle => "Looks like you're new!";

  String get registrationMsg => "Let's quickly set up your profile.";

  String get registrationNameHint => "Enter your name";

  String get registrationNameInputNotice =>
      "This will be displayed to other users.";

  String get registrationPicMsg => "Add a photo for others to see.";

  String get registrationNameError => "Name cannot be blank";

  List<String> get imagePicker => {"Take a photo", "Photo Library"}.toList();

  String get registrationFinaliseTitle => "Finalise Details";

  String get registrationFinaliseMsg => "You can always edit them later on.";

  String get name => "Name";

  String get profilePic => "Profile Picture";

  String get register => "Register";

  List<String> get mainMenuBar =>
      {"Home", "Forum", "Create", "Profile", "More"}.toList();

  List<String> get popupMessages => {
        "Success",
        "Try Again",
        "Loading",
        "An error has occured",
        "User logged in",
        "Your account has been created.",
        "Let's Go",
        "Your profile has been updated",
        "Your account has been deleted",
        "Delete Account",
        "Post created",
        "Reply created",
        "Post Deleted",
        "Reply Deleted",
        "Changes have been saved",
        "Sorry",
        "Cannot upload more than 3 media files.",
        "You must have both a title and a body to make a post."
      }.toList();

  String get back => "Back";

  String get dataJustice =>
      "\nThe KVK Mobile App Project Team would like to acknowledge the ownership of the data that may be collected from the users of this app and the potential for this data to be misused in ways that bring injustice to the original owners of the data. We assert that the personal information collected from all users that register is securely stored, managed, and used throughout the KVK App and is not used for purposes other than those outlined in this statement. The onus is on the developers, administrators, and privileged users of the application to uphold this standard and not use the data of other users, especially that of indigenous farmers, outside of the purposes outlined and without their consent.\nWhile using the KVK App, we may ask you to provide your name and phone number upon registering as a new user. We use your name to help other registered users in the KVK App to identify your presence and enable you to interact with other registered users in the community. We use your phone number to securely log you in and verify that the profile you access is the one that belongs to you. By using the KVK App and registering as a user, you agree to the collection and use of your personal information (name and phone number) in accordance with this policy. We strive to uphold and align our practices with the Australian Privacy Principles (APP) 1-4, 6 and 11-13.\n\nSincerely,\nKVK Mobile App Project Team 2020\n\t\t-\tNathan Rhodes\n\t\t-\tHadley Dixon\n\t\t-\tYu Kai Teh\n\t\t-\tJorel Basangan\n\nAcknowledgements:\nKVK Mobile App Project Team 2019\n\t\t-\tAnton Nguyen\n\t\t-\tJames Reynolds\n\t\t-\tJasper Pajar\n\t\t-\tJericho Guerrero\n\nKVK Mobile App Project Team 2018";

  String get dataJusticeTitle => "Data Justice";

  String get createPost => "Create Post";
  String get replyToPost => "Reply to Post";

  String get post => "Post";
  String get send => "Send";
  String get anonymous => "Anonymous";

  String get postInputPrompt => "Write what you want to say here";

  String get replyInputPrompt => "Write your reply.";

  List<String> get slidingPanel => {
        "Add Attachments",
        "Take a photo",
        "Take a video",
        "Choose from library",
        "Upload a file"
      }.toList();

  List<String> get userType => {
        "User",
        "Scientist",
        "Administrator",
        "Unknown",
      }.toList();

  String get editProfile => "Edit Profile";

  String get myPosts => "My Posts";

  String get noPosts => "No Posts to Show";

  String get newNumberVerificationTitle => "Verify New Number";

  List<String> get deleteDialogMessages => {
        "Delete Account",
        "Enter the number ‘123456’ to delete your account. \n\nNOTE: This action ",
        "cannot ",
        "be undone.",
        "Enter",
        "Cancel",
        "Delete",
      }.toList();

  String get phoneNumberText => "Phone Number";

  String get changeNumber => "Change Number";

  String get deleteProfile => "Delete Profile";

  String get kvk => "Krishi Vigyan Kendra";

  String get contactText =>
      "Call us for information about the App or any general enquiries.";

  String get mondayToFriday => "Monday to Friday";

  String get directCall => "Direct Call";
  String get viewPost => "View Post";
  String get viewReply => "View Reply";
  String get viewFiles => "View Files";

  List<String> get subscribe => {"Subscribe", "Subscribed"}.toList();

  List<String> get editOptions => {
        "Edit Post",
        "Delete Post",
        "Edit Reply",
        "Delete Reply",
        "Edit Announcement",
        "Delete Announcement"
      }.toList();

  List<String> get deleteDialog => {
        "Cancel",
        "Delete",
        "Are you sure you want to delete the post?",
        "Are you sure you want to delete the reply?"
      }.toList();

  String get save => "Save";
  String get edited => "Edited";
  String get loadMore => "Load more";

  List<String> get featureLockedMessages => {
        "Feature Locked",
        "You must be a registered user to access this feature. ",
        "Sign In ",
        "to use this feature.",
        "Looks like you don’t have a profile with us yet! Please finish creating your profile to access this feature.",
        "Create Profile"
      }.toList();
  String get createAnnouncement => "Create Announcement";
  String get createAnnouncementPrompt => "What do you want to announce?";
  String get reply => "Reply";
}
