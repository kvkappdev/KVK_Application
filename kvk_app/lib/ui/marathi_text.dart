import 'package:kvk_app/ui/text_interface.dart';

/// Returns all static text marathi values for the application
///
/// returns: Varries
/// Initial creation: 03/09/2020
/// Last Updated: 03/09/2020
class MarathiText implements TextInterface {
  String get next => "";

  String get enter => "";

  List<String> get verificationMsg => {"", " ", "  "}.toList();

  List<String> get verificationCodeMsg =>
      {"", " ", "  ", "   ", "    "}.toList();

  String get verificationTitle => "";

  String get ok => "";

  List<String> get moreButtons => {
        "प्रशासक",
        "डेटा न्या",
        "सूचना पुश करा",
        "इंग्रजी",
        "साइन इन करा",
        "साइन आउट करा"
      }.toList();

  List<String> get logoutDialog => {"", "  ", "   ", "    "}.toList();

  String get verificationError => "";

  List<String> get countries => {"", " "}.toList();

  String get login => "";

  List<String> get verificationCodeResend => {"", " "}.toList();

  String get skip => "";

  String get registrationTitle => "";

  String get registrationNameTitle => "";

  String get registrationMsg => "";

  String get registrationNameHint => "";

  String get registrationNameInputNotice => "";

  String get registrationPicMsg => "";

  String get registrationNameError => "";

  List<String> get imagePicker => {"", " "}.toList();

  String get registrationFinaliseTitle => "";

  String get registrationFinaliseMsg => "";

  String get name => "";

  String get profilePic => "";

  String get register => "";

  List<String> get mainMenuBar =>
      {"मुख्यपृष्ठ", "मंच", "तयार करा", "प्रोफाइल", "अधिक"}.toList();

  List<String> get popupMessages => {
        "",
        " ",
        "  ",
        "   ",
        "    ",
        "     ",
        "      ",
        "       ",
        "        ",
        "         ",
        "          ",
        "           ",
        "            ",
        "             ",
        "              ",
        "                ",
        "                  ",
        "               "
      }.toList();

  String get back => "";

  String get dataJustice => "";

  String get dataJusticeTitle => "";

  String get createPost => "";
  String get replyToPost => "";
  String get post => "";
  String get send => "";
  String get anonymous => "";
  String get title => "";
  String get postInputPrompt => "";
  String get replyInputPrompt => "";

  List<String> get slidingPanel => {"", " ", "  ", "   ", "    "}.toList();

  List<String> get userType => {
        "",
        " ",
        "  ",
        "   ",
      }.toList();

  String get editProfile => "";

  String get myPosts => "";

  String get noPosts => "";

  String get newNumberVerificationTitle => "";

  List<String> get deleteDialogMessages => {
        "",
        " ",
        "  ",
        "   ",
        "    ",
        "     ",
        "      ",
      }.toList();

  String get phoneNumberText => "";

  String get changeNumber => "";

  String get deleteProfile => "";

  String get contactText => "";

  String get directCall => "";

  String get kvk => "";

  String get mondayToFriday => "";

  String get viewPost => "";
  String get viewReply => "";
  String get viewFiles => "";

  List<String> get subscribe => {"", " "}.toList();

  List<String> get editOptions =>
      {"", " ", "  ", "    ", "   ", "     "}.toList();

  List<String> get deleteDialog => {"", " ", "  ", "    "}.toList();

  String get save => "";
  String get edited => "";
  String get loadMore => "";

  List<String> get featureLockedMessages =>
      {"", " ", "  ", "    ", "      ", "        "}.toList();
  String get createAnnouncement => "";
  String get createAnnouncementPrompt => "";
  String get reply => "";
}
