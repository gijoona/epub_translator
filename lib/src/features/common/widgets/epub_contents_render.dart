import 'dart:convert';

import 'package:epub_translator/src/features/epub_reader/services/epub_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/src/widgets/image.dart' as Images;

class EpubContentsRender extends ConsumerWidget {
  const EpubContentsRender({
    super.key,
    required String contents,
  }) : _currChapterContents = contents;

  final String _currChapterContents;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Html(
      data: _currChapterContents,
      style: {
        "body": Style(
          fontSize: FontSize(18.0),
          lineHeight: const LineHeight(1.5),
        ),
        "h1": Style(
          fontWeight: FontWeight.bold,
          fontSize: FontSize(24.0),
        ),
      },
      extensions: [
        TagExtension(
          tagsToExtend: {'img'},
          builder: (extensionContext) {
            final base64Image = ref.read(epubServiceProvider).getImageAsBase64(
                  '${extensionContext.attributes['src']}',
                );

            return Images.Image.memory(
              base64Decode(base64Image.split(',').last),
              fit: BoxFit.contain,
            );
          },
        ),
      ],
    );
  }
}
