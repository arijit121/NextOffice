import 'package:flutter/material.dart';
import 'package:nextoffice/features/shared/data/local_storage_service.dart';
import 'package:nextoffice/navigation/custom_router/custom_route.dart';
import 'package:nextoffice/navigation/router_name.dart';
import 'package:nextoffice/shared/constants/color_const.dart';

class FileManagerPage extends StatefulWidget {
  const FileManagerPage({super.key});

  @override
  State<FileManagerPage> createState() => _FileManagerPageState();
}

class _FileItem {
  final String id;
  String name;
  final String type; // folder, doc, sheet, slide
  final DateTime createdAt;
  final IconData icon;
  final Color color;

  _FileItem({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.icon,
    required this.color,
  });

  factory _FileItem.fromLocalData(LocalFileData data) {
    IconData icon;
    Color color;
    switch (data.type) {
      case 'doc':
        icon = Icons.description_rounded;
        color = Colors.blue;
        break;
      case 'sheet':
        icon = Icons.table_chart_rounded;
        color = Colors.green;
        break;
      case 'slide':
        icon = Icons.slideshow_rounded;
        color = Colors.orange;
        break;
      case 'folder':
      default:
        icon = Icons.folder_rounded;
        color = Colors.amber.shade700;
        break;
    }
    return _FileItem(
      id: data.id,
      name: data.name,
      type: data.type,
      createdAt: data.createdAt,
      icon: icon,
      color: color,
    );
  }
}

