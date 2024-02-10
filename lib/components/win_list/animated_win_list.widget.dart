import 'package:flutter/material.dart';
import 'package:happiness_team_app/models/win.model.dart';
import 'package:happiness_team_app/components/win_list/win_card.widget.dart';

class AnimatedWinList extends StatefulWidget {
  final Wins wins;
  final Function(Win) onEdit;

  const AnimatedWinList({
    required this.wins,
    required this.onEdit,
    Key? key,
  }) : super(key: key);

  @override
  State<AnimatedWinList> createState() => _AnimatedWinListState();
}

class _AnimatedWinListState extends State<AnimatedWinList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    return SlideTransition(
      position: animation.drive(
        Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16.0),
        child: WinCard(
          win: widget.wins[index],
          onEdit: () => widget.onEdit(
            widget.wins[index],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      padding: const EdgeInsets.all(0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      key: _listKey,
      initialItemCount: widget.wins.length,
      itemBuilder: (context, index, animation) {
        return _buildItem(context, index, animation);
      },
    );
  }
}
