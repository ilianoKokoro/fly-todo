import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fly_todo/core/constants.dart';
import 'package:fly_todo/core/modal.dart';
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

  void _onTextChanged(String newValue) {
    setState(() {
      widget.task.name = newValue;
    });
    _updateTask();
  }

  void _onStatusChanged(bool? newValue) {
    setState(() {
      widget.task.isCompleted = newValue ?? false;
    });
    _updateTask();
  }

  void _updateTask() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: App.debounceMs), () {
      try {
        widget.onUpdate(widget.task);
      } on Exception catch (err) {
        Modal.showError(err, context);
      }
    });
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
          onChanged: (value) => {_onStatusChanged(value)},
        ),
        Expanded(
          child: TextField(
            controller: _controller,
            onChanged: (value) => {_onTextChanged(value)},
            enabled: true,
          ),
        ),
      ],
    );
  }
}
