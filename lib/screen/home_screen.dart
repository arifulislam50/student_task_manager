import 'package:flutter/material.dart';

import '../model/task_model.dart';
import '../service/auth_service.dart';
import '../service/task_service.dart';
import '../widegt/loading_widget.dart';
import '../widegt/task_card.dart';
import 'profile_screen.dart';
import 'task_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _taskService = TaskService();
  final _searchController = TextEditingController();

  String _priority = 'All';
  String _status = 'All';
  String _sort = 'Due Date';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openTaskForm([TaskModel? task]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
    );
  }

  Future<void> _openProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );

    if (mounted) setState(() {});
  }

  Future<void> _deleteTask(TaskModel task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task?'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _taskService.deleteTask(task.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Study Tasks'),
        actions: [
          IconButton(
            tooltip: 'My Profile',
            onPressed: _openProfile,
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTaskForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
      body: StreamBuilder<List<TaskModel>>(
        stream: _taskService.getTasks(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Unable to load tasks: ${snapshot.error}'),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }

          final tasks = snapshot.data ?? [];

          final pendingCount = tasks.where((task) => !task.isCompleted).length;
          final completedCount = tasks.where((task) => task.isCompleted).length;

          final query = _searchController.text.trim().toLowerCase();

          final filtered = tasks.where((task) {
            final matchesTitle = task.title.toLowerCase().contains(query);
            final matchesPriority =
                _priority == 'All' || task.priority == _priority;

            final matchesStatus =
                _status == 'All' ||
                (_status == 'Pending' && !task.isCompleted) ||
                (_status == 'Completed' && task.isCompleted);

            return matchesTitle && matchesPriority && matchesStatus;
          }).toList();

          const priorityOrder = {'High': 0, 'Medium': 1, 'Low': 2};

          switch (_sort) {
            case 'Priority':
              filtered.sort(
                (a, b) => (priorityOrder[a.priority] ?? 1).compareTo(
                  priorityOrder[b.priority] ?? 1,
                ),
              );
            case 'Title':
              filtered.sort(
                (a, b) =>
                    a.title.toLowerCase().compareTo(b.title.toLowerCase()),
              );
            default:
              filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome${user?.displayName?.isNotEmpty == true ? ', ${user!.displayName}' : ''}!',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text('Let’s make today productive.'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _summaryCard(
                            'Pending',
                            pendingCount,
                            Colors.orange,
                            Icons.pending_actions,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _summaryCard(
                            'Completed',
                            completedCount,
                            Colors.green,
                            Icons.task_alt,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search tasks by title...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.clear),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _priority,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Priority',
                            ),
                            items: ['All', 'Low', 'Medium', 'High']
                                .map(
                                  (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _priority = value ?? 'All'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _status,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Status',
                            ),
                            items: ['All', 'Pending', 'Completed']
                                .map(
                                  (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _status = value ?? 'All'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _sort,
                      decoration: const InputDecoration(
                        labelText: 'Sort Tasks',
                        prefixIcon: Icon(Icons.sort),
                      ),
                      items: ['Due Date', 'Priority', 'Title']
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _sort = value ?? 'Due Date'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _taskService.getTasks().first;
                  },
                  child: filtered.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(24),
                          children: [
                            const SizedBox(height: 28),
                            Icon(
                              tasks.isEmpty ? Icons.task_alt : Icons.search_off,
                              size: 72,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: Text(
                                tasks.isEmpty
                                    ? 'No tasks yet'
                                    : 'No matching tasks',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Center(
                              child: Text(
                                tasks.isEmpty
                                    ? 'Tap Add Task to create your first task.'
                                    : 'Try changing your search or filters.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 90, top: 4),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final task = filtered[index];

                            return TaskCard(
                              task: task,
                              onEdit: () => _openTaskForm(task),
                              onDelete: () => _deleteTask(task),
                              onToggle: () async {
                                final messenger = ScaffoldMessenger.maybeOf(context);

                                try {
                                  await _taskService.toggleComplete(task);
                                } catch (e) {
                                  if (!mounted) return;
                                  if (messenger != null) {
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text('Update failed: $e'),
                                      ),
                                    );
                                  }
                                }
                              },
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryCard(String title, int count, Color color, IconData icon) {
    return Card(
      color: color.withValues(alpha: 0.10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 10),
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }
}
