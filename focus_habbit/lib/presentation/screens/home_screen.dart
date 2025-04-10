// 생략: import들
import 'package:flutter/material.dart';
import '../widgets/custom_calendar.dart';
import 'add_event_screen.dart';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();
  int _dragStage = 1;
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();

  final Map<String, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    // _resetEvents(); // 딱 한 번 실행해서 초기화
    _loadEvents(); // ✅ 앱 시작 시 저장된 데이터 불러오기
  }

  String _formatDateKey(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  void _onDateSelected(DateTime date) {
    setState(() => _selectedDate = date);
  }

  void _onDragStageChanged(int stage) {
    setState(() => _dragStage = stage);
  }

  List<Map<String, dynamic>> _getEventsForSelectedDate() {
    final key = _formatDateKey(_selectedDate);
    return _events[key] ?? [];
  }

  double _getCalendarHeight(double screenHeight) {
    if (_dragStage == 2) return 0;
    if (_dragStage == 1) return screenHeight * 0.37;
    return screenHeight;
  }

  double _getListHeightFactor() {
    if (_dragStage == 1) return 0.59;
    if (_dragStage == 2) return 1.0;
    return 0.0;
  }

  void _addEvent(DateTime start, DateTime end, String title, String imagePath, Color color, String caption) {
    final key = _formatDateKey(start);
    setState(() {
      _events.putIfAbsent(key, () => []);
      _events[key]!.add({
        'title': title,
        'color': color,
        'image': imagePath.isNotEmpty ? imagePath : null,
        'start': start,
        'caption': caption,
      });
    });
    _saveEvents(); // ✅ 이벤트 추가 후 저장
  }

  // ✅ SharedPreferences에 저장
  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(_events.map((key, list) => MapEntry(
      key,
      list.map((e) => {
        'title': e['title'],
        'image': e['image'],
        'start': e['start'].toIso8601String(),
        'caption': e['caption'],
        'color': (e['color'] as Color).value,
      }).toList(),
    )));
    await prefs.setString('events', encoded);
  }

  // ✅ SharedPreferences에서 불러오기
  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('events');
    if (raw != null) {
      final decoded = json.decode(raw) as Map<String, dynamic>;
      setState(() {
        _events.clear();
        decoded.forEach((key, value) {
          _events[key] = (value as List).map((e) => {
            'title': e['title'],
            'image': e['image'],
            'start': DateTime.parse(e['start']),
            'caption': e['caption'],
            'color': Color(e['color']),
          }).toList();
        });
      });
    }
  }

Future<void> _resetEvents() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('events');
  setState(() {
    _events.clear();
  });
}

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final events = _getEventsForSelectedDate();
    final calendarHeight = _getCalendarHeight(screenHeight);
    final listHeightFactor = _getListHeightFactor();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onVerticalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            if (_dragStage == 0 && velocity < -300) {
              _onDragStageChanged(1);
            } else if (_dragStage == 2 && velocity > 300) {
              _onDragStageChanged(1);
            }
          },
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: calendarHeight,
                width: double.infinity,
                child: calendarHeight < 100
                    ? const SizedBox.shrink()
                    : CustomCalendar(
                        selectedDate: _selectedDate,
                        onDateSelected: _onDateSelected,
                        events: _events, // 🔥 전체 맵 전달
                        dragStage: _dragStage,
                        onDragStageChanged: _onDragStageChanged,
                      ),
              ),
              if (_dragStage == 1 || _dragStage == 2)
                AnimatedAlign(
                  duration: const Duration(milliseconds: 300),
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: listHeightFactor,
                    widthFactor: 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 16,
                            offset: Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          if (_dragStage != 0)
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onVerticalDragEnd: (details) {
                                final velocity = details.primaryVelocity ?? 0;
                                if (_dragStage == 1 && velocity < -300) {
                                  _onDragStageChanged(2);
                                } else if (_dragStage == 1 && velocity > 300) {
                                  _onDragStageChanged(0);
                                }
                              },
                              child: Container(
                                width: 40,
                                height: 8,
                                margin: const EdgeInsets.only(top: 6, bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          Expanded(
                            child: events.isEmpty
                                ? const Center(child: Text('오늘 일정이 없습니다.'))
                                : ListView.builder(
                                    controller: _scrollController,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    itemCount: events.length,
                                    itemBuilder: (_, index) {
                                      final event = events[index];
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // 제목 (이미지 위)
                                          Padding(
                                            padding: const EdgeInsets.only(left: 4, bottom: 6),
                                            child: Text(
                                              event['title'],
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          // 이미지
                                          if (event['image'] != null)
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: Image.file(
                                                File(event['image']),
                                                width: double.infinity,
                                                height: 280,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          // 문구
                                          if (event['caption'] != null && event['caption'].toString().isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
                                              child: Text(
                                                event['caption'],
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            ),
                                          // 시간
                                          if (event['start'] != null)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4, left: 4),
                                              child: Text(
                                                TimeOfDay.fromDateTime(event['start']).format(context),
                                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                              ),
                                            ),
                                          const SizedBox(height: 16),
                                        ],
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: '기록 보기'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: '집중 모드'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '통계'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEventScreen(
                onSave: (start, end, title, imagePath, color, caption) =>
                    _addEvent(start, end, title, imagePath, color, caption),
                              initialDate: _selectedDate, // 🔥 현재 선택한 날짜 넘김
              ),
            ),
          );
        },
        backgroundColor: Colors.white,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
