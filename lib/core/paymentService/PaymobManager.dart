import 'package:dio/dio.dart';
import 'constants.dart';

class PaymobManager {
  final Dio _dio = Dio();

  Future<String> getPaymentKey(int amount, String currency) async {
    try {
      String authToken = await _getAuthToken();
      int orderId = await _getOrderId(authToken, 100 * amount, currency);
      String paymentKey = await _getPaymentKey(
        authToken,
        (100 * amount).toString(),
        currency,
        orderId.toString(),
      );
      return paymentKey;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? "Failed to get payment key");
    }
  }

  /// Step 4: Pay directly with card details (no WebView)
  Future<Map<String, dynamic>> payWithCard({
    required String paymentKey,
    required String cardNumber,
    required String cardholderName,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
  }) async {
    try {
      final response = await _dio.post(
        "https://accept.paymob.com/api/acceptance/payments/pay",
        data: {
          "source": {
            "identifier": cardNumber.replaceAll(' ', ''),
            "sourceholder_name": cardholderName,
            "subtype": "CARD",
            "expiry_month": expiryMonth,
            "expiry_year": expiryYear,
            "cvn": cvv,
          },
          "payment_token": paymentKey,
        },
      );

      final data = response.data;
      return {
        "success": data["success"] ?? false,
        "is_3d_secure": data["is_3d_secure"] ?? false,
        "redirect_url": data["redirect_url"] ?? "",
        "message": data["data"]?["message"] ?? "",
      };
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? "Payment failed");
    }
  }

  Future<String> _getAuthToken() async {
    final response = await _dio.post(
      "https://accept.paymob.com/api/auth/tokens",
      data: {"api_key": Constants.apiKey},
    );
    return response.data["token"];
  }

  Future<int> _getOrderId(String authToken, int amount, String currency) async {
    final response = await _dio.post(
      "https://accept.paymob.com/api/ecommerce/orders",
      data: {
        "auth_token": authToken,
        "delivery_needed": "false",
        "amount_cents": amount,
        "currency": currency,
        "items": [],
      },
    );
    return response.data["id"];
  }

  Future<String> _getPaymentKey(
      String authToken,
      String amount,
      String currency,
      String orderId,
      ) async {
    final response = await _dio.post(
      "https://accept.paymob.com/api/acceptance/payment_keys",
      data: {
        "auth_token": authToken,
        "amount_cents": amount,
        "expiration": 3600,
        "order_id": orderId,
        "currency": currency,
        "integration_id": Constants.integrationId,
        "billing_data": {
          "apartment": "NA",
          "email": "test@example.com",
          "floor": "NA",
          "first_name": "Test",
          "street": "NA",
          "building": "NA",
          "phone_number": "+201000000000",
          "shipping_method": "NA",
          "postal_code": "NA",
          "city": "Cairo",
          "country": "EG",
          "last_name": "Account",
          "state": "NA",
        },
      },
    );
    return response.data["token"];
  }
}