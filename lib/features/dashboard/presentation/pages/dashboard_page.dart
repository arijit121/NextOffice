import 'package:flutter/material.dart';
import 'package:nextoffice/features/dashboard/presentation/widgets/dashboard_drawer.dart';
import 'package:nextoffice/navigation/custom_router/custom_route.dart';
import 'package:nextoffice/navigation/router_name.dart';
import 'package:nextoffice/shared/constants/color_const.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const double _mobileBreakpoint = 600;
  static const double _desktopBreakpoint = 900;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < _mobileBreakpoint;
        final isDesktop = constraints.maxWidth >= _desktopBreakpoint;

        if (isMobile) {
          return _MobileDashboard();
        } else {
          return _DesktopDashboard(isExtended: isDesktop);
        }
      },
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━ MOBILE LAYOUT ━━━━━━━━━━━━━━━━━━━━━

class _MobileDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NextOffice'),
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: theme.appBarTheme.foregroundColor ?? Colors.white,
        ),
      ),
      drawer: DashboardDrawer(
        selectedIndex: 0,
        items: _navItems,
        onItemTapped: (index) => _navigateTo(index),
      ),
      body: const _DashboardBody(),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━ DESKTOP LAYOUT ━━━━━━━━━━━━━━━━━━━━━

class _DesktopDashboard extends StatelessWidget {
  final bool isExtended;
  const _DesktopDashboard({required this.isExtended});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final railBg = isDark ? const Color(0xFF1A1D2E) : const Color(0xFFF0F2F8);
    final selectedColor = ColorConst.violate;
    final unselectedColor = isDark ? Colors.white54 : ColorConst.secondaryDark;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: isExtended,
            minWidth: 72,
            minExtendedWidth: 200,
            backgroundColor: railBg,
            selectedIndex: 0,
            onDestinationSelected: (index) => _navigateTo(index),
            indicatorColor: selectedColor.withOpacity(0.15),
            selectedIconTheme: IconThemeData(color: selectedColor),
            unselectedIconTheme: IconThemeData(color: unselectedColor),
            selectedLabelTextStyle: TextStyle(
              color: selectedColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            unselectedLabelTextStyle: TextStyle(
              color: unselectedColor,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      selectedColor,
                      selectedColor.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.business_center_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            labelType: isExtended
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            destinations: _navItems
                .map((item) => NavigationRailDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.icon),
                      label: Text(item.label),
                    ))
                .toList(),
          ),
          VerticalDivider(
            thickness: 1,
            width: 1,
            color: isDark ? Colors.white12 : Colors.black12,
          ),
          const Expanded(child: _DashboardBody()),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━ SHARED BODY CONTENT ━━━━━━━━━━━━━━━━━━

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 900
        ? 4
        : screenWidth > 600
            ? 3
            : 2;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero Welcome Card ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorConst.violate,
                  ColorConst.violate.withOpacity(0.75),
                  const Color(0xFF7C3AED),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: ColorConst.violate.withOpacity(0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome Back 👋',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your productivity suite is ready. Create, edit, and manage your documents.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.85),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _QuickActionChip(
                      icon: Icons.description_rounded,
                      label: 'New Doc',
                      onTap: () => CustomRoute.navigateNamed(RouteName.docs),
                    ),
                    _QuickActionChip(
                      icon: Icons.table_chart_rounded,
                      label: 'New Sheet',
                      onTap: () => CustomRoute.navigateNamed(RouteName.sheets),
                    ),
                    _QuickActionChip(
                      icon: Icons.slideshow_rounded,
                      label: 'New Slide',
                      onTap: () => CustomRoute.navigateNamed(RouteName.slides),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Stats Row ──
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.insert_drive_file_rounded,
                  label: 'Documents',
                  value: '0',
                  color: Colors.blue,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.access_time_rounded,
                  label: 'Recent Edits',
                  value: '0',
                  color: Colors.orange,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.storage_rounded,
                  label: 'Storage',
                  value: '0 MB',
                  color: Colors.green,
                  isDark: isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ── Modules Section ──
          Text(
            'Modules',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),

          GridView.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _ModuleTile(
                title: 'Docs',
                subtitle: 'Word processor',
                icon: Icons.description_rounded,
                color: Colors.blue,
                onTap: () => CustomRoute.navigateNamed(RouteName.docs),
                isDark: isDark,
              ),
              _ModuleTile(
                title: 'Sheets',
                subtitle: 'Spreadsheets',
                icon: Icons.table_chart_rounded,
                color: Colors.green,
                onTap: () => CustomRoute.navigateNamed(RouteName.sheets),
                isDark: isDark,
              ),
              _ModuleTile(
                title: 'Slides',
                subtitle: 'Presentations',
                icon: Icons.slideshow_rounded,
                color: Colors.orange,
                onTap: () => CustomRoute.navigateNamed(RouteName.slides),
                isDark: isDark,
              ),
              _ModuleTile(
                title: 'Files',
                subtitle: 'File manager',
                icon: Icons.folder_rounded,
                color: Colors.amber.shade700,
                onTap: () =>
                    CustomRoute.navigateNamed(RouteName.fileManager),
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ── Recent Documents (placeholder) ──
          Text(
            'Recent Documents',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.grey.shade200,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 48,
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                ),
                const SizedBox(height: 12),
                Text(
                  'No recent documents',
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey.shade500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Documents you create or edit will appear here',
                  style: TextStyle(
                    color: isDark ? Colors.white24 : Colors.grey.shade400,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━ WIDGETS ━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : color.withOpacity(0.15),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: color.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const _ModuleTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white10 : color.withOpacity(0.12),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: color.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(isDark ? 0.2 : 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━ NAV ITEMS ━━━━━━━━━━━━━━━━━━━━━━━━━━

final List<DashboardDrawerItem> _navItems = const [
  DashboardDrawerItem(
    icon: Icons.dashboard_rounded,
    label: 'Dashboard',
    routeName: RouteName.dashboard,
  ),
  DashboardDrawerItem(
    icon: Icons.description_rounded,
    label: 'Docs',
    routeName: RouteName.docs,
  ),
  DashboardDrawerItem(
    icon: Icons.table_chart_rounded,
    label: 'Sheets',
    routeName: RouteName.sheets,
  ),
  DashboardDrawerItem(
    icon: Icons.slideshow_rounded,
    label: 'Slides',
    routeName: RouteName.slides,
  ),
  DashboardDrawerItem(
    icon: Icons.folder_rounded,
    label: 'Files',
    routeName: RouteName.fileManager,
  ),
  DashboardDrawerItem(
    icon: Icons.settings_rounded,
    label: 'Settings',
    routeName: RouteName.settings,
  ),
];

void _navigateTo(int index) {
  CustomRoute.navigateNamed(_navItems[index].routeName);
}
