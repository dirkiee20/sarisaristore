import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom AppBar widget implementing Professional Minimalism design
/// Provides clean authority without decorative elements for retail business management
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The title to display in the app bar
  final String title;

  /// Optional leading widget (typically back button or menu)
  final Widget? leading;

  /// List of action widgets to display on the right side
  final List<Widget>? actions;

  /// Whether to show the back button automatically
  final bool automaticallyImplyLeading;

  /// Background color override (uses theme default if null)
  final Color? backgroundColor;

  /// Foreground color override (uses theme default if null)
  final Color? foregroundColor;

  /// Whether to center the title
  final bool centerTitle;

  /// Custom bottom widget (typically TabBar)
  final PreferredSizeWidget? bottom;

  /// Elevation override (uses 0 for clean appearance if null)
  final double? elevation;

  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.centerTitle = true,
    this.bottom,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brightness = theme.brightness;
    final isLight = brightness == Brightness.light;

    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: foregroundColor ??
              (isLight ? const Color(0xFF2C3E50) : Colors.white),
          letterSpacing: 0.15,
        ),
      ),
      leading: leading,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      centerTitle: centerTitle,
      bottom: bottom,
      elevation: elevation ?? 0, // Clean appearance without shadows
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,

      // Icon theme for consistent sizing and color
      iconTheme: IconThemeData(
        color: foregroundColor ?? colorScheme.onSurface,
        size: 24,
      ),

      // Action icon theme
      actionsIconTheme: IconThemeData(
        color: foregroundColor ?? colorScheme.onSurface,
        size: 24,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}

/// Specialized AppBar for dashboard/home screens
class CustomDashboardAppBar extends CustomAppBar {
  const CustomDashboardAppBar({
    super.key,
    required super.title,
    super.actions,
  }) : super(
          automaticallyImplyLeading: false,
          centerTitle: false,
        );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brightness = theme.brightness;
    final isLight = brightness == Brightness.light;

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: isLight ? const Color(0xFF2C3E50) : Colors.white,
              letterSpacing: 0,
            ),
          ),
          Text(
            _getCurrentDateString(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color:
                  isLight ? const Color(0xFF7F8C8D) : const Color(0xFFBDC3C7),
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
      actions: actions ??
          [
            IconButton(
              onPressed: () => _showNotifications(context),
              icon: const Icon(Icons.notifications_outlined),
              tooltip: 'Notifications',
            ),
            IconButton(
              onPressed: () => _showProfile(context),
              icon: const Icon(Icons.account_circle_outlined),
              tooltip: 'Profile',
            ),
          ],
      automaticallyImplyLeading: false,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      centerTitle: false,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: 24,
      ),
      actionsIconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: 24,
      ),
    );
  }

  String _getCurrentDateString() {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  void _showNotifications(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifications feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showProfile(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Specialized AppBar with search functionality
class CustomSearchAppBar extends CustomAppBar {
  final String hintText;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchSubmitted;

  const CustomSearchAppBar({
    super.key,
    required super.title,
    this.hintText = 'Search...',
    this.onSearchChanged,
    this.onSearchSubmitted,
    super.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brightness = theme.brightness;
    final isLight = brightness == Brightness.light;

    return AppBar(
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isLight ? const Color(0xFFFAFBFC) : const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          onChanged: onSearchChanged,
          onSubmitted: (_) => onSearchSubmitted?.call(),
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color:
                  isLight ? const Color(0xFF95A5A6) : const Color(0xFF95A5A6),
            ),
            prefixIcon: Icon(
              Icons.search,
              color:
                  isLight ? const Color(0xFF7F8C8D) : const Color(0xFFBDC3C7),
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ),
      actions: actions,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: 24,
      ),
      actionsIconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: 24,
      ),
    );
  }
}
