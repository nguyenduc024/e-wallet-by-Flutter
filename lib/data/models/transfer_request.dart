class TransferRequest {
  const TransferRequest({
    required this.requestId,
    required this.accountNumber,
    required this.bankBin,
    required this.amount,
    this.description,
  });

  final String requestId;
  final String accountNumber;
  final String bankBin;
  final int amount;
  final String? description;

  Map<String, dynamic> toJson() => {
        'requestId': requestId,
        'accountNumber': accountNumber,
        'bankBin': bankBin,
        'amount': amount,
        if (description != null) 'description': description,
      };
}
