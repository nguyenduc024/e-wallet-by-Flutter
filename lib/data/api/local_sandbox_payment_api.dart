import '../models/beneficiary_info.dart';
import '../models/qr_payment_data.dart';
import '../models/transfer_request.dart';
import '../models/transfer_result.dart';
import 'payment_api.dart';
import 'sandbox_payment_service.dart';

/// API sandbox in-process — dùng khi chạy web hoặc không cần HTTP server.
class LocalSandboxPaymentApi implements PaymentApi {
  LocalSandboxPaymentApi({SandboxPaymentService? service})
      : _service = service ?? SandboxPaymentService.instance;

  final SandboxPaymentService _service;

  @override
  Future<BeneficiaryInfo> validateQr(QrPaymentData data) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return _service.validateQr(data);
  }

  @override
  Future<TransferResult> createTransfer(TransferRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return _service.createTransfer(request);
  }
}
