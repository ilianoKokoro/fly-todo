import "dart:convert";

import "package:fly_todo/core/request_helper.dart";
import "package:fly_todo/models/task.dart";
import "package:fly_todo/models/user.dart";
import "package:fly_todo/repositories/datastore_repository.dart";

class TaskRepository {
  final DatastoreRepository _datastoreRepository = DatastoreRepository();

  Future<List<Task>> getUserTasks(User user) async {
    String responseBody = await RequestHelper.get(user.href);
    List<Task> tasks = List<Task>.from(
      json.decode(responseBody)["tasks"].map((model) => Task.fromJson(model)),
    );
    return tasks;
  }

  Future<Task> updateTask(Task task) async {
    var body = task.toJsonString();
    String responseBody = await RequestHelper.patch(task.href, body);
    return Task.fromJson(json.decode(responseBody));
  }

  Future<Task> createTask() async {
    var body = {"name": "New task"};
    User savedUser = await _datastoreRepository.getUser();
    String responseBody = await RequestHelper.post(
      "${savedUser.href}/tasks",
      jsonEncode(body),
    );
    return Task.fromJson(json.decode(responseBody));
  }
}
