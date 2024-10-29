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

  static String m0(msgType) => "${Intl.select(msgType, {
            'noneSelectedFile': 'Plase Selected EPUB File.',
            'other': '',
          })}";

  static String m1(msgType) => "${Intl.select(msgType, {
            'saveSattings': 'Settings save complated',
            'other': '',
          })}";

  static String m2(themeMode) => "${Intl.select(themeMode, {
            'system': 'System',
            'light': 'Light',
            'dark': 'Dark',
            'other': '',
          })}";

  static String m3(language) => "${Intl.select(language, {
            'ko': 'Korean',
            'ja': 'Japenes',
            'en': 'English',
            'other': '',
          })}";

  static String m4(msgType) => "${Intl.select(msgType, {
            'notInvalid': 'Check All Fields.',
            'other': '',
          })}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "appName": MessageLookupByLibrary.simpleMessage("E-BOOK Reader"),
        "errorMsg": m0,
        "fileOpen": MessageLookupByLibrary.simpleMessage("open EPUB"),
        "filePickerTitle":
            MessageLookupByLibrary.simpleMessage("EPUB File Select"),
        "openaiAPI": MessageLookupByLibrary.simpleMessage("OPENAI API"),
        "openaiAPIKey": MessageLookupByLibrary.simpleMessage("OPENAI API Key"),
        "openaiAPIModel":
            MessageLookupByLibrary.simpleMessage("OPENAI API Model"),
        "openaiAPIPrompt":
            MessageLookupByLibrary.simpleMessage("Translate Prompt"),
        "settingsSaveBtn":
            MessageLookupByLibrary.simpleMessage("Save Settings"),
        "settingsTitle": MessageLookupByLibrary.simpleMessage("Settings"),
        "successMsg": m1,
        "themeMode": MessageLookupByLibrary.simpleMessage("Theme Mode"),
        "themeModeOption": m2,
        "translateLanguage":
            MessageLookupByLibrary.simpleMessage("Translate Language"),
        "translateLanguageOption": m3,
        "validMsg": m4
      };
}
