import 'dart:convert';
import 'dart:io';

import '../../core/config/app_config.dart';
import '../models/qr_payment_data.dart';
import '../models/transfer_request.dart';
import '../models/transfer_result.dart';
import 'payment_api.dart';
import 'sandbox_payment_service.dart';

/// Sandbox HTTP server — mô phỏng provider bên thứ 3 qua REST.
class SandboxHttpServer {
  SandboxHttpServer._();

  static HttpServer? _server;
  static final _service = SandboxPaymentService.instance;

  static Future<void> start() async {
    if (_server != null) return;
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
    _server!.listen(_handleRequest);
  }

  static Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }

  static Future<void> _handleRequest(HttpRequest request) async {
    final path = request.uri.path;
    final method = request.method;

    try {
      if (method == 'POST' && path == '${AppConfig.apiPrefix}/qr/validate') {
        final body = await _readBody(request);
        try {
          final data = _service.validateQr(QrPaymentData(
            rawPayload: body['rawPayload'] as String? ?? '',
            accountNumber: body['accountNumber'] as String,
            bankBin: body['bankBin'] as String,
            amount: body['amount'] as int,
            recipientName: body['recipientName'] as String?,
            description: body['description'] as String?,
          ));
          await _sendJson(request, 200, {
            'accountNumber': data.accountNumber,
            'bankBin': data.bankBin,
            'bankName': data.bankName,
            'recipientName': data.recipientName,
            'amount': data.amount,
            if (data.description != null) 'description': data.description,
          });
        } on PaymentApiException catch (e) {
          await _sendJson(request, 400, {'code': e.code, 'message': e.message});
        }
        return;
      }

      if (method == 'POST' && path == '${AppConfig.apiPrefix}/transfers') {
        final body = await _readBody(request);
        try {
          final result = _service.createTransfer(TransferRequest(
            requestId: body['requestId'] as String,
            accountNumber: body['accountNumber'] as String,
            bankBin: body['bankBin'] as String,
            amount: body['amount'] as int,
            description: body['description'] as String?,
          ));
          await _sendJson(request, 200, _transferToJson(result));
        } on PaymentApiException catch (e) {
          final code = e.code == 'INSUFFICIENT_BALANCE' ? 422 : 400;
          await _sendJson(request, code, {'code': e.code, 'message': e.message});
        }
        return;
      }

      if (method == 'GET' &&
          path.startsWith('${AppConfig.apiPrefix}/transfers/')) {
        final id = path.split('/').last;
        final result = _service.getTransfer(id);
        if (result == null) {
          await _sendJson(request, 404,
              {'code': 'NOT_FOUND', 'message': 'Giao dịch không tồn tại'});
          return;
        }
        await _sendJson(request, 200, _transferToJson(result));
        return;
      }

      if (method == 'GET' && path == '${AppConfig.apiPrefix}/health') {
        await _sendJson(request, 200, {'status': 'ok', 'mode': 'sandbox'});
        return;
      }

      await _sendJson(request, 404,
          {'code': 'NOT_FOUND', 'message': 'Endpoint không tồn tại'});
    } catch (_) {
      await _sendJson(request, 500,
          {'code': 'INTERNAL_ERROR', 'message': 'Lỗi sandbox server'});
    }
  }

  static Future<Map<String, dynamic>> _readBody(HttpRequest request) async {
    final content = await utf8.decoder.bind(request).join();
    return jsonDecode(content) as Map<String, dynamic>;
  }

  static Future<void> _sendJson(
    HttpRequest request,
    int statusCode,
    Map<String, dynamic> body,
  ) async {
    request.response
      ..statusCode = statusCode
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(body));
    await request.response.close();
  }

  static Map<String, dynamic> _transferToJson(TransferResult result) => {
        'transactionId': result.transactionId,
        'status': result.status.name,
        'amount': result.amount,
        'recipientName': result.recipientName,
        'message': result.message,
      };
}
