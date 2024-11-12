import 'dart:convert';

import 'package:epub_translator/generated/l10n.dart';
import 'package:epub_translator/src/features/common/utils/utils.dart';
import 'package:epub_translator/src/features/epub_history/models/history_model.dart';
import 'package:epub_translator/src/features/epub_history/services/history_service.dart';
import 'package:epub_translator/src/features/epub_history/epub_history_screen.dart';
import 'package:epub_translator/src/features/epub_reader/epub_screen.dart';
import 'package:epub_translator/src/features/epub_reader/origintext/controllers/epub_controller.dart';
import 'package:epub_translator/src/features/epub_reader/origintext/models/epub_book_model.dart';
import 'package:epub_translator/src/features/epub_reader/origintext/models/epub_content_model.dart';
import 'package:epub_translator/src/features/settings/views/settings_screen.dart';
import 'package:epub_translator/src/features/epub_reader/translation/controllers/translation_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;

class FilePickerScreen extends ConsumerWidget {
  static const String routeURL = '/';
  static const String routeName = 'filePicker';

  const FilePickerScreen({super.key});

  Future<void> _onPressed(BuildContext context, WidgetRef ref) async {
    // File Picker를 통해 EPUB 파일 선택
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub'],
    );

    if (result != null && result.files.single.path != null) {
      // 선택된 EPUB 파일 load
      String filePath = result.files.single.path!;
      await ref.read(epubControllerProvider.notifier).loadEpub(filePath);

      // 새로운 EPUB파일 로드 시 포함된 이미지 파일등의 정보가 변경되므로 이전 번역데이터 초기화.
      ref.read(translatedEpubContentsProvider.notifier).state = [''];
      final book = ref.read(epubBookProvider.notifier).state;

      if (book != null) {
        await saveHistory(ref, book, filePath);

        Map<String, List<String>> translatesMap = {};
        for (var value in book.contents.values.indexed) {
          translatesMap['${value.$1}'] = [value.$2.Content ?? ''];
        }

        ref.read(epubContentProvider.notifier).state = EpubContentModel(
          title: book.title,
          author: book.author,
          chapters: book.chapters,
          content: book.contents.values.first,
          contents: book.contents.values.toList(),
          translates: translatesMap,
        );

        // EPUB Reader 화면으로 이동
        context.pushNamed(EpubScreen.routeName);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context).errorMsg('epubLoadFailed'),
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context).errorMsg('noneSelectedFile'),
          ),
        ),
      );
    }
  }

  Future<void> saveHistory(
    WidgetRef ref,
    EpubBookModel book,
    String epubFilePath,
  ) async {
    // coverImage가 없을 경우 AppIcon 이미지로 대체
    final iconImage =
        await Utils.loadAssetAsImage('assets/icon/Ebook_Icon_1024x1024.png');
    final coverImage =
        book.coverImage ?? base64Encode(img.encodePng(iconImage!));
    await ref.read(historyServiceProvider).saveHistory(
          HistoryModel(
            epubName: book.title,
            coverImage: 'data:image/png;base64,$coverImage',
            lastViewIndex: 0,
            epubFilePath: epubFilePath,
          ),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).filePickerTitle),
          actions: [
            IconButton(
              onPressed: () {
                context.pushNamed(SettingsScreen.routeName);
              },
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () => _onPressed(context, ref),
            child: Text(S.of(context).fileOpen),
          ),
        ),
        extendBody: true,
        persistentFooterButtons: [
          ElevatedButton(
            onPressed: () {
              context.pushNamed(EpubHistoryScreen.routeName);
            },
            child: Center(
              child: Text(S.of(context).viewReadingHistory),
            ),
          ),
        ],
      ),
    );
  }
}
