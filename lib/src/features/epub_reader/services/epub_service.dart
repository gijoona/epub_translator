import 'dart:convert';
import 'dart:io';

import 'package:epub_translator/src/features/epub_reader/models/epub_book_model.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EpubService {
  late EpubBook _epubBook;

  final ProviderRef ref;

  EpubService(this.ref);

  Future<EpubBookModel> loadEpub(String filePath) async {
    final bytes = File(filePath).readAsBytesSync();
    _epubBook = await EpubReader.readBook(bytes);
    EpubBookModel epubBookModel = EpubBookModel.fromEpubBook(_epubBook);
    ref.read(epubBookProvider.notifier).state = epubBookModel;
    return epubBookModel;
  }

  String getImageAsBase64(String src) {
    final asset = _epubBook.Content!.Images!.entries
        .firstWhere(
          (entry) => src.contains(entry.key),
          orElse: () => MapEntry('', EpubByteContentFile()),
        )
        .value;

    final bytes = asset.Content ?? [];
    return 'data:image/png;base64,${base64Encode(bytes)}';
  }
}

final epubServiceProvider = Provider<EpubService>((ref) => EpubService(ref));
