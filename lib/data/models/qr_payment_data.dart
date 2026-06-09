class QrPaymentData {
  const QrPaymentData({
    required this.rawPayload,
    required this.accountNumber,
    required this.bankBin,
    required this.amount,
    this.recipientName,
    this.description,
  });

  final String rawPayload;
  final String accountNumber;
  final String bankBin;
  final int amount;
  final String? recipientName;
  final String? description;

  Map<String, dynamic> toJson() => {
        'rawPayload': rawPayload,
        'accountNumber': accountNumber,
        'bankBin': bankBin,
        'amount': amount,
        if (recipientName != null) 'recipientName': recipientName,
        if (description != null) 'description': description,
      };
}
