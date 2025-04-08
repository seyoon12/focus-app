import 'package:flutter/material.dart';
import '../widgets/custom_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  int _dragStage = 1;
  int _currentIndex = 0;
  double _subDragPercent = 0.5;

  late AnimationController _calendarSizeController;

  final Map<String, List<String>> _dummyEvents = {
    '2025-04-06': ['예시 일정 1', '예시 일정 2', '예시 일정 3'],
  };

  Animation<double> get _animatedHeight =>
      CurvedAnimation(parent: _calendarSizeController, curve: Curves.easeInOutCubic);

  @override
  void initState() {
    super.initState();
    _calendarSizeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      value: _subDragPercent,
    );
  }

  @override
  void dispose() {
    _calendarSizeController.dispose();
    super.dispose();
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _onDragStageChanged(int stage, {double? fixedPercent}) {
    setState(() {
      _dragStage = stage;
      if (stage == 0) {
        _calendarSizeController.animateTo(1.0);
      } else if (stage == 1) {
        _subDragPercent = fixedPercent ?? 0.5;
        _calendarSizeController.animateTo(_subDragPercent);
      } else {
        _calendarSizeController.animateTo(0.0);
      }
    });
  }

  List<String> _getEventsForSelectedDate() {
    final key = _selectedDate.toIso8601String().substring(0, 10);
    return _dummyEvents[key] ?? [];
  }

  double _getCalendarHeight(double screenHeight) {
    if (_dragStage == 2) return 0;
    if (_dragStage == 1) return screenHeight * (_subDragPercent == 0.4 ? 0.6 : 0.5);
    return screenHeight;
  }

  @override
  Widget build(BuildContext context) {
    final events = _getEventsForSelectedDate();
    final screenHeight = MediaQuery.of(context).size.height;
    final calendarHeight = _getCalendarHeight(screenHeight);
    final listHeight = screenHeight - calendarHeight;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: calendarHeight,
              width: double.infinity,
              child: CustomCalendar(
                selectedDate: _selectedDate,
                onDateSelected: _onDateSelected,
                eventDates: _dummyEvents.keys.map((e) => DateTime.parse(e)).toList(),
                dragStage: _dragStage,
                onDragStageChanged: _onDragStageChanged,
              ),
            ),

            Positioned(
              top: calendarHeight,
              left: 0,
              right: 0,
              height: listHeight,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragEnd: (details) {
                  final velocity = details.primaryVelocity ?? 0;
                  const threshold = 300;
                  if (_dragStage == 1 && velocity < -threshold) {
                    _onDragStageChanged(2);
                  } else if (_dragStage == 2 && velocity > threshold) {
                    _onDragStageChanged(1, fixedPercent: 0.5);
                  }
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
                    ],
                  ),
                  child: _buildEventList(events),
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
      return const Center(child: Padding(
        padding: EdgeInsets.only(top: 32),
        child: Text('오늘 일정이 없습니다.'),
      ));
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
