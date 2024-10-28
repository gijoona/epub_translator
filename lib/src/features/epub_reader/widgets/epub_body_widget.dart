import 'package:epub_translator/src/features/epub_reader/epub_screen.dart';
import 'package:epub_translator/src/features/epub_reader/origintext/views/epub_reader_screen.dart';
import 'package:epub_translator/src/features/settings/views/settings_screen.dart';
import 'package:epub_translator/src/features/epub_reader/translation/views/epub_translation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marquee/marquee.dart';

typedef ScrollUpdateCallback = void Function({
  required ScrollController controller,
});

class EpubBodyWidget extends ConsumerStatefulWidget {
  const EpubBodyWidget({
    super.key,
    required this.caption,
    required EpubViewMode viewMode,
    required this.contentsNum,
    required this.scrollController,
    this.onScrollUpdate,
  }) : _viewMode = viewMode;

  final String caption;
  final EpubViewMode _viewMode;
  final int contentsNum;
  final ScrollController scrollController;
  final ScrollUpdateCallback? onScrollUpdate;

  @override
  ConsumerState<EpubBodyWidget> createState() => _EpubBodyWidgetState();
}

class _EpubBodyWidgetState extends ConsumerState<EpubBodyWidget> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController;

    _scrollController.addListener(_updateScrollProgress);
  }

  void _updateScrollProgress() {
    // 스크롤이 진행될 때마다 현재 스크롤 위치와 전체 높이를 계산
    if (_scrollController.hasClients &&
        _scrollController.positions.length == 1 &&
        _scrollController.position.maxScrollExtent > 0) {
      widget.onScrollUpdate?.call(controller: _scrollController);
    }
  }

  double _blankSpace() {
    double textWidth = _calcTextSize(
      text: widget.caption,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
      context: context,
    ).width;

    var calcBlankSpace = MediaQuery.of(context).size.width - textWidth;
    return calcBlankSpace > 30 ? calcBlankSpace : 30;
  }

  Size _calcTextSize({
    required String text,
    required TextStyle style,
    required BuildContext context,
  }) {
    final Size size = (TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textScaler: MediaQuery.of(context).textScaler,
      textDirection: TextDirection.ltr,
    )..layout())
        .size;
    return size;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollProgress);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          leading: IconButton(
            onPressed: GoRouter.of(context).pop,
            icon: const Icon(Icons.close),
          ),
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
                blankSpace: _blankSpace(),
                velocity: 100.0,
                pauseAfterRound: const Duration(seconds: 5),
                startPadding: 10.0,
                accelerationDuration: const Duration(seconds: 1),
                accelerationCurve: Curves.linear,
                decelerationDuration: const Duration(milliseconds: 500),
                decelerationCurve: Curves.easeOut,
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
