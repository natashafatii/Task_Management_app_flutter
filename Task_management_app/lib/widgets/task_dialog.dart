// widgets/task_dialog.dart
import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskDialog extends StatelessWidget {
  final Task? task;
  final Function(Task) onSave;

  const TaskDialog({
    super.key,
    this.task,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(task == null ? 'Add Task' : 'Edit Task'),
      content: const Text('Task dialog content'), // Will integrate with TaskForm
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Handle save
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}