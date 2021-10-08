import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentHelper {
  Razorpay _razorpay;

  createOrder(double amount) async {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    var options = {
      'key': 'rzp_test_mJh9QWD7lZ8ToY',
      'amount': 50000, //in the smallest currency sub-unit.
      'name': 'Test Truk',
      'description': 'Fine T-Shirt',
      'timeout': 60, // in seconds
      'prefill': {'contact': '9123456789', 'email': 'something@example.com'}
    };
    _razorpay.open(options);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
    print("Payment Success : ${response.orderId}");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    print("Payment Error : ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
    print(response.walletName);
  }
}
