// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ko locale. All the
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
  String get localeName => 'ko';

  static String m0(btnType) => "${Intl.select(btnType, {
            'first': '처음부터',
            'continue': '이어본다',
            'other': '',
          })}";

  static String m1(dialogType) => "${Intl.select(dialogType, {
            'continueReading': '이전에 보던 챕터가 있습니다.',
            'other': '',
          })}";

  static String m2(btnType) => "${Intl.select(btnType, {
            'viewMode': '화면분할',
            'prevChapter': '이전 챕터',
            'prevContents': '이전 컨텐츠',
            'nextChapter': '다음 챕터',
            'nextContents': '다음 컨텐츠',
            'other': '',
          })}";

  static String m3(msgType) => "${Intl.select(msgType, {
            'noneSelectedFile': '선택된 파일이 없습니다.',
            'emptyAPIInfo': '번역기능을 이용하기 위해서는 설정에서 OPENAI정보를 입력하셔야 합니다.',
            'imageLoadFail': '이미지 로드 실패',
            'localEpubNotExists': '로컬 디바이스 내에 해당 파일정보가 없습니다.',
            'epubLoadFailed': 'EPUB 파일을 여는 중 오류가 발생했습니다.',
            'historyLoadFailed': '열람이력 조회 중 오류가 발생했습니다.',
            'other': '',
          })}";

  static String m4(msgType) => "${Intl.select(msgType, {
            'saveSattings': '설정이 저장되었습니다.',
            'other': '',
          })}";

  static String m5(themeMode) => "${Intl.select(themeMode, {
            'system': '시스템',
            'light': '라이트',
            'dark': '다크',
            'other': '',
          })}";

  static String m6(language) => "${Intl.select(language, {
            'ko': '한국어',
            'ja': '일본어',
            'en': '영어',
            'other': '',
          })}";

  static String m7(msgType) => "${Intl.select(msgType, {
            'notInvalid': '모든 필드를 올바르게 입력하세요.',
            'other': '',
          })}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "appName": MessageLookupByLibrary.simpleMessage("E-BOOK 리더"),
        "deleted": MessageLookupByLibrary.simpleMessage("삭제됨"),
        "dialogActionBtns": m0,
        "dialogTitle": m1,
        "epubActionBtns": m2,
        "errorMsg": m3,
        "fileOpen": MessageLookupByLibrary.simpleMessage("EPUB 열기"),
        "filePickerTitle": MessageLookupByLibrary.simpleMessage("EPUB File 선택"),
        "historyDate": MessageLookupByLibrary.simpleMessage("열람일시"),
        "historyTitle": MessageLookupByLibrary.simpleMessage("열람이력"),
        "openaiAPI": MessageLookupByLibrary.simpleMessage("OPENAI API"),
        "openaiAPIKey": MessageLookupByLibrary.simpleMessage("OPENAI API 키"),
        "openaiAPIModel": MessageLookupByLibrary.simpleMessage("OPENAI API 모델"),
        "openaiAPIPrompt": MessageLookupByLibrary.simpleMessage("번역 프롬프트"),
        "settingsSaveBtn": MessageLookupByLibrary.simpleMessage("설정 저장"),
        "settingsTitle": MessageLookupByLibrary.simpleMessage("설정 관리"),
        "successMsg": m4,
        "themeMode": MessageLookupByLibrary.simpleMessage("테마 모드"),
        "themeModeOption": m5,
        "translateLanguage": MessageLookupByLibrary.simpleMessage("번역 언어"),
        "translateLanguageOption": m6,
        "validMsg": m7,
        "viewReadingHistory": MessageLookupByLibrary.simpleMessage("열람이력 보기")
      };
}
