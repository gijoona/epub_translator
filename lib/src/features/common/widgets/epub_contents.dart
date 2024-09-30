import 'package:epub_translator/src/features/common/views/epub_screen.dart';
import 'package:epub_translator/src/features/epub_reader/views/epub_reader_screen.dart';
import 'package:epub_translator/src/features/settings/views/settings_screen.dart';
import 'package:epub_translator/src/features/translation/views/epub_translation_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marquee/marquee.dart';

class EpubContents extends StatelessWidget {
  const EpubContents({
    super.key,
    // required ScrollController scrollController,
    required this.caption,
    required EpubViewMode viewMode,
    required this.contentsNum,
  }) : _viewMode = viewMode;

  // final ScrollController _scrollController;
  final String caption;
  final EpubViewMode _viewMode;
  final int contentsNum;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      // controller: _scrollController,Í
      slivers: [
        SliverAppBar(
          snap: false,
          floating: true,
          stretch: true,
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const [
              StretchMode.blurBackground,
              StretchMode.zoomBackground,
            ],
            centerTitle: true,
            title: Padding(
              padding: const EdgeInsets.only(
                top: 12,
                right: 50,
                left: 50,
              ),
              child: Marquee(
                pauseAfterRound: const Duration(milliseconds: 5),
                text: caption,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                context.pushNamed(SettingsScreen.routeName);
              },
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.only(
              top: 10,
              left: 30,
              right: 30,
              bottom: 60,
            ),
            width: MediaQuery.of(context).size.width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_viewMode == EpubViewMode.both ||
                    _viewMode == EpubViewMode.original)
                  Flexible(
                    flex: 1,
                    child: EpubReaderScreen(
                      contentsNum: contentsNum,
                    ), // EPUB 원본
                  ),
                if (_viewMode == EpubViewMode.both ||
                    _viewMode == EpubViewMode.translation)
                  const Flexible(
                    flex: 1,
                    child: EpubTranslationScreen(), // EPUB 번역
                  ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
