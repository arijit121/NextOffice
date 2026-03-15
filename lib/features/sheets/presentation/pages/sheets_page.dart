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

  // Initial grid: 10 rows x 6 columns (A-F)
  static const int _initialRows = 20;
  static const List<String> _columnNames = ['A', 'B', 'C', 'D', 'E', 'F'];

  late List<List<String>> _cellData;

  @override
  void initState() {
    super.initState();
    _cellData = List.generate(
      _initialRows,
      (_) => List.filled(_columnNames.length, ''),
    );
    _dataSource = _SpreadsheetDataSource(
      cellData: _cellData,
      columnNames: _columnNames,
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
      _dataSource = _SpreadsheetDataSource(
        cellData: _cellData,
        columnNames: _columnNames,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          IconButton(
            icon: const Icon(Icons.save_rounded),
            onPressed: () {
              // Save logic
            },
            tooltip: 'Save',
          ),
          const SizedBox(width: 8),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                        color: isDark ? Colors.white30 : Colors.grey.shade400,
                        fontSize: 13,
                      ),
                      isDense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Toolbar ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1D2E) : const Color(0xFFF1F5F9),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                ),
              ),
            ),
            child: Row(
              children: [
                _ToolbarButton(
                  icon: Icons.format_bold_rounded,
                  isDark: isDark,
                  onTap: () {},
                ),
                _ToolbarButton(
                  icon: Icons.format_italic_rounded,
                  isDark: isDark,
                  onTap: () {},
                ),
                _VerticalDivider(isDark: isDark),
                _ToolbarButton(
                  icon: Icons.attach_money_rounded,
                  isDark: isDark,
                  onTap: () {},
                  tooltip: 'Currency',
                ),
                _ToolbarButton(
                  icon: Icons.percent_rounded,
                  isDark: isDark,
                  onTap: () {},
                  tooltip: 'Percentage',
                ),
                _VerticalDivider(isDark: isDark),
                _ToolbarButton(
                  icon: Icons.sort_rounded,
                  isDark: isDark,
                  onTap: () {},
                  tooltip: 'Sort',
                ),
                _ToolbarButton(
                  icon: Icons.filter_list_rounded,
                  isDark: isDark,
                  onTap: () {},
                  tooltip: 'Filter',
                ),
                _VerticalDivider(isDark: isDark),
                _ToolbarButton(
                  icon: Icons.bar_chart_rounded,
                  isDark: isDark,
                  onTap: () {},
                  tooltip: 'Insert Chart',
                ),
              ],
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
                  '${_cellData.length} rows × ${_columnNames.length} columns',
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
  _SpreadsheetDataSource({
    required List<List<String>> cellData,
    required List<String> columnNames,
  }) {
    _rows = cellData
        .map<DataGridRow>(
          (row) => DataGridRow(
            cells: List.generate(
              columnNames.length,
              (colIdx) => DataGridCell<String>(
                columnName: columnNames[colIdx],
                value: row[colIdx],
              ),
            ),
          ),
        )
        .toList();
  }

  List<DataGridRow> _rows = [];

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
    final String displayText =
        dataGridRow.getCells()[rowColumnIndex.columnIndex].value?.toString() ??
            '';
    return _EditCell(
      displayText: displayText,
      submitCell: submitCell,
    );
  }
}

class _EditCell extends StatefulWidget {
  final String displayText;
  final CellSubmit submitCell;
  const _EditCell({required this.displayText, required this.submitCell});

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
          widget.submitCell();
        },
      ),
    );
  }
}
