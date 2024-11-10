import 'dart:convert';

import 'package:epub_translator/src/features/epub_history/models/history_model.dart';
import 'package:epub_translator/src/features/epub_history/services/history_service.dart';
import 'package:epub_translator/src/features/epub_reader/epub_screen.dart';
import 'package:epub_translator/src/features/epub_reader/origintext/controllers/epub_controller.dart';
import 'package:epub_translator/src/features/epub_reader/origintext/models/epub_book_model.dart';
import 'package:epub_translator/src/features/epub_reader/origintext/models/epub_content_model.dart';
import 'package:epub_translator/src/features/epub_reader/translation/controllers/translation_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:epub_translator/src/features/settings/views/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class EpubHistoryScreen extends ConsumerWidget {
  static const routeURL = '/history';
  static const routeName = 'history';

  // file_picker > 열람파일 보기 > EpubHistoryScreen
  const EpubHistoryScreen({super.key});

  void _onTap(BuildContext context, WidgetRef ref, HistoryModel history) async {
    // 선택된 EPUB 파일 load
    // 새로운 EPUB파일 로드 시 포함된 이미지 파일등의 정보가 변경되므로 이전 번역데이터 초기화.
    await ref
        .read(epubControllerProvider.notifier)
        .loadEpub(history.epubFilePath);

    ref.read(translatedEpubContentsProvider.notifier).state = [''];
    final book = ref.read(epubBookProvider.notifier).state;

    if (book != null) {
      await saveHistory(ref, history);

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
    }
  }

  void _openEpubFileForHistory() {}

  Future<void> saveHistory(WidgetRef ref, HistoryModel history) async {
    ref.read(historyServiceProvider).saveHistory(history);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('열람이력'),
          actions: [
            IconButton(
              onPressed: () {
                context.pushNamed(SettingsScreen.routeName);
              },
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
        body: FutureBuilder(
          future: ref.read(historyServiceProvider).loadAllHistory(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final historyList = snapshot.data!;
              return ListView.separated(
                clipBehavior: Clip.none,
                itemBuilder: (context, index) {
                  final history = historyList[index];
                  return ListTile(
                    onTap: () => _onTap(context, ref, history),
                    minLeadingWidth: 50,
                    leading: Image.memory(
                      base64Decode(history.coverImage.split(',').last),
                      fit: BoxFit.contain,
                      width: 50,
                    ),
                    title: Container(
                      height: 50,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        history.epubName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    subtitle: Text(
                      '열람일시 : ${DateFormat('yyyy-MM-dd').format(history.lastViewDate)}',
                    ),
                    subtitleTextStyle: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Colors.grey),
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider(
                    indent: 20,
                    endIndent: 20,
                  );
                },
                itemCount: historyList.length,
              );
            }

            return const Center(child: Text('열람이력이 없습니다.'));
          },
        ),
      ),
    );
  }
}
