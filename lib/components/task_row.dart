import 'package:flutter/material.dart';
import 'package:fly_todo/models/task.dart';

class TaskRow extends StatefulWidget {
  const TaskRow({
    super.key,
    required this.task,
    required this.onUpdate,
    required this.onDelete,
  });

  final Task task;
  final Function(Task) onUpdate;
  final Function(Task) onDelete;

  @override
  State<TaskRow> createState() => _TaskRowState();
}

class _TaskRowState extends State<TaskRow> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _updateTask({String? name, bool? isCompleted}) {
    final updatedTask = Task(
      widget.task.id,
      name ?? widget.task.name,
      isCompleted ?? widget.task.isCompleted,
      widget.task.creator,
      widget.task.createdAt,
    );

    widget.onUpdate(updatedTask);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Checkbox(
            shape: const CircleBorder(),
            value: widget.task.isCompleted,
            onChanged: (value) => _updateTask(isCompleted: value ?? false),
          ),
        ),
        Expanded(
          child: TextFormField(
            initialValue: widget.task.name,
            onChanged: (value) => _updateTask(name: value),
            enabled: true,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete_rounded),
          onPressed: () => widget.onDelete(widget.task),
        ),
      ],
    );
  }
}
