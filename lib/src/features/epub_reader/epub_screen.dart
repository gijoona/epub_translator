import 'package:epub_translator/generated/l10n.dart';
import 'package:epub_translator/src/db/providers/config_provider.dart';
import 'package:epub_translator/src/db/providers/history_provider.dart';
import 'package:epub_translator/src/features/epub_reader/widgets/continue_reading_dialog_widget.dart';
import 'package:epub_translator/src/features/epub_reader/widgets/epub_body_widget.dart';
import 'package:epub_translator/src/features/epub_reader/widgets/epub_pagenum_widget.dart';
import 'package:epub_translator/src/features/epub_reader/origintext/models/epub_book_model.dart';
import 'package:epub_translator/src/features/epub_reader/origintext/models/epub_content_model.dart';
import 'package:epub_translator/src/features/epub_reader/translation/controllers/translation_controller.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 화면모드
/// 0 : 원본/번역 둘다 표시
/// 1 : 원본만 표시
/// 2 : 번역만 표시
enum EpubViewMode { both, original, translation }

// 스크롤 진행상황을 표시
final scrollProgressProvider = StateProvider((ref) => 0.0);

final visibleFABProvider = StateProvider((ref) => false);

class EpubScreen extends ConsumerStatefulWidget {
  static const routeURL = '/epub';
  static const routeName = 'epub';

  const EpubScreen({super.key});

  @override
  ConsumerState<EpubScreen> createState() => _EpubScreenState();
}

class _EpubScreenState extends ConsumerState<EpubScreen> {
  final PageController _pageController = PageController();
  // 페이지별로 ScrollController를 관리하는 Map
  final Map<int, ScrollController> _scrollControllers = {};
  late ScrollController _contentScrollController;

  EpubViewMode _viewMode = EpubViewMode.original;
  int _maxContentsIdx = 1;
  bool _isTranslating = false; // 번역 상태 플래그
  bool _isVisibleFAB = false; // 기능버튼 Visible 플래그
  late EpubBookModel? _book;
  EpubChapter? _chapter;
  double _childMaxScrollExtent = 0.0;

