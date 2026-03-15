import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:nextoffice/navigation/custom_router/custom_route.dart';
import 'package:nextoffice/shared/constants/color_const.dart';

class DocsPage extends StatefulWidget {
  const DocsPage({super.key});

  @override
  State<DocsPage> createState() => _DocsPageState();
}

class _DocsPageState extends State<DocsPage> {
  late final QuillController _controller;
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();
  final TextEditingController _titleController = TextEditingController(
    text: 'Untitled Document',
  );

  int _wordCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();
    _controller.addListener(_updateWordCount);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateWordCount);
    _controller.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _updateWordCount() {
    final text = _controller.document.toPlainText().trim();
    setState(() {
      _wordCount = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    });
  }

  void _saveDocument() {
    // Serialize document to JSON for storage
    final docJson = _controller.document.toDelta().toJson();
    final title = _titleController.text.trim();
    // TODO: Persist to local storage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Document "${title.isEmpty ? "Untitled" : title}" saved'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _exportAsText() {
    final plainText = _controller.document.toPlainText();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export as Plain Text'),
        content: SelectableText(
          plainText,
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDocumentInfo() {
    final text = _controller.document.toPlainText().trim();
    final words = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    final chars = text.length;
    final lines = text.isEmpty ? 0 : text.split('\n').length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Document Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow('Title', _titleController.text),
            _InfoRow('Words', '$words'),
            _InfoRow('Characters', '$chars'),
            _InfoRow('Lines', '$lines'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
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
              hintText: 'Document title...',
              hintStyle: TextStyle(color: Colors.white54),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.undo_rounded),
            onPressed: () => _controller.undo(),
            tooltip: 'Undo',
          ),
          IconButton(
            icon: const Icon(Icons.redo_rounded),
            onPressed: () => _controller.redo(),
            tooltip: 'Redo',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              switch (value) {
                case 'save':
                  _saveDocument();
                  break;
                case 'export':
                  _exportAsText();
                  break;
                case 'info':
                  _showDocumentInfo();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'save',
                child: ListTile(
                  leading: Icon(Icons.save_rounded),
                  title: Text('Save'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.text_snippet_rounded),
                  title: Text('Export as Text'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'info',
                child: ListTile(
                  leading: Icon(Icons.info_outline_rounded),
                  title: Text('Document Info'),
                  dense: true,
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // ── Formatting Toolbar ──
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                ),
              ),
            ),
            child: QuillSimpleToolbar(
              controller: _controller,
              config: QuillSimpleToolbarConfig(
                showAlignmentButtons: true,
                showBackgroundColorButton: true,
                showBoldButton: true,
                showItalicButton: true,
                showUnderLineButton: true,
                showStrikeThrough: true,
                showFontFamily: true,
                showFontSize: true,
                showColorButton: true,
                showListBullets: true,
                showListNumbers: true,
                showListCheck: true,
                showLink: true,
                showIndent: true,
                showHeaderStyle: true,
                showSearchButton: true,
                showCodeBlock: true,
                showQuote: true,
                showDividers: true,
                multiRowsDisplay: false,
              ),
            ),
          ),

          // ── Editor Area ──
          Expanded(
            child: Container(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 816),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color:
                          isDark ? const Color(0xFF0F172A) : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: QuillEditor(
                      controller: _controller,
                      focusNode: _editorFocusNode,
                      scrollController: _editorScrollController,
                      config: QuillEditorConfig(
                        placeholder: 'Start typing...',
                        padding: const EdgeInsets.all(32),
                        expands: true,
                      ),
                    ),
                  ),
                ),
              ),
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
                Icon(Icons.text_fields_rounded,
                    size: 14,
                    color:
                        isDark ? Colors.white38 : Colors.grey.shade500),
                const SizedBox(width: 6),
                Text(
                  '$_wordCount words',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        isDark ? Colors.white38 : Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: ColorConst.violate.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'NextDoc',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ColorConst.violate,
                    ),
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
