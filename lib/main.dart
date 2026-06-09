import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/app_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/api/http_payment_api.dart';
import 'data/api/local_sandbox_payment_api.dart';
import 'data/api/payment_api.dart';
import 'data/api/sandbox_http_server.dart'
    if (dart.library.html) 'data/api/sandbox_http_server_stub.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PaymentApi paymentApi;

  if (kIsWeb) {
    paymentApi = LocalSandboxPaymentApi();
  } else {
    await SandboxHttpServer.start();
    paymentApi = HttpPaymentApi();
  }

  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  runApp(
    ProviderScope(
      overrides: [
        paymentApiProvider.overrideWithValue(paymentApi),
      ],
      child: const EWalletApp(),
    ),
  );
}

class EWalletApp extends StatelessWidget {
  const EWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'eWallet Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
