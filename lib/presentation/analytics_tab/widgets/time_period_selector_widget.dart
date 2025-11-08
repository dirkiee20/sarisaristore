import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class TimePeriodSelectorWidget extends StatelessWidget {
  final List<String> periods;
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;

  const TimePeriodSelectorWidget({
    super.key,
    required this.periods,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final isLight = brightness == Brightness.light;

    return Container(
      height: 6.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFFAFBFC) : const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: periods.map((period) {
          final isSelected = selectedPeriod == period;

          return Expanded(
            child: GestureDetector(
              onTap: () => onPeriodChanged(period),
              child: Container(
                margin: EdgeInsets.all(0.5.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isLight
                          ? const Color(0xFF2C3E50)
                          : const Color(0xFF34495E))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    period,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? Colors.white
                          : (isLight
                              ? const Color(0xFF7F8C8D)
                              : const Color(0xFFBDC3C7)),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
