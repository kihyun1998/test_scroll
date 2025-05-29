import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            title: const Text(
                'Synced Scroll Controllers Demo with Integrated Table Scroll')),
        body: Column(
          children: [
            // 고정된 상단 카드 (이전과 동일)
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Container(
                height: 100,
                alignment: Alignment.center,
                child: const Text('Fixed Top Card (100px height)'),
              ),
            ),
            // 남은 공간을 차지하는 확장된 카드 (커스텀 테이블 포함)
            Expanded(
              child: Card(
                margin: const EdgeInsets.all(8.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double availableHeight = constraints.maxHeight;
                    final double availableWidth = constraints.maxWidth;

                    // 테이블 데이터 생성 (예시)
                    final List<List<String>> tableData =
                        _generateTableData(50, 20); // 50행, 20열 데이터

                    // 컬럼 헤더 정의 (각 컬럼의 최소 너비를 포함)
                    final List<Map<String, dynamic>> columnHeaders =
                        _generateColumnHeaders(tableData[0].length);

                    // 테이블의 동적인 너비 계산: 모든 컬럼의 최소 너비 합계
                    final double calculatedTableWidth = columnHeaders.fold(0.0,
                        (sum, header) => sum + (header['minWidth'] as double));

                    // 테이블 데이터 부분의 높이 계산: (행 개수 * 행 높이)
                    final double calculatedTableDataHeight =
                        _getTableRowHeight() * tableData.length;

                    // 스크롤 가능한 콘텐츠의 최종 너비와 높이를 결정합니다.
                    // (헤더 높이를 고려하지 않은 데이터 부분만의 스크롤 영역 높이)
                    final double contentWidth =
                        max(calculatedTableWidth, availableWidth);
                    // ListView의 높이는 실제 테이블 데이터 높이 + 헤더 높이만큼 필요.
                    // 여기서는 ListView가 Expnaded 안의 SingleChildScrollView 안에 들어가고,
                    // 그 SingleChildScrollView가 contentHeight를 가짐.
                    // 실제 ListView의 height는 calculatedTableDataHeight.
                    // 하지만 스크롤바 height는 전체 컨텐츠 높이(_getTableHeaderHeight() + calculatedTableDataHeight)를 따라가야 함.
                    final double totalContentHeightForScrollbar =
                        _getTableHeaderHeight() + calculatedTableDataHeight;

                    return SyncedScrollControllers(
                      builder: (context,
                          verticalScrollController,
                          verticalScrollbarController,
                          horizontalScrollController,
                          horizontalScrollbarController) {
                        return Column(
                          children: [
                            // ----------------- 테이블 전체 가로 스크롤 영역 -----------------
                            // 헤더와 데이터를 하나의 가로 SingleChildScrollView로 감쌉니다.
                            Expanded(
                              // 세로 공간을 채웁니다.
                              child: Row(
                                children: [
                                  Expanded(
                                    // 가로 공간을 채웁니다.
                                    child: SingleChildScrollView(
                                      controller:
                                          horizontalScrollController, // 가로 스크롤 컨트롤러 (헤더/데이터 공통)
                                      scrollDirection: Axis.horizontal,
                                      physics:
                                          const ClampingScrollPhysics(), // 스크롤바가 끝에 닿으면 고정
                                      child: SizedBox(
                                        width:
                                            contentWidth, // 계산된 테이블 전체 너비만큼 확장
                                        // height는 Expanded가 처리하므로 지정하지 않습니다.
                                        child: Column(
                                          // 헤더와 데이터 영역을 세로로 배치
                                          children: [
                                            // --------------- 테이블 헤더 ---------------
                                            _buildTableHeaderRow(columnHeaders,
                                                calculatedTableWidth),
                                            const Divider(
                                                height: 1), // 헤더와 데이터 분리선

                                            // --------------- 테이블 데이터 (세로 스크롤) ---------------
                                            Expanded(
                                              // 남은 세로 공간을 데이터가 채우고 자체 세로 스크롤
                                              child: _buildTableData(
                                                  tableData,
                                                  columnHeaders,
                                                  verticalScrollController),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // 세로 스크롤바 영역 (테이블의 세로 스크롤과 동기화)
                                  SizedBox(
                                    width: 20,
                                    child: Scrollbar(
                                      controller: verticalScrollbarController,
                                      thumbVisibility: true,
                                      child: SingleChildScrollView(
                                        // 스크롤바 자체 스크롤 (hidden content)
                                        controller: verticalScrollbarController,
                                        scrollDirection: Axis.vertical,
                                        child: SizedBox(
                                          height:
                                              totalContentHeightForScrollbar, // 스크롤바 높이도 동기화
                                          width: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // 가로 스크롤바 영역 (전체 테이블의 가로 스크롤과 동기화)
                            SizedBox(
                              height: 20,
                              child: Scrollbar(
                                controller: horizontalScrollbarController,
                                thumbVisibility: true,
                                child: SingleChildScrollView(
                                  // 스크롤바 자체 스크롤 (hidden content)
                                  controller: horizontalScrollbarController,
                                  scrollDirection: Axis.horizontal,
                                  child: SizedBox(
                                    width: contentWidth, // 스크롤바 너비도 동기화
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - Custom Table 구성 요소 헬퍼 함수

  // 임의의 테이블 데이터 생성
  List<List<String>> _generateTableData(int rows, int cols) {
    return List.generate(rows, (rowIndex) {
      return List.generate(cols, (colIndex) {
        return 'Cell R${rowIndex + 1}C${colIndex + 1}';
      });
    });
  }

  // 컬럼 헤더 정의 (각 컬럼의 최소 너비를 포함)
  List<Map<String, dynamic>> _generateColumnHeaders(int numCols) {
    return List.generate(numCols, (index) {
      final double minWidth = 120.0 + (index % 5) * 10; // 예시: 컬럼마다 다른 최소 너비
      return {'name': 'Column ${index + 1}', 'minWidth': minWidth};
    });
  }

  // 헤더 행 위젯 빌드
  Widget _buildTableHeaderRow(
      List<Map<String, dynamic>> headers, double totalWidth) {
    return Container(
      width: totalWidth, // 계산된 테이블 전체 너비만큼 확장
      height: _getTableHeaderHeight(),
      color: Colors.grey[200],
      child: Row(
        children: headers.map((header) {
          return SizedBox(
            width: header['minWidth'] as double,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  header['name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 데이터 영역 위젯 빌드 (ListView.builder 사용)
  Widget _buildTableData(List<List<String>> data,
      List<Map<String, dynamic>> headers, ScrollController verticalController) {
    return ListView.builder(
      controller: verticalController, // SyncedScrollControllers의 수직 컨트롤러와 연결
      itemCount: data.length,
      itemBuilder: (context, rowIndex) {
        return _buildTableRow(data[rowIndex], headers, rowIndex);
      },
    );
  }

  // 각 테이블 행 위젯 빌드
  Widget _buildTableRow(
      List<String> rowData, List<Map<String, dynamic>> headers, int rowIndex) {
    final Color rowColor = rowIndex % 2 == 0 ? Colors.white : Colors.grey[50]!;
    return Container(
      height: _getTableRowHeight(),
      color: rowColor,
      child: Row(
        children: List.generate(rowData.length, (colIndex) {
          final double cellWidth = headers[colIndex]['minWidth'] as double;
          return SizedBox(
            width: cellWidth,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                rowData[colIndex],
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }),
      ),
    );
  }

  // 상수 값 (필요에 따라 변경)
  double _getTableHeaderHeight() => 48.0;
  double _getTableRowHeight() => 40.0;
}

// SyncedScrollControllers 위젯 (이전 코드와 동일, 리스너 제거 로직 수정)
class SyncedScrollControllers extends StatefulWidget {
  const SyncedScrollControllers({
    super.key,
    required this.builder,
    this.scrollController, // 수직 메인 스크롤 컨트롤러 (sc11)
    this.verticalScrollbarController, // 수직 스크롤바 컨트롤러 (sc12)
    this.horizontalScrollController, // 수평 메인 스크롤 컨트롤러 (sc21)
    this.horizontalScrollbarController, // 수평 스크롤바 컨트롤러 (sc22)
  });

  final ScrollController? scrollController;
  final ScrollController? verticalScrollbarController;
  final ScrollController? horizontalScrollController;
  final ScrollController? horizontalScrollbarController;

  final Widget Function(
    BuildContext context,
    ScrollController verticalDataController,
    ScrollController verticalScrollbarController,
    ScrollController horizontalMainController, // 헤더와 데이터가 함께 가로 스크롤될 컨트롤러
    ScrollController horizontalScrollbarController,
  ) builder;

  @override
  SyncedScrollControllersState createState() => SyncedScrollControllersState();
}

class SyncedScrollControllersState extends State<SyncedScrollControllers> {
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
    _disposeOrUnsubscribe(); // 기존 리스너 및 컨트롤러 해제
    _initControllers(); // 새 컨트롤러 초기화
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
    _syncScrollControllers(_sc11!, _sc12); // 수직 메인 <-> 수직 스크롤바
    _syncScrollControllers(_sc21!, _sc22); // 수평 메인 <-> 수평 스크롤바
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
    _listenersMap[master] = masterListener; // 리스너 맵에 저장

    // 슬레이브 컨트롤러에 리스너 추가
    slaveListener() => _jumpToNoCascade(slave, master);
    slave.addListener(slaveListener);
    _listenersMap[slave] = slaveListener; // 리스너 맵에 저장
  }

  void _jumpToNoCascade(ScrollController master, ScrollController slave) {
    if (!master.hasClients || !slave.hasClients || slave.position.outOfRange) {
      return;
    }
    // 이 컨트롤러가 이미 다른 컨트롤러로부터 점프 명령을 받았는지 확인
    if (_doNotReissueJump[master] == null ||
        _doNotReissueJump[master]! == false) {
      _doNotReissueJump[slave] = true; // 슬레이브에 점프 명령 발행 표시
      slave.jumpTo(master.offset);
    } else {
      _doNotReissueJump[master] = false; // 점프 명령 처리 완료 표시
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(
      context, _sc11!, _sc12, _sc21!, _sc22); // _sc21이 헤더/데이터 공통 가로 스크롤 컨트롤러
}
