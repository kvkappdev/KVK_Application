import 'package:kvk_app/ui/eng_text.dart';
import 'package:kvk_app/ui/marathi_text.dart';
import 'package:kvk_app/ui/text_interface.dart';

class LanguageService {
  final EngText _eng = new EngText();
  final MarathiText _marathi = new MarathiText();

  // 0 = English, 1 = Marathi
  int language = 0;
  TextInterface getLanguage() {
    if (language == 0) {
      return _eng;
    } else {
      return _marathi;
    }
  }

  int getLanguageVal() {
    return language;
  }

  void setLanguage(int lang) {
    language = lang;
  }
}
