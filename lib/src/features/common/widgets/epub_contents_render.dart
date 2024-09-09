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
  }) : _currContents = contents;

  final String _currContents;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Html(
      data: _currContents,
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
          tagsToExtend: {'img', 'svg'},
          builder: (context) {
            var element = context.element;
            String? src;
            // 표지 등의 이미지의 경우 img가 아닌 svg image로 표시하므로 별도의 처리로직이 필요
            if (context.elementName == 'svg') {
              if (context.element!.children.isNotEmpty &&
                  context.element!.children.first.localName == 'image') {
                element = context.element!.children.first;
                var attributeName = element.attributes.keys
                    .firstWhere((key) => key.toString().contains('href'));
                src = element.attributes[attributeName];
              }
            } else {
              src = element!.attributes['src'];
            }

            try {
              final base64Image =
                  ref.read(epubServiceProvider).getImageAsBase64(
                        '$src',
                      );

              return Images.Image.memory(
                base64Decode(base64Image.split(',').last),
                fit: BoxFit.contain,
              );
            } catch (err) {
              return const Text('Error loading image');
            }
          },
        ),
      ],
    );
  }
}
