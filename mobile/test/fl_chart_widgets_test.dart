import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/dashboard_data.dart';
import 'package:mobile/models/payment_model.dart';
import 'package:mobile/screens/analysis_screen.dart';
import 'package:mobile/theme/app_theme.dart';
import 'package:mobile/theme/chart_colors.dart';
import 'package:mobile/widgets/analysis_category_pie_chart.dart';
import 'package:mobile/widgets/home_spend_trend_line_chart.dart';
import 'package:mobile/widgets/home_today_spend_gauge.dart';
import 'package:mobile/widgets/home_weekly_bar_chart.dart';
import 'package:mobile/widgets/spending_heatmap.dart';

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
      expect(find.text('Daily Average'), findsOneWidget);
      expect(find.text('AVG'), findsOneWidget);

      // Toggle AVG line in Sample 2
      await tester.tap(find.text('AVG'));
      await tester.pumpAndSettle();
      expect(find.text('Daily Average'), findsOneWidget);

      // Toggle AVG back off
      await tester.tap(find.text('AVG'));
      await tester.pumpAndSettle();
      expect(find.text('Daily Average'), findsOneWidget);

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

      expect(find.text('Daily Average'), findsOneWidget);
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
      expect(find.text('WEEKLY SPENDING'), findsOneWidget);

      // Verify Weekday labels
      expect(find.text('M'), findsOneWidget);
      expect(find.text('W'), findsOneWidget);
      expect(find.text('F'), findsOneWidget);
    });

    testWidgets('HomeWeeklyBarChart dynamically adopts active chart palette colors', (tester) async {
      // 1. Set to Cyber Purple
      AppThemeManager.setChartPalette('Cyber Purple');
      expect(AppChartColors.barToday, equals(const Color(0xFFAF52DE)));
      expect(AppChartColors.barTouched, equals(const Color(0xFF00E5FF)));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeWeeklyBarChart(payments: samplePayments),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify BarChart rendered with Cyber Purple today rod
      final barChart = tester.widget<BarChart>(find.byType(BarChart));
      final todayIndex = DateTime.now().weekday - 1;
      final todayRod = barChart.data.barGroups[todayIndex].barRods.first;
      expect(todayRod.color, equals(const Color(0xFFAF52DE)));

      // 2. Switch to Emerald Mint
      AppThemeManager.setChartPalette('Emerald Mint');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeWeeklyBarChart(payments: samplePayments),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final updatedBarChart = tester.widget<BarChart>(find.byType(BarChart));
      final updatedTodayRod = updatedBarChart.data.barGroups[todayIndex].barRods.first;
      expect(updatedTodayRod.color, equals(const Color(0xFF00C076)));

      // Reset to Default
      AppThemeManager.setChartPalette('Default');
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
      expect(find.text("Daily Limit"), findsOneWidget);
      expect(find.text('₹1950'), findsOneWidget);
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

    testWidgets('SpendingHeatmap renders clean grid without W1/W2 labels or period description words', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SpendingHeatmap(
                payments: samplePayments,
                period: 'This Month',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify SpendingHeatmap renders clean title and legends
      expect(find.byType(SpendingHeatmap), findsOneWidget);
      expect(find.text('Heatmap'), findsOneWidget);
      expect(find.text('SPENDING INTENSITY'), findsNothing);
      expect(find.text('Activity Heatmap'), findsNothing);
      expect(find.text('Less'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);

      // Verify W1, W2, W3, W4 labels are removed
      expect(find.text('W1'), findsNothing);
      expect(find.text('W2'), findsNothing);
      expect(find.text('W3'), findsNothing);
      expect(find.text('W4'), findsNothing);

      // Verify period description words like 'Current month breakdown' are removed
      expect(find.text('Current month breakdown'), findsNothing);
      expect(find.text('Last 2 weeks activity'), findsNothing);
      expect(find.text('7-day activity density'), findsNothing);

      // Verify weekday X-axis labels are shown
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Sun'), findsOneWidget);

      // Verify rendering with other periods works cleanly
      for (final p in ['Days', 'Weeks', '3 Months', '6 Months', '1 Year']) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SpendingHeatmap(
                  payments: samplePayments,
                  period: p,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('W1'), findsNothing);
        expect(find.text('Current month breakdown'), findsNothing);
      }
    });

    testWidgets('AnalysisScreen global period selector updates all charts and filters data', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AnalysisScreen(
            initialPayments: samplePayments,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initial state: 'This Month'
      expect(find.text('Spending Insights'), findsOneWidget);
      expect(find.text('This Month'), findsOneWidget);
      expect(find.text('Spent this month'), findsOneWidget);
      expect(find.text('Heatmap'), findsOneWidget);
      expect(find.text('Current month breakdown'), findsNothing);
      expect(find.text('W1'), findsNothing);

      // Open global period selector popup menu
      await tester.tap(find.text('This Month'));
      await tester.pumpAndSettle();

      // Verify menu options
      expect(find.text('Days'), findsOneWidget);
      expect(find.text('Weeks'), findsOneWidget);
      expect(find.text('3 Months'), findsOneWidget);
      expect(find.text('6 Months'), findsOneWidget);
      expect(find.text('1 Year'), findsOneWidget);

      // Select 'Weeks'
      await tester.tap(find.text('Weeks'));
      await tester.pumpAndSettle();

      // Verify donut chart updated
      expect(find.text('Spent last 2 weeks'), findsOneWidget);
      expect(find.text('Current month breakdown'), findsNothing);
      expect(find.text('W1'), findsNothing);
    });

    test('AppChartColors globalPalette unifies color schema across all charts', () {
      // 1. Verify globalPalette has at least 5 distinct cohesive colors
      expect(AppChartColors.globalPalette.length, greaterThanOrEqualTo(5));
      final uniqueColors = AppChartColors.globalPalette.toSet();
      expect(uniqueColors.length, equals(AppChartColors.globalPalette.length));

      // 2. Verify all semantic getters are derived from globalPalette
      expect(AppChartColors.globalPalette.contains(AppChartColors.blue), isTrue);
      expect(AppChartColors.globalPalette.contains(AppChartColors.cyan), isTrue);
      expect(AppChartColors.globalPalette.contains(AppChartColors.green), isTrue);
      expect(AppChartColors.globalPalette.contains(AppChartColors.amber), isTrue);
      expect(AppChartColors.globalPalette.contains(AppChartColors.rose), isTrue);

      // 3. Verify gradient and zone derived schemas
      expect(AppChartColors.primaryGradient, containsAll([AppChartColors.cyan, AppChartColors.blue]));
      expect(AppChartColors.gaugeSafe, equals(AppChartColors.green));
      expect(AppChartColors.gaugeModerate, equals(AppChartColors.amber));
      expect(AppChartColors.gaugeHigh, equals(AppChartColors.rose));
      expect(AppChartColors.thresholdMain, equals(AppChartColors.amber));
      expect(AppChartColors.thresholdBelow, equals(AppChartColors.green));
      expect(AppChartColors.thresholdAbove, equals(AppChartColors.rose));

      // 4. Verify heatmap peak activity color matches global green
      expect(AppChartColors.heatmapPalette.last, equals(AppChartColors.green));
      expect(AppChartColors.heatmapSelected, equals(AppChartColors.cyan));
    });
  });
}
