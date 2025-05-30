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
