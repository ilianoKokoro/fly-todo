import 'package:flutter/material.dart';
import 'package:fly_todo/models/task.dart';

class TaskRow extends StatefulWidget {
  const TaskRow({super.key, required this.task});

  final Task task;

  @override
  State<TaskRow> createState() => _TaskRowState();
}

class _TaskRowState extends State<TaskRow> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: widget.task.isCompleted,
        shape: const CircleBorder(),
        onChanged: (bool? value) {
          setState(() {
            widget.task.isCompleted = value ?? false;
          });
        },
      ),
      title: Text(widget.task.name),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minLeadingWidth: 0,
    );
  }
}
