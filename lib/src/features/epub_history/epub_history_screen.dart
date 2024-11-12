import 'dart:convert';

import 'package:epub_translator/generated/l10n.dart';
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
import 'package:visibility_detector/visibility_detector.dart';

class EpubHistoryScreen extends ConsumerStatefulWidget {
  static const routeURL = '/history';
  static const routeName = 'history';

  // file_picker > 열람파일 보기 > EpubHistoryScreen
  const EpubHistoryScreen({super.key});

  @override
  ConsumerState<EpubHistoryScreen> createState() => _EpubHistoryScreenState();
}

class _EpubHistoryScreenState extends ConsumerState<EpubHistoryScreen> {
  List<HistoryModel> historyList = [];
  int pageNum = 1;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    if (!mounted || isLoading) return;
    await ref
        .read(historyServiceProvider)
        .loadAllHistoryPaging(pageNum: pageNum)
        .then((data) {
      if (data!.isEmpty) return;
      setState(() {
        historyList.addAll(data);
        pageNum += 1;
        isLoading = false;
      });
    });
  }

  void _onTap(HistoryModel history) async {
    // 선택된 EPUB 파일 load
    // 새로운 EPUB파일 로드 시 포함된 이미지 파일등의 정보가 변경되므로 이전 번역데이터 초기화.
    await ref
        .read(epubControllerProvider.notifier)
        .loadEpub(history.epubFilePath);

    ref.read(translatedEpubContentsProvider.notifier).state = [''];
    final book = ref.read(epubBookProvider.notifier).state;

    if (book != null) {
      await saveHistory(history);

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
          content: Text(S.of(context).errorMsg('localEpubNotExists')),
        ),
      );
    }
  }

  Future<void> saveHistory(HistoryModel history) async {
    ref.read(historyServiceProvider).saveHistory(
          history.copyWith(
            lastViewDate: DateTime.now(),
          ),
        );
  }

  void deleteHistory(String epubName) {
    ref.read(historyServiceProvider).deleteHistory(epubName);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$epubName ${S.of(context).deleted}')),
    );
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).historyTitle),
          actions: [
            IconButton(
              onPressed: () {
                context.pushNamed(SettingsScreen.routeName);
              },
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
        body: ListView.separated(
          shrinkWrap: true,
          itemCount: historyList.length,
          itemBuilder: (context, index) {
            final history = historyList[index];
            return VisibilityDetector(
              key: ValueKey(history.epubName),
              onVisibilityChanged: (info) {
                if (!isLoading && index >= historyList.length - 1) {
                  loadHistory();
                }
              },
              child: Dismissible(
                key: ValueKey(history.epubName),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Theme.of(context).colorScheme.errorContainer,
                ),
                onDismissed: (direction) {
                  switch (direction.name) {
                    case 'endToStart':
                      deleteHistory(history.epubName);
                      setState(() => historyList.removeAt(index));
                      break;
                  }
                },
                child: ListTile(
                  onTap: () => _onTap(history),
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
                    '${S.of(context).historyDate} : ${DateFormat('yyyy-MM-dd').format(history.lastViewDate)}',
                  ),
                  subtitleTextStyle: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: Colors.grey),
                ),
              ),
            );
          },
          separatorBuilder: (context, index) {
            return const Divider(
              indent: 20,
              endIndent: 20,
            );
          },
        ),
      ),
    );
  }
}
