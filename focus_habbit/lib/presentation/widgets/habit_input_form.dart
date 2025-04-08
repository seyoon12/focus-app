// lib/widgets/habit_input_form.dart
import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class HabitInputForm extends StatefulWidget {
  final DateTime selectedDate;
  const HabitInputForm({super.key, required this.selectedDate});

  @override
  State<HabitInputForm> createState() => _HabitInputFormState();
}

class _HabitInputFormState extends State<HabitInputForm> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _days = ['월', '화', '수', '목', '금', '토', '일'];
  final List<String> _selectedDays = [];
  final List<TimeOfDay> _selectedTimes = [];
  String _selectedCategory = '개인';

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTimes.add(picked);
      });
    }
  }

  void _toggleDay(String day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '애인':
        return Icons.favorite;
      case '가족':
        return Icons.home;
      case '친구':
        return Icons.group;
      case '회사':
        return Icons.work;
      case '개인':
        return Icons.person;
      default:
        return Icons.star;
    }
  }

Future<void> _submitHabit() async {
  final text = _controller.text.trim();
  if (text.isEmpty) return;

  int baseId = DateTime.now().millisecondsSinceEpoch % 100000;

  for (int i = 0; i < _selectedTimes.length; i++) {
    final time = _selectedTimes[i];
    await NotificationService.scheduleNotification(
      id: baseId + i,
      title: '습관 알림 ⏰',
      body: '"$text" 하셨나요?',
      time: time,
    );
  }

  final habit = {
    'text': text,
    'checked': false,
    'category': _selectedCategory,
    'time': _selectedTimes.isNotEmpty
        ? '${_selectedTimes[0].hour}:${_selectedTimes[0].minute}'
        : null,
    'id': baseId,
    'repeatDays': _selectedDays,
    'date': widget.selectedDate.toString().substring(0, 10),
  };

  if (mounted) {
    Navigator.pop(context, habit);
  }
}
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('습관 이름', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: '예: 영어 단어 외우기',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          const Text('요일 선택'),
          Wrap(
            spacing: 8,
            children: _days.map((day) {
              final selected = _selectedDays.contains(day);
              return ChoiceChip(
                label: Text(day),
                selected: selected,
                onSelected: (_) => _toggleDay(day),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text('시간 선택'),
          Wrap(
            spacing: 8,
            children: [
              ..._selectedTimes.map((t) {
                return GestureDetector(
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: t,
                    );
                    if (picked != null) {
                      setState(() {
                        final index = _selectedTimes.indexOf(t);
                        _selectedTimes[index] = picked;
                      });
                    }
                  },
                  child: Chip(
                    label: Text('${t.hour}시 ${t.minute}분'),
                    onDeleted: () => setState(() => _selectedTimes.remove(t)),
                  ),
                );
              }),
              ActionChip(
                label: const Text('+ 시간 추가'),
                onPressed: _pickTime,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('카테고리 선택'),
          Wrap(
            spacing: 10,
            children: ['애인', '가족', '친구', '회사', '개인'].map((c) {
              return ChoiceChip(
                label: Icon(
                  _getCategoryIcon(c),
                  color: _selectedCategory == c ? Colors.white : Colors.black,
                ),
                selected: _selectedCategory == c,
                selectedColor: Colors.blue,
                onSelected: (_) => setState(() => _selectedCategory = c),
              );
            }).toList(),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitHabit,
              child: const Text('저장하기'),
            ),
          )
        ],
      ),
    );
  }
}
