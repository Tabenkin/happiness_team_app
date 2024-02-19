import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:happiness_team_app/providers/wins.provider.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:provider/provider.dart';

class GroupingTabs extends StatefulWidget {
  const GroupingTabs({
    Key? key,
  }) : super(key: key);

  @override
  State<GroupingTabs> createState() => _GroupingTabsState();
}

class _GroupingTabsState extends State<GroupingTabs> {
  late WinsProvider _winsProvider;

  @override
  initState() {
    super.initState();

    _winsProvider = Provider.of<WinsProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    // Creating the map for the children of CupertinoSlidingSegmentedControl

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        
      ),      
      padding: const EdgeInsets.all(8.0),
      child: MultiValueListenableBuilder(
        valueListenables: [
          _winsProvider.tabs,
          _winsProvider.selectedTab,
        ],
        builder: (context, values, child) {
          if (_winsProvider.tabs.value.length <= 1) return const SizedBox();

          final Map<int, Widget> children = {
            for (int index = 0;
                index < _winsProvider.tabs.value.length;
                index++)
              index: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _winsProvider.tabs.value[index],
                  style: TextStyle(
                    color: _winsProvider.selectedTab.value == index
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onPrimary,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          };

          return IntrinsicHeight(
            child: Container(
              margin: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.all(0),
              child: Center(
                child: SizedBox(
                  height: double.infinity,
                  width: double.infinity,
                  child: CupertinoSlidingSegmentedControl<int>(
                    children: children,
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    padding: const EdgeInsets.all(11.0),
                    onValueChanged: (int? newValue) {
                      _winsProvider.setSelectedTab(newValue ?? 0);
                    },
                    groupValue: _winsProvider.selectedTab.value,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
