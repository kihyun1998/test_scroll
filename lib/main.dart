import 'package:flutter/material.dart';

import 'widgets/custom_table/custom_table.dart';
import 'widgets/custom_table/model/table_model.dart';

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
        title: const Text('Custom Table Demo - Overlay Scrollbars'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // 고정된 상단 카드
          const Card(
            margin: EdgeInsets.all(8.0),
            child: SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  'Fixed Top Card (100px height)\n마우스를 테이블에 올려보세요!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          // 커스텀 테이블이 들어갈 확장된 영역
          Expanded(
            child: Card(
              margin: const EdgeInsets.all(8.0),
              child: CustomTable(
                config: const CustomTableConfig(
                  // 스크롤바 설정 커스터마이징
                  scrollbarHoverOnly: true, // 호버시에만 표시
                  scrollbarOpacity: 0.9, // 불투명도 90%
                  scrollbarAnimationDuration:
                      Duration(milliseconds: 250), // 애니메이션 속도
                  scrollbarWidth: 14.0, // 스크롤바 두께

                  // 기존 테이블 설정
                  headerHeight: 50.0,
                  rowHeight: 45.0,
                  showHorizontalScrollbar: true,
                  showVerticalScrollbar: true,
                  enableHeaderSorting: true,
                ),
              ),
            ),
          ),

          // 설명 카드
          const Card(
            margin: EdgeInsets.all(8.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '새로운 기능:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text('✅ 스크롤바가 테이블 위에 오버레이로 표시됩니다'),
                  Text('✅ 마우스 호버시에만 나타나고 사라집니다'),
                  Text('✅ 부드러운 애니메이션 효과'),
                  Text('✅ 반투명 배경과 둥근 모서리'),
                  Text('✅ 테이블 터치 영역을 방해하지 않습니다'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
