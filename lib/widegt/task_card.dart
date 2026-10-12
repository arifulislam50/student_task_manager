import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const TaskCard({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = switch (task.priority) {
      'High' => Colors.red,
      'Low' => Colors.green,
      _ => Colors.orange,
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    task.priority,
                    style: TextStyle(
                      color: priorityColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.menu_book_outlined, size: 18),
                const SizedBox(width: 6),
                Expanded(child: Text(task.subject)),
              ],
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(task.description),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_month, size: 18),
                const SizedBox(width: 6),
                Text(DateFormat('dd MMM yyyy').format(task.dueDate)),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                Checkbox(value: task.isCompleted, onChanged: (_) => onToggle()),
                const Expanded(child: Text('Completed')),
                IconButton(
                  tooltip: 'Edit task',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Delete task',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
