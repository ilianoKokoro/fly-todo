import 'package:flutter/material.dart';
import 'package:fly_todo/models/task.dart';

class TaskRow extends StatefulWidget {
  const TaskRow({super.key, required this.task, required this.onTaskUpdated});

  final Task task;
  final Function(Task) onTaskUpdated;

  @override
  State<TaskRow> createState() => _TaskRowState();
}

class _TaskRowState extends State<TaskRow> {
  void _handleEditTask() async {
    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: widget.task.name);
        return AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Task name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (newName != null && newName != widget.task.name) {
      setState(() {
        widget.task.name = newName;
      });
      widget.onTaskUpdated(widget.task);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _handleEditTask,
        hoverColor: Theme.of(context).hoverColor,
        splashColor: Theme.of(context).splashColor,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              // Checkbox with custom tap handling
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: IgnorePointer(
                  ignoring: false,
                  child: Checkbox(
                    value: widget.task.isCompleted,
                    onChanged: (value) {
                      setState(() {
                        widget.task.isCompleted = value ?? false;
                      });
                      widget.onTaskUpdated(widget.task);
                    },
                    shape: const CircleBorder(),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Task text that fills remaining space
              Expanded(
                child: Text(
                  widget.task.name,
                  style: TextStyle(
                    fontSize: 16,
                    decoration:
                        widget.task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
