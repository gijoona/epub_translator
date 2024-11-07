import 'dart:convert';

import 'package:epub_translator/src/db/providers/history_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:epub_translator/src/features/settings/views/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EpubHistoryScreen extends ConsumerWidget {
  static const routeURL = '/history';
  static const routeName = 'history';

  // file_picker > 열람파일 보기 > EpubHistoryScreen
  const EpubHistoryScreen({super.key});

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
          future: ref.read(historyProvider.notifier).loadAllHistory(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final historyList = snapshot.data!;
              return ListView.separated(
                itemBuilder: (context, index) {
                  final history = historyList[index];
                  return ListTile(
                    leading: Image.memory(
                      base64Decode(history.coverImage.split(',').last),
                      fit: BoxFit.contain,
                    ),
                    title: Text(history.epubName),
                    subtitle: Text(history.lastViewDate.toIso8601String()),
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider();
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
