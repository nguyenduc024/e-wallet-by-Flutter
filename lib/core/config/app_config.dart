/// Cấu hình sandbox — đổi baseUrl khi gắn API bên thứ 3 thật.
class AppConfig {
  AppConfig._();

  static const sandboxBaseUrl = 'http://127.0.0.1:8080';
  static const apiPrefix = '/api/v1';
  static const connectTimeout = Duration(seconds: 10);
  static const transferTimeout = Duration(seconds: 15);

  /// Tự quay về màn quét sau khi thành công.
  static const successAutoBackSeconds = 2;
}
