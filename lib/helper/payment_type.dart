class PaymentType {
  static const String cod = 'COD';
  static const String online = 'ONLINE';
  static const String paid = 'PAID';
  static const String pending = 'PENDING';
  static const String trukMoney = 'TRUKMONEY';
  static const Map<String, String> paymentKeys = {
    cod: 'Cash On Delivery',
    online: 'Pre-Paid Order',
    trukMoney: 'TruK Money'
  };
}
