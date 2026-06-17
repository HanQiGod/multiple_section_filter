part of '../page/multiple_section_filter.dart';

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
