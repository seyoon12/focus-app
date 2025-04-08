// lib/widgets/habit_list_view.dart
import 'package:flutter/material.dart';

class HabitListView extends StatelessWidget {
  final List<Map<String, dynamic>> habits;

  const HabitListView({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    if (habits.isEmpty) {
      return const Center(child: Text('일정이 없습니다'));
    }

    final colors = [Colors.yellow, Colors.blue, Colors.red];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];
        final hasImage = habit['image'] != null && habit['image'].toString().isNotEmpty;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.circle, color: colors[index % colors.length], size: 12),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(habit['text'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    if (habit['time'] != null)
                      Text(habit['time'], style: const TextStyle(color: Colors.grey)),
                    if (hasImage)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(habit['image'], height: 120, fit: BoxFit.cover),
                        ),
                      ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
