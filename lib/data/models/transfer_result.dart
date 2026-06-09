enum TransferStatus { success, pending, failed }

class TransferResult {
  const TransferResult({
    required this.transactionId,
    required this.status,
    required this.amount,
    required this.recipientName,
    this.message,
  });

  final String transactionId;
  final TransferStatus status;
  final int amount;
  final String recipientName;
  final String? message;

  factory TransferResult.fromJson(Map<String, dynamic> json) {
    return TransferResult(
      transactionId: json['transactionId'] as String,
      status: TransferStatus.values.byName(json['status'] as String),
      amount: json['amount'] as int,
      recipientName: json['recipientName'] as String,
      message: json['message'] as String?,
    );
  }
}
