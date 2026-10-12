import 'package:flutter/material.dart';

import '../model/task_model.dart';
import '../service/task_service.dart';

class TaskFormScreen extends StatefulWidget {
  final TaskModel? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _subject = TextEditingController();
  final _service = TaskService();

  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  String _priority = 'Medium';
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    final task = widget.task;
    if (task != null) {
      _title.text = task.title;
      _description.text = task.description;
      _subject.text = task.subject;
      _dueDate = task.dueDate;
      _priority = task.priority;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _subject.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && mounted) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final oldTask = widget.task;

      final task = TaskModel(
        id: oldTask?.id ?? '',
        title: _title.text.trim(),
        description: _description.text.trim(),
        subject: _subject.text.trim(),
        dueDate: _dueDate,
        priority: _priority,
        isCompleted: oldTask?.isCompleted ?? false,
      );

      if (oldTask == null) {
        await _service.addTask(task);
      } else {
        await _service.updateTask(task);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not save task: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Task' : 'Add New Task')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _title,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Task Title *',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Title is required'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _description,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _subject,
                  decoration: const InputDecoration(
                    labelText: 'Subject *',
                    prefixIcon: Icon(Icons.menu_book_outlined),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Subject is required'
                      : null,
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_month),
                    title: const Text('Due Date'),
                    subtitle: Text(
                      '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                    ),
                    trailing: const Icon(Icons.edit_calendar),
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _priority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                  items: ['Low', 'Medium', 'High']
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _priority = value);
                    }
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: _loading ? null : _saveTask,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(_loading ? 'Saving...' : 'Save Task'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
