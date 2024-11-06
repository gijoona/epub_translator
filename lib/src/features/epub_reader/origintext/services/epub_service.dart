import 'dart:io';

import 'package:epub_translator/src/features/common/utils/utils.dart';
import 'package:epub_translator/src/features/epub_reader/origintext/models/epub_book_model.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EpubService {
  late EpubBook _epubBook;

  final Ref ref;

  EpubService(this.ref);

  Future<void> loadEpub(String filePath) async {
    final bytes = File(filePath).readAsBytesSync();
    _epubBook = await EpubReader.readBook(bytes);
    ref.read(epubBookProvider.notifier).state =
        EpubBookModel.fromEpubBook(_epubBook);
  }

  String getImage(String src) {
    final asset = _epubBook.Content!.Images!.entries
        .firstWhere(
          (entry) => entry.key.contains(src) || src.contains(entry.key),
          orElse: () => MapEntry('', EpubByteContentFile()),
        )
        .value;

    return Utils.getImageAsBase64(asset);
  }
}

final epubServiceProvider = Provider<EpubService>((ref) => EpubService(ref));
