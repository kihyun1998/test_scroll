# test_scroll
## Project Structure

```
test_scroll/
└── lib/
    ├── widgets/
        ├── custom_table/
        │   ├── model/
        │   │   └── table_model.dart
        │   ├── custom_table.dart
        │   ├── table_data.dart
        │   └── table_header.dart
        └── synced_scroll_controll_widget.dart
    └── main.dart
```

## lib/main.dart
```dart
import 'package:flutter/material.dart';

import 'widgets/custom_table/custom_table.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Table Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Table Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Column(
        children: [
          // 고정된 상단 카드
          Card(
            margin: EdgeInsets.all(8.0),
            child: SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  'Fixed Top Card (100px height)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
          // 커스텀 테이블이 들어갈 확장된 영역
          Expanded(
            child: Card(
              margin: EdgeInsets.all(8.0),
              child: CustomTable(),
            ),
          ),
        ],
      ),
    );
  }
}

```
## lib/widgets/custom_table/custom_table.dart
```dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:test_scroll/widgets/custom_table/model/table_model.dart';
import 'package:test_scroll/widgets/synced_scroll_controll_widget.dart';

import 'table_data.dart';
import 'table_header.dart';

/// 커스텀 테이블 위젯
/// 동기화된 스크롤과 반응형 컬럼 너비를 지원합니다.
class CustomTable extends StatefulWidget {
  final List<CustomTableColumn>? columns;
  final List<List<String>>? data;
  final CustomTableConfig? config;

  const CustomTable({
    super.key,
    this.columns,
    this.data,
    this.config,
  });

  @override
  State<CustomTable> createState() => _CustomTableState();
}

class _CustomTableState extends State<CustomTable> {
  late List<CustomTableColumn> _columns;
  late List<CustomTableRow> _rows;
  late CustomTableConfig _config;

  @override
  void initState() {
    super.initState();
    _initializeTableData();
  }

  void _initializeTableData() {
    // 컬럼 초기화 (기본값 또는 전달받은 값 사용)
    _columns = widget.columns ?? _generateDefaultColumns();

    // 설정 초기화
    _config = widget.config ?? const CustomTableConfig();

    // 행 데이터 초기화
    final rawData = widget.data ?? _generateSampleData();
    _rows = rawData.asMap().entries.map((entry) {
      return CustomTableRow(
        index: entry.key,
        cells: entry.value,
      );
    }).toList();
  }

  /// 기본 컬럼 생성 (5개 컬럼으로 테스트)
  List<CustomTableColumn> _generateDefaultColumns() {
    return [
      const CustomTableColumn(name: 'ID', minWidth: 80.0),
      const CustomTableColumn(name: 'Name', minWidth: 150.0),
      const CustomTableColumn(name: 'Email', minWidth: 200.0),
      const CustomTableColumn(name: 'Department', minWidth: 120.0),
      const CustomTableColumn(name: 'Status', minWidth: 100.0),
    ];
  }

  /// 샘플 데이터 생성
  List<List<String>> _generateSampleData() {
    return List.generate(50, (rowIndex) {
      return [
        '${rowIndex + 1}',
        'User ${rowIndex + 1}',
        'user${rowIndex + 1}@example.com',
        _getDepartment(rowIndex),
        _getStatus(rowIndex),
      ];
    });
  }

  String _getDepartment(int index) {
    final departments = ['Engineering', 'Design', 'Marketing', 'Sales', 'HR'];
    return departments[index % departments.length];
  }

  String _getStatus(int index) {
    final statuses = ['Active', 'Inactive', 'Pending'];
    return statuses[index % statuses.length];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableHeight = constraints.maxHeight;
        final double availableWidth = constraints.maxWidth;

        // 테이블의 최소 너비 계산
        final double minTableWidth =
            _columns.fold(0.0, (sum, col) => sum + col.minWidth);

        // 실제 콘텐츠 너비: 최소 너비와 사용 가능한 너비 중 큰 값
        final double contentWidth = max(minTableWidth, availableWidth);

        // 테이블 데이터 높이 계산
        final double tableDataHeight = _config.rowHeight * _rows.length;

        // 스크롤바를 위한 전체 콘텐츠 높이
        final double totalContentHeight =
            _config.headerHeight + tableDataHeight;

        return SyncedScrollControllers(
          builder: (
            context,
            verticalScrollController,
            verticalScrollbarController,
            horizontalScrollController,
            horizontalScrollbarController,
          ) {
            return Column(
              children: [
                // 테이블 영역 (헤더 + 데이터)
                Expanded(
                  child: Row(
                    children: [
                      // 메인 테이블 영역
                      Expanded(
                        child: SingleChildScrollView(
                          controller: horizontalScrollController,
                          scrollDirection: Axis.horizontal,
                          physics: const ClampingScrollPhysics(),
                          child: SizedBox(
                            width: contentWidth,
                            child: Column(
                              children: [
                                // 테이블 헤더
                                TableHeader(
                                  columns: _columns,
                                  totalWidth: contentWidth,
                                  availableWidth: availableWidth,
                                  config: _config,
                                ),

                                // 테이블 데이터
                                Expanded(
                                  child: TableData(
                                    rows: _rows,
                                    columns: _columns,
                                    availableWidth: availableWidth,
                                    config: _config,
                                    verticalController:
                                        verticalScrollController,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // 세로 스크롤바
                      if (_config.showVerticalScrollbar)
                        SizedBox(
                          width: 20,
                          child: Scrollbar(
                            controller: verticalScrollbarController,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: verticalScrollbarController,
                              scrollDirection: Axis.vertical,
                              child: SizedBox(
                                height: totalContentHeight,
                                width: 20,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // 가로 스크롤바
                if (_config.showHorizontalScrollbar)
                  SizedBox(
                    height: 20,
                    child: Scrollbar(
                      controller: horizontalScrollbarController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: horizontalScrollbarController,
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: contentWidth,
                          height: 20,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void didUpdateWidget(CustomTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.columns != oldWidget.columns ||
        widget.data != oldWidget.data ||
        widget.config != oldWidget.config) {
      _initializeTableData();
    }
  }
}

/// 테이블 사용 예시를 위한 확장
extension CustomTableBuilder on CustomTable {
  /// 빠른 테이블 생성을 위한 팩토리 생성자
  static CustomTable simple({
    required List<String> headers,
    required List<List<String>> data,
    CustomTableConfig? config,
  }) {
    final columns =
        headers.map((header) => CustomTableColumn(name: header)).toList();
    return CustomTable(
      columns: columns,
      data: data,
      config: config,
    );
  }
}

```
## lib/widgets/custom_table/model/table_model.dart
```dart
/// 테이블 컬럼 정보를 나타내는 모델
class CustomTableColumn {
  final String name;
  final double minWidth;
  final double? maxWidth;
  final bool isResizable;

  const CustomTableColumn({
    required this.name,
    this.minWidth = 100.0,
    this.maxWidth,
    this.isResizable = true,
  });

  CustomTableColumn copyWith({
    String? name,
    double? minWidth,
    double? maxWidth,
    bool? isResizable,
  }) {
    return CustomTableColumn(
      name: name ?? this.name,
      minWidth: minWidth ?? this.minWidth,
      maxWidth: maxWidth ?? this.maxWidth,
      isResizable: isResizable ?? this.isResizable,
    );
  }
}

/// 테이블 행 데이터를 나타내는 모델
class CustomTableRow {
  final List<String> cells;
  final int index;

  const CustomTableRow({
    required this.cells,
    required this.index,
  });
}

/// 테이블 설정을 관리하는 모델
class CustomTableConfig {
  final double headerHeight;
  final double rowHeight;
  final bool showHorizontalScrollbar;
  final bool showVerticalScrollbar;
  final bool enableHeaderSorting;

  const CustomTableConfig({
    this.headerHeight = 48.0,
    this.rowHeight = 40.0,
    this.showHorizontalScrollbar = true,
    this.showVerticalScrollbar = true,
    this.enableHeaderSorting = false,
  });

  CustomTableConfig copyWith({
    double? headerHeight,
    double? rowHeight,
    bool? showHorizontalScrollbar,
    bool? showVerticalScrollbar,
    bool? enableHeaderSorting,
  }) {
    return CustomTableConfig(
      headerHeight: headerHeight ?? this.headerHeight,
      rowHeight: rowHeight ?? this.rowHeight,
      showHorizontalScrollbar:
          showHorizontalScrollbar ?? this.showHorizontalScrollbar,
      showVerticalScrollbar:
          showVerticalScrollbar ?? this.showVerticalScrollbar,
      enableHeaderSorting: enableHeaderSorting ?? this.enableHeaderSorting,
    );
  }
}

```
## lib/widgets/custom_table/table_data.dart
```dart
import 'package:flutter/material.dart';
import 'package:test_scroll/widgets/custom_table/model/table_model.dart';

/// 테이블 데이터를 렌더링하는 위젯
class TableData extends StatelessWidget {
  final List<CustomTableRow> rows;
  final List<CustomTableColumn> columns;
  final double availableWidth;
  final CustomTableConfig config;
  final ScrollController verticalController;

  const TableData({
    super.key,
    required this.rows,
    required this.columns,
    required this.availableWidth,
    required this.config,
    required this.verticalController,
  });

  /// 각 컬럼의 실제 렌더링 너비를 계산합니다.
  /// 헤더와 동일한 로직을 사용합니다.
  List<double> _calculateColumnWidths() {
    final double totalMinWidth =
        columns.fold(0.0, (sum, col) => sum + col.minWidth);

    if (totalMinWidth >= availableWidth) {
      return columns.map((col) => col.minWidth).toList();
    } else {
      final double expansionRatio = availableWidth / totalMinWidth;
      return columns.map((col) => col.minWidth * expansionRatio).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<double> columnWidths = _calculateColumnWidths();

    return ListView.builder(
      controller: verticalController,
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final row = rows[index];
        return _DataRow(
          row: row,
          columnWidths: columnWidths,
          config: config,
        );
      },
    );
  }
}

/// 개별 데이터 행 위젯
class _DataRow extends StatelessWidget {
  final CustomTableRow row;
  final List<double> columnWidths;
  final CustomTableConfig config;

  const _DataRow({
    required this.row,
    required this.columnWidths,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        row.index % 2 == 0 ? Colors.white : Colors.grey[50]!;

    return Container(
      height: config.rowHeight,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: const Border(
          bottom: BorderSide(color: Colors.grey, width: 0.3),
        ),
      ),
      child: Row(
        children: List.generate(row.cells.length, (cellIndex) {
          final cellData =
              cellIndex < row.cells.length ? row.cells[cellIndex] : '';
          final cellWidth =
              cellIndex < columnWidths.length ? columnWidths[cellIndex] : 100.0;

          return _DataCell(
            data: cellData,
            width: cellWidth,
            config: config,
          );
        }),
      ),
    );
  }
}

/// 개별 데이터 셀 위젯
class _DataCell extends StatelessWidget {
  final String data;
  final double width;
  final CustomTableConfig config;

  const _DataCell({
    required this.data,
    required this.width,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: config.rowHeight,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey, width: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            data,
            style: const TextStyle(fontSize: 13),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}

```
## lib/widgets/custom_table/table_header.dart
```dart
import 'package:flutter/material.dart';
import 'package:test_scroll/widgets/custom_table/model/table_model.dart';

/// 테이블 헤더를 렌더링하는 위젯
class TableHeader extends StatelessWidget {
  final List<CustomTableColumn> columns;
  final double totalWidth;
  final double availableWidth;
  final CustomTableConfig config;

  const TableHeader({
    super.key,
    required this.columns,
    required this.totalWidth,
    required this.availableWidth,
    required this.config,
  });

  /// 각 컬럼의 실제 렌더링 너비를 계산합니다.
  /// minWidth의 합이 availableWidth보다 작으면 비례적으로 확장합니다.
  List<double> _calculateColumnWidths() {
    final double totalMinWidth =
        columns.fold(0.0, (sum, col) => sum + col.minWidth);

    if (totalMinWidth >= availableWidth) {
      // 최소 너비의 합이 화면보다 크거나 같으면 minWidth 그대로 사용
      return columns.map((col) => col.minWidth).toList();
    } else {
      // 화면보다 작으면 비례적으로 확장
      final double expansionRatio = availableWidth / totalMinWidth;
      return columns.map((col) => col.minWidth * expansionRatio).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<double> columnWidths = _calculateColumnWidths();

    return Container(
      width: totalWidth,
      height: config.headerHeight,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: const Border(
          bottom: BorderSide(color: Colors.grey, width: 1),
        ),
      ),
      child: Row(
        children: List.generate(columns.length, (index) {
          final column = columns[index];
          final width = columnWidths[index];

          return _HeaderCell(
            column: column,
            width: width,
            config: config,
          );
        }),
      ),
    );
  }
}

/// 개별 헤더 셀 위젯
class _HeaderCell extends StatelessWidget {
  final CustomTableColumn column;
  final double width;
  final CustomTableConfig config;

  const _HeaderCell({
    required this.column,
    required this.width,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: config.headerHeight,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:
              config.enableHeaderSorting ? () => _onHeaderTap(context) : null,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    column.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (config.enableHeaderSorting)
                  const Icon(
                    Icons.sort,
                    size: 16,
                    color: Colors.grey,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onHeaderTap(BuildContext context) {
    // TODO: 정렬 기능 구현
    debugPrint('Header tapped: ${column.name}');
  }
}

```
## lib/widgets/synced_scroll_controll_widget.dart
```dart
import 'package:flutter/material.dart';

/// 여러 ScrollController를 동기화해주는 위젯
/// 수직/수평 스크롤을 각각 메인 컨트롤러와 스크롤바 컨트롤러로 동기화합니다.
class SyncedScrollControllers extends StatefulWidget {
  const SyncedScrollControllers({
    super.key,
    required this.builder,
    this.scrollController,
    this.verticalScrollbarController,
    this.horizontalScrollController,
    this.horizontalScrollbarController,
  });

  final ScrollController? scrollController;
  final ScrollController? verticalScrollbarController;
  final ScrollController? horizontalScrollController;
  final ScrollController? horizontalScrollbarController;

  final Widget Function(
    BuildContext context,
    ScrollController verticalDataController,
    ScrollController verticalScrollbarController,
    ScrollController horizontalMainController,
    ScrollController horizontalScrollbarController,
  ) builder;

  @override
  State<SyncedScrollControllers> createState() =>
      _SyncedScrollControllersState();
}

class _SyncedScrollControllersState extends State<SyncedScrollControllers> {
  ScrollController? _sc11; // 메인 수직 (ListView 용)
  late ScrollController _sc12; // 수직 스크롤바
  ScrollController? _sc21; // 메인 수평 (헤더 & 데이터 공통)
  late ScrollController _sc22; // 수평 스크롤바

  // 각 컨트롤러에 대한 리스너들을 명확하게 관리하기 위한 Map
  final Map<ScrollController, VoidCallback> _listenersMap = {};

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(SyncedScrollControllers oldWidget) {
    super.didUpdateWidget(oldWidget);
    _disposeOrUnsubscribe();
    _initControllers();
  }

  @override
  void dispose() {
    _disposeOrUnsubscribe();
    super.dispose();
  }

  void _initControllers() {
    _doNotReissueJump.clear();

    // 수직 스크롤 컨트롤러 (메인, ListView 용)
    _sc11 = widget.scrollController ?? ScrollController();

    // 수평 스크롤 컨트롤러 (메인, 헤더와 데이터 영역의 가로 스크롤 공통)
    _sc21 = widget.horizontalScrollController ?? ScrollController();

    // 수직 스크롤바 컨트롤러
    _sc12 = widget.verticalScrollbarController ??
        ScrollController(
          initialScrollOffset: _sc11!.hasClients && _sc11!.positions.isNotEmpty
              ? _sc11!.offset
              : 0.0,
        );

    // 수평 스크롤바 컨트롤러
    _sc22 = widget.horizontalScrollbarController ??
        ScrollController(
          initialScrollOffset: _sc21!.hasClients && _sc21!.positions.isNotEmpty
              ? _sc21!.offset
              : 0.0,
        );

    // 각 쌍의 컨트롤러를 동기화합니다.
    _syncScrollControllers(_sc11!, _sc12);
    _syncScrollControllers(_sc21!, _sc22);
  }

  void _disposeOrUnsubscribe() {
    // 모든 리스너 제거
    _listenersMap.forEach((controller, listener) {
      controller.removeListener(listener);
    });
    _listenersMap.clear();

    // 위젯에서 제공된 컨트롤러가 아니면 직접 dispose
    if (widget.scrollController == null) _sc11?.dispose();
    if (widget.horizontalScrollController == null) _sc21?.dispose();
    if (widget.verticalScrollbarController == null) _sc12.dispose();
    if (widget.horizontalScrollbarController == null) _sc22.dispose();
  }

  final Map<ScrollController, bool> _doNotReissueJump = {};

  void _syncScrollControllers(ScrollController master, ScrollController slave) {
    // 마스터 컨트롤러에 리스너 추가
    masterListener() => _jumpToNoCascade(master, slave);
    master.addListener(masterListener);
    _listenersMap[master] = masterListener;

    // 슬레이브 컨트롤러에 리스너 추가
    slaveListener() => _jumpToNoCascade(slave, master);
    slave.addListener(slaveListener);
    _listenersMap[slave] = slaveListener;
  }

  void _jumpToNoCascade(ScrollController master, ScrollController slave) {
    if (!master.hasClients || !slave.hasClients || slave.position.outOfRange) {
      return;
    }

    if (_doNotReissueJump[master] == null ||
        _doNotReissueJump[master]! == false) {
      _doNotReissueJump[slave] = true;
      slave.jumpTo(master.offset);
    } else {
      _doNotReissueJump[master] = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(
        context,
        _sc11!,
        _sc12,
        _sc21!,
        _sc22,
      );
}

```
