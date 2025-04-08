import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../widgets/habit_list_view.dart';
import '../services/habit_service.dart';
import 'add_habit_screen.dart';
import 'focus_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Map<String, List<Map<String, dynamic>>> _habitMap = {};
  int _dragStage = 0;
  final List<double> _calendarRatios = [1.0, 0.5, 0.2];

  @override
  void initState() {
    super.initState();
    HabitService.loadHabits().then((map) {
      setState(() => _habitMap = map);
    });
  }

  List<Map<String, dynamic>> _getHabitsForDay(DateTime day) {
    final key = day.toString().substring(0, 10);
    return _habitMap[key] ?? [];
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    final sensitivity = 8;
    if (details.primaryDelta! < -sensitivity) {
      if (_dragStage < 2) setState(() => _dragStage++);
    } else if (details.primaryDelta! > sensitivity) {
      if (_dragStage > 0) setState(() => _dragStage--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final habits = _getHabitsForDay(_selectedDay);
    final calendarRatio = _calendarRatios[_dragStage];
    final showHabits = _dragStage != 0;

    final List<Widget> _screens = [
      GestureDetector(
        onVerticalDragUpdate: _onVerticalDragUpdate,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeInOutCubic,
              height: MediaQuery.of(context).size.height * calendarRatio,
              child: SfCalendar(
                view: CalendarView.month,
                todayHighlightColor: Colors.orange,
                selectionDecoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.5),
                  shape: BoxShape.rectangle,
                ),
                initialSelectedDate: _selectedDay,
                onTap: (CalendarTapDetails details) {
                  if (details.date != null) {
                    setState(() {
                      _selectedDay = details.date!;
                      _focusedDay = details.date!;
                    });
                  }
                },
                monthViewSettings: MonthViewSettings(
                  numberOfWeeksInView: _dragStage == 2 ? 1 : 6,
                ),
              ),
            ),
            if (_dragStage != 0)
              Container(
                height: 20,
                alignment: Alignment.center,
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            if (showHabits)
              Expanded(
                child: GestureDetector(
                  onVerticalDragUpdate: _onVerticalDragUpdate,
                  child: HabitListView(habits: habits),
                ),
              ),
          ],
        ),
      ),
      const FocusTimerScreen(),
      const StatsScreen(),
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: Colors.white,
          height: 20,
        ),
      ),
      body: Container(
        color: Colors.white,
        child: _screens[_currentIndex],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddHabitScreen(
                      selectedDate: _selectedDay,
                    ),
                  ),
                );
                if (result != null && result is Map<String, dynamic>) {
                  final key = result['date'] ?? DateTime.now().toString().substring(0, 10);
                  setState(() {
                    _habitMap.putIfAbsent(key, () => []).add(result);
                  });
                  HabitService.saveHabits(_habitMap);
                }
              },
              label: const Text('Create an event...'),
              icon: const Icon(Icons.add),
            )
          : null,
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
}
