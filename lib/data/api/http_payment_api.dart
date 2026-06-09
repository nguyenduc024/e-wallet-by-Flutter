import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/utils/sandbox_url.dart';
import '../models/beneficiary_info.dart';
import '../models/qr_payment_data.dart';
import '../models/transfer_request.dart';
import '../models/transfer_result.dart';
import 'payment_api.dart';

class HttpPaymentApi implements PaymentApi {
  HttpPaymentApi({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _base = (baseUrl ?? resolveSandboxBaseUrl()) + AppConfig.apiPrefix;

  final http.Client _client;
  final String _base;

  @override
  Future<BeneficiaryInfo> validateQr(QrPaymentData data) async {
    final response = await _client
        .post(
          Uri.parse('$_base/qr/validate'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data.toJson()),
        )
        .timeout(AppConfig.connectTimeout);

    return _handleResponse(response, BeneficiaryInfo.fromJson);
  }

  @override
  Future<TransferResult> createTransfer(TransferRequest request) async {
    final response = await _client
        .post(
          Uri.parse('$_base/transfers'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(request.toJson()),
        )
        .timeout(AppConfig.transferTimeout);

    return _handleResponse(response, TransferResult.fromJson);
  }

  T _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return fromJson(body);
    }

    throw PaymentApiException(
      body['code'] as String? ?? 'API_ERROR',
      body['message'] as String? ?? 'Yêu cầu thất bại',
    );
  }
}
