import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final void Function(TimeOfDay) onTimeSelected;

  const CustomTimePicker({
    super.key,
    required this.initialTime,
    required this.onTimeSelected,
  });

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  late int selectedHour; // 1~12
  late int selectedMinute; // 0~59
  late String selectedPeriod; // 오전 or 오후

  final List<String> periodList = ['오전', '오후'];
  final List<int> hourList = List.generate(12, (i) => i + 1);
  final List<int> minuteList = List.generate(60, (i) => i);

  @override
  void initState() {
    super.initState();

    final hour = widget.initialTime.hour;
    selectedPeriod = hour < 12 ? '오전' : '오후';
    selectedHour = (hour % 12 == 0) ? 12 : hour % 12;
    selectedMinute = widget.initialTime.minute;
  }

  int get selected24Hour {
    if (selectedPeriod == '오전') {
      return selectedHour == 12 ? 0 : selectedHour;
    } else {
      return selectedHour == 12 ? 12 : selectedHour + 12;
    }
  }

  void _onConfirm() {
    final time = TimeOfDay(hour: selected24Hour, minute: selectedMinute);
    widget.onTimeSelected(time);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          // 오전/오후
          Expanded(
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: periodList.indexOf(selectedPeriod),
              ),
              itemExtent: 40,
              onSelectedItemChanged: (index) {
                setState(() => selectedPeriod = periodList[index]);
              },
              children: periodList.map((e) => Center(child: Text(e))).toList(),
            ),
          ),

          // 시
          Expanded(
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: selectedHour - 1,
              ),
              itemExtent: 40,
              onSelectedItemChanged: (index) {
                setState(() => selectedHour = hourList[index]);
              },
              children: hourList.map((e) => Center(child: Text(e.toString()))).toList(),
            ),
          ),

          // 분
          Expanded(
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: selectedMinute,
              ),
              itemExtent: 40,
              onSelectedItemChanged: (index) {
                setState(() => selectedMinute = minuteList[index]);
              },
              children: minuteList.map((e) => Center(child: Text(e.toString().padLeft(2, '0')))).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
