import 'package:flutter/material.dart';
import '../widgets/custom_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  int _dragStage = 1; // 0: 전체 달력, 1: 5대5, 2: 전체 리스트
  int _currentIndex = 0;

  final Map<String, List<String>> _dummyEvents = {
    '2025-04-06': ['예시 일정 1', '예시 일정 2', '예시 일정 3'],
  };

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _onDragStageChanged(int stage) {
    setState(() {
      _dragStage = stage;
    });
  }

  List<String> _getEventsForSelectedDate() {
    final key = _selectedDate.toIso8601String().substring(0, 10);
    return _dummyEvents[key] ?? [];
  }

  double _getCalendarHeight(double screenHeight) {
    if (_dragStage == 2) return 0; // 전체 리스트
    if (_dragStage == 1) return screenHeight * 0.35; // 5대5
    return screenHeight; // 전체 달력
  }

  double _getListHeightFactor() {
    if (_dragStage == 1) return 0.59;
    if (_dragStage == 2) return 1.0;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final events = _getEventsForSelectedDate();
    final screenHeight = MediaQuery.of(context).size.height;
    final calendarHeight = _getCalendarHeight(screenHeight);
    final listHeightFactor = _getListHeightFactor();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // ✅ 달력 (높이 작을 땐 렌더 생략)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: calendarHeight,
              width: double.infinity,
              child: calendarHeight < 100
                  ? const SizedBox.shrink()
                  : GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onVerticalDragEnd: (details) {
                        final velocity = details.primaryVelocity ?? 0;
                        const threshold = 300;
                        if (_dragStage == 1 && velocity > threshold) {
                          _onDragStageChanged(0);
                        } else if (_dragStage == 0 && velocity < -threshold) {
                          _onDragStageChanged(1);
                        }
                      },
                      child: CustomCalendar(
                        selectedDate: _selectedDate,
                        onDateSelected: _onDateSelected,
                        eventDates: _dummyEvents.keys.map((e) => DateTime.parse(e)).toList(),
                        dragStage: _dragStage,
                        onDragStageChanged: _onDragStageChanged,
                      ),
                    ),
            ),

            // ✅ 리스트 (팝업)
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: listHeightFactor,
                widthFactor: 1.0,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragEnd: (details) {
                    final velocity = details.primaryVelocity ?? 0;
                    const threshold = 300;
                    if (_dragStage == 1 && velocity < -threshold) {
                      _onDragStageChanged(2);
                    } else if (_dragStage == 2 && velocity > threshold) {
                      _onDragStageChanged(1);
                    }
                  },
                  child: ClipRect(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          height: constraints.maxHeight,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 12),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  // 전체리스트 -> 리스트+달력 스와이프 시 오버플로우 문제 해결을 위하여 maxheight 제한
                                  maxHeight: constraints.maxHeight.clamp(0.0, constraints.maxHeight - 20),
                                ),
                                child: NotificationListener<OverscrollIndicatorNotification>(
                                  onNotification: (overscroll) {
                                    overscroll.disallowIndicator();
                                    return true;
                                  },
                                  child: _buildEventList(events),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
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
    );
  }

  Widget _buildEventList(List<String> events) {
    if (events.isEmpty) {
      return const Center(child: Text('오늘 일정이 없습니다.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            title: Text(events[index]),
          ),
        );
      },
    );
  }
}