class _FileManagerPageState extends State<FileManagerPage>
    with SingleTickerProviderStateMixin {
  bool _isGridView = true;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'name'; // name, date, type

  static const List<String> _categories = ['All', 'Docs', 'Sheets', 'Slides'];

  final LocalStorageService _storage = LocalStorageService();
  List<_FileItem> _files = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    final localFiles = await _storage.getAllFiles();
    setState(() {
      _files = localFiles.map((f) => _FileItem.fromLocalData(f)).toList();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<_FileItem> _filteredFiles(String category) {
    var list = _files.toList();

    // Filter by category
    if (category != 'All') {
      final type = category.toLowerCase();
      // Map category to types
      final typeMap = {
        'docs': 'doc',
        'sheets': 'sheet',
        'slides': 'slide',
      };
      list = list
          .where((f) => f.type == typeMap[type] || f.type == 'folder')
          .toList();
    }

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((f) => f.name.toLowerCase().contains(_searchQuery))
          .toList();
    }

    // Sort
    switch (_sortBy) {
      case 'name':
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'date':
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'type':
        list.sort((a, b) => a.type.compareTo(b.type));
        break;
    }

    return list;
  }

  void _createFolder() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Folder'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Folder name',
            prefixIcon: Icon(Icons.folder_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final data = LocalFileData(id: _storage.generateId(), name: name, type: 'folder', createdAt: DateTime.now());
                await _storage.saveFile(data);
                await _loadFiles();
                if (mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _createDocument() {
    final controller = TextEditingController(text: 'Untitled Document');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Document'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Document name',
            prefixIcon: Icon(Icons.description_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final data = LocalFileData(id: _storage.generateId(), name: name, type: 'doc', createdAt: DateTime.now());
                await _storage.saveFile(data);
                await _loadFiles();
                if (mounted) {
                  Navigator.pop(ctx);
                  CustomRoute.navigateNamed(RouteName.docs);
                }
              }
            },
            child: const Text('Create & Open'),
          ),
        ],
      ),
    );
  }

  void _createSpreadsheet() {
    final controller = TextEditingController(text: 'Untitled Spreadsheet');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Spreadsheet'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Spreadsheet name',
            prefixIcon: Icon(Icons.table_chart_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final data = LocalFileData(id: _storage.generateId(), name: name, type: 'sheet', createdAt: DateTime.now());
                await _storage.saveFile(data);
                await _loadFiles();
                if (mounted) {
                  Navigator.pop(ctx);
                  CustomRoute.navigateNamed(RouteName.sheets);
                }
              }
            },
            child: const Text('Create & Open'),
          ),
        ],
      ),
    );
  }

  void _createPresentation() {
    final controller = TextEditingController(text: 'Untitled Presentation');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Presentation'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Presentation name',
            prefixIcon: Icon(Icons.slideshow_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final data = LocalFileData(id: _storage.generateId(), name: name, type: 'slide', createdAt: DateTime.now());
                await _storage.saveFile(data);
                await _loadFiles();
                if (mounted) {
                  Navigator.pop(ctx);
                  CustomRoute.navigateNamed(RouteName.slides);
                }
              }
            },
            child: const Text('Create & Open'),
          ),
        ],
      ),
    );
  }

  void _renameFile(int index) {
    final controller = TextEditingController(text: _files[index].name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'New name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await _storage.renameFile(_files[index].id, name);
                await _loadFiles();
                if (mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _deleteFile(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Delete "${_files[index].name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _storage.deleteFile(_files[index].id);
              await _loadFiles();
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openFile(_FileItem file) {
    switch (file.type) {
      case 'doc':
        CustomRoute.navigateNamed(RouteName.docs);
        break;
      case 'sheet':
        CustomRoute.navigateNamed(RouteName.sheets);
        break;
      case 'slide':
        CustomRoute.navigateNamed(RouteName.slides);
        break;
      case 'folder':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opened folder "${file.name}"'),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        break;
    }
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Sort By',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          RadioListTile<String>(
            title: const Text('Name'),
            value: 'name',
            groupValue: _sortBy,
            onChanged: (v) {
              setState(() => _sortBy = v!);
              Navigator.pop(ctx);
            },
          ),
          RadioListTile<String>(
            title: const Text('Date Created'),
            value: 'date',
            groupValue: _sortBy,
            onChanged: (v) {
              setState(() => _sortBy = v!);
              Navigator.pop(ctx);
            },
          ),
          RadioListTile<String>(
            title: const Text('Type'),
            value: 'type',
            groupValue: _sortBy,
            onChanged: (v) {
              setState(() => _sortBy = v!);
              Navigator.pop(ctx);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showFileContextMenu(int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final file = _files[index];
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(file.icon, color: file.color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(file.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.open_in_new_rounded),
            title: const Text('Open'),
            onTap: () {
              Navigator.pop(ctx);
              _openFile(file);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_rounded),
            title: const Text('Rename'),
            onTap: () {
              Navigator.pop(ctx);
              _renameFile(index);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_rounded, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(ctx);
              _deleteFile(index);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
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
            onPressed: _showSortOptions,
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
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
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
              children: _categories.map((cat) {
                final filtered = _filteredFiles(cat);
                if (filtered.isEmpty) {
                  return _buildEmptyState(isDark);
                }
                return _isGridView
                    ? _buildGridView(filtered, isDark)
                    : _buildListView(filtered, isDark);
              }).toList(),
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

  Widget _buildGridView(List<_FileItem> files, bool isDark) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 900
        ? 5
        : width > 600
            ? 4
            : 2;
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final fileIndex = _files.indexOf(files[index]);
        return _FileGridTile(
          file: files[index],
          isDark: isDark,
          onTap: () => _openFile(files[index]),
          onLongPress: () => _showFileContextMenu(fileIndex),
        );
      },
    );
  }

  Widget _buildListView(List<_FileItem> files, bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: files.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final file = files[index];
        final fileIndex = _files.indexOf(file);
        return ListTile(
          onTap: () => _openFile(file),
          onLongPress: () => _showFileContextMenu(fileIndex),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: file.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(file.icon, color: file.color, size: 24),
          ),
          title: Text(
            file.name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          subtitle: Text(
            '${file.type.toUpperCase()} • ${_formatDate(file.createdAt)}',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white38 : Colors.grey.shade500,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () => _showFileContextMenu(fileIndex),
          ),
        );
      },
    );
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
            _searchQuery.isNotEmpty ? 'No results found' : 'No files yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Create documents, sheets, or slides\nto get started',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isDark ? Colors.white30 : Colors.grey.shade400,
            ),
          ),
          if (_searchQuery.isEmpty) ...[
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
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
              onTap: () {
                Navigator.pop(context);
                _createFolder();
              },
            ),
            _CreateOption(
              icon: Icons.description_rounded,
              label: 'New Document',
              color: Colors.blue,
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                _createDocument();
              },
            ),
            _CreateOption(
              icon: Icons.table_chart_rounded,
              label: 'New Spreadsheet',
              color: Colors.green,
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                _createSpreadsheet();
              },
            ),
            _CreateOption(
              icon: Icons.slideshow_rounded,
              label: 'New Presentation',
              color: Colors.orange,
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                _createPresentation();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

// ━━━━━━━━━━━━━━━━━━ Widgets ━━━━━━━━━━━━━━━━━━

class _FileGridTile extends StatelessWidget {
  final _FileItem file;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _FileGridTile({
    required this.file,
    required this.isDark,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white10 : file.color.withOpacity(0.12),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: file.color.withOpacity(isDark ? 0.2 : 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(file.icon, size: 28, color: file.color),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  file.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                file.type.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.white38 : Colors.grey.shade500,
                ),
              ),
            ],
          ),
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
