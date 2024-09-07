import 'package:epubx/epubx.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EpubBookModel {
  final String title;
  final String author;
  final List<EpubChapter> chapters;
  final Map<String, EpubTextContentFile> contents;

  EpubBookModel({
    required this.title,
    required this.author,
    required this.chapters,
    required this.contents,
  });

  factory EpubBookModel.fromEpubBook(EpubBook epubBook) {
    return EpubBookModel(
      title: epubBook.Title ?? 'untitled',
      author: epubBook.Author ?? 'unknown Author',
      chapters: epubBook.Chapters!.map((chapter) => chapter).toList(),
      contents: epubBook.Content!.Html!,
    );
  }
}

final epubBookProvider = StateProvider<EpubBookModel?>(
  (ref) => null,
);
