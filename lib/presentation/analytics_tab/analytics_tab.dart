import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/expense_widget.dart';
import './widgets/insights_card_widget.dart';
import './widgets/metric_card_widget.dart';
import './widgets/profit_trend_chart_widget.dart';
import './widgets/time_period_selector_widget.dart';
import './widgets/top_products_chart_widget.dart';

class AnalyticsTab extends StatefulWidget {
  const AnalyticsTab({super.key});

  @override
  State<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<AnalyticsTab>
    with TickerProviderStateMixin {
  String _selectedPeriod = 'Today';
  final List<String> _periods = ['Today', 'Week', 'Month', 'Year'];

  // Mock data for analytics
  final List<Map<String, dynamic>> _mockMetrics = [
    {
      "title": "Today's Revenue",
      "value": "₱2,450.00",
      "subtitle": "From 15 transactions",
      "changePercentage": 12.5,
      "isPositive": true,
    },
    {
      "title": "Total Profit",
      "value": "₱1,230.00",
      "subtitle": "50.2% margin",
      "changePercentage": 8.3,
      "isPositive": true,
    },
    {
      "title": "Expenses",
      "value": "₱890.00",
      "subtitle": "Operational costs",
      "changePercentage": -5.2,
      "isPositive": false,
    },
    {
      "title": "Net Income",
      "value": "₱1,560.00",
      "subtitle": "After all expenses",
      "changePercentage": 15.7,
      "isPositive": true,
    },
  ];

  final List<Map<String, dynamic>> _mockProfitTrends = [
    {"label": "Mon", "value": 850.0},
    {"label": "Tue", "value": 1200.0},
    {"label": "Wed", "value": 980.0},
    {"label": "Thu", "value": 1450.0},
    {"label": "Fri", "value": 1680.0},
    {"label": "Sat", "value": 2100.0},
    {"label": "Sun", "value": 1890.0},
  ];

  final List<Map<String, dynamic>> _mockTopProducts = [
    {"name": "Coca Cola 1.5L", "quantity": 45.0},
    {"name": "Lucky Me Instant Noodles", "quantity": 38.0},
    {"name": "Bread Loaf", "quantity": 32.0},
    {"name": "Rice 5kg", "quantity": 28.0},
    {"name": "Cooking Oil 1L", "quantity": 25.0},
  ];

  final List<Map<String, dynamic>> _mockExpenseData = [
    {"category": "Inventory", "amount": 450.0},
    {"category": "Utilities", "amount": 180.0},
    {"category": "Transportation", "amount": 120.0},
    {"category": "Maintenance", "amount": 90.0},
    {"category": "Miscellaneous", "amount": 50.0},
  ];

  final List<Map<String, dynamic>> _mockInsights = [
    {
      "title": "Peak Sales Hour",
      "description":
          "Most sales happen between 5-7 PM. Consider stocking more during these hours.",
      "iconName": "schedule",
      "iconColor": Color(0xFF3498DB),
    },
    {
      "title": "Low Stock Alert",
      "description":
          "5 products are running low. Restock soon to avoid lost sales.",
      "iconName": "warning",
      "iconColor": Color(0xFFF39C12),
    },
    {
      "title": "Best Selling Category",
      "description": "Beverages account for 35% of your total sales this week.",
      "iconName": "local_drink",
      "iconColor": Color(0xFF27AE60),
    },
    {
      "title": "Profit Margin Trend",
      "description":
          "Your profit margin increased by 3.2% compared to last month.",
      "iconName": "trending_up",
      "iconColor": Color(0xFF27AE60),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final isLight = brightness == Brightness.light;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Analytics',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showReportsScreen,
            icon: CustomIconWidget(
              iconName: 'assessment',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            tooltip: 'Reports',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAnalytics,
        color: const Color(0xFF3498DB),
        child: CustomScrollView(
          slivers: [
            // Time Period Selector
            SliverToBoxAdapter(
              child: TimePeriodSelectorWidget(
                periods: _periods,
                selectedPeriod: _selectedPeriod,
                onPeriodChanged: _onPeriodChanged,
              ),
            ),

            // Key Metrics Cards
            SliverToBoxAdapter(
              child: SizedBox(
                height: 20.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  itemCount: _mockMetrics.length,
                  itemBuilder: (context, index) {
                    final metric = _mockMetrics[index];
                    return MetricCardWidget(
                      title: metric['title'] as String,
                      value: metric['value'] as String,
                      subtitle: metric['subtitle'] as String?,
                      changePercentage: metric['changePercentage'] as double?,
                      isPositive: metric['isPositive'] as bool,
                      onTap: () => _showMetricDetails(metric),
                    );
                  },
                ),
              ),
            ),

            // Profit Trend Chart
            SliverToBoxAdapter(
              child: ProfitTrendChartWidget(
                chartData: _getProfitTrendsForPeriod(),
                period: _selectedPeriod,
              ),
            ),

            // Top Products Chart
            SliverToBoxAdapter(
              child: TopProductsChartWidget(
                productData: _mockTopProducts,
              ),
            ),

            // Expense Breakdown Chart
            SliverToBoxAdapter(
              child: ExpenseBreakdownChartWidget(
                expenseData: _mockExpenseData,
              ),
            ),

            // Business Insights Section
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Text(
                  'Business Insights',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),

            // Insights Cards
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final insight = _mockInsights[index];
                  return InsightsCardWidget(
                    title: insight['title'] as String,
                    description: insight['description'] as String,
                    iconName: insight['iconName'] as String,
                    iconColor: insight['iconColor'] as Color?,
                    onTap: () => _showInsightDetails(insight),
                  );
                },
                childCount: _mockInsights.length,
              ),
            ),

            // Bottom padding for floating action button
            SliverToBoxAdapter(
              child: SizedBox(height: 10.h),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 1, // Analytics tab is at index 1
        onTap: _onBottomNavTap,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showReportsScreen,
        backgroundColor:
            isLight ? const Color(0xFF2C3E50) : const Color(0xFF34495E),
        foregroundColor: Colors.white,
        tooltip: 'Generate Reports',
        child: CustomIconWidget(
          iconName: 'file_download',
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  void _onPeriodChanged(String period) {
    setState(() {
      _selectedPeriod = period;
    });
    _refreshAnalytics();
  }

  Future<void> _refreshAnalytics() async {
    // Simulate data refresh
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Analytics updated for $_selectedPeriod'),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF27AE60),
        ),
      );
    }
  }

  List<Map<String, dynamic>> _getProfitTrendsForPeriod() {
    switch (_selectedPeriod) {
      case 'Today':
        return [
          {"label": "6AM", "value": 120.0},
          {"label": "9AM", "value": 280.0},
          {"label": "12PM", "value": 450.0},
          {"label": "3PM", "value": 380.0},
          {"label": "6PM", "value": 680.0},
          {"label": "9PM", "value": 530.0},
        ];
      case 'Week':
        return _mockProfitTrends;
      case 'Month':
        return [
          {"label": "Week 1", "value": 8500.0},
          {"label": "Week 2", "value": 9200.0},
          {"label": "Week 3", "value": 7800.0},
          {"label": "Week 4", "value": 10500.0},
        ];
      case 'Year':
        return [
          {"label": "Q1", "value": 35000.0},
          {"label": "Q2", "value": 42000.0},
          {"label": "Q3", "value": 38000.0},
          {"label": "Q4", "value": 45000.0},
        ];
      default:
        return _mockProfitTrends;
    }
  }

  void _onBottomNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/products-tab');
        break;
      case 1:
        // Already on Analytics tab
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/stock-management-tab');
        break;
    }
  }

  void _showReportsScreen() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildReportsModal(),
    );
  }

  Widget _buildReportsModal() {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final isLight = brightness == Brightness.light;

    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.only(top: 2.h),
            decoration: BoxDecoration(
              color:
                  isLight ? const Color(0xFF95A5A6) : const Color(0xFF95A5A6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Text(
              'Generate Reports',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              children: [
                _buildReportOption(
                  'Sales Report',
                  'Detailed sales analysis and trends',
                  'bar_chart',
                  () => _generateReport('Sales'),
                ),
                _buildReportOption(
                  'Profit & Loss Report',
                  'Complete financial overview',
                  'account_balance',
                  () => _generateReport('P&L'),
                ),
                _buildReportOption(
                  'Inventory Report',
                  'Stock levels and movement analysis',
                  'inventory',
                  () => _generateReport('Inventory'),
                ),
                _buildReportOption(
                  'Customer Analysis',
                  'Customer behavior and preferences',
                  'people',
                  () => _generateReport('Customer'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportOption(
      String title, String description, String iconName, VoidCallback onTap) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final isLight = brightness == Brightness.light;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: ListTile(
        leading: Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: const Color(0xFF3498DB).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: iconName,
              color: const Color(0xFF3498DB),
              size: 24,
            ),
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isLight ? const Color(0xFF7F8C8D) : const Color(0xFFBDC3C7),
          ),
        ),
        trailing: CustomIconWidget(
          iconName: 'download',
          color: const Color(0xFF3498DB),
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }

  void _generateReport(String reportType) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Generating $reportType report...'),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF3498DB),
      ),
    );
  }

  void _showMetricDetails(Map<String, dynamic> metric) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(metric['title'] as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Value: ${metric['value']}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (metric['subtitle'] != null) ...[
              SizedBox(height: 1.h),
              Text('Details: ${metric['subtitle']}'),
            ],
            if (metric['changePercentage'] != null) ...[
              SizedBox(height: 1.h),
              Text(
                'Change: ${metric['isPositive'] ? '+' : ''}${metric['changePercentage']}%',
                style: TextStyle(
                  color: metric['isPositive']
                      ? const Color(0xFF27AE60)
                      : const Color(0xFFE74C3C),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showInsightDetails(Map<String, dynamic> insight) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(insight['title'] as String),
        content: Text(insight['description'] as String),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
