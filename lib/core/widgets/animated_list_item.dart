import 'package:flutter/material.dart';

/// A widget that animates its child with a staggered slide + fade effect.
/// Useful for building animated lists where each item enters with a delay.
class AnimatedListItem extends StatelessWidget {
  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    required this.controller,
    this.verticalOffset = 40.0,
    this.horizontalOffset = 0.0,
    this.staggerFraction = 0.06,
  });

  final Widget child;
  final int index;
  final AnimationController controller;
  final double verticalOffset;
  final double horizontalOffset;
  final double staggerFraction;

  @override
  Widget build(BuildContext context) {
    final start = (index * staggerFraction).clamp(0.0, 0.7);
    final end = (start + 0.5).clamp(start + 0.1, 1.0);

    final slideAnim = Tween<Offset>(
      begin: Offset(horizontalOffset, verticalOffset),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOutQuart),
    ));

    final fadeAnim = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, verticalOffset / 100),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: controller,
          curve: Interval(start, end, curve: Curves.easeOutQuart),
        )),
        child: child,
      ),
    );
  }
}
