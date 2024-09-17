import 'package:epub_translator/src/features/common/widgets/epub_contents_render.dart';
import 'package:epub_translator/src/features/translation/controllers/translation_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EpubTranslationScreen extends ConsumerStatefulWidget {
  static const routerURL = '/epubTranslation';
  static const routerName = 'epubTranslation';

  const EpubTranslationScreen({super.key});

  @override
  ConsumerState<EpubTranslationScreen> createState() =>
      _EpubTranslationScreenState();
}

class _EpubTranslationScreenState extends ConsumerState<EpubTranslationScreen> {
  @override
  Widget build(BuildContext context) {
    final translationEpubContents = ref.watch(translatedEpubContentsProvider);

    return SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      child: ListView.builder(
        shrinkWrap: true, // <==== limit height. 리스트뷰 크기 고정
        primary: false, // <====  disable scrolling. 리스트뷰 내부는 스크롤 안할거임
        itemCount: translationEpubContents.length,
        itemBuilder: (context, index) {
          return EpubContentsRender(
            contents: translationEpubContents[index],
          );
        },
      ),
    );
  }
}
