class HomeV4FilterTokens {
  const HomeV4FilterTokens._();

  static const String distanceQuickTag = '装货地距离';
  static const String nearestSort = '离我最近';
  static const String sortPlaceholder = '排序';
  static const String allOwner = '全部货主';
  static const String loadingPlaceholder = '装货地';
  static const String unloadingPlaceholder = '卸货地';
  static const String distanceUnit = 'km';

  static bool isDistanceOption(String value) {
    return value.trim().endsWith(distanceUnit);
  }

  static String formatDistanceOption(num distance) {
    return '$distance$distanceUnit';
  }

  static num parseDistanceOption(String value) {
    final String normalized = value.trim();
    if (!isDistanceOption(normalized)) {
      return 0;
    }
    return num.tryParse(
          normalized.substring(0, normalized.length - distanceUnit.length),
        ) ??
        0;
  }
}

class HomeFilterData {
  HomeFilterData({
    this.sortType = "",
    List<String>? skuId,
    this.distance = 0,
  }) : skuId = List<String>.from(skuId ?? <String>[]);

  String? sortType;
  List<String> skuId;
  num? distance;

  void reset() {
    sortType = "";
    skuId = <String>[];
    distance = 0;
  }

  HomeFilterData copyWith({
    String? sortType,
    List<String>? skuId,
    num? distance,
  }) {
    return HomeFilterData(
      sortType: sortType ?? this.sortType,
      skuId: skuId ?? this.skuId,
      distance: distance ?? this.distance,
    );
  }

  bool hasFilterConditions() {
    return skuId.isNotEmpty || (distance ?? 0) > 0;
  }
}

class HomeFilterSubmitData {
  const HomeFilterSubmitData({
    required this.sortType,
    required this.skuIds,
    required this.distance,
    required this.onlyDistance,
  });

  final String sortType;
  final List<String> skuIds;
  final num distance;
  final bool onlyDistance;

  bool get hasFilterConditions {
    return skuIds.isNotEmpty || distance > 0;
  }

  List<String> toSelectedOptions() {
    final List<String> options = <String>[
      ...skuIds.where((String item) => item.isNotEmpty),
    ];
    if (distance > 0) {
      options.add(HomeV4FilterTokens.formatDistanceOption(distance));
    }
    return options;
  }
}

class HomeV4FilterSelectionState {
  const HomeV4FilterSelectionState({
    required this.advancedOptions,
    required this.distance,
  });

  final List<String> advancedOptions;
  final num distance;

  bool get hasDistanceFilter => distance > 0;

  List<String> get selectedOptions {
    return <String>[
      ...advancedOptions,
      if (hasDistanceFilter) HomeV4FilterTokens.formatDistanceOption(distance),
    ];
  }

  String distanceLabel({String? fallbackLabel}) {
    if (hasDistanceFilter) {
      return HomeV4FilterTokens.formatDistanceOption(distance);
    }
    return fallbackLabel ?? HomeV4FilterTokens.distanceQuickTag;
  }

  factory HomeV4FilterSelectionState.fromSelectedOptions(
    Iterable<String> options,
  ) {
    final List<String> advancedOptions = <String>[];
    final Set<String> seen = <String>{};
    num distance = 0;

    for (final String rawItem in options) {
      final String item = rawItem.trim();
      if (item.isEmpty) {
        continue;
      }
      if (HomeV4FilterTokens.isDistanceOption(item)) {
        distance = HomeV4FilterTokens.parseDistanceOption(item);
        continue;
      }
      if (seen.add(item)) {
        advancedOptions.add(item);
      }
    }

    return HomeV4FilterSelectionState(
      advancedOptions: advancedOptions,
      distance: distance,
    );
  }
}

class HomeV4FilterPanelState {
  const HomeV4FilterPanelState({
    required this.segmentIndex,
    required this.sortType,
    required this.skuIds,
    required this.distance,
    required this.onlyDistance,
    required this.channelOptions,
    required this.highlightOptions,
  });

  final int segmentIndex;
  final String sortType;
  final List<String> skuIds;
  final num distance;
  final bool onlyDistance;
  final List<String> channelOptions;
  final List<String> highlightOptions;

  factory HomeV4FilterPanelState.fromLogic({
    required int segmentIndex,
    required List<String> skuIds,
    required num distance,
    required bool onlyDistance,
    required List<String> channelOptions,
    required List<String> highlightOptions,
  }) {
    return HomeV4FilterPanelState(
      segmentIndex: segmentIndex,
      sortType: '',
      skuIds: skuIds,
      distance: distance,
      onlyDistance: onlyDistance,
      channelOptions: channelOptions,
      highlightOptions: highlightOptions,
    );
  }
}

class HomeV4QuickTagDisplayState {
  const HomeV4QuickTagDisplayState({
    required this.tag,
    required this.label,
    required this.selected,
    required this.showArrow,
  });

