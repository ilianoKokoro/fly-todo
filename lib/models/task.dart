import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fly_todo/core/constants.dart';

class Task {
  static Future<void> create() async {
    await FirebaseFirestore.instance.collection(Collections.tasks).add({
      "name": "",
      "isCompleted": "false",
      "creator": FirebaseAuth.instance.currentUser!.uid,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  static List<Task> listFromDocuments(
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final tasks = List<Task>.from(
      docs.map((doc) {
        final data = doc.data();

        final createdAt =
            data["createdAt"] is Timestamp
                ? (data["createdAt"] as Timestamp).toDate()
                : DateTime.now();

        return Task(
          doc.id,
          data["name"] as String,
          data["isCompleted"] is bool
              ? data["isCompleted"] as bool
              : data["isCompleted"].toString() == "true",
          data["creator"] as String,
          createdAt,
        );
      }),
      growable: false,
    );

    return tasks;
  }

  String id;
  String name;
  bool isCompleted;
  String creator;
  DateTime createdAt;

  Task(this.id, this.name, this.isCompleted, this.creator, this.createdAt);

  Future<void> update() async {
    await FirebaseFirestore.instance
        .collection(Collections.tasks)
        .doc(id)
        .update({"name": name, "isCompleted": isCompleted.toString()});
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance
        .collection(Collections.tasks)
        .doc(id)
        .delete();
  }
}
