class BeneficiaryInfo {
  const BeneficiaryInfo({
    required this.accountNumber,
    required this.bankBin,
    required this.bankName,
    required this.recipientName,
    required this.amount,
    this.description,
  });

  final String accountNumber;
  final String bankBin;
  final String bankName;
  final String recipientName;
  final int amount;
  final String? description;

  factory BeneficiaryInfo.fromJson(Map<String, dynamic> json) {
    return BeneficiaryInfo(
      accountNumber: json['accountNumber'] as String,
      bankBin: json['bankBin'] as String,
      bankName: json['bankName'] as String,
      recipientName: json['recipientName'] as String,
      amount: json['amount'] as int,
      description: json['description'] as String?,
    );
  }
}
