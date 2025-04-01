import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fly_todo/core/constants.dart';
import 'package:fly_todo/core/modal.dart';
import 'package:fly_todo/models/task.dart';

class TaskRow extends StatefulWidget {
  const TaskRow({super.key, required this.task});

  final Task task;

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
    widget.task.name = newValue;
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: App.debounceMs), () {
      setState(() {
        try {
          widget.task.update();
        } on Exception catch (err) {
          Modal.showError(err, context);
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.task.name);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: (value) => {_onTextChanged(value)},
    );
  }
}
