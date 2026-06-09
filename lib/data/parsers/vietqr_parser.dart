import '../models/qr_payment_data.dart';
/// EMVCo / VietQR TLV parser — đủ cho demo sandbox.
class VietQrParser {
  static QrPaymentData? parse(String payload) {
    final trimmed = payload.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.startsWith('000201')) {
      return _parseEmvCo(trimmed);
    }

    return _parseSimpleDemo(trimmed);
  }

  static QrPaymentData? _parseEmvCo(String payload) {
    final tags = _readTlv(payload);
    final merchantAccount = tags['38'];
    if (merchantAccount == null) return null;

    final nested = _readTlv(merchantAccount);
    final accountNumber = nested['01'] ?? nested['02'];
    final bankBin = nested['00'];
    if (accountNumber == null || bankBin == null) return null;

    final amountStr = tags['54'];
    final amount = amountStr != null ? (double.tryParse(amountStr)?.round() ?? 0) : 0;
    final name = tags['59'];
    final description = tags['62'] != null ? _readTlv(tags['62']!)['08'] : null;

    return QrPaymentData(
      rawPayload: payload,
      accountNumber: accountNumber,
      bankBin: bankBin,
      amount: amount,
      recipientName: name,
      description: description,
    );
  }

  static QrPaymentData? _parseSimpleDemo(String payload) {
    // Format demo: EWALLET|970422|0123456789|250000|NGUYEN VAN A
    if (!payload.toUpperCase().startsWith('EWALLET|')) return null;
    final parts = payload.split('|');
    if (parts.length < 4) return null;

    return QrPaymentData(
      rawPayload: payload,
      bankBin: parts[1],
      accountNumber: parts[2],
      amount: int.tryParse(parts[3]) ?? 0,
      recipientName: parts.length > 4 ? parts[4] : null,
    );
  }

  static Map<String, String> _readTlv(String data) {
    final result = <String, String>{};
    var index = 0;
    while (index + 4 <= data.length) {
      final tag = data.substring(index, index + 2);
      final length = int.tryParse(data.substring(index + 2, index + 4));
      if (length == null) break;
      index += 4;
      if (index + length > data.length) break;
      result[tag] = data.substring(index, index + length);
      index += length;
    }
    return result;
  }

  /// Payload demo để test trên desktop / emulator.
  static const demoPayload =
      'EWALLET|970422|0123456789|250000|NGUYEN VAN A';
}
