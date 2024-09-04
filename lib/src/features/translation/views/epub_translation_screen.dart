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

    return EpubContentsRender(
      contents: translationEpubContents,
    );
  }
}
