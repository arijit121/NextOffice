import 'package:flutter/material.dart';
import 'package:nextoffice/navigation/custom_router/custom_route.dart';
import 'package:nextoffice/shared/constants/color_const.dart';

class FileManagerPage extends StatefulWidget {
  const FileManagerPage({super.key});

  @override
  State<FileManagerPage> createState() => _FileManagerPageState();
}

class _FileManagerPageState extends State<FileManagerPage>
    with SingleTickerProviderStateMixin {
  bool _isGridView = true;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _categories = [
    'All',
    'Docs',
    'Sheets',
    'Slides',
  ];

  // Empty file list — files will be added via local storage later
  final List<Map<String, dynamic>> _files = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => CustomRoute.back(),
        ),
        title: const Text('File Manager'),
        backgroundColor: Colors.blueGrey.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isGridView
                ? Icons.view_list_rounded
                : Icons.grid_view_rounded),
            onPressed: () => setState(() => _isGridView = !_isGridView),
            tooltip: _isGridView ? 'List view' : 'Grid view',
          ),
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            onPressed: () {},
            tooltip: 'Sort',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ── Search Bar ──
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Search files...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : Colors.grey.shade400,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: isDark ? Colors.white38 : Colors.grey.shade400,
                ),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // ── Category Tabs ──
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: ColorConst.violate,
              unselectedLabelColor:
                  isDark ? Colors.white54 : Colors.grey.shade600,
              indicatorColor: ColorConst.violate,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              tabAlignment: TabAlignment.start,
              tabs: _categories.map((cat) => Tab(text: cat)).toList(),
            ),
          ),

          // ── File List / Grid / Empty ──
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children:
                  _categories.map((_) => _buildFileContent(isDark)).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        backgroundColor: ColorConst.violate,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label:
            const Text('Create', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildFileContent(bool isDark) {
    if (_files.isEmpty) {
      return _buildEmptyState(isDark);
    }
    // Future: render actual file grid/list
    return _buildEmptyState(isDark);
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color:
                  isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.folder_open_rounded,
              size: 64,
              color: isDark ? Colors.white24 : Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No files yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create documents, sheets, or slides\nto get started',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isDark ? Colors.white30 : Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _showCreateDialog,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Create New'),
            style: OutlinedButton.styleFrom(
              foregroundColor: ColorConst.violate,
              side: BorderSide(color: ColorConst.violate.withOpacity(0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create New',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            _CreateOption(
              icon: Icons.create_new_folder_rounded,
              label: 'New Folder',
              color: Colors.amber.shade700,
              isDark: isDark,
              onTap: () => Navigator.pop(context),
            ),
            _CreateOption(
              icon: Icons.description_rounded,
              label: 'New Document',
              color: Colors.blue,
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                CustomRoute.navigateNamed('docs');
              },
            ),
            _CreateOption(
              icon: Icons.table_chart_rounded,
              label: 'New Spreadsheet',
              color: Colors.green,
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                CustomRoute.navigateNamed('sheets');
              },
            ),
            _CreateOption(
              icon: Icons.slideshow_rounded,
              label: 'New Presentation',
              color: Colors.orange,
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                CustomRoute.navigateNamed('slides');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _CreateOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _CreateOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF1E293B),
        ),
      ),
    );
  }
}
