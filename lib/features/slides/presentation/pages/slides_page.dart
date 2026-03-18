import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nextoffice/features/shared/data/local_storage_service.dart';
import 'package:nextoffice/navigation/custom_router/custom_route.dart';
import 'package:nextoffice/shared/constants/color_const.dart';

class SlidesPage extends StatefulWidget {
  final String? fileId;
  const SlidesPage({super.key, this.fileId});

  @override
  State<SlidesPage> createState() => _SlidesPageState();
}

class _SlidesPageState extends State<SlidesPage> {
  int _selectedSlide = 0;
  final LocalStorageService _storage = LocalStorageService();
  LocalFileData? _localFile;
  final TextEditingController _titleController = TextEditingController(text: 'Untitled Presentation');
  
  @override
  void initState() {
    super.initState();
    _loadPresentation();
  }

  Future<void> _loadPresentation() async {
    if (widget.fileId == null) return;
    final file = await _storage.getFile(widget.fileId!);
    if (file != null && mounted) {
      setState(() {
        _localFile = file;
        _titleController.text = file.name;
      });
      if (file.payload.isNotEmpty) {
        try {
          final List<dynamic> decoded = jsonDecode(file.payload);
          setState(() {
            _slides.clear();
            _slides.addAll(decoded.map((s) => _SlideData.fromJson(s)).toList());
          });
        } catch (e) {
          // Ignore parse errors
        }
      }
    }
  }


  final List<_SlideData> _slides = [
    _SlideData(
      title: 'Title Slide',
      subtitle: 'Click to add subtitle',
      bgColor: const Color(0xFF4E69F4),
      elements: [],
    ),
  ];

