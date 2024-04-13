import 'package:flutter/material.dart';
import 'package:happiness_team_app/providers/wins.provider.dart';
import 'package:happiness_team_app/screens/home/grouping_tabs.widget.dart';
import 'package:provider/provider.dart';

class GroupingHeader extends StatelessWidget {
  final double height;

  const GroupingHeader(
      {super.key, this.height = 70.0}); // Default height is 60.0, but it can be overridden

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Provider.of<WinsProvider>(context, listen: false).tabs,
      builder: (context, tabs, _) {
        return SliverPersistentHeader(
          pinned: true,
          delegate: _GroupingHeaderDelegate(
            height: tabs.isNotEmpty ? height : 8,
            child: const GroupingTabs(), // Your custom GroupingTabs widget
          ),
        );
      }
    );
  }
}

class _GroupingHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  _GroupingHeaderDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_GroupingHeaderDelegate oldDelegate) {
    return height != oldDelegate.height || child != oldDelegate.child;
  }
}
