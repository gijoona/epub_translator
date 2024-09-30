import 'package:epub_translator/src/features/epub_reader/models/epub_content_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EpubPageNum extends StatelessWidget {
  const EpubPageNum({
    super.key,
    required int maxContentsIdx,
  }) : _maxContentsIdx = maxContentsIdx;

  final int _maxContentsIdx;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        var contentInfo = ref.watch(epubContentProvider);
        return Column(
          children: [
            RichText(
              text: TextSpan(
                style: Theme.of(context)
                    .textTheme
                    .labelLarge!
                    .copyWith(fontSize: 28),
                children: [
                  TextSpan(text: '${contentInfo!.currContentNum}'),
                  const TextSpan(
                    text: ' / ',
                  ),
                  TextSpan(
                    text: '${_maxContentsIdx - 1} ',
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
