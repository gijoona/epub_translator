import 'package:epub_translator/src/features/common/views/epub_screen.dart';
import 'package:epub_translator/src/features/epub_reader/views/epub_reader_screen.dart';
import 'package:epub_translator/src/features/settings/views/settings_screen.dart';
import 'package:epub_translator/src/features/translation/views/epub_translation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marquee/marquee.dart';

typedef ScrollUpdateCallback = void Function(
  double offset,
  double maxScrollExtent,
);

class EpubContents extends ConsumerStatefulWidget {
  const EpubContents({
    super.key,
    required this.caption,
    required EpubViewMode viewMode,
    required this.contentsNum,
    this.onScrollUpdate,
  }) : _viewMode = viewMode;

  final String caption;
  final EpubViewMode _viewMode;
  final int contentsNum;
  final ScrollUpdateCallback? onScrollUpdate;

  @override
  ConsumerState<EpubContents> createState() => _EpubContentsState();
}

class _EpubContentsState extends ConsumerState<EpubContents> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_updateScrollProgress);
  }

  void _updateScrollProgress() {
    // 스크롤이 진행될 때마다 현재 스크롤 위치와 전체 높이를 계산
    if (_scrollController.hasClients &&
        _scrollController.position.maxScrollExtent > 0) {
      final currentScroll = _scrollController.offset;
      final totalScroll = _scrollController.position.maxScrollExtent;

      if (widget.onScrollUpdate != null) {
        widget.onScrollUpdate!(currentScroll, totalScroll);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
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
                text: widget.caption,
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
                if (widget._viewMode == EpubViewMode.both ||
                    widget._viewMode == EpubViewMode.original)
                  Flexible(
                    flex: 1,
                    child: EpubReaderScreen(
                      contentsNum: widget.contentsNum,
                    ), // EPUB 원본
                  ),
                if (widget._viewMode == EpubViewMode.both ||
                    widget._viewMode == EpubViewMode.translation)
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
