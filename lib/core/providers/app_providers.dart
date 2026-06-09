import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/http_payment_api.dart';
import '../../data/api/payment_api.dart';
import '../../data/models/beneficiary_info.dart';

final paymentApiProvider = Provider<PaymentApi>((ref) => HttpPaymentApi());

final transferSessionProvider =
    StateProvider<BeneficiaryInfo?>((ref) => null);
