import 'package:flutter/material.dart';

class CustomCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final Map<String, List<Map<String, dynamic>>> events;
  final int dragStage;
  final Function(int) onDragStageChanged;

  const CustomCalendar({
    Key? key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.events,
    required this.dragStage,
    required this.onDragStageChanged,
  }) : super(key: key);

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  late DateTime currentMonth;

  @override
  void initState() {
    super.initState();
    currentMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month);
  }

  void _goToPreviousMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final totalCells = ((firstWeekday + daysInMonth) / 7).ceil() * 7;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _goToPreviousMonth,
              ),
              Text(
                '${currentMonth.year}.${currentMonth.month.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _goToNextMonth,
              ),
            ],
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
                    final dayNumber = cellIndex - firstWeekday + 1;
                    DateTime? cellDate;
                    bool isInMonth = dayNumber >= 1 && dayNumber <= daysInMonth;

                    if (isInMonth) {
                      cellDate = DateTime(currentMonth.year, currentMonth.month, dayNumber);
                    }

                    final key = cellDate != null
                        ? "${cellDate.year.toString().padLeft(4, '0')}-${cellDate.month.toString().padLeft(2, '0')}-${cellDate.day.toString().padLeft(2, '0')}"
                        : '';

                    final dailyEvents = widget.events[key] ?? [];
                    final hasEvent = dailyEvents.isNotEmpty;

                    final isSelected = cellDate != null &&
                        widget.selectedDate.year == cellDate.year &&
                        widget.selectedDate.month == cellDate.month &&
                        widget.selectedDate.day == cellDate.day;

                    final isSunday = dayIndex == 0;
                    final isSaturday = dayIndex == 6;

                    return Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: cellDate != null ? () => widget.onDateSelected(cellDate!) : null,
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            decoration: isSelected
                                ? BoxDecoration(
                                    border: Border.all(color: const Color.fromARGB(255, 182, 181, 181), width: 1),
                                    borderRadius: BorderRadius.circular(8),
                                  )
                                : null,
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                Positioned(
                                  top: 6,
                                  child: Text(
                                    isInMonth ? '$dayNumber' : '',
                                    style: TextStyle(
                                      color: isInMonth
                                          ? (isSunday || isSaturday
                                              ? const Color.fromARGB(255, 194, 26, 26)
                                              : Colors.black87)
                                          : Colors.grey,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                if (hasEvent)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: widget.dragStage == 0
                                        ? _buildEventTitles(dailyEvents)
                                        : _buildSmallMarker(dailyEvents),
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

  Widget _buildEventTitles(List<Map<String, dynamic>> events) {
    int maxVisible = 3;
    List<Map<String, dynamic>> visibleEvents = events.take(maxVisible).toList();
    int extraCount = events.length - maxVisible;

    return Column(
      children: [
        ...visibleEvents.map((event) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: (event['color'] is int)
                      ? Color(event['color'])
                      : (event['color'] as Color),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              Flexible(
                child: Text(
                  event['title'] ?? '',
                  style: const TextStyle(fontSize: 9, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        }).toList(),
        if (extraCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '+$extraCount개 더 있음',
              style: const TextStyle(fontSize: 8, color: Colors.grey),
            ),
          ),
      ],
    );
  }

  Widget _buildSmallMarker(List<Map<String, dynamic>> events) {
    final first = events.first;
    final color = (first['color'] is int)
        ? Color(first['color'])
        : (first['color'] as Color);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 16,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        if (events.length > 1)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              '+${events.length - 1}',
              style: const TextStyle(fontSize: 8, color: Colors.black87),
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
                fontSize: 11,
                color: isSunday || isSaturday ? Colors.redAccent : Colors.black87,
              ),
            ),
          ),
        );
      }),
    );
  }
}
