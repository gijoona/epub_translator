import 'package:epub_translator/router.dart';
import 'package:epub_translator/src/db/provider/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  GoRouter loadAppInfo(WidgetRef ref) {
    // OpenAI API MODEL 및 API KEY 불러오기
    ref.watch(configProvider.notifier).loadAllConfigs();
    return ref.watch(routerProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouterConf = loadAppInfo(ref);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: goRouterConf,
      title: 'EPUB Translator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
    );
  }
}
