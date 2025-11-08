import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tab item data structure for custom tab navigation
class TabItem {
  final String label;
  final IconData? icon;
  final Widget? customIcon;
  final String? route;

  const TabItem({
    required this.label,
    this.icon,
    this.customIcon,
    this.route,
  });
}

/// Custom Tab Bar implementing Professional Minimalism design
/// Provides clean navigation hierarchy for retail business sections
class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  /// List of tab items to display
  final List<TabItem> tabs;

  /// Tab controller for managing tab state
  final TabController? controller;

  /// Callback when tab is tapped
  final ValueChanged<int>? onTap;

  /// Whether tabs are scrollable
  final bool isScrollable;

  /// Tab alignment for scrollable tabs
  final TabAlignment tabAlignment;

  /// Background color override
  final Color? backgroundColor;

  /// Selected tab color override
  final Color? selectedColor;

  /// Unselected tab color override
  final Color? unselectedColor;

  /// Indicator color override
  final Color? indicatorColor;

  /// Whether to show icons in tabs
  final bool showIcons;

  /// Custom indicator decoration
  final Decoration? indicator;

  const CustomTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.onTap,
    this.isScrollable = false,
    this.tabAlignment = TabAlignment.center,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.indicatorColor,
    this.showIcons = false,
    this.indicator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brightness = theme.brightness;
    final isLight = brightness == Brightness.light;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: isLight
                ? const Color(0x1A2C3E50) // 10% opacity of text color
                : const Color(0x1AFFFFFF),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: controller,
        onTap: onTap,
        isScrollable: isScrollable,
        tabAlignment: tabAlignment,
        labelColor: selectedColor ??
            (isLight ? const Color(0xFF2C3E50) : const Color(0xFF34495E)),
        unselectedLabelColor: unselectedColor ??
            (isLight ? const Color(0xFF7F8C8D) : const Color(0xFFBDC3C7)),
        indicatorColor: indicatorColor ??
            (isLight ? const Color(0xFF2C3E50) : const Color(0xFF34495E)),
        indicatorSize: TabBarIndicatorSize.label,
        indicatorWeight: 2,
        indicator: indicator,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        tabs: tabs.map((tab) => _buildTab(tab)).toList(),
      ),
    );
  }

  /// Build individual tab widget
  Widget _buildTab(TabItem tab) {
    if (showIcons && (tab.icon != null || tab.customIcon != null)) {
      return Tab(
        icon: tab.customIcon ??
            Icon(
              tab.icon,
              size: 20,
            ),
        text: tab.label,
        iconMargin: const EdgeInsets.only(bottom: 4),
      );
    } else {
      return Tab(
        text: tab.label,
        height: 48,
      );
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}

/// Specialized Tab Bar for analytics sections
class CustomAnalyticsTabBar extends CustomTabBar {
  CustomAnalyticsTabBar({
    super.key,
    super.controller,
    super.onTap,
  }) : super(
          tabs: const [
            TabItem(label: 'Overview'),
            TabItem(label: 'Sales'),
            TabItem(label: 'Inventory'),
            TabItem(label: 'Trends'),
          ],
          isScrollable: true,
          tabAlignment: TabAlignment.start,
        );
}

/// Specialized Tab Bar for product management
class CustomProductTabBar extends CustomTabBar {
  CustomProductTabBar({
    super.key,
    super.controller,
    super.onTap,
  }) : super(
          tabs: const [
            TabItem(label: 'All Products'),
            TabItem(label: 'Categories'),
            TabItem(label: 'Low Stock'),
            TabItem(label: 'Favorites'),
          ],
          isScrollable: true,
          tabAlignment: TabAlignment.start,
        );
}

/// Segmented Tab Bar for binary choices
class CustomSegmentedTabBar extends StatelessWidget
    implements PreferredSizeWidget {
  /// List of tab labels
  final List<String> tabs;

  /// Current selected index
  final int selectedIndex;

  /// Callback when tab is selected
  final ValueChanged<int>? onTap;

  /// Background color override
  final Color? backgroundColor;

  /// Selected segment color override
  final Color? selectedColor;

  /// Unselected segment color override
  final Color? unselectedColor;

  const CustomSegmentedTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    this.onTap,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final isLight = brightness == Brightness.light;

    return Container(
      height: 48,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ??
            (isLight ? const Color(0xFFFAFBFC) : const Color(0xFF2D2D2D)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final isSelected = selectedIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap?.call(index),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (selectedColor ??
                          (isLight
                              ? const Color(0xFF2C3E50)
                              : const Color(0xFF34495E)))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.w400,
                      color: isSelected
                          ? Colors.white
                          : (unselectedColor ??
                              (isLight
                                  ? const Color(0xFF7F8C8D)
                                  : const Color(0xFFBDC3C7))),
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80); // 48 + 32 margin
}

/// Pill-style Tab Bar for filter options
class CustomPillTabBar extends StatelessWidget implements PreferredSizeWidget {
  /// List of tab labels
  final List<String> tabs;

  /// Current selected index
  final int selectedIndex;

  /// Callback when tab is selected
  final ValueChanged<int>? onTap;

  /// Whether tabs are scrollable
  final bool isScrollable;

  const CustomPillTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    this.onTap,
    this.isScrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final isLight = brightness == Brightness.light;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onTap?.call(index),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isLight
                          ? const Color(0xFF2C3E50)
                          : const Color(0xFF34495E))
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : (isLight
                            ? const Color(0x1A2C3E50)
                            : const Color(0x1AFFFFFF)),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tabs[index],
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                    color: isSelected
                        ? Colors.white
                        : (isLight
                            ? const Color(0xFF7F8C8D)
                            : const Color(0xFFBDC3C7)),
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
