// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(btnType) => "${Intl.select(btnType, {
            'first': 'From start',
            'continue': 'Continue',
            'other': '',
          })}";

  static String m1(dialogType) => "${Intl.select(dialogType, {
            'continueReading': 'You have a previous chapter.',
            'other': '',
          })}";

  static String m2(btnType) => "${Intl.select(btnType, {
            'viewMode': 'View Mode',
            'prevChapter': 'Prev Chapter',
            'prevContents': 'Prev Contents',
            'nextChapter': 'Next Chapter',
            'nextContents': 'Next Contents',
            'other': '',
          })}";

  static String m3(msgType) => "${Intl.select(msgType, {
            'noneSelectedFile': 'Plase Selected EPUB File.',
            'emptyAPIInfo':
                'To use the translation function, you must enter OPENAI information in settings.',
            'imageLoadFail': 'Image load failed',
            'localEpubNotExists':
                'The file information does not exist on the local device.',
            'epubLoadFailed': 'An error occurred while opening the EPUB file.',
            'other': '',
          })}";

  static String m4(msgType) => "${Intl.select(msgType, {
            'saveSattings': 'Settings save complated',
            'other': '',
          })}";

  static String m5(themeMode) => "${Intl.select(themeMode, {
            'system': 'System',
            'light': 'Light',
            'dark': 'Dark',
            'other': '',
          })}";

  static String m6(language) => "${Intl.select(language, {
            'ko': 'Korean',
            'ja': 'Japenes',
            'en': 'English',
            'other': '',
          })}";

  static String m7(msgType) => "${Intl.select(msgType, {
            'notInvalid': 'Check All Fields.',
            'other': '',
          })}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "appName": MessageLookupByLibrary.simpleMessage("E-BOOK Reader"),
        "deleted": MessageLookupByLibrary.simpleMessage("Deleted"),
        "dialogActionBtns": m0,
        "dialogTitle": m1,
        "epubActionBtns": m2,
        "errorMsg": m3,
        "fileOpen": MessageLookupByLibrary.simpleMessage("open EPUB"),
        "filePickerTitle":
            MessageLookupByLibrary.simpleMessage("EPUB File Select"),
        "historyDate": MessageLookupByLibrary.simpleMessage("Reading Date"),
        "historyTitle": MessageLookupByLibrary.simpleMessage("Reading History"),
        "openaiAPI": MessageLookupByLibrary.simpleMessage("OPENAI API"),
        "openaiAPIKey": MessageLookupByLibrary.simpleMessage("OPENAI API Key"),
        "openaiAPIModel":
            MessageLookupByLibrary.simpleMessage("OPENAI API Model"),
        "openaiAPIPrompt":
            MessageLookupByLibrary.simpleMessage("Translate Prompt"),
        "settingsSaveBtn":
            MessageLookupByLibrary.simpleMessage("Save Settings"),
        "settingsTitle": MessageLookupByLibrary.simpleMessage("Settings"),
        "successMsg": m4,
        "themeMode": MessageLookupByLibrary.simpleMessage("Theme Mode"),
        "themeModeOption": m5,
        "translateLanguage":
            MessageLookupByLibrary.simpleMessage("Translate Language"),
        "translateLanguageOption": m6,
        "validMsg": m7,
        "viewReadingHistory":
            MessageLookupByLibrary.simpleMessage("View Reading History")
      };
}
