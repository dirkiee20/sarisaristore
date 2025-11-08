import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ExpenseBreakdownChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> expenseData;

  const ExpenseBreakdownChartWidget({
    super.key,
    required this.expenseData,
  });

  @override
  State<ExpenseBreakdownChartWidget> createState() =>
      _ExpenseBreakdownChartWidgetState();
}

class _ExpenseBreakdownChartWidgetState
    extends State<ExpenseBreakdownChartWidget> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final isLight = brightness == Brightness.light;

    return Container(
      width: double.infinity,
      height: 35.h,
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isLight ? const Color(0x0A000000) : const Color(0x1A000000),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Expense Breakdown',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              CustomIconWidget(
                iconName: 'pie_chart',
                color:
                    isLight ? const Color(0xFF3498DB) : const Color(0xFF3498DB),
                size: 20,
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Expanded(
            child: widget.expenseData.isEmpty
                ? _buildEmptyState(theme)
                : Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildChart(theme),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        flex: 2,
                        child: _buildLegend(theme),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'account_balance_wallet',
            color: const Color(0xFF95A5A6),
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'No expense data available',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF95A5A6),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Track expenses to see breakdown',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF95A5A6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(ThemeData theme) {
    return Semantics(
      label: "Pie chart showing expense breakdown by category",
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback:
                (FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
              setState(() {
                if (pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  touchedIndex = -1;
                  return;
                }
                touchedIndex =
                    pieTouchResponse.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          borderData: FlBorderData(show: false),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: _buildPieChartSections(),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final total = widget.expenseData.fold<double>(
      0,
      (sum, expense) => sum + (expense['amount'] as double),
    );

    return widget.expenseData.asMap().entries.map((entry) {
      final index = entry.key;
      final expense = entry.value;
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 14.sp : 12.sp;
      final radius = isTouched ? 65.0 : 55.0;
      final amount = expense['amount'] as double;
      final percentage = (amount / total * 100);

      return PieChartSectionData(
        color: _getSectionColor(index),
        value: amount,
        title: isTouched ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: isTouched
            ? _buildBadge(expense['category'] as String, amount)
            : null,
        badgePositionPercentageOffset: 1.3,
      );
    }).toList();
  }

  Widget _buildBadge(String category, double amount) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            category,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C3E50),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '₱${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 9.sp,
              color: const Color(0xFF7F8C8D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(ThemeData theme) {
    final total = widget.expenseData.fold<double>(
      0,
      (sum, expense) => sum + (expense['amount'] as double),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        Expanded(
          child: ListView.builder(
            itemCount: widget.expenseData.length,
            itemBuilder: (context, index) {
              final expense = widget.expenseData[index];
              final amount = expense['amount'] as double;
              final percentage = (amount / total * 100);

              return Container(
                margin: EdgeInsets.only(bottom: 1.5.h),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getSectionColor(index),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense['category'] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.2.h),
                          Text(
                            '₱${amount.toStringAsFixed(2)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF7F8C8D),
                              fontSize: 9.sp,
                            ),
                          ),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF95A5A6),
                              fontSize: 8.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getSectionColor(int index) {
    final colors = [
      const Color(0xFFE74C3C), // Red for high expenses
      const Color(0xFFF39C12), // Orange for medium expenses
      const Color(0xFF3498DB), // Blue for operational
      const Color(0xFF27AE60), // Green for utilities
      const Color(0xFF9B59B6), // Purple for miscellaneous
      const Color(0xFF34495E), // Dark blue for inventory
      const Color(0xFF1ABC9C), // Teal for marketing
      const Color(0xFFE67E22), // Orange for maintenance
    ];

    return colors[index % colors.length];
  }
}
