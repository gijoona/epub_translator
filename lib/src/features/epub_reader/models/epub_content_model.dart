import 'package:epubx/epubx.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EpubContentModel {
  final String title;
  final String author;
  final EpubChapter? chapter;
  final List<EpubChapter> chapters;
  final int currContentNum;
  final EpubTextContentFile content;
  final List<EpubTextContentFile> contents;

  EpubContentModel({
    required this.title,
    required this.author,
    this.chapter,
    required this.chapters,
    this.currContentNum = 0,
    required this.content,
    required this.contents,
  });

  EpubContentModel copyWith({
    String? title,
    String? author,
    EpubChapter? chapter,
    List<EpubChapter>? chapters,
    int currContentNum = 0,
    EpubTextContentFile? content,
    List<EpubTextContentFile>? contents,
  }) {
    return EpubContentModel(
      title: title ?? this.title,
      author: author ?? this.author,
      chapter: chapter ?? this.chapter,
      chapters: chapters ?? this.chapters,
      currContentNum: currContentNum,
      content: content ?? this.content,
      contents: contents ?? this.contents,
    );
  }
}

final epubContentProvider = StateProvider<EpubContentModel?>((ref) => null);
