import 'dart:convert';
import 'dart:io';

import 'package:epub_translator/src/features/epub_reader/models/epub_book_model.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EpubService {
  late EpubBook _epubBook;

  final ProviderRef ref;

  EpubService(this.ref);

  Future<void> loadEpub(String filePath) async {
    final bytes = File(filePath).readAsBytesSync();
    _epubBook = await EpubReader.readBook(bytes);
    ref.read(epubBookProvider.notifier).state =
        EpubBookModel.fromEpubBook(_epubBook);
  }

  String getImageAsBase64(String src) {
    final asset = _epubBook.Content!.Images!.entries
        .firstWhere(
          (entry) => entry.key.contains(src) || src.contains(entry.key),
          orElse: () => MapEntry('', EpubByteContentFile()),
        )
        .value;

    final bytes = asset.Content ?? [];
    return 'data:image/png;base64,${base64Encode(bytes)}';
  }
}

final epubServiceProvider = Provider<EpubService>((ref) => EpubService(ref));
