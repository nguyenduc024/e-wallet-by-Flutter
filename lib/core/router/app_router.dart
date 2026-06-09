import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/confirm/confirm_screen.dart';
import '../../features/scan/scan_screen.dart';
import '../../features/success/success_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: ScanScreen(),
      ),
    ),
    GoRoute(
      path: '/confirm',
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const ConfirmScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    ),
    GoRoute(
      path: '/success',
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const SuccessScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
  ],
);
