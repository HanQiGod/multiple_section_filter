part of '../page/multiple_section_filter.dart';

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
        padding: EdgeInsets.fromLTRB(22.w, 18.h, 22.w, 16.h),
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
            SizedBox(height: 16.h),
            Text(
              '上海青浦园区 -> 苏州昆山仓',
              style: TextStyle(
                color: Colors.white,
                fontSize: 34.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '司机已接单，预计 2 小时后到达装货地',
              style: TextStyle(
                color: const Color(0xCCFFFFFF),
                fontSize: 24.sp,
              ),
            ),
            const Spacer(),
            Row(
              children: const <Widget>[
                Expanded(
                  child: _TransportMetric(
                    label: '运输单号',
                    value: 'WB20260617001',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _TransportMetric(
                    label: '司机',
                    value: '王师傅',
                  ),
                ),
                SizedBox(width: 12),
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
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
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
                mainAxisSize: MainAxisSize.min,
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
                  SizedBox(height: 4.h),
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
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
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
          SizedBox(height: 4.h),
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
          const Row(
            children: <Widget>[
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
