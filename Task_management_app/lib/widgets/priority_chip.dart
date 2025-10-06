// widgets/priority_chip.dart
import 'package:flutter/material.dart';
import '../models/task_model.dart';

class PriorityChip extends StatelessWidget {
  final String priority;
  final bool small;

  const PriorityChip({
    super.key,
    required this.priority,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final task = Task(id: '', title: '', description: '', createdAt: DateTime.now(), priority: priority);

    return Container(
      padding: small
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 2)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: task.priorityBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: task.priorityColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            task.priorityIcon,
            size: small ? 12 : 14,
            color: task.priorityColor,
          ),
          if (!small) ...[
            const SizedBox(width: 4),
            Text(
              task.priorityText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: task.priorityColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}