import 'package:brain_match/ui/theme.dart';
import 'package:flutter/material.dart';

class BouncingArrow extends StatefulWidget {
  final double size;
  final Duration duration;
  final IconData icon;

  const BouncingArrow({
    super.key,
    this.size = 50.0,
    this.duration = const Duration(seconds: 1),
    this.icon = Icons.keyboard_arrow_down,
  });

  @override
  State<BouncingArrow> createState() => _BouncingArrowState();
}

class _BouncingArrowState extends State<BouncingArrow> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 0.15),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Icon(
        widget.icon,
        size: widget.size,
        color: AppColors.primary,
      ),
    );
  }
}
