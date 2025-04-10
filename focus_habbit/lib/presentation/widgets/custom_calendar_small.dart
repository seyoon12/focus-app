import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomCalendarSmall extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const CustomCalendarSmall({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<CustomCalendarSmall> createState() => _CustomCalendarSmallState();
}

class _CustomCalendarSmallState extends State<CustomCalendarSmall> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month);
  }

  // 해당 월의 첫 요일 위치 계산
  int _getStartWeekdayOfMonth() {
    return DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday % 7;
  }

  // 해당 월의 마지막 날짜
  int _getDaysInMonth() {
    final nextMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    return nextMonth.subtract(const Duration(days: 1)).day;
  }

  void _goToPrevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = _getDaysInMonth();
    final startWeekday = _getStartWeekdayOfMonth();
    final List<Widget> dayTiles = [];

    // 빈 공간 채우기 (1일 시작 전)
    for (int i = 0; i < startWeekday; i++) {
      dayTiles.add(const SizedBox.shrink());
    }

    // 날짜 위젯 생성
    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, i);
      final isSelected = DateUtils.isSameDay(date, widget.selectedDate);

      dayTiles.add(
        GestureDetector(
          onTap: () => widget.onDateSelected(date),
          child: Container(
            alignment: Alignment.center,
            decoration: isSelected
                ? BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  )
                : null,
            child: Text(
              '$i',
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상단 년/월 & 화살표
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(onPressed: _goToPrevMonth, icon: const Icon(Icons.chevron_left)),
            Text(
              DateFormat('yyyy년 M월', 'ko').format(_focusedMonth),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            IconButton(onPressed: _goToNextMonth, icon: const Icon(Icons.chevron_right)),
          ],
        ),

        // 요일 헤더
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Text('일', style: TextStyle(color: Colors.red)),
              Text('월'),
              Text('화'),
              Text('수'),
              Text('목'),
              Text('금'),
              Text('토', style: TextStyle(color: Colors.blue)),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // 날짜들 (7열 그리드)
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.2,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          children: dayTiles,
        ),
      ],
    );
  }
}
