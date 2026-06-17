part of '../page/multiple_section_filter.dart';

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
