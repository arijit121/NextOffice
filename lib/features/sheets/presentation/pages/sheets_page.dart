import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:nextoffice/features/shared/data/local_storage_service.dart';
import 'package:nextoffice/navigation/custom_router/custom_route.dart';

class SheetsPage extends StatefulWidget {
  final String? fileId;
  const SheetsPage({super.key, this.fileId});

  @override
  State<SheetsPage> createState() => _SheetsPageState();
}

class _SheetsPageState extends State<SheetsPage> {
  late _SpreadsheetDataSource _dataSource;
  final TextEditingController _formulaController = TextEditingController();
  final TextEditingController _titleController = TextEditingController(
    text: 'Untitled Spreadsheet',
  );

  static const int _initialRows = 20;
  List<String> _columnNames = ['A', 'B', 'C', 'D', 'E', 'F'];

  late List<List<String>> _cellData;
  String _selectedCell = 'A1';
  final LocalStorageService _storage = LocalStorageService();
  LocalFileData? _localFile;

  @override
  void initState() {
    super.initState();
    _cellData = List.generate(
      _initialRows,
      (_) => List.filled(_columnNames.length, ''),
    );
    _rebuildDataSource();
    _loadSpreadsheet();
  }

  Future<void> _loadSpreadsheet() async {
    if (widget.fileId == null) return;
    final file = await _storage.getFile(widget.fileId!);
    if (file != null && mounted) {
      setState(() {
        _localFile = file;
        _titleController.text = file.name;
      });
      if (file.payload.isNotEmpty) {
        try {
          final decoded = jsonDecode(file.payload) as Map<String, dynamic>;
          if (decoded.containsKey('columns')) {
            _columnNames = List<String>.from(decoded['columns']);
          }
          if (decoded.containsKey('cells')) {
            final List<dynamic> rows = decoded['cells'];
            _cellData = rows.map((r) => List<String>.from(r)).toList();
          }
          _rebuildDataSource();
        } catch (e) {
          // ignore parsing error
        }
      }
    }
  }

  void _rebuildDataSource() {
    _dataSource = _SpreadsheetDataSource(
      cellData: _cellData,
      columnNames: _columnNames,
      onCellValueChanged: (int row, int col, String newValue) {
        setState(() {
          _cellData[row][col] = newValue;
        });
      },
      onCellSelected: (int row, int col) {
        setState(() {
          _selectedCell = '${_columnNames[col]}${row + 1}';
          _formulaController.text = _cellData[row][col];
        });
      },
    );
  }

