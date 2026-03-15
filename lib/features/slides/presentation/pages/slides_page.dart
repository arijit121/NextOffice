import 'package:flutter/material.dart';
import 'package:nextoffice/navigation/custom_router/custom_route.dart';
import 'package:nextoffice/shared/constants/color_const.dart';

class SlidesPage extends StatefulWidget {
  const SlidesPage({super.key});

  @override
  State<SlidesPage> createState() => _SlidesPageState();
}

class _SlidesPageState extends State<SlidesPage> {
  int _selectedSlide = 0;
  final TextEditingController _titleController = TextEditingController(
    text: 'Untitled Presentation',
  );

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
  }

  void _deleteSlide(int index) {
    if (_slides.length <= 1) return;
    setState(() {
      _slides.removeAt(index);
      if (_selectedSlide >= _slides.length) {
        _selectedSlide = _slides.length - 1;
      }
    });
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
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
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
            ),
          ),
        ),
        backgroundColor: Colors.orange.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded),
            onPressed: () {},
            tooltip: 'Save',
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow_rounded),
            onPressed: () {},
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
            child: Row(
              children: [
                _ToolButton(Icons.text_fields_rounded, 'Text', isDark, () {}),
                _ToolButton(Icons.image_rounded, 'Image', isDark, () {}),
                _ToolButton(Icons.crop_square_rounded, 'Shape', isDark, () {}),
                _ToolButton(Icons.bar_chart_rounded, 'Chart', isDark, () {}),
                const Spacer(),
                _ToolButton(Icons.palette_rounded, 'Theme', isDark, () {}),
                _ToolButton(Icons.animation_rounded, 'Animate', isDark, () {}),
              ],
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
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: _slides.length,
                            itemBuilder: (context, index) {
                              final selected = index == _selectedSlide;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedSlide = index),
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
                                                color: _slides[index]
                                                            .bgColor ==
                                                        Colors.white
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
                                    color: ColorConst.violate.withOpacity(0.5)),
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
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _slides[_selectedSlide].title,
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: _slides[_selectedSlide]
                                                    .bgColor ==
                                                Colors.white
                                            ? const Color(0xFF1E293B)
                                            : Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _slides[_selectedSlide].subtitle,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: _slides[_selectedSlide]
                                                    .bgColor ==
                                                Colors.white
                                            ? Colors.grey
                                            : Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
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
              color: isDark ? const Color(0xFF1A1D2E) : const Color(0xFFF1F5F9),
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
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
      // Mobile: drawer-style slide panel via bottom sheet
      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: _addSlide,
              backgroundColor: Colors.orange.shade700,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━ Helpers ━━━━━━━━━━━━━━━━━━━━

class _SlideData {
  String title;
  String subtitle;
  Color bgColor;
  List<dynamic> elements;

  _SlideData({
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.elements,
  });
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
