import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Task {
  static Future<void> create() async {
    await FirebaseFirestore.instance.collection("tasks").add({
      "name": "",
      "isCompleted": "false",
      "creator": FirebaseAuth.instance.currentUser!.uid,
    });
  }

  static List<Task> listFromDocuments(
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> tasksDocuments,
  ) {
    final List<Task> tasks = [];
    for (var taskDocument in tasksDocuments) {
      tasks.add(
        Task(
          taskDocument.id,
          taskDocument["name"],
          taskDocument["isCompleted"] == "true",
          taskDocument["creator"],
        ),
      );
    }

    return tasks;
  }

  String id;
  String name;
  bool isCompleted;
  String creator;

  Task(this.id, this.name, this.isCompleted, this.creator);

  Future<void> update() async {
    await FirebaseFirestore.instance.collection("tasks").doc(id).update({
      "name": name,
      "isCompleted": isCompleted.toString(),
    });
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance.collection("task").doc(id).delete();
  }
}
