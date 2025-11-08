import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Navigation item data structure for bottom navigation
class BottomNavItem {
  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final String route;

  const BottomNavItem({
    required this.label,
    required this.icon,
    this.activeIcon,
    required this.route,
  });
}

/// Custom Bottom Navigation Bar implementing Professional Minimalism design
/// Provides contextual navigation for task-focused retail business users
class CustomBottomBar extends StatelessWidget {
  /// Current selected index
  final int currentIndex;

  /// Callback when navigation item is tapped
  final ValueChanged<int>? onTap;

  /// Background color override
  final Color? backgroundColor;

  /// Selected item color override
  final Color? selectedItemColor;

  /// Unselected item color override
  final Color? unselectedItemColor;

  /// Whether to show labels
  final bool showLabels;

  /// Navigation type (fixed or shifting)
  final BottomNavigationBarType type;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.showLabels = true,
    this.type = BottomNavigationBarType.fixed,
  });

  /// Predefined navigation items for retail business management
  static const List<BottomNavItem> _navigationItems = [
    BottomNavItem(
      label: 'Products',
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2,
      route: '/products-tab',
    ),
    BottomNavItem(
      label: 'Analytics',
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
      route: '/analytics-tab',
    ),
    BottomNavItem(
      label: 'Stock',
      icon: Icons.warehouse_outlined,
      activeIcon: Icons.warehouse,
      route: '/stock-management-tab',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brightness = theme.brightness;
    final isLight = brightness == Brightness.light;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: isLight
                ? const Color(0x33000000) // 20% opacity black for light theme
                : const Color(0x33000000), // Same for dark theme
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex.clamp(0, _navigationItems.length - 1),
        onTap: (index) {
          if (onTap != null) {
            onTap!(index);
          } else {
            // Default navigation behavior
            _navigateToRoute(context, _navigationItems[index].route);
          }
        },
        type: type,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: selectedItemColor ??
            (isLight ? const Color(0xFF2C3E50) : const Color(0xFF34495E)),
        unselectedItemColor: unselectedItemColor ??
            (isLight ? const Color(0xFF7F8C8D) : const Color(0xFFBDC3C7)),
        showSelectedLabels: showLabels,
        showUnselectedLabels: showLabels,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
        ),
        items: _navigationItems
            .map((item) => BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Icon(
                      item.icon,
                      size: 24,
                    ),
                  ),
                  activeIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Icon(
                      item.activeIcon ?? item.icon,
                      size: 24,
                    ),
                  ),
                  label: item.label,
                  tooltip: item.label,
                ))
            .toList(),
      ),
    );
  }

  /// Navigate to the specified route
  void _navigateToRoute(BuildContext context, String route) {
    // Get current route name
    final currentRoute = ModalRoute.of(context)?.settings.name;

    // Only navigate if not already on the target route
    if (currentRoute != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }
}

/// Specialized Bottom Bar with FAB integration
class CustomBottomBarWithFAB extends StatelessWidget {
  /// Current selected index
  final int currentIndex;

  /// Callback when navigation item is tapped
  final ValueChanged<int>? onTap;

  /// FAB callback
  final VoidCallback? onFABPressed;

  /// FAB icon
  final IconData fabIcon;

  /// FAB tooltip
  final String fabTooltip;

  /// Background color override
  final Color? backgroundColor;

  const CustomBottomBarWithFAB({
    super.key,
    required this.currentIndex,
    this.onTap,
    this.onFABPressed,
    this.fabIcon = Icons.add,
    this.fabTooltip = 'Add Product',
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final isLight = brightness == Brightness.light;

    return Scaffold(
      body: Container(), // This will be replaced by the actual body content
      bottomNavigationBar: CustomBottomBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: backgroundColor,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onFABPressed ?? () => _defaultFABAction(context),
        backgroundColor:
            isLight ? const Color(0xFF2C3E50) : const Color(0xFF34495E),
        foregroundColor: Colors.white,
        elevation: 4,
        tooltip: fabTooltip,
        child: Icon(
          fabIcon,
          size: 24,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  /// Default FAB action - navigate to add product screen
  void _defaultFABAction(BuildContext context) {
    Navigator.pushNamed(context, '/add-product-screen');
  }
}

/// Compact Bottom Bar for smaller screens
class CustomCompactBottomBar extends StatelessWidget {
  /// Current selected index
  final int currentIndex;

  /// Callback when navigation item is tapped
  final ValueChanged<int>? onTap;

  const CustomCompactBottomBar({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brightness = theme.brightness;
    final isLight = brightness == Brightness.light;

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: isLight ? const Color(0x33000000) : const Color(0x33000000),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: CustomBottomBar._navigationItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = currentIndex == index;

          return Expanded(
            child: InkWell(
              onTap: () {
                if (onTap != null) {
                  onTap!(index);
                } else {
                  Navigator.pushReplacementNamed(context, item.route);
                }
              },
              child: Container(
                height: 60,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                      size: 20,
                      color: isSelected
                          ? (isLight
                              ? const Color(0xFF2C3E50)
                              : const Color(0xFF34495E))
                          : (isLight
                              ? const Color(0xFF7F8C8D)
                              : const Color(0xFFBDC3C7)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.label,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.w400,
                        color: isSelected
                            ? (isLight
                                ? const Color(0xFF2C3E50)
                                : const Color(0xFF34495E))
                            : (isLight
                                ? const Color(0xFF7F8C8D)
                                : const Color(0xFFBDC3C7)),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
