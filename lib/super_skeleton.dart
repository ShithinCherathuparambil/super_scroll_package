import 'package:flutter/material.dart';

/// A widget that provides a pulsing shimmer effect for loading states.
class SuperSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final ShapeBorder shape;
  final EdgeInsetsGeometry? margin;

  const SuperSkeleton({
    super.key,
    this.width,
    this.height,
    this.shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
    ),
    this.margin,
  });

  const SuperSkeleton.rectangle({
    super.key,
    this.width,
    this.height,
    this.margin,
  }) : shape = const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        );

  const SuperSkeleton.circle({
    super.key,
    double? size,
    this.margin,
  })  : width = size,
        height = size,
        shape = const CircleBorder();

  @override
  State<SuperSkeleton> createState() => _SuperSkeletonState();
}

class _SuperSkeletonState extends State<SuperSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        decoration: ShapeDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.grey[300]
              : Colors.grey[700],
          shape: widget.shape,
        ),
      ),
    );
  }
}
