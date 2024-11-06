import 'dart:async';
import 'dart:io';

import 'package:epub_translator/generated/l10n.dart';
import 'package:epub_translator/router.dart';
import 'package:epub_translator/src/db/providers/config_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> initializeApp() async {
  // 환경 변수 로드
  await dotenv.load(fileName: ".env");

  // 데이터베이스 초기화 - Only initialize sqflite_common_ffi for non-web platforms
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi; // Initialize the databasefactory
  }
}

void main() async {
  // Flutter의 시스템 위젯이 완전히 초기화되도록 보장
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Heavy 작업을 백그라운드에서 처리
    await initializeApp();

    // run app here
    runApp(
      const ProviderScope(child: MyApp()),
    );
  } catch (err, stacktrace) {
    debugPrint('앱 초기화 실패: $err');
    debugPrintStack(stackTrace: stacktrace);
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  final bool _debugShowCheckedModeBanner = false;
  // 다국어지원 설정된 언어일 경우 해당 언어를 가져오고 아니면 기본값으로 ko(한국어)를 가져온다.
  late Locale _systemLocale;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _systemLocale = _getSystemLocale();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    super.didChangeLocales(locales);
    setState(() {
      _systemLocale = _getSystemLocale();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Locale _getSystemLocale() {
    // 언어 코드로 로케일을 처리합니다.
    return S.delegate.supportedLocales.firstWhere(
      (locale) =>
          locale.toString() ==
          WidgetsBinding.instance.platformDispatcher.locale.languageCode,
      orElse: () => const Locale('ko'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ref.watch(configProvider.notifier).loadAllConfigs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 초기화 작업이 완료될 때까지 로딩 화면 표시
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        /// TODO 저장된 ThemeMode를 반영하기 위해 configProvider를 Watch하는 부분. watch - configProvider의 변경을 감지해서 ThemeMode를 즉각 갱신. read - 갱신을 감지하지 못하므로 설정에서 변경/저장해도 재시작하지 않으면 반영안됨.
        /// 문제는 watch 시 epubScreen, settingsScreen 둘 다 새로 build 됨에 따라 setting 저장 시 epubScreen의 initState가 재호출되어서 epub를 다시 로드, 이어보기 체크를 재수행하는 등의 오작동을 일으킴.
        // final config = ref.watch(configProvider);
        var theme = '2';
        // if (config.hasValue) {
        //   theme = config.value!['APP_THEMEMODE'] ?? '0';
        // }

        // 설정이 완료된 후에 앱을 정상적으로 실행
        return MaterialApp.router(
          debugShowCheckedModeBanner: _debugShowCheckedModeBanner,
          routerConfig: ref.watch(routerProvider),
          themeMode: ThemeMode.values.elementAt(int.parse(theme)),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            useMaterial3: true,
          ),
          locale: _systemLocale,
          darkTheme: ThemeData.dark(
            useMaterial3: true,
          ),
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
        );
      },
    );
  }
}
