import 'package:flutter_test/flutter_test.dart';
import 'package:hulypay/Model/transaction_model.dart';

void main() {
  group('TransactionModel.formatMerchantName', () {
    test('formats raw merchant names without UPI handles directly', () {
      expect(TransactionModel.formatMerchantName('Starbucks Coffee'), 'Starbucks Coffee');
      expect(TransactionModel.formatMerchantName('Swiggy'), 'Swiggy');
      expect(TransactionModel.formatMerchantName('Zomato'), 'Zomato');
    });

    test('extracts and formats names from UPI ID / VPA handles', () {
      expect(TransactionModel.formatMerchantName('cafe_coffee_day@okhdfcbank'), 'Cafe Coffee Day');
      expect(TransactionModel.formatMerchantName('swiggy@icici'), 'Swiggy');
      expect(TransactionModel.formatMerchantName('john.doe@okaxis'), 'John Doe');
      expect(TransactionModel.formatMerchantName('sharma-sweets@paytm'), 'Sharma Sweets');
    });

    test('formats numeric UPI handles as Merchant (number)', () {
      expect(TransactionModel.formatMerchantName('9876543210@paytm'), 'Merchant (9876543210)');
    });

    test('falls back safely on null or empty input', () {
      expect(TransactionModel.formatMerchantName(null), 'UPI Merchant');
      expect(TransactionModel.formatMerchantName(''), 'UPI Merchant');
      expect(TransactionModel.formatMerchantName('   '), 'UPI Merchant');
      expect(TransactionModel.formatMerchantName('@okaxis'), 'UPI Merchant');
    });
  });

  group('TransactionModel.toTransactionItem', () {
    test('displays formatted merchant name instead of raw UPI ID', () {
      final tx1 = TransactionModel(
        id: 'tx_1',
        amount: 250.0,
        currency: 'INR',
        merchantName: 'cafe_coffee_day@okhdfcbank',
        upiId: 'cafe_coffee_day@okhdfcbank',
        status: 'SUCCESS',
      );
      final item1 = tx1.toTransactionItem();
      expect(item1.title, 'Cafe Coffee Day');

      final tx2 = TransactionModel(
        id: 'tx_2',
        amount: 150.0,
        currency: 'INR',
        merchantName: null,
        upiId: 'starbucks@icici',
        status: 'SUCCESS',
      );
      final item2 = tx2.toTransactionItem();
      expect(item2.title, 'Starbucks');

      final tx3 = TransactionModel(
        id: 'tx_3',
        amount: 80.0,
        currency: 'INR',
        merchantName: 'Blue Tokai',
        upiId: 'bt@okaxis',
        status: 'SUCCESS',
      );
      final item3 = tx3.toTransactionItem();
      expect(item3.title, 'Blue Tokai');
    });
  });
}
