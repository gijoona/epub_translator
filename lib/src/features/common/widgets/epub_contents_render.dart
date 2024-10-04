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
    final bodyColor = Theme.of(context).textTheme.bodyLarge!.color;
    return Html(
      shrinkWrap: true,
      data: _currContents,
      style: {
        "body": Style(
          fontSize: FontSize(18.0),
          lineHeight: const LineHeight(2),
        ),
        "h1": Style(
          fontWeight: FontWeight.bold,
          fontSize: FontSize(24.0),
        ),
      },
      extensions: [
        // ruby 태그 처리
        TagExtension(
          tagsToExtend: {'ruby'},
          builder: (context) {
            final rubyElement = context.element; // tree 대신 element로 접근
            final rbTexts = rubyElement!.children
                .where((e) => e.localName == 'rb')
                .map((e) => e.text)
                .join(''); // rb 태그의 모든 텍스트 결합
            final rtTexts = rubyElement.children
                .where((e) => e.localName == 'rt')
                .map((e) => e.text)
                .join(' '); // rt 태그의 모든 텍스트 결합
            const rbTextStyle = TextStyle(
              fontSize: 18.0,
              color: Colors.transparent,
            );

            return RichText(
              text: TextSpan(
                children: [
                  WidgetSpan(
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Text(
                          rbTexts,
                          style: rbTextStyle,
                        ),
                        Positioned(
                          child: Text(
                            rbTexts, // 한자 부분
                            style: rbTextStyle.copyWith(color: bodyColor),
                          ),
                        ),
                        Positioned(
                          top: -14,
                          child: Text(
                            rtTexts, // 후리가나 부분
                            style: const TextStyle(
                              fontSize: 12.0, // 후리가나는 더 작은 글자 크기
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        // image 태그 처리
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
