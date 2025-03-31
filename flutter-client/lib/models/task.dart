import 'package:fly_todo/repositories/task_repository.dart';

class Task {
  String name;
  bool isCompleted;
  String href;

  Task(this.name, this.isCompleted, this.href);

  Task.fromJson(Map<String, dynamic> json)
    : name = json['name'] as String,
      isCompleted = json['isCompleted'] as bool,
      href = json['href'] as String;

  Map<String, dynamic> toJson() => {
    'name': name,
    'isCompleted': isCompleted,
    "href": href,
  };

  void update() async {
    final TaskRepository taskRepository = TaskRepository();
    await taskRepository.updateTask(this);
  }
}
