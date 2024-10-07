import 'package:epubx/epubx.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EpubBookModel {
  final String title;
  final String author;
  final List<EpubChapter> chapters;
  final Map<String, EpubTextContentFile> contents;
  final Map<String, EpubByteContentFile> images;

  EpubBookModel({
    required this.title,
    required this.author,
    required this.chapters,
    required this.contents,
    required this.images,
  });

  factory EpubBookModel.fromEpubBook(EpubBook epubBook) {
    return EpubBookModel(
      title: epubBook.Title ?? '제목없음',
      author: epubBook.Author ?? '작자미상',
      chapters: epubBook.Chapters!.map((chapter) => chapter).toList(),
      contents: epubBook.Content!.Html!,
      images: epubBook.Content!.Images!,
    );
  }
}

final epubBookProvider = StateProvider<EpubBookModel?>(
  (ref) => null,
);
