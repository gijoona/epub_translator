// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ja locale. All the
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
  String get localeName => 'ja';

  static String m0(btnType) => "${Intl.select(btnType, {
            'first': '最初から',
            'continue': '続ける',
            'other': '',
          })}";

  static String m1(dialogType) => "${Intl.select(dialogType, {
            'continueReading': '前回読んでいた章があります。',
            'other': '',
          })}";

  static String m2(btnType) => "${Intl.select(btnType, {
            'viewMode': '画面分割',
            'prevChapter': '前の章',
            'prevContents': '前のコンテンツ',
            'nextChapter': '次の章',
            'nextContents': '次のコンテンツ',
            'other': '',
          })}";

  static String m3(msgType) => "${Intl.select(msgType, {
            'noneSelectedFile': '選択されたファイルがありません。',
            'emptyAPIInfo': '翻訳機能を利用するには、設定でOPENAI情報を入力する必要があります。',
            'imageLoadFail': '画像の読み込みに失敗しました',
            'localEpubNotExists': 'ローカルデバイスに該当するファイル情報が存在しません。',
            'epubLoadFailed': 'EPUBファイルを開く際にエラーが発生しました。',
            'historyLoadFailed': '閲覧履歴の取得中にエラーが発生しました。',
            'other': '',
          })}";

  static String m4(msgType) => "${Intl.select(msgType, {
            'saveSattings': '設定が保存されました。',
            'other': '',
          })}";

  static String m5(themeMode) => "${Intl.select(themeMode, {
            'system': 'システム',
            'light': 'ライト',
            'dark': 'ダーク',
            'other': '',
          })}";

  static String m6(language) => "${Intl.select(language, {
            'ko': '韓国語',
            'ja': '日本語',
            'en': '英語',
            'other': '',
          })}";

  static String m7(msgType) => "${Intl.select(msgType, {
            'notInvalid': 'すべてのフィールドを正しく入力してください。',
            'other': '',
          })}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "appName": MessageLookupByLibrary.simpleMessage("E-BOOKリーダー"),
        "deleted": MessageLookupByLibrary.simpleMessage("削除済み"),
        "dialogActionBtns": m0,
        "dialogTitle": m1,
        "epubActionBtns": m2,
        "errorMsg": m3,
        "fileOpen": MessageLookupByLibrary.simpleMessage("EPUBを開く"),
        "filePickerTitle": MessageLookupByLibrary.simpleMessage("EPUBファイル選択"),
        "historyDate": MessageLookupByLibrary.simpleMessage("閲覧日時"),
        "historyTitle": MessageLookupByLibrary.simpleMessage("閲覧履歴"),
        "openaiAPI": MessageLookupByLibrary.simpleMessage("OPENAI API"),
        "openaiAPIKey": MessageLookupByLibrary.simpleMessage("OPENAI APIキー"),
        "openaiAPIModel": MessageLookupByLibrary.simpleMessage("OPENAI APIモデル"),
        "openaiAPIPrompt": MessageLookupByLibrary.simpleMessage("翻訳プロンプト"),
        "settingsSaveBtn": MessageLookupByLibrary.simpleMessage("設定を保存"),
        "settingsTitle": MessageLookupByLibrary.simpleMessage("設定管理"),
        "successMsg": m4,
        "themeMode": MessageLookupByLibrary.simpleMessage("テーマモード"),
        "themeModeOption": m5,
        "translateLanguage": MessageLookupByLibrary.simpleMessage("翻訳言語"),
        "translateLanguageOption": m6,
        "validMsg": m7,
        "viewReadingHistory": MessageLookupByLibrary.simpleMessage("閲覧履歴を見る")
      };
}
