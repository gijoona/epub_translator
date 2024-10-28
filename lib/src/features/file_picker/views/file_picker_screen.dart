import 'package:epub_translator/src/features/common/views/epub_screen.dart';
import 'package:epub_translator/src/features/epub_reader/origintext/controllers/epub_controller.dart';
import 'package:epub_translator/src/features/epub_reader/origintext/models/epub_book_model.dart';
import 'package:epub_translator/src/features/epub_reader/origintext/models/epub_content_model.dart';
import 'package:epub_translator/src/features/settings/views/settings_screen.dart';
import 'package:epub_translator/src/features/epub_reader/translation/controllers/translation_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilePickerScreen extends ConsumerWidget {
  static const String routeURL = '/';
  static const String routeName = 'filePicker';

  const FilePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('EPUB File 선택'),
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
            onPressed: () async {
              // File Picker를 통해 EPUB 파일 선택
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['epub'],
              );

              if (result != null && result.files.single.path != null) {
                // 선택된 EPUB 파일 load
                String filePath = result.files.single.path!;
                await ref
                    .read(epubControllerProvider.notifier)
                    .loadEpub(filePath);
                // 새로운 EPUB파일 로드 시 포함된 이미지 파일등의 정보가 변경되므로 이전 번역데이터 초기화.
                ref.read(translatedEpubContentsProvider.notifier).state = [''];
                var book = ref.read(epubBookProvider.notifier).state;

                if (book != null) {
                  Map<String, List<String>> translatesMap = {};
                  book.contents.values.indexed.forEach((value) =>
                      translatesMap['${value.$1}'] = [value.$2.Content ?? '']);

                  ref.read(epubContentProvider.notifier).state =
                      EpubContentModel(
                    title: book.title,
                    author: book.author,
                    chapters: book.chapters,
                    content: book.contents.values.first,
                    contents: book.contents.values.toList(),
                    translates: translatesMap,
                  );
                }

                // EPUB Reader 화면으로 이동
                context.pushNamed(EpubScreen.routeName);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('선택된 파일이 없습니다.')),
                );
              }
            },
            child: const Text('EPUB 열기'),
          ),
        ),
      ),
    );
  }
}
