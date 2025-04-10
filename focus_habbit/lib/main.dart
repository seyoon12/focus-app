import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // ✅ 추가: 로케일 초기화용
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko'); // ✅ 한국어 로케일 초기화
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus Habit',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        fontFamily: 'NotoSansKR'
      ),
      home: const HomeScreen(),
    );
  }
}
