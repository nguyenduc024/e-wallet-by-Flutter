# eWallet Demo

Demo ví điện tử nội bộ — quét QR, xác nhận, chuyển tiền qua **sandbox API local**.

## Chạy nhanh

```bash
flutter pub get
flutter run
```

| Nền tảng | Ghi chú |
|----------|---------|
| **Android** (emulator/điện thoại) | Camera quét QR thật |
| **Windows** | Bật **Developer Mode** (Settings → For developers) để build plugin. Debug: **chạm màn hình đen** để demo QR |
| **iOS** | Cần Mac + Xcode |

### Demo trên Windows (không camera)

1. `flutter run -d windows`
2. Màn Scan (đen) → **chạm anywhere** → Confirm → Success → tự về Scan

### Demo trên Android

Tạo QR từ chuỗi:

```
EWALLET|970422|0123456789|250000|NGUYEN VAN A
```

## Luồng sản phẩm

```
Scan (camera full) → API validate QR → Confirm → API transfer → Success → Scan
```

## Sandbox API (`127.0.0.1:8080`)

Server tự khởi động cùng app. Chi tiết endpoint: xem phần API trong file này hoặc `lib/data/api/sandbox_http_server.dart`.

| Endpoint | Mô tả |
|----------|-------|
| `POST /api/v1/qr/validate` | Xác thực QR, trả tên người nhận |
| `POST /api/v1/transfers` | Thực hiện chuyển tiền (idempotent) |
| `GET /api/v1/health` | Health check |

## Cấu trúc

```
lib/
├── core/       theme, router, config, providers
├── data/       models, VietQR parser, HTTP client, sandbox server
└── features/   scan · confirm · success
```

## Gắn API bên thứ 3 thật

1. Implement `PaymentApi` → `lib/data/api/payment_api.dart`
2. Đổi provider → `lib/core/providers/app_providers.dart`
3. Tắt `SandboxHttpServer.start()` → `lib/main.dart`
4. Cập nhật base URL → `lib/core/utils/sandbox_url.dart`
