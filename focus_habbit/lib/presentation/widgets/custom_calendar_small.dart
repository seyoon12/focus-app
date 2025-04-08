import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

class CustomCalendarSmall extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final List<DateTime> eventDates;
  final int dragStage;
  final Function(int) onDragStageChanged;

  const CustomCalendarSmall({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.eventDates,
    required this.dragStage,
    required this.onDragStageChanged,
  });

  @override
  State<CustomCalendarSmall> createState() => _CustomCalendarSmallState();
}

class _CustomCalendarSmallState extends State<CustomCalendarSmall> {
  late DateTime _currentMonth;
  double _dragStartY = 0;
  bool _hasDragged = false;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month);
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    final firstWeekday = first.weekday % 7;

    final List<DateTime> daysBefore = List.generate(
      firstWeekday,
      (i) => first.subtract(Duration(days: firstWeekday - i)),
    );

    final List<DateTime> daysInMonth = List.generate(
      last.day,
      (i) => DateTime(month.year, month.month, i + 1),
    );

    final List<DateTime> total = [...daysBefore, ...daysInMonth];
    final int remaining = 7 - (total.length % 7);
    final List<DateTime> filler = remaining < 7
        ? List.generate(remaining, (i) => last.add(Duration(days: i + 1)))
        : <DateTime>[];

    final List<DateTime> allDays = [...total, ...filler];

    if (widget.dragStage == 2) {
      return allDays.sublist(allDays.length - 7);
    }

    return allDays;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
Widget build(BuildContext context) {
  final days = _getDaysInMonth(_currentMonth);
  const weekDays = ['일', '월', '화', '수', '목', '금', '토'];

  return Listener(
    onPointerDown: (event) {
      _dragStartY = event.position.dy;
      _hasDragged = false;
    },
    onPointerMove: (event) {
      final dy = event.position.dy - _dragStartY;
      const threshold = 20.0;
      if (!_hasDragged && dy < -threshold && widget.dragStage < 2) {
        _hasDragged = true;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          widget.onDragStageChanged(widget.dragStage + 1);
        });
      } else if (!_hasDragged && dy > threshold && widget.dragStage > 0) {
        _hasDragged = true;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          widget.onDragStageChanged(widget.dragStage - 1);
        });
      }
    },
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            DateFormat('y년 M월', 'ko').format(_currentMonth),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: weekDays
              .map((d) => Center(child: Text(d, style: const TextStyle(fontSize: 12))))
              .toList(),
        ),
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 1,
            ),
            itemBuilder: (_, index) {
              final day = days[index];
              final isSelected = _isSameDay(day, widget.selectedDate);
              final isCurrentMonth = day.month == _currentMonth.month;
              final hasEvent = widget.eventDates.any((e) => _isSameDay(e, day));

              return GestureDetector(
                onTap: () {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    widget.onDateSelected(day);
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.redAccent.withOpacity(0.15) : null,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isCurrentMonth ? Colors.black : Colors.grey,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (hasEvent)
                        Positioned(
                          bottom: 4,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

}
