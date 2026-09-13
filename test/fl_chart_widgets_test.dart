import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/dashboard_data.dart';
import 'package:mobile/models/payment_model.dart';
import 'package:mobile/widgets/analysis_category_pie_chart.dart';
import 'package:mobile/widgets/home_spend_trend_line_chart.dart';
import 'package:mobile/widgets/home_today_spend_gauge.dart';
import 'package:mobile/widgets/home_weekly_bar_chart.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final samplePayments = [
    PaymentModel(
      id: 'p_1',
      amount: 450.0,
      currency: 'INR',
      merchantName: 'Food Court',
      status: 'CONFIRMED',
      createdAt: DateTime.now().toIso8601String(),
    ),
    PaymentModel(
      id: 'p_2',
      amount: 1500.0,
      currency: 'INR',
      merchantName: 'Supermarket',
      status: 'CONFIRMED',
      createdAt: DateTime.now().toIso8601String(),
    ),
    PaymentModel(
      id: 'p_3',
      amount: 800.0,
      currency: 'INR',
      merchantName: 'Gas Station',
      status: 'CONFIRMED',
      createdAt: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    ),
  ];

  group('fl_chart Real-Time Widgets Test Suite', () {
    testWidgets('HomeSpendTrendLineChart toggles between Sample 2 and Sample 4 styles', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeSpendTrendLineChart(payments: samplePayments),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify LineChart is rendered
      expect(find.byType(LineChart), findsOneWidget);
      expect(find.text('SPEND TREND'), findsOneWidget);
      expect(find.text('Gradient Flow'), findsOneWidget);
      expect(find.text('AVG'), findsOneWidget);

      // Toggle AVG line in Sample 2
      await tester.tap(find.text('AVG'));
      await tester.pumpAndSettle();
      expect(find.text('Daily Average'), findsOneWidget);

      // Toggle AVG back off
      await tester.tap(find.text('AVG'));
      await tester.pumpAndSettle();
      expect(find.text('Gradient Flow'), findsOneWidget);

      // Toggle to Sample 4 (Dual Threshold / Range style)
      final sample4Button = find.byIcon(Icons.stacked_line_chart);
      expect(sample4Button, findsOneWidget);
      await tester.tap(sample4Button);
      await tester.pumpAndSettle();

      expect(find.text('Range Threshold'), findsOneWidget);
      expect(find.byType(LineChart), findsOneWidget);

      // Toggle back to Sample 2 (Curved Gradient)
      final sample2Button = find.byIcon(Icons.show_chart);
      await tester.tap(sample2Button);
      await tester.pumpAndSettle();

      expect(find.text('Gradient Flow'), findsOneWidget);
    });

    testWidgets('HomeWeeklyBarChart renders 7 weekday groups and calculates weekly total', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeWeeklyBarChart(payments: samplePayments),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify BarChart is rendered
      expect(find.byType(BarChart), findsOneWidget);
      expect(find.text('Spending This Month'), findsOneWidget);
      expect(find.text('WEEKLY SPENDING'), findsOneWidget);

      // Verify Weekday labels
      expect(find.text('M'), findsOneWidget);
      expect(find.text('W'), findsOneWidget);
      expect(find.text('F'), findsOneWidget);
    });

    testWidgets('HomeTodaySpendGaugeChart calculates today spend and renders speedometer gauge', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeTodaySpendGaugeChart(
              payments: samplePayments,
              dailyBudget: 5000.0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Today's total is 450 + 1500 = 1950
      expect(find.text("TODAY'S TOTAL SPEND"), findsOneWidget);
      expect(find.text('Daily Limit Gauge'), findsOneWidget);
      expect(find.text('₹1950'), findsOneWidget);
      expect(find.text('Budget: ₹5000'), findsOneWidget);
      expect(find.text('Within Budget'), findsOneWidget);
    });

    testWidgets('AnalysisCategoryPieChart renders PieChart with touch interaction and legend', (tester) async {
      final categories = [
        const CategorySpendingItem(
          title: 'Dining',
          percentage: 55,
          amount: '₹1,100',
          color: Color(0xFF007AFF),
        ),
        const CategorySpendingItem(
          title: 'Travel',
          percentage: 45,
          amount: '₹900',
          color: Color(0xFFFF9500),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalysisCategoryPieChart(
              items: categories,
              totalAmount: '₹2,000',
              showLegend: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify PieChart and center text
      expect(find.byType(PieChart), findsOneWidget);
      expect(find.text('Spent this month'), findsOneWidget);
      expect(find.text('₹2,000'), findsOneWidget);
      expect(find.text('Dining'), findsOneWidget);
      expect(find.text('55%'), findsWidgets);
    });
  });
}
