import 'dart:io';

import 'package:flutter/material.dart';

class ShareAppButton extends StatefulWidget {
  final bool shouldGlow;
  final VoidCallback? onPressed;

  const ShareAppButton({Key? key, required this.shouldGlow, this.onPressed})
      : super(key: key);

  @override
  _ShareAppButtonState createState() => _ShareAppButtonState();
}

class _ShareAppButtonState extends State<ShareAppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 1.2).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: const Color(0xFF0C5363),
      end: const Color(0xFFF7941D),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.shouldGlow) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ShareAppButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldGlow != oldWidget.shouldGlow) {
      if (widget.shouldGlow) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _defaultShareApp() {
    // Default share app logic (if needed)
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.shouldGlow ? _scaleAnimation.value : 1.0,
          child: IconButton(
            onPressed: widget.onPressed ?? _defaultShareApp,
            icon: Icon(
              Platform.isIOS ? Icons.ios_share : Icons.share,
              color: _colorAnimation.value,
            ),
          ),
        );
      },
    );
  }
}
