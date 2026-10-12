import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String subject;
  final DateTime dueDate;
  final String priority;
  final bool isCompleted;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
  });

  factory TaskModel.fromMap(String id, Map<String, dynamic> map) {
    final rawDate = map['dueDate'];

    DateTime parsedDate;
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return TaskModel(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      subject: map['subject'] as String? ?? '',
      dueDate: parsedDate,
      priority: map['priority'] as String? ?? 'Medium',
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'subject': subject,
      'dueDate': Timestamp.fromDate(dueDate),
      'priority': priority,
      'isCompleted': isCompleted,
    };
  }

  TaskModel copyWith({
    String? title,
    String? description,
    String? subject,
    DateTime? dueDate,
    String? priority,
    bool? isCompleted,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
