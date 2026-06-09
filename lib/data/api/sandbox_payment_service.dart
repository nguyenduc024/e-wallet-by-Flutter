import '../models/beneficiary_info.dart';
import '../models/qr_payment_data.dart';
import '../models/transfer_request.dart';
import '../models/transfer_result.dart';
import 'payment_api.dart';

/// Logic sandbox dùng chung — HTTP server và in-process API.
class SandboxPaymentService {
  SandboxPaymentService._();
  static final instance = SandboxPaymentService._();

  final _processedRequests = <String, TransferResult>{};
  final _transactionsById = <String, TransferResult>{};

  static const bankNames = {
    '970422': 'MB Bank',
    '970436': 'Vietcombank',
    '970415': 'VietinBank',
    '970418': 'BIDV',
    '970407': 'Techcombank',
  };

  static const beneficiaryDirectory = {
    '970422:0123456789': 'NGUYEN VAN A',
    '970436:9876543210': 'TRAN THI B',
    '970415:5555666677': 'LE VAN C',
  };

  BeneficiaryInfo validateQr(QrPaymentData data) {
    if (data.amount <= 0) {
      throw PaymentApiException('INVALID_AMOUNT', 'Số tiền không hợp lệ');
    }
    if (data.amount > 50000000) {
      throw PaymentApiException(
        'AMOUNT_EXCEEDED',
        'Vượt hạn mức sandbox (50.000.000₫)',
      );
    }

    final key = '${data.bankBin}:${data.accountNumber}';
    final name = beneficiaryDirectory[key] ??
        data.recipientName ??
        'NGUOI NHAN ${data.accountNumber}';
    final bankName = bankNames[data.bankBin] ?? 'Ngan hang ${data.bankBin}';

    return BeneficiaryInfo(
      accountNumber: data.accountNumber,
      bankBin: data.bankBin,
      bankName: bankName,
      recipientName: name.toUpperCase(),
      amount: data.amount,
      description: data.description,
    );
  }

  TransferResult createTransfer(TransferRequest request) {
    if (_processedRequests.containsKey(request.requestId)) {
      return _processedRequests[request.requestId]!;
    }

    if (request.amount > 10000000) {
      throw PaymentApiException(
        'INSUFFICIENT_BALANCE',
        'Số dư sandbox không đủ',
      );
    }

    final key = '${request.bankBin}:${request.accountNumber}';
    final name =
        beneficiaryDirectory[key] ?? 'NGUOI NHAN ${request.accountNumber}';

    final result = TransferResult(
      transactionId: 'TX${DateTime.now().millisecondsSinceEpoch}',
      status: TransferStatus.success,
      amount: request.amount,
      recipientName: name.toUpperCase(),
      message: 'Chuyển tiền thành công',
    );

    _processedRequests[request.requestId] = result;
    _transactionsById[result.transactionId] = result;
    return result;
  }

  TransferResult? getTransfer(String transactionId) =>
      _transactionsById[transactionId];
}
