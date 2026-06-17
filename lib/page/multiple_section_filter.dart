import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/filter_models.dart';

class MultipleSectionFilterPage extends StatefulWidget {
  const MultipleSectionFilterPage({super.key});

  @override
  State<MultipleSectionFilterPage> createState() =>
      _MultipleSectionFilterPageState();
}

class _MultipleSectionFilterPageState extends State<MultipleSectionFilterPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _stackKey = GlobalKey();
  final GlobalKey _tabKey = GlobalKey();

  int _currentTab = 0;
  int _selectedSortIndex = -1;
  int _selectedOwnerIndex = -1;
  bool _showStickyTransportCard = false;
  bool _showFilterOverlay = false;
  bool _onlyDistanceFilter = false;
  String _routeStart = '';
  String _routeEnd = '';
  List<String> _selectedAdvancedOptions = <String>[];
  num _selectedDistance = 0;

  final List<String> _tabs = const <String>['我的货源', '推荐货源'];
  final List<String> _sortOptions = const <String>['离我最近', '运费最高', '装货最早'];
  final List<String> _ownerOptions = const <String>[
    '全部货主',
    '直营货主',
    '合作货主',
    '优选货主',
  ];
  final List<String> _myQuickTags = const <String>['高运价', '返程单', '限时单', '常跑线路'];
  final List<String> _recommendQuickTags = const <String>[
    '高运价',
    '返程单',
    '秒装货',
    FilterTokens.distanceQuickTag,
  ];
  final List<String> _advancedFilterOptions = const <String>[
    '高运价',
    '返程单',
    '秒装货',
    '常跑线路',
    '优质货主',
    '整车',
  ];
  final List<num> _distanceOptions = const <num>[50, 100, 200, 500];

  late final List<_DemoFreightCardData> _allItems;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _allItems = List<_DemoFreightCardData>.generate(18, (int index) {
      final bool myTab = index.isEven;
      return _DemoFreightCardData(
        id: index,
        title: myTab ? '我的熟线货源 ${index + 1}' : '推荐货源 ${index + 1}',
        price: '${980 + index * 35}',
        route: index.isEven ? '上海 -> 苏州' : '杭州 -> 宁波',
        owner: _ownerOptions[index % _ownerOptions.length],
        tab: myTab ? 0 : 1,
        tags: <String>[
          if (index % 2 == 0) '高运价',
          if (index % 3 == 0) '返程单',
          if (index % 4 == 0) '秒装货',
          if (index % 5 == 0) '常跑线路',
          if (index % 6 == 0) '优质货主',
        ],
        distanceKm: _distanceOptions[index % _distanceOptions.length],
      );
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  _StickyLayoutMetrics _layoutMetrics([BuildContext? context]) {
    final MediaQueryData? mediaQuery = context == null
        ? null
        : MediaQuery.maybeOf(context);
    return _StickyLayoutMetrics(
      hasPinnedTransportCard: _showStickyTransportCard,
      viewportHeight: mediaQuery == null
          ? 0
          : mediaQuery.size.height - mediaQuery.padding.top,
    );
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final bool shouldShowStickyCard =
        _scrollController.offset > _PageTokens.transportStickySwitchOffset;
    if (shouldShowStickyCard == _showStickyTransportCard) {
      return;
    }
    setState(() {
      _showStickyTransportCard = shouldShowStickyCard;
    });
  }

  Future<void> _scrollToPinnedTab() async {
    final BuildContext? targetContext = _tabKey.currentContext;
    final BuildContext? stackContext = _stackKey.currentContext;
    final RenderBox? tabBox = targetContext?.findRenderObject() as RenderBox?;
    final RenderBox? stackBox = stackContext?.findRenderObject() as RenderBox?;
    if (tabBox == null || stackBox == null || !_scrollController.hasClients) {
      return;
    }
    final _StickyLayoutMetrics layoutMetrics = _layoutMetrics();
    final double tabTop = tabBox
        .localToGlobal(Offset.zero, ancestor: stackBox)
        .dy;
    final double pinnedTabTop = layoutMetrics.pinnedTopHeight;
    if (tabTop <= pinnedTabTop + _PageTokens.pinnedScrollTolerance) {
      return;
    }
    final ScrollPosition position = _scrollController.position;
    final double targetOffset = position.pixels + tabTop - pinnedTabTop;
    if ((targetOffset - position.pixels).abs() <=
        _PageTokens.pinnedScrollTolerance) {
      return;
    }
    await _scrollController.animateTo(
      targetOffset.clamp(0, position.maxScrollExtent),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _handleFilterTap({bool onlyDistance = false}) async {
    if (_showFilterOverlay) {
      _closeFilterView();
      return;
    }
    _onlyDistanceFilter = onlyDistance;
    await _scrollToPinnedTab();
    if (!mounted) {
      return;
    }
    setState(() {
      _showFilterOverlay = true;
    });
  }

  void _closeFilterView() {
    if (!_showFilterOverlay) {
      return;
    }
    setState(() {
      _showFilterOverlay = false;
      _onlyDistanceFilter = false;
    });
  }

  double _filterOverlayTop() {
    final _StickyLayoutMetrics layoutMetrics = _layoutMetrics();
    final BuildContext? stackContext = _stackKey.currentContext;
    final BuildContext? tabContext = _tabKey.currentContext;
    final RenderBox? stackBox = stackContext?.findRenderObject() as RenderBox?;
    final RenderBox? tabBox = tabContext?.findRenderObject() as RenderBox?;
    return layoutMetrics.resolveFilterOverlayTop(
      stackBox: stackBox,
      tabBox: tabBox,
    );
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentTab = index;
      _closeFilterView();
    });
  }

  void _selectSortIndex(int index) {
    setState(() {
      _selectedSortIndex = index;
    });
  }

  void _selectOwnerIndex(int index) {
    setState(() {
      _selectedOwnerIndex = index;
    });
  }

  void _toggleQuickTag(String tag) {
    if (tag == FilterTokens.distanceQuickTag) {
      _handleFilterTap(onlyDistance: true);
      return;
    }
    setState(() {
      final List<String> options = List<String>.from(_selectedAdvancedOptions);
      if (options.contains(tag)) {
        options.remove(tag);
      } else {
        options.add(tag);
      }
      _selectedAdvancedOptions = options;
    });
  }

  void _updateRouteAddress({String? from, String? to}) {
    setState(() {
      if (from != null) {
        _routeStart = from.trim();
      }
      if (to != null) {
        _routeEnd = to.trim();
      }
    });
  }

  void _resetFilters() {
    setState(() {
      if (_onlyDistanceFilter) {
        _selectedDistance = 0;
      } else {
        _selectedAdvancedOptions = <String>[];
        _selectedDistance = 0;
      }
    });
  }

  void _applyFilters(List<String> selectedOptions, num distance) {
    setState(() {
      _selectedAdvancedOptions = selectedOptions;
      _selectedDistance = distance;
      _showFilterOverlay = false;
      _onlyDistanceFilter = false;
    });
  }

  List<_DemoFreightCardData> get _filteredItems {
    Iterable<_DemoFreightCardData> items = _allItems.where(
      (_DemoFreightCardData item) => item.tab == _currentTab,
    );

    final String selectedOwner = _selectedOwnerLabel;
    if (_currentTab == 0 &&
        _selectedOwnerIndex > 0 &&
        selectedOwner != FilterTokens.allOwner) {
      items = items.where(
        (_DemoFreightCardData item) => item.owner == selectedOwner,
      );
    }

    if (_selectedAdvancedOptions.isNotEmpty) {
      items = items.where(
        (_DemoFreightCardData item) => _selectedAdvancedOptions.every(
          (String tag) => item.tags.contains(tag),
        ),
      );
    }

    if (_selectedDistance > 0) {
      items = items.where(
        (_DemoFreightCardData item) => item.distanceKm <= _selectedDistance,
      );
    }

    if (_routeStart.trim().isNotEmpty) {
      items = items.where(
        (_DemoFreightCardData item) => item.route.contains(_routeStart.trim()),
      );
    }

    if (_routeEnd.trim().isNotEmpty) {
      items = items.where(
        (_DemoFreightCardData item) => item.route.contains(_routeEnd.trim()),
      );
    }

    final List<_DemoFreightCardData> result = items.toList();
    if (_selectedSortIndex == 0) {
      result.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    } else if (_selectedSortIndex == 1) {
      result.sort((a, b) => int.parse(b.price).compareTo(int.parse(a.price)));
    } else if (_selectedSortIndex == 2) {
      result.sort((a, b) => a.id.compareTo(b.id));
    }
    return result;
  }

  String get _selectedSortLabel {
    if (_selectedSortIndex < 0 || _selectedSortIndex >= _sortOptions.length) {
      return FilterTokens.sortPlaceholder;
    }
    return _sortOptions[_selectedSortIndex];
  }

  String get _selectedOwnerLabel {
    if (_selectedOwnerIndex < 0 ||
        _selectedOwnerIndex >= _ownerOptions.length) {
      return FilterTokens.allOwner;
    }
    return _ownerOptions[_selectedOwnerIndex];
  }

  FilterDisplayState get _filterDisplayState {
    final FilterSelectionState selectionState = FilterSelectionState(
      advancedOptions: _selectedAdvancedOptions,
      distance: _selectedDistance,
    );
    final List<String> quickTags = _currentTab == 0
        ? _myQuickTags
        : _recommendQuickTags;

    return FilterDisplayState(
      currentTab: _currentTab,
      selectedSortIndex: _selectedSortIndex,
      selectedSortLabel: _selectedSortLabel,
      selectedOwnerIndex: _selectedOwnerIndex,
      selectedOwnerLabel: _selectedOwnerLabel,
      ownerOptions: _ownerOptions,
      selectedFilterCount: selectionState.selectedOptions.length,
      hasActiveFilters: selectionState.selectedOptions.isNotEmpty,
      routeStartLabel: _routeStart.isEmpty
          ? FilterTokens.loadingPlaceholder
          : _routeStart,
      routeEndLabel: _routeEnd.isEmpty
          ? FilterTokens.unloadingPlaceholder
          : _routeEnd,
      quickTags: quickTags.map((String tag) {
        final bool isDistanceTag = tag == FilterTokens.distanceQuickTag;
        return QuickTagDisplayState(
          tag: tag,
          label: isDistanceTag
              ? selectionState.distanceLabel(fallbackLabel: tag)
              : tag,
          selected: isDistanceTag
              ? selectionState.hasDistanceFilter
              : _selectedAdvancedOptions.contains(tag),
          showArrow: isDistanceTag,
        );
      }).toList(),
      selectedOptions: selectionState.selectedOptions,
      selectedDistanceLabel: selectionState.distanceLabel(),
      loadingPlaceText: _routeStart,
      unloadingPlaceText: _routeEnd,
    );
  }

  Widget _buildEmptyStateBody(BuildContext context) {
    final _StickyLayoutMetrics layoutMetrics = _layoutMetrics(context);
    return SizedBox(
      height: layoutMetrics.emptyStateHeight,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.inbox_rounded,
              size: 72.sp,
              color: const Color(0xFFB4BAC8),
            ),
            SizedBox(height: 20.h),
            Text(
              '没有找到相关货源',
              style: TextStyle(
                fontSize: 30.sp,
                color: const Color(0xFF3A4150),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              '请修改筛选条件后再试',
              style: TextStyle(fontSize: 24.sp, color: const Color(0xFF8B91A1)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF1F3F7),
      child: SafeArea(
        bottom: false,
        child: Stack(
          key: _stackKey,
          children: <Widget>[
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: SizedBox(height: _PageTokens.sectionGapHeight),
                ),
                _TransportStickySliver(showSticky: _showStickyTransportCard),
                const SliverToBoxAdapter(child: _HeroSection()),
                SliverToBoxAdapter(
                  child: SizedBox(height: _PageTokens.sectionGapHeight),
                ),
                _TabStickySliver(
                  tabs: _tabs,
                  currentTab: _currentTab,
                  onChanged: _onTabChanged,
                  tabKey: _tabKey,
                ),
                _FilterStickySliver(
                  state: _filterDisplayState,
                  onSortTap: _showSortMenu,
                  onOwnerTap: _showOwnerMenu,
                  onFilterTap: _handleFilterTap,
                  onDistanceFilterTap: () =>
                      _handleFilterTap(onlyDistance: true),
                  onQuickTagTap: _toggleQuickTag,
                  onRouteSwapTap: _swapRoute,
                  onRouteInputFocus: _scrollToPinnedTab,
                  onRouteSubmitted: _updateRouteAddress,
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: _PageTokens.sectionGapHeight),
                ),
                if (_filteredItems.isEmpty)
                  SliverToBoxAdapter(child: _buildEmptyStateBody(context))
                else
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _PageTokens.listHorizontalPadding,
                    ),
                    sliver: SliverList.builder(
                      itemCount: _filteredItems.length,
                      itemBuilder: (BuildContext context, int index) {
                        final _DemoFreightCardData item = _filteredItems[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == _filteredItems.length - 1
                                ? 0
                                : _PageTokens.sectionGapHeight,
                          ),
                          child: _FreightCard(item: item),
                        );
                      },
                    ),
                  ),
                SliverToBoxAdapter(child: SizedBox(height: 40.h)),
              ],
            ),
            _FilterOverlay(
              isVisible: _showFilterOverlay,
              top: _filterOverlayTop(),
              onDismiss: _closeFilterView,
              child: _FilterPanel(
                onlyDistance: _onlyDistanceFilter,
                advancedOptions: _advancedFilterOptions,
                distanceOptions: _distanceOptions,
                initialSelectedOptions: _selectedAdvancedOptions,
                initialDistance: _selectedDistance,
                onReset: _resetFilters,
                onConfirm: _applyFilters,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSortMenu() async {
    final int? result = await _showOptionSheet(
      options: _sortOptions,
      initialIndex: _selectedSortIndex,
    );
    if (result != null) {
      _selectSortIndex(result);
    }
  }

  Future<void> _showOwnerMenu() async {
    final int? result = await _showOptionSheet(
      options: _ownerOptions,
      initialIndex: _selectedOwnerIndex,
    );
    if (result != null) {
      _selectOwnerIndex(result);
    }
  }

  Future<int?> _showOptionSheet({
    required List<String> options,
    required int initialIndex,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 32.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List<Widget>.generate(options.length, (int index) {
                final bool selected = index == initialIndex;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    options[index],
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? const Color(0xFFF08A27)
                          : const Color(0xFF1E2433),
                    ),
                  ),
                  trailing: selected
                      ? Icon(
                          Icons.check_rounded,
                          size: 34.sp,
                          color: const Color(0xFFF08A27),
                        )
                      : null,
                  onTap: () => Navigator.of(context).pop(index),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  void _swapRoute() {
    setState(() {
      final String temp = _routeStart;
      _routeStart = _routeEnd;
      _routeEnd = temp;
    });
  }
}

class _PageTokens {
  const _PageTokens._();

  static const double pinnedScrollTolerance = 2;
  static const double filterOverlayOpacity = 0.4;
  static const Duration filterOverlayFadeDuration = Duration(milliseconds: 420);
  static const Duration filterOverlayPanelDuration = Duration(
    milliseconds: 320,
  );
  static const Duration transportCardSwitchDuration = Duration(
    milliseconds: 280,
  );

  static double get bigTransportCardHeight => 276.h;

  static double get smallTransportCardHeight => 108.h;

  static double get transportStickySwitchOffset => 170.h;

  static double get tabStickyHeight => 96.h;

  static double get filterStickyHeight => 176.h;

  static double get sectionGapHeight => 16.h;

  static double get listHorizontalPadding => 16.w;

  static double get emptyStateMinHeight => 220.h;
}

class _StickyLayoutMetrics {
  const _StickyLayoutMetrics({
    required this.hasPinnedTransportCard,
    required this.viewportHeight,
  });

  final bool hasPinnedTransportCard;
  final double viewportHeight;

  double get pinnedTransportHeight => hasPinnedTransportCard
      ? _PageTokens.smallTransportCardHeight
      : 0;

  double get pinnedTopHeight => pinnedTransportHeight;

  double get stickyOccupiedHeight =>
      pinnedTransportHeight +
      _PageTokens.tabStickyHeight +
      _PageTokens.filterStickyHeight;

  double get emptyStateHeight {
    final double remainingHeight =
        viewportHeight - stickyOccupiedHeight - _PageTokens.sectionGapHeight;
    return remainingHeight > _PageTokens.emptyStateMinHeight
        ? remainingHeight
        : _PageTokens.emptyStateMinHeight;
  }

  double resolveFilterOverlayTop({
    required RenderBox? stackBox,
    required RenderBox? tabBox,
  }) {
    if (stackBox == null || tabBox == null) {
      return pinnedTransportHeight + _PageTokens.tabStickyHeight;
    }
    final Offset topLeft = tabBox.localToGlobal(
      Offset.zero,
      ancestor: stackBox,
    );
    return topLeft.dy + tabBox.size.height;
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _StickyHeaderDelegate({
    required this.child,
    required this.height,
    this.showShadow = false,
  });

  final Widget child;
  final double height;
  final bool showShadow;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F7),
        boxShadow: showShadow && overlapsContent
            ? <BoxShadow>[
                BoxShadow(
                  color: const Color(0x14000000),
                  blurRadius: 18.r,
                  offset: Offset(0, 10.h),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return oldDelegate.height != height ||
        oldDelegate.child != child ||
        oldDelegate.showShadow != showShadow;
  }
}

class _TransportStickySliver extends StatelessWidget {
  const _TransportStickySliver({
    required this.showSticky,
  });

  final bool showSticky;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickyHeaderDelegate(
        height: showSticky
            ? _PageTokens.smallTransportCardHeight
            : _PageTokens.bigTransportCardHeight,
        child: _TransportStickyCard(showSticky: showSticky),
      ),
    );
  }
}

class _TransportStickyCard extends StatelessWidget {
  const _TransportStickyCard({
    required this.showSticky,
  });

  final bool showSticky;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: _PageTokens.transportCardSwitchDuration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      transitionBuilder: (Widget child, Animation<double> animation) {
        final Animation<double> fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        final Animation<double> scaleAnimation = Tween<double>(
          begin: 0.994,
          end: 1,
        ).animate(fadeAnimation);
        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            alignment: Alignment.topCenter,
            child: child,
          ),
        );
      },
      child: showSticky
          ? const _TransportStickyContainer(
              key: ValueKey<String>('small_transport_card'),
              alignment: Alignment.center,
              child: _SmallTransportCard(),
            )
          : const _TransportStickyContainer(
              key: ValueKey<String>('big_transport_card'),
              alignment: Alignment.topCenter,
              child: _BigTransportCard(),
            ),
    );
  }
}

