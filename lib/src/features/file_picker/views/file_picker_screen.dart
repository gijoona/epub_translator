import 'package:epub_translator/src/features/common/views/epub_screen.dart';
import 'package:epub_translator/src/features/epub_reader/controllers/epub_controller.dart';
import 'package:epub_translator/src/features/epub_reader/models/epub_book_model.dart';
import 'package:epub_translator/src/features/epub_reader/models/epub_content_model.dart';
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
          title: const Text('Selected EPUB File'),
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
                var book = ref.read(epubBookProvider.notifier).state;

                if (book != null) {
                  var currContentKey = book.contents.keys.elementAt(0);
                  ref.read(epubContentProvider.notifier).state =
                      EpubContentModel(
                    title: book.title,
                    author: book.author,
                    chapter: book.chapters.first,
                    contentKey: currContentKey,
                    contentFile: book.contents[currContentKey]!,
                  );
                }

                // EPUB Reader 화면으로 이동
                context.pushNamed(EpubScreen.routerName);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No File Selected')),
                );
              }
            },
            child: const Text('Open EPUB'),
          ),
        ),
      ),
    );
  }
}
