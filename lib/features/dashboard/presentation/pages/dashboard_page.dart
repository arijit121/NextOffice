import 'package:flutter/material.dart';
import 'package:nextoffice/navigation/custom_router/custom_route.dart';
import 'package:nextoffice/navigation/router_name.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'NextOffice',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome Back 👋',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a module to get started',
              style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildModuleTile(
                    context,
                    title: 'Docs',
                    icon: Icons.description_rounded,
                    color: Colors.blue,
                    routeName: RouteName.docs,
                  ),
                  _buildModuleTile(
                    context,
                    title: 'Sheets',
                    icon: Icons.table_chart_rounded,
                    color: Colors.green,
                    routeName: RouteName.sheets,
                  ),
                  _buildModuleTile(
                    context,
                    title: 'Slides',
                    icon: Icons.slideshow_rounded,
                    color: Colors.orange,
                    routeName: RouteName.slides,
                  ),
                  _buildModuleTile(
                    context,
                    title: 'Files',
                    icon: Icons.folder_rounded,
                    color: Colors.amber,
                    routeName: RouteName.fileManager,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String routeName,
  }) {
    return InkWell(
      onTap: () => CustomRoute.navigateNamed(routeName),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.1), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
