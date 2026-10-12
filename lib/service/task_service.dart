import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/task_model.dart';

class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _tasks {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      throw Exception('Please log in first.');
    }

    return _db.collection('users').doc(uid).collection('tasks');
  }

  Stream<List<TaskModel>> getTasks() {
    return _tasks.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return TaskModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> addTask(TaskModel task) async {
    final doc = _tasks.doc();

    await doc.set({...task.toMap(), 'createdAt': FieldValue.serverTimestamp()});
  }

  Future<void> updateTask(TaskModel task) async {
    await _tasks.doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String id) async {
    await _tasks.doc(id).delete();
  }

  Future<void> toggleComplete(TaskModel task) async {
    await _tasks.doc(task.id).update({'isCompleted': !task.isCompleted});
  }
}
