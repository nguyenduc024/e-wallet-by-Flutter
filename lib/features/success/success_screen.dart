import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_config.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';

class SuccessScreen extends ConsumerStatefulWidget {
  const SuccessScreen({super.key});

  @override
  ConsumerState<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends ConsumerState<SuccessScreen>
    with TickerProviderStateMixin {
  late final AnimationController _tickController;
  late final AnimationController _textController;
  late final Animation<double> _tickScale;
  late final Animation<double> _textOpacity;
  Timer? _backTimer;

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();

    _tickController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _tickScale = CurvedAnimation(
      parent: _tickController,
      curve: Curves.elasticOut,
    );
    _textOpacity = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    );

    _tickController.forward().then((_) {
      _textController.forward();
    });

    _backTimer = Timer(
      Duration(seconds: AppConfig.successAutoBackSeconds),
      () {
        if (mounted) {
          ref.read(transferSessionProvider.notifier).state = null;
          context.go('/');
        }
      },
    );
  }

  @override
  void dispose() {
    _backTimer?.cancel();
    _tickController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _tickScale,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 52,
                  color: AppColors.success,
                ),
              ),
            ),
            const SizedBox(height: 32),
            FadeTransition(
              opacity: _textOpacity,
              child: Text(
                'Thành công',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
