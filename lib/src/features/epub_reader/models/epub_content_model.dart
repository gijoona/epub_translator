import 'package:epubx/epubx.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EpubContentModel {
  final String title;
  final String author;
  final EpubChapter chapter;
  final String contentKey;
  final EpubTextContentFile contentFile;

  EpubContentModel({
    required this.title,
    required this.author,
    required this.chapter,
    required this.contentKey,
    required this.contentFile,
  });

  EpubContentModel copyWith({
    String? title,
    String? author,
    EpubChapter? chapter,
    String? contentKey,
    EpubTextContentFile? contentFile,
  }) {
    return EpubContentModel(
      title: title ?? this.title,
      author: author ?? this.author,
      chapter: chapter ?? this.chapter,
      contentKey: contentKey ?? this.contentKey,
      contentFile: contentFile ?? this.contentFile,
    );
  }
}

final epubContentProvider = StateProvider<EpubContentModel?>((ref) => null);
