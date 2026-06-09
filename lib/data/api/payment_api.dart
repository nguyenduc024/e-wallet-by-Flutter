import '../models/beneficiary_info.dart';
import '../models/qr_payment_data.dart';
import '../models/transfer_request.dart';
import '../models/transfer_result.dart';

/// Contract API — swap implementation khi gắn provider thật.
abstract class PaymentApi {
  Future<BeneficiaryInfo> validateQr(QrPaymentData data);
  Future<TransferResult> createTransfer(TransferRequest request);
}

class PaymentApiException implements Exception {
  PaymentApiException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => '$code: $message';
}
