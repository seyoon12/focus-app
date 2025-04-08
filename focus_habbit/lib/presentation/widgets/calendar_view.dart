import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends StatefulWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Map<String, List<Map<String, dynamic>>> habitMap;
  final void Function(DateTime selected, DateTime focused) onDaySelected;
  final VoidCallback onOutsideTap;

  const CalendarView({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.habitMap,
    required this.onDaySelected,
    required this.onOutsideTap,
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  double _heightRatio = 0.4;
  double _startHeightRatio = 0.4;
  double _dragStartY = 0.0;

  void _onDragStart(DragStartDetails details) {
    _dragStartY = details.globalPosition.dy;
    _startHeightRatio = _heightRatio;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final delta = (_dragStartY - details.globalPosition.dy) / MediaQuery.of(context).size.height;
    setState(() {
      _heightRatio = (_startHeightRatio + delta).clamp(0.4, 0.6);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final calendarHeight = screenHeight * _heightRatio;

    return GestureDetector(
      onTap: widget.onOutsideTap,
      onVerticalDragStart: _onDragStart,
      onVerticalDragUpdate: _onDragUpdate,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: calendarHeight,
        child: Column(
          children: [
            const Icon(Icons.drag_handle, size: 20, color: Colors.grey),
            Expanded(
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: widget.focusedDay,
                selectedDayPredicate: (day) => isSameDay(widget.selectedDay, day),
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.monday,
                onDaySelected: widget.onDaySelected,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    final key = date.toString().substring(0, 10);
                    final habits = widget.habitMap[key] ?? [];
                    if (habits.isNotEmpty) {
                      return Positioned(
                        bottom: 1,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}