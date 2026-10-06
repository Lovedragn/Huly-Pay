import 'package:flutter_test/flutter_test.dart';
import 'package:hulypay/services/qr_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QrService.injectAmountIntoUpiUri', () {
    test('appends am to clean URI without am', () {
      const uri = 'upi://pay?pa=merchant@okaxis&pn=Merchant';
      final result = QrService.injectAmountIntoUpiUri(uri, 150.0);
      expect(result, 'upi://pay?pa=merchant@okaxis&pn=Merchant&am=150.00');
    });

    test('replaces existing am parameter', () {
      const uri = 'upi://pay?pa=merchant@okaxis&am=10.00&pn=Merchant';
      final result = QrService.injectAmountIntoUpiUri(uri, 250.5);
      expect(result, 'upi://pay?pa=merchant@okaxis&am=250.50&pn=Merchant');
    });

    test('replaces existing am at the end', () {
      const uri = 'upi://pay?pa=merchant@okaxis&pn=Merchant&am=99.00';
      final result = QrService.injectAmountIntoUpiUri(uri, 50.0);
      expect(result, 'upi://pay?pa=merchant@okaxis&pn=Merchant&am=50.00');
    });

    test('replaces existing am as only parameter', () {
      const uri = 'upi://pay?am=1.00';
      final result = QrService.injectAmountIntoUpiUri(uri, 500.0);
      expect(result, 'upi://pay?am=500.00');
    });

    test('handles URI without any query parameters', () {
      const uri = 'upi://pay';
      final result = QrService.injectAmountIntoUpiUri(uri, 75.0);
      expect(result, 'upi://pay?am=75.00');
    });

    test('decodes percent encoded URI correctly', () {
      const uri = 'upi://pay%3Fpa%3Dmerchant@okaxis%26pn%3DTest%20Store';
      final result = QrService.injectAmountIntoUpiUri(uri, 100.0);
      expect(result, contains('am=100.00'));
      expect(result, contains('pa=merchant@okaxis'));
    });
  });
}
