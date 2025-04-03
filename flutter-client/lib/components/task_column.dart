import 'package:flutter/material.dart';
import 'package:fly_todo/components/task_row.dart';
import 'package:fly_todo/models/task.dart';

class TaskColumn extends StatelessWidget {
  final List<Task> tasks;
  final bool loading;

  const TaskColumn({
    required this.tasks,
    super.key,
    required this.onUpdate,
    required this.loading,
  });

  final Function(Task) onUpdate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Center(
        child:
            loading
                ? CircularProgressIndicator()
                : tasks.isEmpty
                ? Text("No tasks to show")
                : ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 800),
                  child: ListView.builder(
                    itemCount: tasks.length,
                    cacheExtent: 1000,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskRow(task: task, onUpdate: onUpdate);
                    },
                  ),
                ),
      ),
    );
  }
}
