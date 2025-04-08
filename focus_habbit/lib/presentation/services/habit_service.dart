// lib/services/habit_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HabitService {
  static Future<Map<String, List<Map<String, dynamic>>>> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('habit_list');
    final map = <String, List<Map<String, dynamic>>>{};
    if (saved != null) {
      final List<dynamic> decoded = json.decode(saved);
      for (final item in decoded) {
        final habit = Map<String, dynamic>.from(item);
        final key = habit['date'] ?? DateTime.now().toString().substring(0, 10);
        map.putIfAbsent(key, () => []).add(habit);
      }
    }
    return map;
  }

  static Future<void> saveHabits(Map<String, List<Map<String, dynamic>>> habitMap) async {
    final prefs = await SharedPreferences.getInstance();
    final flatList = habitMap.values.expand((list) => list).toList();
    await prefs.setString('habit_list', json.encode(flatList));
  }
}
