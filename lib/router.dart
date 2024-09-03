import 'package:epub_translator/src/features/file_picker/views/file_picker_screen.dart';
import 'package:epub_translator/src/features/epub_reader/views/epub_reader_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerConfig = GoRouter(
  routes: [
    GoRoute(
      path: FilePickerScreen.routeURL,
      name: FilePickerScreen.routeName,
      builder: (context, state) => const FilePickerScreen(),
    ),
    GoRoute(
      path: EpubReaderScreen.routerURL,
      name: EpubReaderScreen.routerName,
      builder: (context, state) => const EpubReaderScreen(),
    ),
  ],
);

final routerProvider = Provider<GoRouter>((rer) => routerConfig);
