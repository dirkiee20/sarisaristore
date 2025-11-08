import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class TopProductsChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> productData;

  const TopProductsChartWidget({
    super.key,
    required this.productData,
  });

  @override
  State<TopProductsChartWidget> createState() => _TopProductsChartWidgetState();
}

class _TopProductsChartWidgetState extends State<TopProductsChartWidget> {
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
                  'Top Selling Products',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              CustomIconWidget(
                iconName: 'bar_chart',
                color:
                    isLight ? const Color(0xFF3498DB) : const Color(0xFF3498DB),
                size: 20,
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Expanded(
            child: widget.productData.isEmpty
                ? _buildEmptyState(theme)
                : Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildChart(theme, isLight),
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
            iconName: 'inventory_2',
            color: const Color(0xFF95A5A6),
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'No product sales data',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF95A5A6),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Sell products to see top performers',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF95A5A6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(ThemeData theme, bool isLight) {
    return Semantics(
      label: "Bar chart showing top selling products by quantity sold",
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxY(),
          barTouchData: BarTouchData(
            enabled: true,
            touchCallback:
                (FlTouchEvent event, BarTouchResponse? touchResponse) {
              setState(() {
                if (touchResponse != null && touchResponse.spot != null) {
                  touchedIndex = touchResponse.spot!.touchedBarGroupIndex;
                } else {
                  touchedIndex = -1;
                }
              });
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < widget.productData.length) {
                    final productName =
                        widget.productData[index]['name'] as String;
                    return Padding(
                      padding: EdgeInsets.only(top: 1.h),
                      child: Text(
                        productName.length > 8
                            ? '${productName.substring(0, 8)}...'
                            : productName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isLight
                              ? const Color(0xFF7F8C8D)
                              : const Color(0xFFBDC3C7),
                          fontSize: 9.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: _calculateInterval(),
                reservedSize: 40,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    value.toInt().toString(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isLight
                          ? const Color(0xFF7F8C8D)
                          : const Color(0xFFBDC3C7),
                      fontSize: 10.sp,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color:
                  isLight ? const Color(0x1A2C3E50) : const Color(0x1AFFFFFF),
            ),
          ),
          barGroups: widget.productData.asMap().entries.map((entry) {
            final index = entry.key;
            final product = entry.value;
            final isTouched = index == touchedIndex;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: (product['quantity'] as double),
                  color: _getBarColor(index, isTouched),
                  width: isTouched ? 20 : 16,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: _getMaxY(),
                    color: isLight
                        ? const Color(0x0A2C3E50)
                        : const Color(0x0AFFFFFF),
                  ),
                ),
              ],
            );
          }).toList(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _calculateInterval(),
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color:
                    isLight ? const Color(0x1A2C3E50) : const Color(0x1AFFFFFF),
                strokeWidth: 1,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Products',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        Expanded(
          child: ListView.builder(
            itemCount:
                widget.productData.length > 5 ? 5 : widget.productData.length,
            itemBuilder: (context, index) {
              final product = widget.productData[index];
              return Container(
                margin: EdgeInsets.only(bottom: 1.h),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getBarColor(index, false),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name'] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${(product['quantity'] as double).toInt()} sold',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF7F8C8D),
                              fontSize: 9.sp,
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

  Color _getBarColor(int index, bool isTouched) {
    final colors = [
      const Color(0xFF3498DB),
      const Color(0xFF27AE60),
      const Color(0xFFF39C12),
      const Color(0xFFE74C3C),
      const Color(0xFF9B59B6),
    ];

    final baseColor = colors[index % colors.length];
    return isTouched ? baseColor : baseColor.withValues(alpha: 0.8);
  }

  double _getMaxY() {
    if (widget.productData.isEmpty) return 10;
    final maxQuantity = widget.productData
        .map((product) => product['quantity'] as double)
        .reduce((a, b) => a > b ? a : b);
    return (maxQuantity * 1.2).ceilToDouble();
  }

  double _calculateInterval() {
    final maxY = _getMaxY();
    return (maxY / 5).ceilToDouble();
  }
}