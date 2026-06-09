import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/api/payment_api.dart';
import '../../data/models/transfer_request.dart';

class ConfirmScreen extends ConsumerStatefulWidget {
  const ConfirmScreen({super.key});

  @override
  ConsumerState<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends ConsumerState<ConfirmScreen> {
  bool _isSubmitting = false;

  Future<void> _confirm() async {
    final session = ref.read(transferSessionProvider);
    if (session == null || _isSubmitting) return;

    HapticFeedback.mediumImpact();
    setState(() => _isSubmitting = true);

    try {
      await ref.read(paymentApiProvider).createTransfer(
            TransferRequest(
              requestId: const Uuid().v4(),
              accountNumber: session.accountNumber,
              bankBin: session.bankBin,
              amount: session.amount,
              description: session.description,
            ),
          );

      if (!mounted) return;
      HapticFeedback.heavyImpact();
      context.go('/success');
    } on PaymentApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Chuyển tiền thất bại. Thử lại.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(transferSessionProvider);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    if (session == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/');
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Text(
                'Chuyển đến',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.textMuted,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                session.recipientName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                      height: 1.25,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                session.bankName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const Spacer(flex: 2),
              Text(
                formatVnd(session.amount),
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.5,
                      height: 1.1,
                      color: AppColors.textPrimary,
                    ),
              ),
              const Spacer(flex: 3),
              _ConfirmButton(
                isLoading: _isSubmitting,
                onPressed: _confirm,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: isLoading
                ? [
                    AppColors.primary.withValues(alpha: 0.5),
                    AppColors.primaryDark.withValues(alpha: 0.5),
                  ]
                : [AppColors.primary, AppColors.primaryDark],
          ),
          boxShadow: isLoading
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(18),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Xác nhận chuyển tiền',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
