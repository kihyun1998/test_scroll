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
