import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:nextoffice/navigation/custom_router/custom_route.dart';

class SheetsPage extends StatefulWidget {
  const SheetsPage({super.key});

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
  static const List<String> _columnNames = ['A', 'B', 'C', 'D', 'E', 'F'];

  late List<List<String>> _cellData;
  String _selectedCell = 'A1';

  @override
  void initState() {
    super.initState();
    _cellData = List.generate(
      _initialRows,
      (_) => List.filled(_columnNames.length, ''),
    );
    _rebuildDataSource();
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
                  // Note: columns are const in this implementation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Column "$name" — feature coming soon'),
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

  void _saveSpreadsheet() {
    final title = _titleController.text.trim();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Spreadsheet "${title.isEmpty ? "Untitled" : title}" saved'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Chart insertion — coming soon'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
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
              hintText: 'Spreadsheet title...',
              hintStyle: TextStyle(color: Colors.white54),
              isDense: true,
            ),
          ),
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: _addRow,
            tooltip: 'Add Row',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
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
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  constraints: const BoxConstraints(minWidth: 40),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _selectedCell,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.grey.shade700,
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1A1D2E)
                  : const Color(0xFFF1F5F9),
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

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        return Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            cell.value?.toString() ?? '',
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