  @override
  void initState() {
    super.initState();
    loadEpubBook();

    _contentScrollController = _getScrollController(0);

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _showContinueReadingPrompt());
  }

  // 파일로드 실패 시 FilePickerScreen에서 Snackbar로 메시지 표시처리함.
  Future<void> loadEpubBook() async {
    _book = ref.read(epubBookProvider.notifier).state;
    if (_book != null) {
      _maxContentsIdx = _book!.contents.length;
    }
  }

  ScrollController _getScrollController(int pageIndex) {
    // 페이지 인덱스에 해당하는 ScrollController를 반환하거나 생성
    _scrollControllers.putIfAbsent(pageIndex, () => ScrollController());
    return _scrollControllers[pageIndex]!;
  }

  void _showContinueReadingPrompt() {
    final lastViewIndex = ref.read(historyProvider).value!.lastViewIndex;
    if (lastViewIndex != 0) {
      showModalBottomSheet(
        clipBehavior: Clip.hardEdge,
        context: context,
        builder: (context) {
          return ContinueReadingDialog(
              pageController: _pageController, lastViewIndex: lastViewIndex);
        },
      );
    }
  }

  void _changeContentsIndex(String cmd) {
    Duration duration = const Duration(milliseconds: 300);
    Curve curve = Curves.linear;
    switch (cmd) {
      case 'prev':
        _pageController.previousPage(duration: duration, curve: curve);
        break;
      case 'next':
        _pageController.nextPage(duration: duration, curve: curve);
        break;
    }
  }

  void _changeChapterIndex(int addIndex) {
    final epubInfo = ref.read(epubContentProvider.notifier).state!;
    final currChapterIdx = epubInfo.chapter == null
        ? 0
        : epubInfo.chapters.indexOf(epubInfo.chapter!);

    int newChapterIdx =
        (currChapterIdx + addIndex).clamp(0, epubInfo.chapters.length - 1);
    var newChapter = epubInfo.chapters.elementAt(newChapterIdx);
    var newContentIdx =
        _book!.contents.keys.toList().indexOf(newChapter.ContentFileName!);

    _pageController.jumpToPage(newContentIdx);
  }

  void _updateScrollProgress({required ScrollController controller}) {
    if (controller.hasClients && controller.position.maxScrollExtent > 0) {
      // 스크롤이 진행될 때마다 현재 스크롤 위치와 전체 높이를 계산하여 진행 상태를 업데이트
      final currentScrollOffset = controller.offset;
      _childMaxScrollExtent = controller.position.maxScrollExtent;
      final progress =
          (currentScrollOffset / _childMaxScrollExtent).clamp(0.0, 1.0);
      ref.read(scrollProgressProvider.notifier).state = progress;
    }
  }

  void _updateContents(int pageNum) {
    final epubInfo = ref.read(epubContentProvider.notifier).state!;
    final contentFileName = _book!.contents.keys.elementAt(pageNum);
    _chapter = epubInfo.chapters.firstWhere(
      (chapter) => chapter.ContentFileName == contentFileName,
      orElse: () => _chapter ?? EpubChapter(),
    );

    ref.read(epubContentProvider.notifier).state = epubInfo.copyWith(
      currContentNum: pageNum,
      chapter: _chapter,
      content: epubInfo.contents[pageNum],
    );
  }

  void _updateHistory(int pageNum) {
    // 현재 열람 중인 Contents의 index(pageNum)을 history에 갱신한다.
    final history = ref.read(historyProvider).value!.copyWith(
          lastViewIndex: pageNum,
        );
    ref.read(historyProvider.notifier).saveHistory(history);
  }

  void _translateBook() async {
    final config = ref.read(configProvider);
    if (config.hasValue) {
      var apiKey = config.value!['OPENAI_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).errorMsg('emptyAPIInfo')),
          ),
        );
      } else {
        if (_viewMode != EpubViewMode.translation) {
          // 번역기능을 호출한 경우 화면모드를 translation으로 변경.
          setState(() {
            _viewMode = EpubViewMode.translation;
          });
        }
      }
    }

    if (_isTranslating) return; // 이미 번역 중일 경우 중복호출 방지

    _isTranslating = true;
    setState(() {}); // 번역 시작 시 상태갱신

    try {
      await ref.read(translationControllerProvider.notifier).translateEpub();
    } finally {
      _isTranslating = false;
      setState(() {}); // 번역 완료 시 상태갱신
    }
  }

  void _changeView() {
    // Enum 순환: both -> original -> translation -> both
    setState(() {
      _viewMode = EpubViewMode
          .values[(_viewMode.index + 1) % EpubViewMode.values.length];
    });
  }

  void _toggleVisibleFAB() {
    _isVisibleFAB = !_isVisibleFAB;
    ref.read(visibleFABProvider.notifier).state = _isVisibleFAB;
  }

  // 스크롤 진행상태를 표시하는 LinearProgressIndicator에 수평 스와이프 제스처 추가 (수평 스와이프 시 스크롤 이동)
  void _handleScrollHorizontalSwipe(DragUpdateDetails details) {
    var currPositionPercent =
        (details.localPosition.dx / MediaQuery.of(context).size.width)
            .clamp(0.0, 1.0);
    var jumpScrollOffset = (_childMaxScrollExtent * currPositionPercent);
    _contentScrollController.jumpTo(jumpScrollOffset);
  }

  void _onPageChanged(int page) {
    _contentScrollController = _getScrollController(page);
    _updateScrollProgress(controller: _contentScrollController);
    _updateContents(page);
    _updateHistory(page);
  }

  @override
  void dispose() {
    _pageController.dispose();
    // ScrollController를 모두 해제
    for (var controller in _scrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookInfo = ref.read(epubBookProvider.notifier).state;
    final caption =
        bookInfo != null ? '${bookInfo.title} (${bookInfo.author})' : '';
    return SafeArea(
      child: Scaffold(
        body: GestureDetector(
          onTap: _toggleVisibleFAB,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: _maxContentsIdx,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, contentsNum) {
                  final scrollController = _getScrollController(contentsNum);

                  return EpubBodyWidget(
                    caption: caption,
                    viewMode: _viewMode,
                    contentsNum: contentsNum,
                    scrollController: scrollController,
                    updateScrollProgress: _updateScrollProgress,
                  );
                },
              ),
              // 현재 컨텐츠정보를 보여줌. (현재 Contents 번호 / 전체 Contents 번호)
              Consumer(builder: (context, ref, child) {
                var isVisible = ref.watch(visibleFABProvider);
                return isVisible
                    ? Positioned(
                        top: 70,
                        right: 10,
                        child:
                            EpubPageNumWidget(maxContentsIdx: _maxContentsIdx),
                      )
                    : Container();
              }),
              // 번역 중임을 나타내는 LinearProgressIndicator
              if (_isTranslating)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              // 스크롤 상태를 표시하는 LinearProgressIndicator
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onHorizontalDragUpdate: _handleScrollHorizontalSwipe,
                  child: Consumer(
                    builder: (context, ref, child) {
                      var scrollProgress = ref.watch(scrollProgressProvider);
                      return Container(
                        color: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: LinearProgressIndicator(
                          value: scrollProgress,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomAppBar(),
        floatingActionButton: _buildSpeedDial(), // FAB 추가
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildSpeedDial() {
    return Consumer(builder: (context, ref, child) {
      var isVislble = ref.watch(visibleFABProvider);
      return isVislble
          ? SpeedDial(
              heroTag: 'speed-dial-hero-tag',
              // icon: Icons.translate,
              // activeIcon: Icons.close,
              spacing: 5,
              childPadding: const EdgeInsets.all(5),
              childrenButtonSize: const Size(56.0, 56.0),
              buttonSize: const Size(56.0, 56.0),
              spaceBetweenChildren: 5,
              closeManually: false,
              elevation: 8.0,
              animationCurve: Curves.elasticInOut,
              onPress: _isTranslating ? null : _translateBook,
              child: _isTranslating
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.translate),
            )
          : const SizedBox(height: 0);
    });
  }

  // BottomAppBar로 챕터 및 콘텐츠 이동 처리
  Widget _buildBottomAppBar() {
    return Consumer(builder: (context, ref, child) {
      var isVislble = ref.watch(visibleFABProvider);
      return isVislble
          ? BottomAppBar(
              height: 55, // 기본 BottomAppBar는 height가 너무 커서 고정크기 부여
              shape: const CircularNotchedRectangle(),
              notchMargin: 8.0,
              child: LayoutBuilder(
                builder: (context, constraints) => Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // BottomAppBar를 나누어 각 부분을 탭할 때마다 챕터/콘텐츠 이동
                    _buildBottomAppBarButton(
                      width: (constraints.maxWidth - 4) / 5,
                      height: constraints.maxHeight,
                      icon: FontAwesomeIcons.tableColumns,
                      tooltip: S.of(context).epubActionBtns('viewMode'),
                      onTap: _changeView,
                    ),
                    _buildDivider(),
                    _buildBottomAppBarButton(
                      width: (constraints.maxWidth - 4) / 5,
                      height: constraints.maxHeight,
                      icon: Icons.keyboard_double_arrow_left_rounded,
                      tooltip: S.of(context).epubActionBtns('prevChapter'),
                      onTap: () => _changeChapterIndex(-1),
                    ),
                    _buildDivider(),
                    _buildBottomAppBarButton(
                      width: (constraints.maxWidth - 4) / 5,
                      height: constraints.maxHeight,
                      icon: Icons.keyboard_arrow_left_rounded,
                      tooltip: S.of(context).epubActionBtns('prevContents'),
                      onTap: () => _changeContentsIndex('prev'),
                    ),
                    _buildDivider(),
                    _buildBottomAppBarButton(
                      width: (constraints.maxWidth - 4) / 5,
                      height: constraints.maxHeight,
                      icon: Icons.keyboard_arrow_right_rounded,
                      tooltip: S.of(context).epubActionBtns('nextContents'),
                      onTap: () => _changeContentsIndex('next'),
                    ),
                    _buildDivider(),
                    _buildBottomAppBarButton(
                      width: (constraints.maxWidth - 4) / 5,
                      height: constraints.maxHeight,
                      icon: Icons.keyboard_double_arrow_right_rounded,
                      tooltip: S.of(context).epubActionBtns('nextChapter'),
                      onTap: () => _changeChapterIndex(1),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox(height: 0);
    });
  }

  // BottomAppBar 버튼
  Widget _buildBottomAppBarButton({
    required double width,
    required double height,
    required IconData icon,
    required String tooltip,
    required Function onTap,
  }) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        width: width,
        height: height,
        child: Icon(icon, size: 30),
      ),
    );
  }

  // Divider 추가
  Widget _buildDivider() {
    return VerticalDivider(
      color: Colors.grey.shade400,
      thickness: 1,
      width: 1,
    );
  }
}