  void _addSlide() {
    setState(() {
      _slides.add(
        _SlideData(
          title: 'New Slide',
          subtitle: 'Click to edit',
          bgColor: Colors.white,
          elements: [],
        ),
      );
      _selectedSlide = _slides.length - 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Slide ${_slides.length} added'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _savePresentation() async {
    final title = _titleController.text.trim();
    final jsonString = jsonEncode(_slides.map((s) => s.toJson()).toList());
    
    if (_localFile != null) {
      _localFile!.name = title.isEmpty ? "Untitled Presentation" : title;
      _localFile!.payload = jsonString;
      await _storage.saveFile(_localFile!);
    } else {
      final newFile = LocalFileData(
        id: _storage.generateId(),
        name: title.isEmpty ? "Untitled Presentation" : title,
        type: 'slide',
        createdAt: DateTime.now(),
        payload: jsonString,
      );
      await _storage.saveFile(newFile);
      setState(() => _localFile = newFile);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Presentation "${title.isEmpty ? "Untitled Presentation" : title}" saved'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _deleteSlide(int index) {
    if (_slides.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cannot delete the last slide'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Slide'),
        content: Text('Delete slide ${index + 1}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _slides.removeAt(index);
                if (_selectedSlide >= _slides.length) {
                  _selectedSlide = _slides.length - 1;
                }
              });
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _duplicateSlide(int index) {
    final source = _slides[index];
    setState(() {
      _slides.insert(
        index + 1,
        _SlideData(
          title: '${source.title} (Copy)',
          subtitle: source.subtitle,
          bgColor: source.bgColor,
          elements: List.from(source.elements),
        ),
      );
      _selectedSlide = index + 1;
    });
  }

  void _editSlideTitle(int index) {
    final controller = TextEditingController(text: _slides[index].title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Title'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Slide title',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              setState(() {
                _slides[index].title = controller.text.trim();
              });
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editSlideSubtitle(int index) {
    final controller = TextEditingController(text: _slides[index].subtitle);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Subtitle'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Slide subtitle',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              setState(() {
                _slides[index].subtitle = controller.text.trim();
              });
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final xfile = await picker.pickImage(source: ImageSource.gallery);
      if (xfile != null) {
        setState(() {
          _slides[_selectedSlide].elements.add({
            'type': 'image',
            'path': xfile.path,
            'x': 0.3,
            'y': 0.3,
          });
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _addTextElement() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Text'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter text...',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _slides[_selectedSlide].elements.add({
                    'type': 'text',
                    'content': controller.text.trim(),
                    'x': 0.3,
                    'y': 0.7,
                  });
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addShape() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Add Shape',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.crop_square_rounded, color: Colors.blue),
            title: const Text('Rectangle'),
            onTap: () {
              Navigator.pop(ctx);
              setState(() {
                _slides[_selectedSlide].elements.add({
                  'type': 'shape',
                  'shape': 'rectangle',
                  'x': 0.2,
                  'y': 0.6,
                  'color': Colors.blue.value,
                });
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.circle_outlined, color: Colors.green),
            title: const Text('Circle'),
            onTap: () {
              Navigator.pop(ctx);
              setState(() {
                _slides[_selectedSlide].elements.add({
                  'type': 'shape',
                  'shape': 'circle',
                  'x': 0.5,
                  'y': 0.5,
                  'color': Colors.green.value,
                });
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.change_history_rounded,
                color: Colors.orange),
            title: const Text('Triangle'),
            onTap: () {
              Navigator.pop(ctx);
              setState(() {
                _slides[_selectedSlide].elements.add({
                  'type': 'shape',
                  'shape': 'triangle',
                  'x': 0.4,
                  'y': 0.6,
                  'color': Colors.orange.value,
                });
              });
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showThemePicker() {
    final colors = [
      const Color(0xFF4E69F4),
      const Color(0xFF1A1A2E),
      Colors.white,
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFF059669),
      const Color(0xFF0EA5E9),
      const Color(0xFFF97316),
      const Color(0xFF1E293B),
      const Color(0xFFE2E8F0),
    ];

    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Slide Background',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: colors.map((color) {
                final isSelected =
                    _slides[_selectedSlide].bgColor == color;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _slides[_selectedSlide].bgColor = color;
                    });
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? ColorConst.violate
                            : Colors.grey.shade300,
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check_rounded,
                            color: color == Colors.white
                                ? Colors.black
                                : Colors.white,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _presentSlides() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PresentationView(slides: _slides),
      ),
    );
  }


  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => CustomRoute.back(),
        ),
        title: SizedBox(
          width: 300,
          child: TextField(
            controller: _titleController,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: theme.appBarTheme.foregroundColor ?? Colors.white,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Presentation title...',
              hintStyle: TextStyle(color: Colors.white54),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        backgroundColor: Colors.orange.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded),
            onPressed: _savePresentation,
            tooltip: 'Save',
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow_rounded),
            onPressed: _presentSlides,
            tooltip: 'Present',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ── Toolbar ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                ),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _ToolButton(
                      Icons.text_fields_rounded, 'Text', isDark, _addTextElement),
                  _ToolButton(Icons.image_rounded, 'Image', isDark, _pickImage),
                  _ToolButton(
                      Icons.crop_square_rounded, 'Shape', isDark, _addShape),
                  _ToolButton(Icons.bar_chart_rounded, 'Chart', isDark, () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Chart insertion — coming soon'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }),
                  const SizedBox(width: 8),
                  Container(width: 1, height: 28, color: isDark ? Colors.white12 : Colors.grey.shade300),
                  const SizedBox(width: 8),
                  _ToolButton(Icons.palette_rounded, 'Theme', isDark,
                      _showThemePicker),
                  _ToolButton(Icons.animation_rounded, 'Animate', isDark, () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Animations — coming soon'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // ── Main Area (Thumbnail panel + Canvas) ──
          Expanded(
            child: Row(
              children: [
                // Slide Thumbnails
                if (!isMobile)
                  Container(
                    width: 160,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1A1D2E)
                          : const Color(0xFFF1F5F9),
                      border: Border(
                        right: BorderSide(
                          color:
                              isDark ? Colors.white10 : Colors.grey.shade200,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ReorderableListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: _slides.length,
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                if (newIndex > oldIndex) newIndex--;
                                final item = _slides.removeAt(oldIndex);
                                _slides.insert(newIndex, item);
                                _selectedSlide = newIndex;
                              });
                            },
                            itemBuilder: (context, index) {
                              final selected = index == _selectedSlide;
                              return GestureDetector(
                                key: ValueKey('slide_$index'),
                                onTap: () =>
                                    setState(() => _selectedSlide = index),
                                onLongPress: () =>
                                    _showSlideContextMenu(index),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: selected
                                          ? ColorConst.violate
                                          : isDark
                                              ? Colors.white12
                                              : Colors.grey.shade300,
                                      width: selected ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: _slides[index].bgColor,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${index + 1}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: _isLightBg(
                                                        _slides[index]
                                                            .bgColor)
                                                    ? Colors.grey
                                                    : Colors.white
                                                        .withOpacity(0.7),
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _addSlide,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add Slide',
                                  style: TextStyle(fontSize: 12)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: ColorConst.violate,
                                side: BorderSide(
                                    color:
                                        ColorConst.violate.withOpacity(0.5)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Canvas
                Expanded(
                  child: Container(
                    color: isDark
                        ? const Color(0xFF0B0F1A)
                        : const Color(0xFFE2E8F0),
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _slides[_selectedSlide].bgColor,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Title & subtitle
                              Center(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () => _editSlideTitle(
                                          _selectedSlide),
                                      child: Text(
                                        _slides[_selectedSlide].title,
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: _isLightBg(
                                                  _slides[_selectedSlide]
                                                      .bgColor)
                                              ? const Color(0xFF1E293B)
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    GestureDetector(
                                      onTap: () => _editSlideSubtitle(
                                          _selectedSlide),
                                      child: Text(
                                        _slides[_selectedSlide].subtitle,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: _isLightBg(
                                                  _slides[_selectedSlide]
                                                      .bgColor)
                                              ? Colors.grey
                                              : Colors.white70,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Rendered elements
                              ..._slides[_selectedSlide]
                                  .elements
                                  .asMap()
                                  .entries
                                  .map(
                                (entry) {
                                  final elem = entry.value;
                                  final x =
                                      (elem['x'] as double?) ?? 0.5;
                                  final y =
                                      (elem['y'] as double?) ?? 0.5;
                                  return Positioned(
                                    left: x * 100,
                                    top: y * 100,
                                    child: GestureDetector(
                                      onTap: () =>
                                          _showElementOptions(entry.key),
                                      child:
                                          _buildElement(elem),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Status Bar ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1A1D2E)
                  : const Color(0xFFF1F5F9),
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Slide ${_selectedSlide + 1} of ${_slides.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${_slides[_selectedSlide].elements.length} elements',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'NextSlide',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: _addSlide,
              backgroundColor: Colors.orange.shade700,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  void _showSlideContextMenu(int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            child: Text('Slide ${index + 1}',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.edit_rounded),
            title: const Text('Edit Title'),
            onTap: () {
              Navigator.pop(ctx);
              _editSlideTitle(index);
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy_rounded),
            title: const Text('Duplicate'),
            onTap: () {
              Navigator.pop(ctx);
              _duplicateSlide(index);
            },
          ),
          ListTile(
            leading: const Icon(Icons.palette_rounded),
            title: const Text('Change Background'),
            onTap: () {
              Navigator.pop(ctx);
              setState(() => _selectedSlide = index);
              _showThemePicker();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_rounded, color: Colors.red),
            title: const Text('Delete',
                style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(ctx);
              _deleteSlide(index);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showElementOptions(int elementIndex) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Element Options'),
        content: const Text('What would you like to do with this element?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              setState(() {
                _slides[_selectedSlide].elements.removeAt(elementIndex);
              });
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildElement(Map<String, dynamic> elem) {
    final type = elem['type'] as String;
    if (type == 'text') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Text(
          elem['content'] ?? '',
          style: TextStyle(
            color: _isLightBg(_slides[_selectedSlide].bgColor)
                ? Colors.black87
                : Colors.white,
          ),
        ),
      );
    } else if (type == 'shape') {
      final shape = elem['shape'] as String;
      final color = Color(elem['color'] as int);
      if (shape == 'circle') {
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
        );
      } else if (shape == 'triangle') {
        return CustomPaint(
          size: const Size(60, 50),
          painter: _TrianglePainter(color: color),
        );
      } else {
        return Container(
          width: 80,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color, width: 2),
          ),
        );
      }
    } else if (type == 'image') {
      final path = elem['path'] as String;
      return Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: path.startsWith('http')
              ? Image.network(path, fit: BoxFit.cover)
              : Image.file(File(path), fit: BoxFit.cover),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  bool _isLightBg(Color color) {
    return color.computeLuminance() > 0.5;
  }
}

// ━━━━━━━━━━━━━━━━━━ Presentation View ━━━━━━━━━━━━━━━━━━

class _PresentationView extends StatefulWidget {
  final List<_SlideData> slides;
  const _PresentationView({required this.slides});

  @override
  State<_PresentationView> createState() => _PresentationViewState();
}

class _PresentationViewState extends State<_PresentationView> {
  int _current = 0;

  void _next() {
    if (_current < widget.slides.length - 1) {
      setState(() => _current++);
    }
  }

  void _prev() {
    if (_current > 0) {
      setState(() => _current--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = widget.slides[_current];
    final isLight = slide.bgColor.computeLuminance() > 0.5;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _next,
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < 0) {
              _next();
            } else {
              _prev();
            }
          }
        },
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: slide.bgColor,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          slide.title,
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: isLight
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide.subtitle,
                          style: TextStyle(
                            fontSize: 24,
                            color: isLight ? Colors.grey : Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Navigation controls
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _prev,
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white70),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_current + 1} / ${widget.slides.length}',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14),
                    ),
                  ),
                  IconButton(
                    onPressed: _next,
                    icon: const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white70),
                  ),
                ],
              ),
            ),
            // Exit button
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded,
                    color: Colors.white70, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━ Helpers ━━━━━━━━━━━━━━━━━━━━

class _SlideData {
  String title;
  String subtitle;
  Color bgColor;
  List<Map<String, dynamic>> elements;

  _SlideData({
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.elements,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'subtitle': subtitle,
        'bgColor': bgColor.value,
        'elements': elements,
      };

  factory _SlideData.fromJson(Map<String, dynamic> json) => _SlideData(
        title: json['title'] as String,
        subtitle: json['subtitle'] as String,
        bgColor: Color(json['bgColor'] as int),
        elements: List<Map<String, dynamic>>.from(json['elements']),
      );
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _ToolButton(this.icon, this.label, this.isDark, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 20,
                  color: isDark ? Colors.white54 : Colors.grey.shade700),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.white38 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
