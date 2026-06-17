part of '../page/multiple_section_filter.dart';

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
                      const _PanelSectionTitle(title: '标签'),
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
                    const _PanelSectionTitle(title: '装货地距离'),
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
