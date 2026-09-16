import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/services/upi_payment_service.dart';
import 'package:mobile/services/upi_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UpiPaymentService URI Construction Tests', () {
    test('buildSafeUpiUri correctly encodes standard merchant URI with amount', () {
      final uri = UpiPaymentService.buildSafeUpiUri(
        upiId: 'merchant@okaxis',
        payeeName: 'Chai Point',
        amount: 150.50,
        currency: 'INR',
        transactionRef: 'REF12345',
        note: 'Evening Tea',
      );

      expect(uri.scheme, 'upi');
      expect(uri.host, 'pay');
      expect(uri.queryParameters['pa'], 'merchant@okaxis');
      expect(uri.queryParameters['pn'], 'Chai Point');
      expect(uri.queryParameters['am'], '150.50');
      expect(uri.queryParameters['cu'], 'INR');
      expect(uri.queryParameters['tr'], 'REF12345');
      expect(uri.queryParameters['tn'], 'Evening Tea');
    });

    test('buildSafeUpiUri preserves existing QR amount when present in UpiPaymentData', () {
      const data = UpiPaymentData(
        rawUri: 'upi://pay?pa=shop@upi&am=420.00',
        upiId: 'shop@upi',
        amount: 420.00,
      );

      final uri = UpiPaymentService.buildSafeUpiUri(
        upiId: data.upiId,
        amount: data.amount,
      );

      expect(uri.queryParameters['pa'], 'shop@upi');
      expect(uri.queryParameters['am'], '420.00');
    });

    test('SupportedUpiApp lookups find by ID and package correctly', () {
      final gpay = UpiApps.findById('google_pay');
      expect(gpay, isNotNull);
      expect(gpay!.packageName, 'com.google.android.apps.nbu.paisa.user');

      final phonepe = UpiApps.findById('phonepe');
      expect(phonepe, isNotNull);
      expect(phonepe!.packageName, 'com.phonepe.app');

      final paytm = UpiApps.findById('paytm');
      expect(paytm, isNotNull);
      expect(paytm!.packageName, 'net.one97.paytm');

      final bhim = UpiApps.findById('bhim');
      expect(bhim, isNotNull);
      expect(bhim!.packageName, 'in.org.npci.upiapp');

      final amazon = UpiApps.findById('amazon_pay');
      expect(amazon, isNotNull);
      expect(amazon!.packageName, 'in.amazon.mShop.android.shopping');
    });
  });
}
