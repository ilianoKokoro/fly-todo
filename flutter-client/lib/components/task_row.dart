import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fly_todo/core/constants.dart';
import 'package:fly_todo/models/task.dart';

class TaskRow extends StatefulWidget {
  const TaskRow({super.key, required this.task, required this.onUpdate});

  final Task task;
  final Function(Task) onUpdate;

  @override
  State<TaskRow> createState() => _TaskRowState();
}

class _TaskRowState extends State<TaskRow> {
  TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _updateTask({String? name, bool? isCompleted}) {
    setState(() {
      widget.task.name = name ?? widget.task.name;
      widget.task.isCompleted = isCompleted ?? widget.task.isCompleted;
    });

    if (name != null) {
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: App.debounceMs), () {
        widget.onUpdate(widget.task);
      });
    } else {
      widget.onUpdate(widget.task);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.task.name);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          shape: CircleBorder(),
          value: widget.task.isCompleted,
          onChanged: (value) => {_updateTask(isCompleted: value ?? false)},
        ),
        Expanded(
          child: TextField(
            controller: _controller,
            onChanged: (value) => {_updateTask(name: value)},
            enabled: true,
          ),
        ),
      ],
    );
  }
}
