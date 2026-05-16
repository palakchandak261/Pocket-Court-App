import 'package:flutter/material.dart';

class SlideUpRoute extends PageRouteBuilder {
  final Widget page;
  SlideUpRoute({required this.page})
      : super(
          pageBuilder: (_, __, ___) => page,
          transitionDuration: const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 280),
          transitionsBuilder: (_, animation, __, child) {
            final tween = Tween(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic));
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: animation.drive(tween), child: child),
            );
          },
        );
}
