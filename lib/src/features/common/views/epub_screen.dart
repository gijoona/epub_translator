import 'package:epub_translator/src/db/provider/database_provider.dart';
import 'package:epub_translator/src/features/common/widgets/epub_contents.dart';
import 'package:epub_translator/src/features/common/widgets/epub_pagenum.dart';
import 'package:epub_translator/src/features/epub_reader/models/epub_book_model.dart';
import 'package:epub_translator/src/features/epub_reader/models/epub_content_model.dart';
import 'package:epub_translator/src/features/translation/controllers/translation_controller.dart';
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
  late ScrollController _contentScrollController;

  EpubViewMode _viewMode = EpubViewMode.original;
  int _maxContentsIdx = 1;
  bool _isTranslating = false; // 번역 상태 플래그
  bool _isVisibleFAB = false; // 기능버튼 Visible 플래그
  late EpubBookModel? _book;
  EpubChapter? _chapter;
  double _childMaxScrollExtent = 0.0;

  // 페이지별로 ScrollController를 관리하는 Map
  final Map<int, ScrollController> _scrollControllers = {};

  @override
  void initState() {
    super.initState();
    loadEpubBook();

    _contentScrollController = _getScrollController(0);
  }

  void _onScrollUpdate({
    required ScrollController controller,
    double offset = 0.0,
  }) {
    var scrollProgress = 0.0;
    if (controller.hasClients && controller.position.maxScrollExtent > 0) {
      // 스크롤이 진행될 때마다 현재 스크롤 위치와 전체 높이를 계산하여 진행 상태를 업데이트
      final currentScrollOffset = controller.offset;
      _childMaxScrollExtent = controller.position.maxScrollExtent;

      scrollProgress =
          (currentScrollOffset / _childMaxScrollExtent).clamp(0.0, 1.0);
    }

    ref.read(scrollProgressProvider.notifier).state = scrollProgress;
  }

  Future<void> loadEpubBook() async {
    _book = ref.read(epubBookProvider.notifier).state;
    if (_book != null) {
      _maxContentsIdx = _book!.contents.length;
    }
  }

  ScrollController _getScrollController(int pageIndex) {
    // 페이지 인덱스에 해당하는 ScrollController를 반환하거나 생성
    if (!_scrollControllers.containsKey(pageIndex)) {
      _scrollControllers[pageIndex] = ScrollController();
    }
    return _scrollControllers[pageIndex]!;
  }

  void _changeContentsIndex(String cmd) {
    switch (cmd) {
      case 'prev':
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.linear,
        );
        break;
      case 'next':
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.linear,
        );
        break;
    }
  }

  void _changeChapterIndex(int addIndex) {
    var epubInfo = ref.read(epubContentProvider.notifier).state!;
    var currChapterIdx = 0;
    if (epubInfo.chapter != null) {
      currChapterIdx = epubInfo.chapters.indexOf(epubInfo.chapter!);
    }

    int chgChapterIdx =
        (currChapterIdx + addIndex).clamp(0, epubInfo.chapters.length - 1);
    var chgChapter = epubInfo.chapters.elementAt(chgChapterIdx);
    var chgContentIdx =
        _book!.contents.keys.toList().indexOf(chgChapter.ContentFileName!);

    _pageController.jumpToPage(chgContentIdx);
  }

  void _onContentsChange(int pageNum) {
    var epubInfo = ref.read(epubContentProvider.notifier).state!;
    var contentFileName = _book!.contents.keys.elementAt(pageNum);
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

  void _translateBook() async {
    final config = ref.read(configProvider);
    if (config.hasValue) {
      var apiKey = config.value!['OPENAI_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('번역기능을 이용하기 위해서는 설정에서 OPENAI정보를 입력하셔야 합니다.'),
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
    _onScrollUpdate(controller: _contentScrollController);
    _onContentsChange(page);
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
    var bookInfo = ref.read(epubBookProvider.notifier).state;
    var caption =
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

                  return EpubContents(
                    caption: caption,
                    viewMode: _viewMode,
                    contentsNum: contentsNum,
                    scrollController: scrollController,
                    onScrollUpdate: _onScrollUpdate,
                  );
                },
              ),
              // 현재 컨텐츠정보를 보여줌. (현재 Contents 번호 / 전체 Contents 번호)
              Consumer(builder: (context, ref, child) {
                var isVisible = ref.watch(visibleFABProvider);
                return !isVisible
                    ? Container()
                    : Positioned(
                        top: 70,
                        right: 10,
                        child: EpubPageNum(maxContentsIdx: _maxContentsIdx),
                      );
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
      return !isVislble
          ? const SizedBox(height: 0)
          : SpeedDial(
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
            );
    });
  }

  // BottomAppBar로 챕터 및 콘텐츠 이동 처리
  Widget _buildBottomAppBar() {
    return Consumer(builder: (context, ref, child) {
      var isVislble = ref.watch(visibleFABProvider);
      return !isVislble
          ? const SizedBox(height: 0)
          : BottomAppBar(
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
                      tooltip: '화면분할',
                      onTap: _changeView,
                    ),
                    _buildDivider(),
                    _buildBottomAppBarButton(
                      width: (constraints.maxWidth - 4) / 5,
                      height: constraints.maxHeight,
                      icon: Icons.keyboard_double_arrow_left_rounded,
                      tooltip: '이전 챕터',
                      onTap: () => _changeChapterIndex(-1),
                    ),
                    _buildDivider(),
                    _buildBottomAppBarButton(
                      width: (constraints.maxWidth - 4) / 5,
                      height: constraints.maxHeight,
                      icon: Icons.keyboard_arrow_left_rounded,
                      tooltip: '이전 컨텐츠',
                      onTap: () => _changeContentsIndex('prev'),
                    ),
                    _buildDivider(),
                    _buildBottomAppBarButton(
                      width: (constraints.maxWidth - 4) / 5,
                      height: constraints.maxHeight,
                      icon: Icons.keyboard_arrow_right_rounded,
                      tooltip: '다음 컨텐츠',
                      onTap: () => _changeContentsIndex('next'),
                    ),
                    _buildDivider(),
                    _buildBottomAppBarButton(
                      width: (constraints.maxWidth - 4) / 5,
                      height: constraints.maxHeight,
                      icon: Icons.keyboard_double_arrow_right_rounded,
                      tooltip: '다음 챕터',
                      onTap: () => _changeChapterIndex(1),
                    ),
                  ],
                ),
              ),
            );
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
