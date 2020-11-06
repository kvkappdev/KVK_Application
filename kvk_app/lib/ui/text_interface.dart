/// Interface for the languages. This allows the application to get the correct language deopending
/// on user preference.
///
/// returns: dynamic
/// Initial creation: 03/09/2020
/// Last Updated: 04/10/2020

class TextInterface {
  get next {}
  get enter {}

  /// 0 = Enter your mobile number and we will send a
  /// 1 = ont time password
  /// 2 = via SMS
  get verificationMsg {}

  /// 0 = You will get a
  /// 1 = 6-digit
  /// 2 = code via SMS.
  /// 3 = Sent to
  /// 4 = Code sent
  get verificationCodeMsg {}
  get verificationTitle {}

  /// 0 = Administrator
  /// 1 = Data Justice
  /// 2 = Push Notifications
  /// 3 = Language
  /// 4 = Sign in
  /// 5 = Sign out
  get moreButtons {}

  /// 0 = Cancel
  /// 1 = Sign out
  /// 2 = Are you sure?
  /// 3 = Are you sure you want to sign out from your account?
  get logoutDialog {}
  get verificationError {}

  /// 0 = India
  /// 1 = Australia
  get countries {}
  get login {}

  /// 0 = Didn't recieve a code?
  /// 1 = Send again
  get verificationCodeResend {}
  get skip {}
  get registrationTitle {}
  get registrationNameTitle {}
  get registrationMsg {}
  get registrationNameHint {}
  get registrationNameInputNotice {}
  get registrationPicMsg {}
  get registrationNameError {}

  /// 0 = Take a photo
  /// 1 = Photo Library
  get imagePicker {}
  get registrationFinaliseTitle {}
  get registrationFinaliseMsg {}
  get name {}
  get profilePic {}
  get register {}

  /// 0 = Home
  /// 1 = Forum
  /// 2 = Create
  /// 3 = Profile
  /// 4 = More
  get mainMenuBar {}
  get ok {}

  /// 0 = Success
  /// 1 = Try Again
  /// 2 = Loading
  /// 3 = An error has occured
  /// 4 = User logged in
  /// 5 = Your account has been created.
  /// 6 = Let's Go
  /// 7 = Your profile has been updated.
  /// 8 = Your account has been deleted
  /// 9 = Delete Account
  /// 10 = Post created
  /// 11 = Reply created
  /// 12 = Post Deleted
  /// 13 = Reply Deleted
  /// 14 = Changes have been saved
  /// 15 = Sorry
  /// 16 = Cannot upload more than 3 media files.
  /// 17 = You must have both a title and a body to make a post.
  get popupMessages {}
  get back {}
  get dataJustice {}
  get dataJusticeTitle {}
  get createPost {}
  get replyToPost {}
  get post {}
  get send {}
  get anonymous {}
  get title {}
  get postInputPrompt {}
  get replyInputPrompt {}

  /// 0 = Add Attachments
  /// 1 = Take a photo
  /// 2 = Take a video
  /// 3 = Choose from library
  /// 4 = Upload a file
  get slidingPanel {}

  ///0 = User
  ///1 = Scientist
  ///2 = Administrator
  ///3 = Unknown
  get userType {}

  get editProfile {}
  get myPosts {}
  get noPosts {}

  get newNumberVerificationTitle {}

  /// 0 = Delete Account
  /// 1 = Enter the number ‘123456’ to delete your account. \n\nNOTE: This action
  /// 2 = cannot
  /// 3 = be undone.
  /// 4 = Enter
  /// 5 = Cancel
  /// 6 = Delete
  get deleteDialogMessages {}

  get phoneNumberText {}
  get changeNumber {}
  get deleteProfile {}
  get kvk {}
  get contactText {}
  get mondayToFriday {}
  get directCall {}
  get viewPost {}
  get viewReply {}
  get viewFiles {}

  /// 0 = Subscribe
  /// 1 = Subscribed
  get subscribe {}

  /// 0 = Edit Post
  /// 1 = Delete Post
  /// 2 = Edit Reply
  /// 3 = Delete Reply
  /// 4 = Edit Announcement
  /// 5 = Delete Announcement
  get editOptions {}

  /// 0 = Cancel
  /// 1 = Delete
  /// 2 = Are you sure you want to delete the post?
  /// 3 = Are you sure you want to delete the reply?
  get deleteDialog {}
  get save {}
  get edited {}
  get loadMore {}

  /// 0 = "Feature Locked",
  /// 1 = "You must be a registered user to access this feature. ",
  /// 2 = "Sign In ",
  /// 3 = "to use this feature."
  /// 4 = Looks like you don’t have a profile with us yet! Please finish creating your profile to access this feature.
  /// 5 = Create Profile
  get featureLockedMessages {}

  get createAnnouncement {}
  get createAnnouncementPrompt {}
  get reply {}
}
