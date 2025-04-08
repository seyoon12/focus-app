import 'package:flutter/material.dart';
import 'dart:math';

class CustomCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final List<DateTime> eventDates;
  final Function(DateTime) onDateSelected;
  final int dragStage;
  final Function(int) onDragStageChanged;

  const CustomCalendar({
    Key? key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.eventDates,
    required this.dragStage,
    required this.onDragStageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final totalCells = ((firstWeekday - 1 + daysInMonth) / 7).ceil() * 7;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            '${currentMonth.month}월',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        _buildWeekdayRow(),
        const Divider(height: 1),
        Expanded(
          child: Column(
            children: List.generate((totalCells / 7).ceil(), (weekIndex) {
              return Expanded(
                child: Row(
                  children: List.generate(7, (dayIndex) {
                    final cellIndex = weekIndex * 7 + dayIndex;
                    final dayNumber = cellIndex - (firstWeekday - 1) + 1;
                    DateTime? cellDate;
                    bool isInMonth = dayNumber >= 1 && dayNumber <= daysInMonth;

                    if (isInMonth) {
                      cellDate = DateTime(currentMonth.year, currentMonth.month, dayNumber);
                    }

                    final isSelected = cellDate != null &&
                        selectedDate.year == cellDate!.year &&
                        selectedDate.month == cellDate.month &&
                        selectedDate.day == cellDate.day;

                    final hasEvent = cellDate != null &&
                        eventDates.any((e) =>
                            e.year == cellDate!.year &&
                            e.month == cellDate.month &&
                            e.day == cellDate.day);

                    final eventCount = cellDate == null
                        ? 0
                        : eventDates.where((e) =>
                            e.year == cellDate!.year &&
                            e.month == cellDate.month &&
                            e.day == cellDate.day).length;

                    final isSunday = dayIndex == 0;
                    final isSaturday = dayIndex == 6;

                    return Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: cellDate != null ? () => onDateSelected(cellDate!) : null,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    decoration: isSelected
                                        ? BoxDecoration(
                                            border: Border.all(color: Colors.red, width: 1),
                                            borderRadius: BorderRadius.circular(6),
                                          )
                                        : null,
                                    padding: const EdgeInsets.all(4),
                                    child: Text(
                                      isInMonth ? '$dayNumber' : '',
                                      style: TextStyle(
                                        color: isInMonth
                                            ? (isSunday || isSaturday
                                                ? Colors.redAccent
                                                : Colors.black87)
                                            : Colors.grey,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                if (hasEvent)
  Padding(
    padding: const EdgeInsets.only(top: 4),
    child: dragStage == 0
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '일정',
              style: TextStyle(fontSize: 9, color: Colors.red),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center, // ✅ 가운데 정렬
            children: [
              Container(
                width: 16,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (eventCount > 1)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    'x$eventCount',
                    style: const TextStyle(fontSize: 8, color: Colors.redAccent),
                  ),
                ),
            ],
          ),
  ),

                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayRow() {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return Row(
      children: List.generate(7, (index) {
        final isSunday = index == 0;
        final isSaturday = index == 6;
        return Expanded(
          child: Center(
            child: Text(
              weekdays[index],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isSunday || isSaturday ? Colors.redAccent : Colors.black87,
              ),
            ),
          ),
        );
      }),
    );
  }
}
