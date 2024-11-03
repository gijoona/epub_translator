// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `E-BOOK 리더`
  String get appName {
    return Intl.message(
      'E-BOOK 리더',
      name: 'appName',
      desc: '',
      args: [],
    );
  }

  /// `EPUB File 선택`
  String get filePickerTitle {
    return Intl.message(
      'EPUB File 선택',
      name: 'filePickerTitle',
      desc: '',
      args: [],
    );
  }

  /// `EPUB 열기`
  String get fileOpen {
    return Intl.message(
      'EPUB 열기',
      name: 'fileOpen',
      desc: '',
      args: [],
    );
  }

  /// `설정 관리`
  String get settingsTitle {
    return Intl.message(
      '설정 관리',
      name: 'settingsTitle',
      desc: '',
      args: [],
    );
  }

  /// `설정 저장`
  String get settingsSaveBtn {
    return Intl.message(
      '설정 저장',
      name: 'settingsSaveBtn',
      desc: '',
      args: [],
    );
  }

  /// `테마 모드`
  String get themeMode {
    return Intl.message(
      '테마 모드',
      name: 'themeMode',
      desc: '',
      args: [],
    );
  }

  /// `{themeMode, select, system{시스템} light{라이트} dark{다크} other{}}`
  String themeModeOption(String themeMode) {
    return Intl.select(
      themeMode,
      {
        'system': '시스템',
        'light': '라이트',
        'dark': '다크',
        'other': '',
      },
      name: 'themeModeOption',
      desc: '테마모드 선택 옵션',
      args: [themeMode],
    );
  }

  /// `번역 언어`
  String get translateLanguage {
    return Intl.message(
      '번역 언어',
      name: 'translateLanguage',
      desc: '',
      args: [],
    );
  }

  /// `{language, select, ko{한국어} ja{일본어} en{영어} other{}}`
  String translateLanguageOption(String language) {
    return Intl.select(
      language,
      {
        'ko': '한국어',
        'ja': '일본어',
        'en': '영어',
        'other': '',
      },
      name: 'translateLanguageOption',
      desc: '번역언어 선택 옵션',
      args: [language],
    );
  }

  /// `OPENAI API`
  String get openaiAPI {
    return Intl.message(
      'OPENAI API',
      name: 'openaiAPI',
      desc: '',
      args: [],
    );
  }

  /// `OPENAI API 모델`
  String get openaiAPIModel {
    return Intl.message(
      'OPENAI API 모델',
      name: 'openaiAPIModel',
      desc: '',
      args: [],
    );
  }

  /// `OPENAI API 키`
  String get openaiAPIKey {
    return Intl.message(
      'OPENAI API 키',
      name: 'openaiAPIKey',
      desc: '',
      args: [],
    );
  }

  /// `번역 프롬프트`
  String get openaiAPIPrompt {
    return Intl.message(
      '번역 프롬프트',
      name: 'openaiAPIPrompt',
      desc: '',
      args: [],
    );
  }

  /// `{btnType, select, viewMode{화면분할} prevChapter{이전 챕터} prevContents{이전 컨텐츠} nextChapter{다음 챕터} nextContents{다음 컨텐츠} other{}}`
  String epubActionBtns(String btnType) {
    return Intl.select(
      btnType,
      {
        'viewMode': '화면분할',
        'prevChapter': '이전 챕터',
        'prevContents': '이전 컨텐츠',
        'nextChapter': '다음 챕터',
        'nextContents': '다음 컨텐츠',
        'other': '',
      },
      name: 'epubActionBtns',
      desc: 'Epub 화면의 버튼',
      args: [btnType],
    );
  }

  /// `{msgType, select, saveSattings{설정이 저장되었습니다.} other{}}`
  String successMsg(String msgType) {
    return Intl.select(
      msgType,
      {
        'saveSattings': '설정이 저장되었습니다.',
        'other': '',
      },
      name: 'successMsg',
      desc: '완료 메시지 정의',
      args: [msgType],
    );
  }

  /// `{msgType, select, noneSelectedFile{선택된 파일이 없습니다.} emptyAPIInfo{번역기능을 이용하기 위해서는 설정에서 OPENAI정보를 입력하셔야 합니다.} imageLoadFail{이미지 로드 실패} other{}}`
  String errorMsg(String msgType) {
    return Intl.select(
      msgType,
      {
        'noneSelectedFile': '선택된 파일이 없습니다.',
        'emptyAPIInfo': '번역기능을 이용하기 위해서는 설정에서 OPENAI정보를 입력하셔야 합니다.',
        'imageLoadFail': '이미지 로드 실패',
        'other': '',
      },
      name: 'errorMsg',
      desc: '에러 메시지 정의',
      args: [msgType],
    );
  }

  /// `{msgType, select, notInvalid{모든 필드를 올바르게 입력하세요.} other{}}`
  String validMsg(String msgType) {
    return Intl.select(
      msgType,
      {
        'notInvalid': '모든 필드를 올바르게 입력하세요.',
        'other': '',
      },
      name: 'validMsg',
      desc: '검증 메시지 정의',
      args: [msgType],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'ko'),
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ja'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
