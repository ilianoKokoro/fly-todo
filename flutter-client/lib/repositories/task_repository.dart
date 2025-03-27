import "dart:convert";

import "package:fly_todo/core/error_helper.dart";
import "package:fly_todo/models/task.dart";
import "package:fly_todo/models/user.dart";
import "package:http/http.dart" as http;

class TaskRepository {
  Future<List<Task>> getUserTasks(User user) async {
    final response = await http.get(Uri.parse(user.href));

    final success = response.statusCode == 200;
    if (success) return jsonDecode(response.body)["tasks"];
    throw Exception(ErrorHelper.getErrorMessage(response.body));
  }
}
