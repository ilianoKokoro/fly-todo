import 'package:material_ui/material_ui.dart';
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
  late final TextEditingController _controller =
      TextEditingController(text: widget.task.name);
  final FocusNode _focus = FocusNode();

  @override
  bool get wantKeepAlive => true;

  @override
  void didUpdateWidget(TaskRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focus.hasFocus && widget.task.name != _controller.text) {
      _controller.text = widget.task.name;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _updateTask({bool? isCompleted}) {
    widget.onUpdate(
      Task(
        widget.task.id,
        _controller.text,
        isCompleted ?? widget.task.isCompleted,
        widget.task.creator,
        widget.task.createdAt,
      ),
    );
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
          child: TextField(
            controller: _controller,
            focusNode: _focus,
            onChanged: (_) => _updateTask(),
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
