import 'package:flutter/material.dart';

class HabitItem extends StatelessWidget {
  final String text;
  final bool checked;
  final String frequency;
  final VoidCallback onChanged;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const HabitItem({
    required this.text,
    required this.checked,
    required this.frequency,
    required this.onChanged,
    required this.onDelete,
    required this.onEdit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(value: checked, onChanged: (_) => onChanged()),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  decoration: checked ? TextDecoration.lineThrough : null,
                  color: checked ? Colors.grey : Colors.black,
                ),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('수정')),
                PopupMenuItem(value: 'delete', child: Text('삭제')),
              ],
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 44, bottom: 8),
          child: Text(
            frequency,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
