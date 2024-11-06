import 'package:epub_translator/src/features/epub_reader/epub_screen.dart';
import 'package:epub_translator/src/features/file_picker/views/file_picker_screen.dart';
import 'package:epub_translator/src/features/settings/views/settings_screen.dart';
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
      path: EpubScreen.routeURL,
      name: EpubScreen.routeName,
      builder: (context, state) => const EpubScreen(),
    ),
    GoRoute(
      path: SettingsScreen.routeURL,
      name: SettingsScreen.routeName,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

final routerProvider = Provider<GoRouter>((ref) => routerConfig);
