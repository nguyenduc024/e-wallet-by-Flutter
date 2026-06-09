import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/providers/app_providers.dart';
import '../../data/api/payment_api.dart';
import '../../data/parsers/vietqr_parser.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  MobileScannerController? _controller;
  bool _isProcessing = false;

  final bool _useCamera = !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void initState() {
    super.initState();
    ref.read(transferSessionProvider.notifier).state = null;
    if (_useCamera) {
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onQrDetected(String rawValue) async {
    if (_isProcessing) return;

    final parsed = VietQrParser.parse(rawValue);
    if (parsed == null) {
      _showError('Mã QR không hợp lệ');
      return;
    }

    setState(() => _isProcessing = true);
    if (_useCamera) await _controller?.stop();

    try {
      final beneficiary =
          await ref.read(paymentApiProvider).validateQr(parsed);
      ref.read(transferSessionProvider.notifier).state = beneficiary;
      if (!mounted) return;
      await context.push('/confirm');
    } on PaymentApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Không kết nối được sandbox. Kiểm tra server đang chạy.');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
        if (_useCamera) await _controller?.start();
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    if (!kIsWeb) HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  Future<void> _simulateDemoScan() async {
    if (!kIsWeb) HapticFeedback.mediumImpact();
    await _onQrDetected(VietQrParser.demoPayload);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: !_useCamera ? _simulateDemoScan : null,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_useCamera && _controller != null)
              MobileScanner(
                controller: _controller!,
                onDetect: (capture) {
                  final code = capture.barcodes.firstOrNull?.rawValue;
                  if (code != null) _onQrDetected(code);
                },
              )
            else
              const ColoredBox(color: Colors.black),

            if (!_useCamera)
              Center(
                child: Text(
                  kIsWeb ? 'Click để demo quét QR' : 'Chạm để demo quét QR',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 14,
                    letterSpacing: 0.2,
                  ),
                ),
              ),

            if (_isProcessing)
              Container(
                color: Colors.black54,
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
