import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/filter_models.dart';
part '../widget/multiple_section_filter_layout.dart';
part '../widget/multiple_section_filter_transport.dart';
part '../widget/multiple_section_filter_filters.dart';
part '../widget/multiple_section_filter_freight.dart';

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
                SliverToBoxAdapter(child: SizedBox(height: 16.h)),
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