  final String tag;
  final String label;
  final bool selected;
  final bool showArrow;
}

class HomeV4FilterDisplayState {
  const HomeV4FilterDisplayState({
    required this.currentTab,
    required this.selectedSortIndex,
    required this.selectedSortLabel,
    required this.selectedOwnerIndex,
    required this.selectedOwnerLabel,
    required this.ownerOptions,
    required this.selectedFilterCount,
    required this.hasActiveFilters,
    required this.routeStartLabel,
    required this.routeEndLabel,
    required this.quickTags,
    required this.selectedOptions,
    required this.selectedDistanceLabel,
    required this.loadingPlaceText,
    required this.unloadingPlaceText,
  });

  final int currentTab;
  final int selectedSortIndex;
  final String selectedSortLabel;
  final int selectedOwnerIndex;
  final String selectedOwnerLabel;
  final List<String> ownerOptions;
  final int selectedFilterCount;
  final bool hasActiveFilters;
  final String routeStartLabel;
  final String routeEndLabel;
  final List<HomeV4QuickTagDisplayState> quickTags;
  final List<String> selectedOptions;
  final String selectedDistanceLabel;
  final String loadingPlaceText;
  final String unloadingPlaceText;

  bool get isMyTab => currentTab == 0;

  String get refreshKey => <Object>[
        currentTab,
        selectedSortIndex,
        selectedOwnerIndex,
        selectedFilterCount,
        selectedDistanceLabel,
        loadingPlaceText,
        unloadingPlaceText,
        selectedOptions.join('|'),
      ].join('|');
}

class HomeV4PageFilterState {
  const HomeV4PageFilterState({
    required this.refreshKey,
    required this.emptyTitle,
    required this.emptySubtitle,
  });

  final String refreshKey;
  final String emptyTitle;
  final String emptySubtitle;

  factory HomeV4PageFilterState.fromDisplayState(
    HomeV4FilterDisplayState state,
  ) {
    return HomeV4PageFilterState(
      refreshKey: state.refreshKey,
      emptyTitle: state.hasActiveFilters ? '没有找到相关货源' : '暂无符合条件的数据',
      emptySubtitle: state.hasActiveFilters ? '请修改筛选条件' : '切换 tab 或调整筛选条件后再试',
    );
  }
}

class HomeV4PageListState<T> {
  const HomeV4PageListState({
    required this.isFirstLoading,
    required this.hasError,
    required this.items,
    required this.isLoadingMore,
    required this.hasMore,
  });

  final bool isFirstLoading;
  final bool hasError;
  final List<T> items;
  final bool isLoadingMore;
  final bool hasMore;
}

class HomeV4PageContentState<T> {
  const HomeV4PageContentState({
    required this.listState,
    required this.emptyTitle,
    required this.emptySubtitle,
  });

  final HomeV4PageListState<T> listState;
  final String emptyTitle;
  final String emptySubtitle;

  bool get isFirstLoading => listState.isFirstLoading;

  bool get hasError => listState.hasError;

  List<T> get items => listState.items;

  bool get showEmpty => !isFirstLoading && !hasError && items.isEmpty;
}

class HomeV4PageTransportState<T> {
  const HomeV4PageTransportState({
    required this.currentWaybill,
    required this.showSticky,
    required this.showWaybillInfo,
    required this.hasPermission,
    required this.isPreOrder,
  });

  final T? currentWaybill;
  final bool showSticky;
  final bool showWaybillInfo;
  final bool hasPermission;
  final bool isPreOrder;
}

class HomeV4FooterState {
  const HomeV4FooterState({
    required this.isFirstLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.hasItems,
  });

  final bool isFirstLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final bool hasItems;

  factory HomeV4FooterState.fromListState(HomeV4PageListState<dynamic> state) {
    return HomeV4FooterState(
      isFirstLoading: state.isFirstLoading,
      isLoadingMore: state.isLoadingMore,
      hasMore: state.hasMore,
      hasItems: state.items.isNotEmpty,
    );
  }
}

class HomeV4RankSectionState {
  const HomeV4RankSectionState({
    required this.showRanking,
    required this.totalCount,
    required this.updateRankData,
  });

  final bool showRanking;
  final int totalCount;
  final bool updateRankData;
}

class HomeV4PageViewState<T, W> {
  const HomeV4PageViewState({
    required this.filter,
    required this.list,
    required this.content,
    required this.footer,
    required this.rank,
    required this.transport,
  });

  final HomeV4PageFilterState filter;
  final HomeV4PageListState<T> list;
  final HomeV4PageContentState<T> content;
  final HomeV4FooterState footer;
  final HomeV4RankSectionState rank;
  final HomeV4PageTransportState<W> transport;
}
