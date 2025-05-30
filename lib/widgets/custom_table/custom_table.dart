import 'dart:math';

import 'package:flutter/material.dart';
import 'package:test_scroll/widgets/custom_table/model/table_model.dart';
import 'package:test_scroll/widgets/synced_scroll_controll_widget.dart';

import 'table_data.dart';
import 'table_header.dart';

/// 커스텀 테이블 위젯
/// 동기화된 스크롤과 반응형 컬럼 너비를 지원합니다.
/// 스크롤바는 테이블 위에 오버레이로 표시됩니다.
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

  // 호버 상태 관리
  bool _isHovered = false;

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
            return MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: Stack(
                children: [
                  // 메인 테이블 영역 (전체 공간 사용)
                  SingleChildScrollView(
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
                              verticalController: verticalScrollController,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 세로 스크롤바 (우측 오버레이)
                  if (_config.showVerticalScrollbar)
                    Positioned(
                      top: 0,
                      right: 0,
                      bottom: _config.showHorizontalScrollbar
                          ? _config.scrollbarWidth
                          : 0,
                      child: AnimatedOpacity(
                        opacity: _config.scrollbarHoverOnly
                            ? (_isHovered ? _config.scrollbarOpacity : 0.0)
                            : _config.scrollbarOpacity,
                        duration: _config.scrollbarAnimationDuration,
                        child: Container(
                          width: _config.scrollbarWidth,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                                _config.scrollbarWidth / 2),
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              scrollbarTheme: ScrollbarThemeData(
                                thumbColor: WidgetStateProperty.all(
                                  Colors.black.withOpacity(0.5),
                                ),
                                trackColor: WidgetStateProperty.all(
                                  Colors.transparent,
                                ),
                                radius:
                                    Radius.circular(_config.scrollbarWidth / 2),
                                thickness: WidgetStateProperty.all(
                                    _config.scrollbarWidth - 4),
                              ),
                            ),
                            child: Scrollbar(
                              controller: verticalScrollbarController,
                              thumbVisibility: true,
                              trackVisibility: false,
                              child: SingleChildScrollView(
                                controller: verticalScrollbarController,
                                scrollDirection: Axis.vertical,
                                child: SizedBox(
                                  height: totalContentHeight,
                                  width: _config.scrollbarWidth,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // 가로 스크롤바 (하단 오버레이)
                  if (_config.showHorizontalScrollbar)
                    Positioned(
                      left: 0,
                      right: _config.showVerticalScrollbar
                          ? _config.scrollbarWidth
                          : 0,
                      bottom: 0,
                      child: AnimatedOpacity(
                        opacity: _config.scrollbarHoverOnly
                            ? (_isHovered ? _config.scrollbarOpacity : 0.0)
                            : _config.scrollbarOpacity,
                        duration: _config.scrollbarAnimationDuration,
                        child: Container(
                          height: _config.scrollbarWidth,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                                _config.scrollbarWidth / 2),
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              scrollbarTheme: ScrollbarThemeData(
                                thumbColor: WidgetStateProperty.all(
                                  Colors.black.withOpacity(0.5),
                                ),
                                trackColor: WidgetStateProperty.all(
                                  Colors.transparent,
                                ),
                                radius:
                                    Radius.circular(_config.scrollbarWidth / 2),
                                thickness: WidgetStateProperty.all(
                                    _config.scrollbarWidth - 4),
                              ),
                            ),
                            child: Scrollbar(
                              controller: horizontalScrollbarController,
                              thumbVisibility: true,
                              trackVisibility: false,
                              child: SingleChildScrollView(
                                controller: horizontalScrollbarController,
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                  width: contentWidth,
                                  height: _config.scrollbarWidth,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
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
