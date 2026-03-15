import 'package:flutter/material.dart';
import 'package:nextoffice/shared/constants/color_const.dart';

class DashboardDrawerItem {
  final IconData icon;
  final String label;
  final String routeName;

  const DashboardDrawerItem({
    required this.icon,
    required this.label,
    required this.routeName,
  });
}

class DashboardDrawer extends StatelessWidget {
  final int selectedIndex;
  final List<DashboardDrawerItem> items;
  final ValueChanged<int> onItemTapped;

  const DashboardDrawer({
    super.key,
    required this.selectedIndex,
    required this.items,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1D2E) : Colors.white;

    return Drawer(
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = index == selectedIndex;
                  return _buildDrawerTile(
                    context,
                    item: item,
                    isSelected: isSelected,
                    isDark: isDark,
                    onTap: () {
                      Navigator.of(context).pop();
                      onItemTapped(index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorConst.violate,
            ColorConst.violate.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.business_center_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'NextOffice',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your productivity suite',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerTile(
    BuildContext context, {
    required DashboardDrawerItem item,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final selectedColor = ColorConst.violate;
    final unselectedColor =
        isDark ? Colors.white70 : ColorConst.primaryDark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          selected: isSelected,
          selectedTileColor: selectedColor.withOpacity(0.1),
          leading: Icon(
            item.icon,
            color: isSelected ? selectedColor : unselectedColor,
            size: 22,
          ),
          title: Text(
            item.label,
            style: TextStyle(
              color: isSelected ? selectedColor : unselectedColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 15,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