class _TransportStickyContainer extends StatelessWidget {
  const _TransportStickyContainer({
    required super.key,
    required this.child,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Align(
        alignment: alignment,
        child: OverflowBox(
          alignment: alignment,
          minHeight: 0,
          maxHeight: double.infinity,
          child: ColoredBox(
            color: const Color(0xFFF1F3F7),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _BigTransportCard extends StatelessWidget {
  const _BigTransportCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        height: _PageTokens.bigTransportCardHeight,
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(22.w, 22.h, 22.w, 20.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28.r),
          gradient: const LinearGradient(
            colors: <Color>[Color(0xFF1F2433), Color(0xFF38445D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: const Color(0x26FFFFFF),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    '运输中',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '沪A·D5326',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 22.h),
            Text(
              '上海青浦园区 -> 苏州昆山仓',
              style: TextStyle(
                color: Colors.white,
                fontSize: 34.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              '司机已接单，预计 2 小时后到达装货地',
              style: TextStyle(
                color: const Color(0xCCFFFFFF),
                fontSize: 24.sp,
              ),
            ),
            const Spacer(),
            Row(
              children: <Widget>[
                Expanded(
                  child: _TransportMetric(
                    label: '运输单号',
                    value: 'WB20260617001',
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _TransportMetric(
                    label: '司机',
                    value: '王师傅',
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _TransportMetric(
                    label: '车辆',
                    value: '17.5米',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallTransportCard extends StatelessWidget {
  const _SmallTransportCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        height: _PageTokens.smallTransportCardHeight,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFF202534),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: const Color(0x1FFFFFFF),
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Icon(
                Icons.local_shipping_rounded,
                size: 34.sp,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '上海青浦园区 -> 苏州昆山仓',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '司机已接单，预计 2 小时后到达装货地',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xCCFFFFFF),
                      fontSize: 22.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Icon(
              Icons.chevron_right_rounded,
              size: 34.sp,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class _TransportMetric extends StatelessWidget {
  const _TransportMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              color: const Color(0xB3FFFFFF),
              fontSize: 20.sp,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: <Widget>[
          Container(
            height: 188.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28.r),
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFF2D5BFF), Color(0xFF5AA4FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.all(24.w),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '滚动与筛选框架',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '保留双吸顶、筛选浮层、列表滚动定位的核心交互',
                        style: TextStyle(
                          color: const Color(0xD9FFFFFF),
                          fontSize: 24.sp,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    color: const Color(0x1FFFFFFF),
                    borderRadius: BorderRadius.circular(26.r),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    size: 60.sp,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: const <Widget>[
              Expanded(
                child: _MetricCard(title: '双吸顶', value: 'Tab + Filter'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _MetricCard(title: '浮层定位', value: '跟随筛选条'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _MetricCard(title: '交互', value: '滚动后展开'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(color: const Color(0xFF7B8190), fontSize: 22.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              color: const Color(0xFF202534),
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabStickySliver extends StatelessWidget {
  const _TabStickySliver({
    required this.tabs,
    required this.currentTab,
    required this.onChanged,
    required this.tabKey,
  });

  final List<String> tabs;
  final int currentTab;
  final ValueChanged<int> onChanged;
  final GlobalKey tabKey;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickyHeaderDelegate(
        height: _PageTokens.tabStickyHeight,
        child: KeyedSubtree(
          key: tabKey,
          child: Container(
            color: const Color(0xFFF1F3F7),
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE4E8F0),
                borderRadius: BorderRadius.circular(22.r),
              ),
              padding: EdgeInsets.all(8.w),
              child: Row(
                children: List<Widget>.generate(tabs.length, (int index) {
                  final bool selected = index == currentTab;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onChanged(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        decoration: BoxDecoration(
                          color: selected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          tabs[index],
                          style: TextStyle(
                            color: selected
                                ? const Color(0xFF202534)
                                : const Color(0xFF7E8595),
                            fontSize: 28.sp,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterStickySliver extends StatelessWidget {
  const _FilterStickySliver({
    required this.state,
    required this.onSortTap,
    required this.onOwnerTap,
    required this.onFilterTap,
    required this.onDistanceFilterTap,
    required this.onQuickTagTap,
    required this.onRouteSwapTap,
    required this.onRouteInputFocus,
    required this.onRouteSubmitted,
  });

  final FilterDisplayState state;
  final VoidCallback onSortTap;
  final VoidCallback onOwnerTap;
  final Future<void> Function() onFilterTap;
  final Future<void> Function() onDistanceFilterTap;
  final ValueChanged<String> onQuickTagTap;
  final VoidCallback onRouteSwapTap;
  final VoidCallback onRouteInputFocus;
  final void Function({String? from, String? to}) onRouteSubmitted;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickyHeaderDelegate(
        height: _PageTokens.filterStickyHeight,
        showShadow: true,
        child: _FilterSection(
          key: ValueKey<String>('filter_section_${state.refreshKey}'),
          state: state,
          onSortTap: onSortTap,
          onOwnerTap: onOwnerTap,
          onFilterTap: onFilterTap,
          onDistanceFilterTap: onDistanceFilterTap,
          onQuickTagTap: onQuickTagTap,
          onRouteSwapTap: onRouteSwapTap,
          onRouteInputFocus: onRouteInputFocus,
          onRouteSubmitted: onRouteSubmitted,
        ),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.state,
    required this.onSortTap,
    required this.onOwnerTap,
    required this.onFilterTap,
    required this.onDistanceFilterTap,
    required this.onQuickTagTap,
    required this.onRouteSwapTap,
    required this.onRouteInputFocus,
    required this.onRouteSubmitted,
    super.key,
  });

  final FilterDisplayState state;
  final VoidCallback onSortTap;
  final VoidCallback onOwnerTap;
  final Future<void> Function() onFilterTap;
  final Future<void> Function() onDistanceFilterTap;
  final ValueChanged<String> onQuickTagTap;
  final VoidCallback onRouteSwapTap;
  final VoidCallback onRouteInputFocus;
  final void Function({String? from, String? to}) onRouteSubmitted;

  @override
  Widget build(BuildContext context) {
    return state.isMyTab
        ? _buildMySection(context)
        : _buildRecommendedSection(context);
  }

  Widget _buildMySection(BuildContext context) {
    return _buildSectionContainer(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w).copyWith(top: 28.h),
            child: Row(
              children: <Widget>[
                _PlainMenuTrigger(
                  label: state.selectedSortLabel,
                  selected: state.selectedSortIndex != -1,
                  onTap: onSortTap,
                ),
                SizedBox(width: 36.w),
                Expanded(
                  child: _PlainMenuTrigger(
                    label: state.selectedOwnerLabel,
                    selected: state.selectedOwnerIndex != -1,
                    onTap: onOwnerTap,
                  ),
                ),
                SizedBox(width: 18.w),
                _FilterTrigger(
                  label: _filterTriggerLabel(state.selectedFilterCount),
                  onTap: onFilterTap,
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 28.w),
            child: _QuickTagList(
              tags: state.quickTags,
              spacing: 16.w,
              onTap: onQuickTagTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedSection(BuildContext context) {
    return _buildSectionContainer(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w).copyWith(top: 21.h),
            child: Row(
              children: <Widget>[
                _PlainMenuTrigger(
                  label: state.selectedSortLabel,
                  selected: state.selectedSortIndex != -1,
                  onTap: onSortTap,
                ),
                SizedBox(width: 24.w),
                Expanded(
                  child: _RouteSelector(
                    startLabel: state.routeStartLabel,
                    endLabel: state.routeEndLabel,
                    onSwapTap: onRouteSwapTap,
                    onInputFocus: onRouteInputFocus,
                    onStartSubmitted: (String value) =>
                        onRouteSubmitted(from: value),
                    onEndSubmitted: (String value) =>
                        onRouteSubmitted(to: value),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 28.w),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _QuickTagList(
                    tags: state.quickTags,
                    spacing: 14.w,
                    onTap: (String tag) {
                      if (tag == FilterTokens.distanceQuickTag) {
                        onDistanceFilterTap();
                        return;
                      }
                      onQuickTagTap(tag);
                    },
                  ),
                ),
                SizedBox(width: 20.w),
                _FilterTrigger(
                  label: _filterTriggerLabel(state.selectedFilterCount),
                  onTap: onFilterTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(26.r),
          topRight: Radius.circular(26.r),
        ),
      ),
      child: child,
    );
  }

  String _filterTriggerLabel(int filterCount) {
    return filterCount > 0 ? '筛选($filterCount)' : '筛选';
  }
}

class _QuickTagList extends StatelessWidget {
  const _QuickTagList({
    required this.tags,
    required this.spacing,
    required this.onTap,
  });

  final List<QuickTagDisplayState> tags;
  final double spacing;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List<Widget>.generate(tags.length, (int index) {
          final QuickTagDisplayState tag = tags[index];
          return Padding(
            padding: EdgeInsets.only(
              right: index == tags.length - 1 ? 0 : spacing,
            ),
            child: _QuickFilterChip(
              label: tag.label,
              selected: tag.selected,
              showArrow: tag.showArrow,
              onTap: () => onTap(tag.tag),
            ),
          );
        }),
      ),
    );
  }
}

class _PlainMenuTrigger extends StatelessWidget {
  const _PlainMenuTrigger({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color contentColor = selected
        ? const Color(0xFFC78B4F)
        : const Color(0xFF42485B);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              color: contentColor,
              fontSize: 26.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(width: 6.w),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 34.sp,
            color: contentColor,
          ),
        ],
      ),
    );
  }
}

class _FilterTrigger extends StatelessWidget {
  const _FilterTrigger({required this.label, required this.onTap});

  final String label;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.filter_alt_outlined,
            size: 28.sp,
            color: const Color(0xFF3C4353),
          ),
          SizedBox(width: 2.w),
          Text(
            label,
            style: TextStyle(color: const Color(0xFF42485B), fontSize: 26.sp),
          ),
        ],
      ),
    );
  }
}

class _QuickFilterChip extends StatelessWidget {
  const _QuickFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.showArrow = false,
  });

  final String label;
  final bool selected;
  final bool showArrow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: selected ? Colors.white : const Color(0xFFF1F3F7),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: selected ? const Color(0xFFC78B4F) : Colors.transparent,
            width: 1.w,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? const Color(0xFFC78B4F)
                    : const Color(0xFF686F81),
                fontSize: 26.sp,
              ),
            ),
            if (showArrow) ...<Widget>[
              SizedBox(width: 6.w),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 34.sp,
                color: selected
                    ? const Color(0xFFD39A43)
                    : const Color(0xFF707786),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RouteSelector extends StatefulWidget {
  const _RouteSelector({
    required this.startLabel,
    required this.endLabel,
    required this.onSwapTap,
    this.onInputFocus,
    required this.onStartSubmitted,
    required this.onEndSubmitted,
  });

  final String startLabel;
  final String endLabel;
  final VoidCallback onSwapTap;
  final VoidCallback? onInputFocus;
  final ValueChanged<String> onStartSubmitted;
  final ValueChanged<String> onEndSubmitted;

  @override
  State<_RouteSelector> createState() => _RouteSelectorState();
}

class _RouteSelectorState extends State<_RouteSelector> {
  late final TextEditingController _startController;
  late final TextEditingController _endController;
  late final FocusNode _startFocusNode;
  late final FocusNode _endFocusNode;
  late String _lastCommittedStartValue;
  late String _lastCommittedEndValue;
  bool _hadAnyFocus = false;

  @override
  void initState() {
    super.initState();
    _lastCommittedStartValue = _inputValue(
      widget.startLabel,
      FilterTokens.loadingPlaceholder,
    );
    _lastCommittedEndValue = _inputValue(
      widget.endLabel,
      FilterTokens.unloadingPlaceholder,
    );
    _startController = TextEditingController(text: _lastCommittedStartValue);
    _endController = TextEditingController(text: _lastCommittedEndValue);
    _startFocusNode = FocusNode()..addListener(_handleInputFocusChanged);
    _endFocusNode = FocusNode()..addListener(_handleInputFocusChanged);
  }

  @override
  void didUpdateWidget(covariant _RouteSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startLabel != widget.startLabel &&
        !_startFocusNode.hasFocus) {
      _lastCommittedStartValue = _inputValue(
        widget.startLabel,
        FilterTokens.loadingPlaceholder,
      );
      _startController.text = _lastCommittedStartValue;
    }
    if (oldWidget.endLabel != widget.endLabel && !_endFocusNode.hasFocus) {
      _lastCommittedEndValue = _inputValue(
        widget.endLabel,
        FilterTokens.unloadingPlaceholder,
      );
      _endController.text = _lastCommittedEndValue;
    }
  }

  @override
  void dispose() {
    _startFocusNode.removeListener(_handleInputFocusChanged);
    _endFocusNode.removeListener(_handleInputFocusChanged);
    _startController.dispose();
    _endController.dispose();
    _startFocusNode.dispose();
    _endFocusNode.dispose();
    super.dispose();
  }

  String _inputValue(String value, String placeholder) {
    return value == placeholder ? '' : value;
  }

  void _submitStartIfChanged() {
    final String nextValue = _startController.text.trim();
    if (_lastCommittedStartValue == nextValue) {
      return;
    }
    _lastCommittedStartValue = nextValue;
    widget.onStartSubmitted(nextValue);
  }

  void _submitEndIfChanged() {
    final String nextValue = _endController.text.trim();
    if (_lastCommittedEndValue == nextValue) {
      return;
    }
    _lastCommittedEndValue = nextValue;
    widget.onEndSubmitted(nextValue);
  }

  void _handleInputFocusChanged() {
    final bool hasAnyFocus = _startFocusNode.hasFocus || _endFocusNode.hasFocus;
    if (hasAnyFocus && !_hadAnyFocus) {
      widget.onInputFocus?.call();
    } else if (!hasAnyFocus && _hadAnyFocus) {
      _submitStartIfChanged();
      _submitEndIfChanged();
    }
    _hadAnyFocus = hasAnyFocus;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58.h,
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFBABBBC), width: 1.w),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _RouteInputField(
              controller: _startController,
              focusNode: _startFocusNode,
              hintText: FilterTokens.loadingPlaceholder,
              onSubmitted: (_) => _submitStartIfChanged(),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onSwapTap,
            child: Icon(
              Icons.compare_arrows_rounded,
              size: 28.sp,
              color: const Color(0xFFD5A154),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _RouteInputField(
              controller: _endController,
              focusNode: _endFocusNode,
              hintText: FilterTokens.unloadingPlaceholder,
              onSubmitted: (_) => _submitEndIfChanged(),
            ),
          ),
          SizedBox(width: 12.w),
          Icon(
            Icons.location_on_rounded,
            size: 28.sp,
            color: const Color(0xFFD5A154),
          ),
        ],
      ),
    );
  }
}

class _RouteInputField extends StatelessWidget {
  const _RouteInputField({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLines: 1,
      textAlign: TextAlign.center,
      textInputAction: TextInputAction.done,
      style: TextStyle(color: const Color(0xFF3A4150), fontSize: 24.sp),
      decoration: InputDecoration(
        isDense: true,
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        hintText: hintText,
        hintStyle: TextStyle(color: const Color(0xFF9DA1AF), fontSize: 24.sp),
      ),
      onSubmitted: onSubmitted,
      onTapOutside: (_) => focusNode.unfocus(),
    );
  }
}

class _FilterOverlay extends StatelessWidget {
  const _FilterOverlay({
    required this.isVisible,
    required this.top,
    required this.onDismiss,
    required this.child,
  });

  final bool isVisible;
  final double top;
  final VoidCallback onDismiss;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      top: top,
      child: IgnorePointer(
        ignoring: !isVisible,
        child: Stack(
          children: <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onDismiss,
              child: AnimatedOpacity(
                duration: _PageTokens.filterOverlayFadeDuration,
                curve: Curves.easeOutCubic,
                opacity: isVisible ? 1 : 0,
                child: Container(
                  color: Colors.black.withValues(
                    alpha: _PageTokens.filterOverlayOpacity,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: isVisible ? 1 : 0),
                duration: _PageTokens.filterOverlayPanelDuration,
                curve: Curves.easeOutCubic,
                builder: (BuildContext context, double value, Widget? panel) {
                  final double opacity = (value / 0.72).clamp(0, 1);
                  final double slideProgress = ((value - 0.18) / 0.82).clamp(
                    0,
                    1,
                  );
                  final double translateY = slideProgress < 0.82
                      ? -0.02 * (1 - (slideProgress / 0.82)) - 0.0015
                      : -0.0015 * (1 - ((slideProgress - 0.82) / 0.18));
                  return Opacity(
                    opacity: opacity,
                    child: FractionalTranslation(
                      translation: Offset(0, translateY),
                      child: panel,
                    ),
                  );
                },
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {},
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterPanel extends StatefulWidget {
  const _FilterPanel({
    required this.onlyDistance,
    required this.advancedOptions,
    required this.distanceOptions,
    required this.initialSelectedOptions,
    required this.initialDistance,
    required this.onReset,
    required this.onConfirm,
  });

  final bool onlyDistance;
  final List<String> advancedOptions;
  final List<num> distanceOptions;
  final List<String> initialSelectedOptions;
  final num initialDistance;
  final VoidCallback onReset;
  final void Function(List<String> selectedOptions, num distance) onConfirm;

  @override
  State<_FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<_FilterPanel> {
  late List<String> _selectedOptions;
  late num _selectedDistance;

  @override
  void initState() {
    super.initState();
    _selectedOptions = List<String>.from(widget.initialSelectedOptions);
    _selectedDistance = widget.initialDistance;
  }

  @override
  void didUpdateWidget(covariant _FilterPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSelectedOptions != widget.initialSelectedOptions ||
        oldWidget.initialDistance != widget.initialDistance ||
        oldWidget.onlyDistance != widget.onlyDistance) {
      _selectedOptions = List<String>.from(widget.initialSelectedOptions);
      _selectedDistance = widget.initialDistance;
    }
  }

  void _toggleOption(String option) {
    setState(() {
      if (_selectedOptions.contains(option)) {
        _selectedOptions.remove(option);
      } else {
        _selectedOptions.add(option);
      }
    });
  }

  void _selectDistance(num distance) {
    setState(() {
      _selectedDistance = _selectedDistance == distance ? 0 : distance;
    });
  }

  void _handleReset() {
    setState(() {
      if (widget.onlyDistance) {
        _selectedDistance = 0;
      } else {
        _selectedOptions = <String>[];
        _selectedDistance = 0;
      }
    });
    widget.onReset();
  }

  void _handleConfirm() {
    widget.onConfirm(List<String>.from(_selectedOptions), _selectedDistance);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxHeight: 760.h),
        padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 28.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.onlyDistance ? '装货地距离' : '高级筛选',
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF202534),
              ),
            ),
            SizedBox(height: 24.h),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (!widget.onlyDistance) ...<Widget>[
                      _PanelSectionTitle(title: '标签'),
                      Wrap(
                        spacing: 12.w,
                        runSpacing: 12.h,
                        children: widget.advancedOptions.map((String option) {
                          final bool selected = _selectedOptions.contains(
                            option,
                          );
                          return _PanelTag(
                            label: option,
                            selected: selected,
                            onTap: () => _toggleOption(option),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 24.h),
                    ],
                    _PanelSectionTitle(title: '装货地距离'),
                    Wrap(
                      spacing: 12.w,
                      runSpacing: 12.h,
                      children: widget.distanceOptions.map((num distance) {
                        final bool selected = _selectedDistance == distance;
                        return _PanelTag(
                          label: '${distance}km',
                          selected: selected,
                          onTap: () => _selectDistance(distance),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 28.h),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: _handleReset,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD6D9E0)),
                      minimumSize: Size.fromHeight(88.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                    ),
                    child: Text(
                      '重置',
                      style: TextStyle(
                        fontSize: 28.sp,
                        color: const Color(0xFF4E5565),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF202534),
                      minimumSize: Size.fromHeight(88.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                    ),
                    child: Text(
                      '确认',
                      style: TextStyle(fontSize: 28.sp, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PanelSectionTitle extends StatelessWidget {
  const _PanelSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 26.sp,
          color: const Color(0xFF596174),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PanelTag extends StatelessWidget {
  const _PanelTag({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF2E2) : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected ? const Color(0xFFF08A27) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 24.sp,
            color: selected ? const Color(0xFFF08A27) : const Color(0xFF51586A),
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _FreightCard extends StatelessWidget {
  const _FreightCard({required this.item});

  final _DemoFreightCardData item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E2433),
                  ),
                ),
              ),
              Text(
                '¥${item.price}',
                style: TextStyle(
                  fontSize: 34.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFF08A27),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            item.route,
            style: TextStyle(fontSize: 26.sp, color: const Color(0xFF3B4252)),
          ),
          SizedBox(height: 10.h),
          Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F7),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  item.owner,
                  style: TextStyle(
                    fontSize: 22.sp,
                    color: const Color(0xFF6D7484),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                '距离装货地 ${item.distanceKm}km',
                style: TextStyle(
                  fontSize: 22.sp,
                  color: const Color(0xFF8A90A0),
                ),
              ),
            ],
          ),
          if (item.tags.isNotEmpty) ...<Widget>[
            SizedBox(height: 16.h),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: item.tags.map((String tag) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 22.sp,
                      color: const Color(0xFFC97816),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _DemoFreightCardData {
  const _DemoFreightCardData({
    required this.id,
    required this.title,
    required this.price,
    required this.route,
    required this.owner,
    required this.tab,
    required this.tags,
    required this.distanceKm,
  });

  final int id;
  final String title;
  final String price;
  final String route;
  final String owner;
  final int tab;
  final List<String> tags;
  final num distanceKm;
}
