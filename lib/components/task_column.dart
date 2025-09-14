import 'package:flutter/material.dart';
import 'package:fly_todo/components/task_row.dart';
import 'package:fly_todo/models/task.dart';

class TaskColumn extends StatefulWidget {
  const TaskColumn({
    super.key,
    required this.tasks,
    required this.onUpdate,
    required this.onDelete,
    required this.loading,
  });

  final List<Task> tasks;
  final ValueChanged<Task> onUpdate;
  final ValueChanged<Task> onDelete;
  final bool loading;

  @override
  State<TaskColumn> createState() => _TaskColumnState();
}

class _TaskColumnState extends State<TaskColumn> {
  final GlobalKey<SliverAnimatedListState> _listKey =
      GlobalKey<SliverAnimatedListState>();
  late List<Task> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = List.from(widget.tasks);
  }

  @override
  void didUpdateWidget(covariant TaskColumn oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newTasks = widget.tasks;
    final oldTasks = _tasks;

    if (newTasks.length > oldTasks.length) {
      // Add new tasks
      for (int i = 0; i < newTasks.length; i++) {
        final task = newTasks[i];
        if (i >= oldTasks.length || oldTasks[i].id != task.id) {
          _tasks.insert(i, task);
          _listKey.currentState?.insertItem(i);
        }
      }
    } else if (newTasks.length < oldTasks.length) {
      // Remove tasks
      for (int i = oldTasks.length - 1; i >= 0; i--) {
        final task = oldTasks[i];
        if (!newTasks.any((newTask) => newTask.id == task.id)) {
          _tasks.removeAt(i);
          _listKey.currentState?.removeItem(
            i,
            (context, animation) => _getCreatedObject(task, animation),
          );
        }
      }
    } else {
      // Handle updates to existing items
      for (int i = 0; i < _tasks.length; i++) {
        if (i < widget.tasks.length && _tasks[i] != widget.tasks[i]) {
          _tasks[i] = widget.tasks[i];
        }
      }
    }
  }

  Widget _getCreatedObject(Task task, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: TaskRow(
        key: ValueKey(task.id),
        task: task,
        onUpdate: widget.onUpdate,
        onDelete: widget.onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Center(
        child:
            widget.loading
                ? const CircularProgressIndicator()
                : widget.tasks.isEmpty
                ? const Text("No tasks to show", key: ValueKey('empty'))
                : CustomScrollView(
                  slivers: [
                    SliverAnimatedList(
                      key: _listKey,
                      initialItemCount: _tasks.length,
                      itemBuilder: (context, index, animation) {
                        final task = _tasks[index];
                        return _getCreatedObject(task, animation);
                      },
                    ),
                  ],
                ),
      ),
    );
  }
}
