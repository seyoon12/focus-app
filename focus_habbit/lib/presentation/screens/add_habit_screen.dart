// lib/screens/add_habit_screen.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/habit_input_form.dart';

class AddHabitScreen extends StatefulWidget {
  final DateTime selectedDate;
  const AddHabitScreen({super.key, required this.selectedDate});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  @override
  void initState() {
    super.initState();
    _requestNotificationPermissions();
  }

  Future<void> _requestNotificationPermissions() async {
    final status = await Permission.scheduleExactAlarm.status;
    if (!status.isGranted) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('새로운 습관 추가')),
      body: HabitInputForm(selectedDate: widget.selectedDate),
    );
  }
}
