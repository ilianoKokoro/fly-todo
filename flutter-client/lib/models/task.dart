import 'dart:convert';

import 'package:fly_todo/repositories/task_repository.dart';

class Task {
  static final TaskRepository _taskRepository = TaskRepository();
  static Future<Task> create() async {
    return await _taskRepository.createTask();
  }

  String name;
  bool isCompleted;
  String href;

  Task(this.name, this.isCompleted, this.href);

  Task.fromJson(Map<String, dynamic> json)
    : name = json['name'] as String,
      isCompleted = json['isCompleted'] as bool,
      href = json['href'] as String;

  @override
  String toString() {
    return toJsonString();
  }

  String toJsonString() => jsonEncode({
    'name': name,
    'isCompleted': isCompleted.toString(),
    "href": href,
  });

  Future<void> update() async {
    await _taskRepository.updateTask(this);
  }

  Future<void> delete() async {
    return await _taskRepository.deleteTask(this);
  }
}
