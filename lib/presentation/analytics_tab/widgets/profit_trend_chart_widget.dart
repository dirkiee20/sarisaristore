import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ProfitTrendChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> chartData;
  final String period;

  const ProfitTrendChartWidget({
    super.key,
    required this.chartData,
    required this.period,
  });

  @override
  State<ProfitTrendChartWidget> createState() => _ProfitTrendChartWidgetState();
}

class _ProfitTrendChartWidgetState extends State<ProfitTrendChartWidget> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final isLight = brightness == Brightness.light;

    return Container(
      width: double.infinity,
      height: 30.h,
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
                  'Profit Trends - ${widget.period}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              CustomIconWidget(
                iconName: 'show_chart',
                color:
                    isLight ? const Color(0xFF3498DB) : const Color(0xFF3498DB),
                size: 20,
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Expanded(
            child: widget.chartData.isEmpty
                ? _buildEmptyState(theme)
                : _buildChart(theme, isLight),
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
            iconName: 'trending_up',
            color: const Color(0xFF95A5A6),
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'No profit data available',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF95A5A6),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Start making sales to see trends',
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
      label: "Profit trend line chart showing ${widget.period} performance",
      child: LineChart(
        LineChartData(
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
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < widget.chartData.length) {
                    return Padding(
                      padding: EdgeInsets.only(top: 1.h),
                      child: Text(
                        (widget.chartData[index]['label'] as String),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isLight
                              ? const Color(0xFF7F8C8D)
                              : const Color(0xFFBDC3C7),
                          fontSize: 10.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: _calculateInterval(),
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '₱${_formatValue(value)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isLight
                          ? const Color(0xFF7F8C8D)
                          : const Color(0xFFBDC3C7),
                      fontSize: 10.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
          minX: 0,
          maxX: (widget.chartData.length - 1).toDouble(),
          minY: _getMinY(),
          maxY: _getMaxY(),
          lineBarsData: [
            LineChartBarData(
              spots: widget.chartData.asMap().entries.map((entry) {
                return FlSpot(
                  entry.key.toDouble(),
                  (entry.value['value'] as double),
                );
              }).toList(),
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF3498DB),
                  const Color(0xFF3498DB).withValues(alpha: 0.7),
                ],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: touchedIndex == index ? 6 : 4,
                    color: const Color(0xFF3498DB),
                    strokeWidth: 2,
                    strokeColor: theme.colorScheme.surface,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF3498DB).withValues(alpha: 0.3),
                    const Color(0xFF3498DB).withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchCallback:
                (FlTouchEvent event, LineTouchResponse? touchResponse) {
              setState(() {
                if (touchResponse != null &&
                    touchResponse.lineBarSpots != null) {
                  touchedIndex = touchResponse.lineBarSpots!.first.spotIndex;
                } else {
                  touchedIndex = -1;
                }
              });
            },
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: theme.colorScheme.surface,
              tooltipRoundedRadius: 8,
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final flSpot = barSpot;
                  final index = flSpot.x.toInt();
                  if (index >= 0 && index < widget.chartData.length) {
                    return LineTooltipItem(
                      '${widget.chartData[index]['label']}\n₱${_formatValue(flSpot.y)}',
                      theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ) ??
                          const TextStyle(),
                    );
                  }
                  return null;
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  double _getMinY() {
    if (widget.chartData.isEmpty) return 0;
    final values =
        widget.chartData.map((data) => data['value'] as double).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    return (minValue * 0.9).floorToDouble();
  }

  double _getMaxY() {
    if (widget.chartData.isEmpty) return 100;
    final values =
        widget.chartData.map((data) => data['value'] as double).toList();
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    return (maxValue * 1.1).ceilToDouble();
  }

  double _calculateInterval() {
    final range = _getMaxY() - _getMinY();
    return (range / 5).ceilToDouble();
  }

  String _formatValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }
}