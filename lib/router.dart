import 'package:epub_translator/src/features/common/views/epub_screen.dart';
import 'package:epub_translator/src/features/file_picker/views/file_picker_screen.dart';
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
      path: EpubScreen.routerURL,
      name: EpubScreen.routerName,
      builder: (context, state) => const EpubScreen(),
    ),
  ],
);

final routerProvider = Provider<GoRouter>((rer) => routerConfig);
