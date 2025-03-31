import "dart:convert";

import "package:fly_todo/core/error_helper.dart";
import "package:fly_todo/models/task.dart";
import "package:fly_todo/models/tokens.dart";
import "package:fly_todo/models/user.dart";
import "package:fly_todo/repositories/datastore_repository.dart";
import "package:http/http.dart" as http;

class TaskRepository {
  final DatastoreRepository _datastoreRepository = DatastoreRepository();

  Future<List<Task>> getUserTasks(User user) async {
    Tokens tokens = await _datastoreRepository.getTokens();
    final response = await http.get(
      Uri.parse(user.href),
      headers: {'Authorization': 'Bearer ${tokens.access}'},
    );

    final success = response.statusCode == 200;

    if (success) {
      List<Task> tasks = List<Task>.from(
        json
            .decode(response.body)["tasks"]
            .map((model) => Task.fromJson(model)),
      );
      return tasks;
    }

    throw Exception(ErrorHelper.getErrorMessage(response.body));
  }

  Future<Task> updateTask(Task task) async {
    Tokens tokens = await _datastoreRepository.getTokens();
    final response = await http.patch(
      Uri.parse(task.href),
      headers: {'Authorization': 'Bearer ${tokens.access}'},
    );

    final success = response.statusCode == 200;

    if (success) {
      return Task.fromJson(json.decode(response.body));
    }

    throw Exception(ErrorHelper.getErrorMessage(response.body));
  }
}
