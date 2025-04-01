import 'dart:convert';

import 'package:fly_todo/models/task.dart';
import 'package:fly_todo/repositories/task_repository.dart';

class User {
  User(this.name, this.email, this.href);

  String name;
  String email;
  String href;

  Future<List<Task>> getTasks() async {
    final TaskRepository taskRepository = TaskRepository();

    return await taskRepository.getUserTasks(this);
  }

  User.fromJson(Map<String, dynamic> json)
    : name = json['name'] as String,
      email = json['email'] as String,
      href = json['href'] as String;

  String toJsonString() =>
      jsonEncode({'name': name, 'email': email, "href": href});
}
