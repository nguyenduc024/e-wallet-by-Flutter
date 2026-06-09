import 'package:flutter_test/flutter_test.dart';
import 'package:ewallet_demo/data/parsers/vietqr_parser.dart';

void main() {
  test('parse demo EWALLET payload', () {
    final data = VietQrParser.parse(VietQrParser.demoPayload);
    expect(data, isNotNull);
    expect(data!.accountNumber, '0123456789');
    expect(data.bankBin, '970422');
    expect(data.amount, 250000);
    expect(data.recipientName, 'NGUYEN VAN A');
  });
}