  @override
  void dispose() {
    _formulaController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _addRow() {
    setState(() {
      _cellData.add(List.filled(_columnNames.length, ''));
      _rebuildDataSource();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Row ${_cellData.length} added'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _addColumn() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Column'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Column name (e.g. G)',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = controller.text.trim().toUpperCase();
                if (name.isNotEmpty) {
                  Navigator.pop(context);
                  setState(() {
                    _columnNames.add(name);
                    for (var row in _cellData) {
                      row.add('');
                    }
                    _rebuildDataSource();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Column "$name" added successfully'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveSpreadsheet() async {
    final title = _titleController.text.trim();
    final payloadMap = {
      'columns': _columnNames,
      'cells': _cellData,
    };
    final jsonString = jsonEncode(payloadMap);

    if (_localFile != null) {
      _localFile!.name = title.isEmpty ? "Untitled Spreadsheet" : title;
      _localFile!.payload = jsonString;
      await _storage.saveFile(_localFile!);
    } else {
      final newFile = LocalFileData(
        id: _storage.generateId(),
        name: title.isEmpty ? "Untitled Spreadsheet" : title,
        type: 'sheet',
        createdAt: DateTime.now(),
        payload: jsonString,
      );
      await _storage.saveFile(newFile);
      setState(() => _localFile = newFile);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Spreadsheet "${title.isEmpty ? "Untitled Spreadsheet" : title}" saved'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String? sortColumn;
        bool ascending = true;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Sort Data'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Sort by column',
                    border: OutlineInputBorder(),
                  ),
                  items: _columnNames
                      .map((c) => DropdownMenuItem(value: c, child: Text('Column $c')))
                      .toList(),
                  onChanged: (v) => setDialogState(() => sortColumn = v),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Ascending'),
                  value: ascending,
                  onChanged: (v) => setDialogState(() => ascending = v),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (sortColumn != null) {
                    final colIndex = _columnNames.indexOf(sortColumn!);
                    setState(() {
                      _cellData.sort((a, b) {
                        final cmp = a[colIndex].compareTo(b[colIndex]);
                        return ascending ? cmp : -cmp;
                      });
                      _rebuildDataSource();
                    });
                  }
                  Navigator.pop(context);
                },
                child: const Text('Sort'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String? filterColumn;
        final filterController = TextEditingController();
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Filter Data'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Filter column',
                    border: OutlineInputBorder(),
                  ),
                  items: _columnNames
                      .map((c) => DropdownMenuItem(value: c, child: Text('Column $c')))
                      .toList(),
                  onChanged: (v) => setDialogState(() => filterColumn = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: filterController,
                  decoration: const InputDecoration(
                    labelText: 'Contains text',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Clear filter — show all rows
                  setState(() {
                    _rebuildDataSource();
                  });
                  Navigator.pop(context);
                },
                child: const Text('Clear'),
              ),
              FilledButton(
                onPressed: () {
                  final query = filterController.text.trim().toLowerCase();
                  if (filterColumn != null && query.isNotEmpty) {
                    final colIndex = _columnNames.indexOf(filterColumn!);
                    final filtered = _cellData
                        .where(
                            (row) => row[colIndex].toLowerCase().contains(query))
                        .toList();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Found ${filtered.length} matching rows'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }
                  Navigator.pop(context);
                },
                child: const Text('Filter'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _insertChart() {
    showDialog(
      context: context,
      builder: (context) {
        // Build chart data from the first two columns (up to 10 rows)
        final List<Map<String, dynamic>> chartData = [];
        for (var row in _cellData) {
          if (row.length >= 2 && row[0].isNotEmpty && row[1].isNotEmpty) {
            final val = double.tryParse(row[1]);
            if (val != null) {
              chartData.add({'category': row[0], 'value': val});
            }
          }
          if (chartData.length >= 10) break;
        }

        return AlertDialog(
          title: const Text('Chart Preview'),
          content: SizedBox(
            width: 400,
            height: 300,
            child: chartData.isEmpty
                ? const Center(child: Text('Not enough data. Fill first two columns with labels and numbers.'))
                : SfCartesianChart(
                    primaryXAxis: const CategoryAxis(),
                    series: <CartesianSeries>[
                      ColumnSeries<Map<String, dynamic>, String>(
                        dataSource: chartData,
                        xValueMapper: (Map<String, dynamic> data, _) => data['category'] as String,
                        yValueMapper: (Map<String, dynamic> data, _) => data['value'] as double,
                        name: 'Data',
                        color: Colors.green,
                      )
                    ],
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content:
            const Text('This will remove all cell values. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                for (var row in _cellData) {
                  for (int i = 0; i < row.length; i++) {
                    row[i] = '';
                  }
                }
                _rebuildDataSource();
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
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
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F2F1),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white70 : Colors.black87),
          onPressed: () => CustomRoute.back(),
        ),
        title: SizedBox(
          width: 300,
          child: TextField(
            controller: _titleController,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: isDark ? Colors.white : Colors.black87,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Spreadsheet title...',
              hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black38),
              isDense: true,
            ),
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline_rounded, color: isDark ? Colors.white70 : Colors.black87),
            onPressed: _addRow,
            tooltip: 'Add Row',
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: isDark ? Colors.white70 : Colors.black87),
            onSelected: (value) {
              switch (value) {
                case 'save':
                  _saveSpreadsheet();
                  break;
                case 'add_col':
                  _addColumn();
                  break;
                case 'clear':
                  _clearAll();
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
                value: 'add_col',
                child: ListTile(
                  leading: Icon(Icons.view_column_rounded),
                  title: Text('Add Column'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: ListTile(
                  leading: Icon(Icons.delete_sweep_rounded, color: Colors.red),
                  title: Text('Clear All', style: TextStyle(color: Colors.red)),
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
          // ── Formula Bar ──
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade300, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  constraints: const BoxConstraints(minWidth: 40),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _selectedCell,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.green.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'fx',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? Colors.white54 : Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _formulaController,
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'monospace',
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter formula or value...',
                      hintStyle: TextStyle(
                        color:
                            isDark ? Colors.white30 : Colors.grey.shade400,
                        fontSize: 13,
                      ),
                      isDense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onSubmitted: (value) {
                      // Parse the selected cell and apply the formula bar value
                      final col = _selectedCell.substring(0, 1);
                      final row = int.tryParse(_selectedCell.substring(1));
                      if (row != null && row > 0 && row <= _cellData.length) {
                        final colIndex = _columnNames.indexOf(col);
                        if (colIndex >= 0) {
                          setState(() {
                            _cellData[row - 1][colIndex] = value;
                            _rebuildDataSource();
                          });
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Toolbar ──
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _ToolbarButton(
                    icon: Icons.format_bold_rounded,
                    isDark: isDark,
                    tooltip: 'Bold',
                    onTap: () => _showFormatFeedback('Bold'),
                  ),
                  _ToolbarButton(
                    icon: Icons.format_italic_rounded,
                    isDark: isDark,
                    tooltip: 'Italic',
                    onTap: () => _showFormatFeedback('Italic'),
                  ),
                  _ToolbarButton(
                    icon: Icons.format_underline_rounded,
                    isDark: isDark,
                    tooltip: 'Underline',
                    onTap: () => _showFormatFeedback('Underline'),
                  ),
                  _VerticalDivider(isDark: isDark),
                  _ToolbarButton(
                    icon: Icons.attach_money_rounded,
                    isDark: isDark,
                    tooltip: 'Currency',
                    onTap: () => _showFormatFeedback('Currency format'),
                  ),
                  _ToolbarButton(
                    icon: Icons.percent_rounded,
                    isDark: isDark,
                    tooltip: 'Percentage',
                    onTap: () => _showFormatFeedback('Percentage format'),
                  ),
                  _VerticalDivider(isDark: isDark),
                  _ToolbarButton(
                    icon: Icons.sort_rounded,
                    isDark: isDark,
                    tooltip: 'Sort',
                    onTap: _showSortDialog,
                  ),
                  _ToolbarButton(
                    icon: Icons.filter_list_rounded,
                    isDark: isDark,
                    tooltip: 'Filter',
                    onTap: _showFilterDialog,
                  ),
                  _VerticalDivider(isDark: isDark),
                  _ToolbarButton(
                    icon: Icons.bar_chart_rounded,
                    isDark: isDark,
                    tooltip: 'Insert Chart',
                    onTap: _insertChart,
                  ),
                ],
              ),
            ),
          ),

          // ── Data Grid ──
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: SfDataGrid(
                  source: _dataSource,
                  columnWidthMode: ColumnWidthMode.fill,
              gridLinesVisibility: GridLinesVisibility.both,
              headerGridLinesVisibility: GridLinesVisibility.both,
              selectionMode: SelectionMode.single,
              navigationMode: GridNavigationMode.cell,
              allowEditing: true,
              editingGestureType: EditingGestureType.tap,
              headerRowHeight: 36,
              rowHeight: 32,
              columns: _columnNames
                  .map(
                    (col) => GridColumn(
                      columnName: col,
                      width: double.nan,
                      label: Container(
                        alignment: Alignment.center,
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFE2E8F0),
                        child: Text(
                          col,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
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
                Text(
                  '${_cellData.length} rows × ${_columnNames.length} columns',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Cell: $_selectedCell',
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
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'NextSheet',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
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

  void _showFormatFeedback(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$format applied to $_selectedCell'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

// ━━━━━━━━━━━━━ Toolbar Widgets ━━━━━━━━━━━━━

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;
  final String? tooltip;

  const _ToolbarButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 18,
            color: isDark ? Colors.white54 : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  final bool isDark;
  const _VerticalDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: isDark ? Colors.white12 : Colors.grey.shade300,
    );
  }
}

// ━━━━━━━━━━━━━ DataGrid Source ━━━━━━━━━━━━━

class _SpreadsheetDataSource extends DataGridSource {
  final void Function(int row, int col, String value) onCellValueChanged;
  final void Function(int row, int col) onCellSelected;
  final List<List<String>> _cellData;
  final List<String> _columnNames;

  _SpreadsheetDataSource({
    required List<List<String>> cellData,
    required List<String> columnNames,
    required this.onCellValueChanged,
    required this.onCellSelected,
  })  : _cellData = cellData,
        _columnNames = columnNames {
    _buildRows();
  }

  List<DataGridRow> _rows = [];

  void _buildRows() {
    _rows = _cellData
        .map<DataGridRow>(
          (row) => DataGridRow(
            cells: List.generate(
              _columnNames.length,
              (colIdx) => DataGridCell<String>(
                columnName: _columnNames[colIdx],
                value: row[colIdx],
              ),
            ),
          ),
        )
        .toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  String _evaluateFormula(String input) {
    if (!input.startsWith('=')) return input;
    
    String formula = input.substring(1).toUpperCase().trim();
    if (formula.startsWith('SUM(') && formula.endsWith(')')) {
      final range = formula.substring(4, formula.length - 1).split(':');
      if (range.length == 2) {
        return _computeRange(range[0], range[1], (values) => values.fold(0.0, (a, b) => a + b));
      }
    } else if (formula.startsWith('AVERAGE(') && formula.endsWith(')')) {
      final range = formula.substring(8, formula.length - 1).split(':');
      if (range.length == 2) {
        return _computeRange(range[0], range[1], (values) => values.isEmpty ? 0 : values.fold(0.0, (a, b) => a + b) / values.length);
      }
    } else if (formula.startsWith('COUNT(') && formula.endsWith(')')) {
      final range = formula.substring(6, formula.length - 1).split(':');
      if (range.length == 2) {
        return _computeRange(range[0], range[1], (values) => values.length.toDouble());
      }
    }
    
    return '#UNKNOWN!'; // Basic fallback for unsupported formulas
  }

  String _computeRange(String start, String end, double Function(List<double>) operation) {
    List<double> values = [];
    final c1 = start.replaceAll(RegExp(r'[0-9]'), '');
    final r1 = int.tryParse(start.replaceAll(RegExp(r'[A-Z]'), '')) ?? 1;
    final c2 = end.replaceAll(RegExp(r'[0-9]'), '');
    final r2 = int.tryParse(end.replaceAll(RegExp(r'[A-Z]'), '')) ?? 1;
    
    final colStartIdx = _columnNames.indexOf(c1);
    final colEndIdx = _columnNames.indexOf(c2);
    
    if (colStartIdx >= 0 && colEndIdx >= 0 && r1 >= 1 && r2 >= 1) {
      final actualColStart = colStartIdx < colEndIdx ? colStartIdx : colEndIdx;
      final actualColEnd = colStartIdx > colEndIdx ? colStartIdx : colEndIdx;
      final actualRowStart = r1 < r2 ? r1 : r2;
      final actualRowEnd = r1 > r2 ? r1 : r2;
      
      for (int c = actualColStart; c <= actualColEnd; c++) {
        for (int r = actualRowStart - 1; r < actualRowEnd; r++) {
          if (r >= 0 && r < _cellData.length && c < _columnNames.length) {
            String raw = _cellData[r][c];
            // Resolve recursively in case pointing to another formula
            String resolved = raw.startsWith('=') ? _evaluateFormula(raw) : raw;
            final cellVal = double.tryParse(resolved);
            if (cellVal != null) values.add(cellVal);
          }
        }
      }
    }
    final result = operation(values);
    // Return integer formatting if no decimals needed
    return result == result.toInt() ? result.toInt().toString() : result.toStringAsFixed(2);
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        String val = cell.value?.toString() ?? '';
        String display = val.startsWith('=') ? _evaluateFormula(val) : val;
        
        return Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            display,
            style: const TextStyle(fontSize: 13),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget? buildEditWidget(DataGridRow dataGridRow,
      RowColumnIndex rowColumnIndex, GridColumn column,
      CellSubmit submitCell) {
    final int rowIndex = _rows.indexOf(dataGridRow);
    final int colIndex = rowColumnIndex.columnIndex;

    onCellSelected(rowIndex, colIndex);

    final String displayText =
        dataGridRow.getCells()[colIndex].value?.toString() ?? '';
    return _EditCell(
      displayText: displayText,
      onSubmit: (newValue) {
        onCellValueChanged(rowIndex, colIndex, newValue);
      },
      submitCell: submitCell,
    );
  }
}

class _EditCell extends StatefulWidget {
  final String displayText;
  final CellSubmit submitCell;
  final void Function(String value) onSubmit;

  const _EditCell({
    required this.displayText,
    required this.submitCell,
    required this.onSubmit,
  });

  @override
  State<_EditCell> createState() => _EditCellState();
}

class _EditCellState extends State<_EditCell> {
  late TextEditingController _editController;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.displayText);
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.centerLeft,
      child: TextField(
        autofocus: true,
        controller: _editController,
        style: const TextStyle(fontSize: 13),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
        ),
        onSubmitted: (value) {
          widget.onSubmit(value);
          widget.submitCell();
        },
      ),
    );
  }
}
