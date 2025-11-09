import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../services/analytics_service.dart';
import '../../services/demo_mode_service.dart';
import '../../services/file_service.dart';
import '../../services/product_service.dart';
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
  final AnalyticsService _analyticsService = AnalyticsService();
  final DemoModeService _demoModeService = DemoModeService();
  bool _isLoading = true;

  // Real data
  List<Map<String, dynamic>> _metrics = [];
  List<Map<String, dynamic>> _profitTrends = [];
  List<Map<String, dynamic>> _topProducts = [];
  List<Map<String, dynamic>> _expenseData = [];
  List<Map<String, dynamic>> _insights = [];

  @override
  void initState() {
    super.initState();
    _demoModeService.addListener(_onDemoModeChanged);
    _loadAnalyticsData();
  }

  @override
  void dispose() {
    _demoModeService.removeListener(_onDemoModeChanged);
    super.dispose();
  }

  void _onDemoModeChanged() {
    // Reload data when demo mode changes
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_demoModeService.isDemoMode) {
        // Use demo data
        _loadDemoAnalyticsData();
        setState(() {
          _isLoading = false;
        });
      } else {
        await _loadRealAnalyticsData();
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      // Fallback to demo mode on error
      _demoModeService.setDemoMode(true);
      _loadDemoAnalyticsData();
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRealAnalyticsData() async {
    final revenue =
        await _analyticsService.getRevenueForPeriod(_selectedPeriod);
    final profit = await _analyticsService.getProfitForPeriod(_selectedPeriod);
    final expenses =
        await _analyticsService.getExpensesForPeriod(_selectedPeriod);
    final netIncome =
        await _analyticsService.getNetIncomeForPeriod(_selectedPeriod);
    final transactionCount =
        await _analyticsService.getTransactionCountForPeriod(_selectedPeriod);
    final profitMargin =
        await _analyticsService.getProfitMarginForPeriod(_selectedPeriod);

    final profitTrends =
        await _analyticsService.getProfitTrendsForPeriod(_selectedPeriod);
    final topProducts =
        await _analyticsService.getTopProductsForPeriod(_selectedPeriod);
    final expenseCategories =
        await _analyticsService.getExpensesByCategoryForPeriod(_selectedPeriod);
    final lowStockCount = await _analyticsService.getLowStockProductsCount();

    setState(() {
      _metrics = [
        {
          "title": "Today's Revenue",
          "value": "₱${revenue.toStringAsFixed(2)}",
          "subtitle": "From $transactionCount transactions",
          "changePercentage": 0.0, // Would need previous period comparison
          "isPositive": true,
        },
        {
          "title": "Total Profit",
          "value": "₱${profit.toStringAsFixed(2)}",
          "subtitle": "${profitMargin.toStringAsFixed(1)}% margin",
          "changePercentage": 0.0,
          "isPositive": true,
        },
        {
          "title": "Expenses",
          "value": "₱${expenses.toStringAsFixed(2)}",
          "subtitle": "Operational costs",
          "changePercentage": 0.0,
          "isPositive": false,
        },
        {
          "title": "Net Income",
          "value": "₱${netIncome.toStringAsFixed(2)}",
          "subtitle": "After all expenses",
          "changePercentage": 0.0,
          "isPositive": netIncome >= 0,
        },
      ];

      _profitTrends = profitTrends;
      _topProducts = topProducts;

      _expenseData = expenseCategories.entries
          .map((entry) => {
                "category": entry.key,
                "amount": entry.value,
              })
          .toList();

      _insights = [
        {
          "title": "Low Stock Alert",
          "description":
              "$lowStockCount products are running low. Restock soon to avoid lost sales.",
          "iconName": "warning",
          "iconColor": const Color(0xFFF39C12),
        },
        {
          "title": "Profit Margin",
          "description":
              "Current profit margin is ${profitMargin.toStringAsFixed(1)}% for $_selectedPeriod.",
          "iconName": "trending_up",
          "iconColor": const Color(0xFF27AE60),
        },
        {
          "title": "Top Performing Period",
          "description":
              "Analytics for $_selectedPeriod show ${transactionCount} transactions.",
          "iconName": "bar_chart",
          "iconColor": const Color(0xFF3498DB),
        },
      ];
    });
  }

  void _loadDemoAnalyticsData() {
    setState(() {
      _metrics = [
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

      _profitTrends = [
        {"label": "Mon", "value": 850.0},
        {"label": "Tue", "value": 1200.0},
        {"label": "Wed", "value": 980.0},
        {"label": "Thu", "value": 1450.0},
        {"label": "Fri", "value": 1680.0},
        {"label": "Sat", "value": 2100.0},
        {"label": "Sun", "value": 1890.0},
      ];

      _topProducts = [
        {"name": "Coca Cola 1.5L", "quantity": 45.0},
        {"name": "Lucky Me Instant Noodles", "quantity": 38.0},
        {"name": "Bread Loaf", "quantity": 32.0},
        {"name": "Rice 5kg", "quantity": 28.0},
        {"name": "Cooking Oil 1L", "quantity": 25.0},
      ];

      _expenseData = [
        {"category": "Inventory", "amount": 450.0},
        {"category": "Utilities", "amount": 180.0},
        {"category": "Transportation", "amount": 120.0},
        {"category": "Maintenance", "amount": 90.0},
        {"category": "Miscellaneous", "amount": 50.0},
      ];

      _insights = [
        {
          "title": "Peak Sales Hour",
          "description":
              "Most sales happen between 5-7 PM. Consider stocking more during these hours.",
          "iconName": "schedule",
          "iconColor": const Color(0xFF3498DB),
        },
        {
          "title": "Low Stock Alert",
          "description":
              "5 products are running low. Restock soon to avoid lost sales.",
          "iconName": "warning",
          "iconColor": const Color(0xFFF39C12),
        },
        {
          "title": "Best Selling Category",
          "description":
              "Beverages account for 35% of your total sales this week.",
          "iconName": "local_drink",
          "iconColor": const Color(0xFF27AE60),
        },
        {
          "title": "Profit Margin Trend",
          "description":
              "Your profit margin increased by 3.2% compared to last month.",
          "iconName": "trending_up",
          "iconColor": const Color(0xFF27AE60),
        },
      ];
    });
  }

  void _switchToDemoMode() {
    _demoModeService.setDemoMode(true);
  }

  void _switchToDatabaseMode() async {
    _demoModeService.setDemoMode(false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final isLight = brightness == Brightness.light;

    if (_isLoading) {
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
        ),
        body: const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: CustomBottomBar(
          currentIndex: 1,
          showDemoToggle: true,
          onTap: _onBottomNavTap,
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Analytics${_demoModeService.isDemoMode ? " (Demo)" : ""}',
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
                  itemCount: _metrics.length,
                  itemBuilder: (context, index) {
                    final metric = _metrics[index];
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
                productData: _topProducts,
              ),
            ),

            // Expense Breakdown Chart
            SliverToBoxAdapter(
              child: ExpenseBreakdownChartWidget(
                expenseData: _expenseData,
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
                  final insight = _insights[index];
                  return InsightsCardWidget(
                    title: insight['title'] as String,
                    description: insight['description'] as String,
                    iconName: insight['iconName'] as String,
                    iconColor: insight['iconColor'] as Color?,
                    onTap: () => _showInsightDetails(insight),
                  );
                },
                childCount: _insights.length,
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
    if (!_demoModeService.isDemoMode) {
      _loadRealAnalyticsData();
    }
  }

  Future<void> _refreshAnalytics() async {
    if (_demoModeService.isDemoMode) {
      // Simulate refresh for demo mode
      await Future.delayed(const Duration(milliseconds: 1500));
    } else {
      // Refresh real data
      await _loadRealAnalyticsData();
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Analytics updated for $_selectedPeriod${_demoModeService.isDemoMode ? " (Demo)" : ""}'),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF27AE60),
        ),
      );
    }
  }

  List<Map<String, dynamic>> _getProfitTrendsForPeriod() {
    if (_demoModeService.isDemoMode) {
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
          return _profitTrends;
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
          return _profitTrends;
      }
    } else {
      return _profitTrends;
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

  Future<void> _generateReport(String reportType) async {
    Navigator.pop(context);

    try {
      // Show loading message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Generating $reportType report...'),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF3498DB),
        ),
      );

      // Generate report content based on type
      String reportContent;
      String fileName;
      String extension = 'csv'; // Default to CSV

      switch (reportType) {
        case 'Sales':
          reportContent = await _generateSalesReport();
          fileName =
              'sales_report_${_selectedPeriod.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}';
          break;
        case 'P&L':
          reportContent = await _generateProfitLossReport();
          fileName =
              'profit_loss_report_${_selectedPeriod.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}';
          break;
        case 'Inventory':
          reportContent = await _generateInventoryReport();
          fileName =
              'inventory_report_${DateTime.now().millisecondsSinceEpoch}';
          break;
        case 'Customer':
          reportContent = await _generateCustomerReport();
          fileName =
              'customer_report_${_selectedPeriod.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}';
          break;
        default:
          throw Exception('Unknown report type: $reportType');
      }

      // Save report to file
      final filePath = await FileService.saveReportToFile(
        reportContent,
        fileName,
        extension,
      );

      if (filePath != null) {
        // Show success message with share option
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: Colors.white,
                  size: 5.w,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text('$reportType report saved successfully!'),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF27AE60),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Share',
              textColor: Colors.white,
              onPressed: () async {
                try {
                  await FileService.shareFile(filePath, '$reportType Report');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to share report: $e'),
                      backgroundColor: const Color(0xFFE74C3C),
                    ),
                  );
                }
              },
            ),
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Failed to save report. Please check storage permissions.'),
            backgroundColor: Color(0xFFE74C3C),
          ),
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate report: $e'),
          backgroundColor: const Color(0xFFE74C3C),
        ),
      );
    }
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

  Future<String> _generateSalesReport() async {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('SALES REPORT');
    buffer.writeln('Period: $_selectedPeriod');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('');

    // Summary metrics
    final revenue =
        await _analyticsService.getRevenueForPeriod(_selectedPeriod);
    final transactionCount =
        await _analyticsService.getTransactionCountForPeriod(_selectedPeriod);
    final profit = await _analyticsService.getProfitForPeriod(_selectedPeriod);

    buffer.writeln('SUMMARY:');
    buffer.writeln('Total Revenue: ₱${revenue.toStringAsFixed(2)}');
    buffer.writeln('Total Transactions: $transactionCount');
    buffer.writeln('Total Profit: ₱${profit.toStringAsFixed(2)}');
    buffer.writeln('');

    // Top products
    final topProducts =
        await _analyticsService.getTopProductsForPeriod(_selectedPeriod);
    buffer.writeln('TOP PRODUCTS:');
    buffer.writeln('Product Name,Quantity Sold');
    for (final product in topProducts) {
      buffer.writeln('"${product['name']}","${product['quantity']}"');
    }
    buffer.writeln('');

    // Profit trends
    final profitTrends =
        await _analyticsService.getProfitTrendsForPeriod(_selectedPeriod);
    buffer.writeln('PROFIT TRENDS:');
    buffer.writeln('Period,Profit Amount');
    for (final trend in profitTrends) {
      buffer.writeln(
          '"${trend['label']}","₱${(trend['value'] as double).toStringAsFixed(2)}"');
    }

    return buffer.toString();
  }

  Future<String> _generateProfitLossReport() async {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('PROFIT & LOSS REPORT');
    buffer.writeln('Period: $_selectedPeriod');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('');

    // Financial summary
    final revenue =
        await _analyticsService.getRevenueForPeriod(_selectedPeriod);
    final profit = await _analyticsService.getProfitForPeriod(_selectedPeriod);
    final expenses =
        await _analyticsService.getExpensesForPeriod(_selectedPeriod);
    final netIncome =
        await _analyticsService.getNetIncomeForPeriod(_selectedPeriod);
    final profitMargin =
        await _analyticsService.getProfitMarginForPeriod(_selectedPeriod);

    buffer.writeln('FINANCIAL SUMMARY:');
    buffer.writeln('Total Revenue: ₱${revenue.toStringAsFixed(2)}');
    buffer.writeln('Total Expenses: ₱${expenses.toStringAsFixed(2)}');
    buffer.writeln('Gross Profit: ₱${profit.toStringAsFixed(2)}');
    buffer.writeln('Net Income: ₱${netIncome.toStringAsFixed(2)}');
    buffer.writeln('Profit Margin: ${profitMargin.toStringAsFixed(1)}%');
    buffer.writeln('');

    // Expense breakdown
    final expenseCategories =
        await _analyticsService.getExpensesByCategoryForPeriod(_selectedPeriod);
    buffer.writeln('EXPENSE BREAKDOWN:');
    buffer.writeln('Category,Amount');
    expenseCategories.forEach((category, amount) {
      buffer.writeln(
          '"${category.replaceAll(',', ';')}","₱${amount.toStringAsFixed(2)}"');
    });

    return buffer.toString();
  }

  Future<String> _generateInventoryReport() async {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('INVENTORY REPORT');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('');

    // Get all products from product service
    final productService = ProductService();
    final products = await productService.getAllProducts();

    buffer.writeln('PRODUCT INVENTORY:');
    buffer.writeln(
        'Product Name,Category,Current Stock,Cost Price,Selling Price,Total Value');

    double totalValue = 0;
    for (final product in products) {
      final productValue = product.sellingPrice * product.stock;
      totalValue += productValue;

      buffer.writeln(
          '"${product.name.replaceAll('"', '""')}","${product.category}","${product.stock}","₱${product.costPrice.toStringAsFixed(2)}","₱${product.sellingPrice.toStringAsFixed(2)}","₱${productValue.toStringAsFixed(2)}"');
    }

    buffer.writeln('');
    buffer.writeln('SUMMARY:');
    buffer.writeln('Total Products: ${products.length}');
    buffer.writeln('Total Inventory Value: ₱${totalValue.toStringAsFixed(2)}');

    // Low stock items
    final lowStockProducts = products.where((p) => p.stock <= 10).toList();
    if (lowStockProducts.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('LOW STOCK ITEMS (≤10 units):');
      buffer.writeln('Product Name,Current Stock');
      for (final product in lowStockProducts) {
        buffer.writeln(
            '"${product.name.replaceAll('"', '""')}","${product.stock}"');
      }
    }

    return buffer.toString();
  }

  Future<String> _generateCustomerReport() async {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('CUSTOMER ANALYSIS REPORT');
    buffer.writeln('Period: $_selectedPeriod');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('');

    // Transaction analysis
    final transactionCount =
        await _analyticsService.getTransactionCountForPeriod(_selectedPeriod);
    final revenue =
        await _analyticsService.getRevenueForPeriod(_selectedPeriod);

    buffer.writeln('TRANSACTION ANALYSIS:');
    buffer.writeln('Total Transactions: $transactionCount');
    buffer.writeln('Total Revenue: ₱${revenue.toStringAsFixed(2)}');

    if (transactionCount > 0) {
      final avgTransactionValue = revenue / transactionCount;
      buffer.writeln(
          'Average Transaction Value: ₱${avgTransactionValue.toStringAsFixed(2)}');
    }

    buffer.writeln('');
    buffer.writeln(
        'NOTE: Detailed customer data requires additional customer management features.');
    buffer.writeln('This report provides basic transaction analysis.');

    return buffer.toString();
  }
}
