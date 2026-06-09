import 'dart:io';

import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

/// Base URL sandbox — Android emulator dùng 10.0.2.2 thay cho localhost.
String resolveSandboxBaseUrl() {
  if (kIsWeb) return AppConfig.sandboxBaseUrl;

  if (Platform.isAndroid && !kReleaseMode) {
    // Emulator / debug: host machine localhost
    return 'http://10.0.2.2:8080';
  }

  return AppConfig.sandboxBaseUrl;
}
