import 'package:epubx/epubx.dart';

class EpubBookModel {
  final String title;
  final String author;
  final List<EpubChapter> chapters;

  EpubBookModel({
    required this.title,
    required this.author,
    required this.chapters,
  });

  factory EpubBookModel.fromEpubBook(EpubBook epubBook) {
    return EpubBookModel(
      title: epubBook.Title ?? 'untitled',
      author: epubBook.Author ?? 'unknown Author',
      chapters: epubBook.Chapters!.map((chapter) => chapter).toList(),
    );
  }
}
