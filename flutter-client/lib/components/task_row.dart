import 'package:flutter/material.dart';
import 'package:fly_todo/models/task.dart';

class TaskRow extends StatefulWidget {
  const TaskRow({super.key, required this.task});

  final Task task;

  @override
  State<TaskRow> createState() => _TaskRowState();
}

class _TaskRowState extends State<TaskRow> {
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.task.name);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged:
          (value) => {
            setState(() {
              widget.task.name = value;
            }),
          },
      onEditingComplete: () => {widget.task.update()},
    );
  }
}
