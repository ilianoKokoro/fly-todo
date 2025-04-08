import 'package:flutter/material.dart';
import 'package:fly_todo/components/task_row.dart';
import 'package:fly_todo/core/constants.dart';
import 'package:fly_todo/models/task.dart';

class TaskColumn extends StatefulWidget {
  final List<Task> tasks;
  final bool loading;
  final Function(Task) onUpdate;
  final Function(Task) onDelete;

  const TaskColumn({
    required this.tasks,
    required this.loading,
    required this.onUpdate,
    required this.onDelete,
    super.key,
  });

  @override
  State<TaskColumn> createState() => _TaskColumnState();
}

class _TaskColumnState extends State<TaskColumn> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<Task> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = List.from(widget.tasks);
  }

  @override
  void didUpdateWidget(covariant TaskColumn oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle transition from empty to first item
    if (widget.tasks.isNotEmpty && _tasks.isEmpty) {
      _tasks = List.from(widget.tasks);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_listKey.currentState != null && _tasks.isNotEmpty) {
          _listKey.currentState!.insertItem(0);
        }
      });
      return;
    }

    // Handle removal of last item
    if (widget.tasks.isEmpty && _tasks.isNotEmpty) {
      final lastItem = _tasks.last;
      _tasks.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_listKey.currentState != null) {
          _listKey.currentState!.removeItem(
            0,
            (context, animation) => _getRemovedObject(lastItem, animation),
          );
        }
      });
      return;
    }

    // Handle item additions
    if (widget.tasks.length > _tasks.length) {
      final newItems =
          widget.tasks.where((item) => !_tasks.contains(item)).toList();
      for (final item in newItems) {
        final index = widget.tasks.indexOf(item);
        if (index >= 0 && index <= _tasks.length) {
          _insertItem(index, item);
        }
      }
    }

    // Handle item removals
    if (widget.tasks.length < _tasks.length) {
      final removedItems =
          _tasks.where((item) => !widget.tasks.contains(item)).toList();
      for (final item in removedItems) {
        final index = _tasks.indexOf(item);
        if (index >= 0 && index < _tasks.length) {
          _removeItem(index, item);
        }
      }
    }
  }

  void _insertItem(int index, Task task) {
    if (index >= 0 && index <= _tasks.length) {
      _tasks.insert(index, task);
      _listKey.currentState?.insertItem(
        index,
        duration: const Duration(milliseconds: App.animation),
      );
    }
  }

  void _removeItem(int index, Task task) {
    if (index >= 0 && index < _tasks.length) {
      _tasks.removeAt(index);
      _listKey.currentState?.removeItem(
        index,
        (context, animation) => _getRemovedObject(task, animation),
        duration: const Duration(milliseconds: App.animation),
      );
    }
  }

  Widget _getRemovedObject(Task task, Animation<double> animation) {
    // TODO THE ANIMATION IS INVERTED
    final invertedAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

    return FadeTransition(
      opacity: invertedAnimation,
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 1.0,
          end: 0.8,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: TaskRow(
          task: task,
          onUpdate: widget.onUpdate,
          onDelete: widget.onDelete,
        ),
      ),
    );
  }

  Widget _getCreatedObject(Animation<double> animation, Task task) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
      child: FadeTransition(
        opacity: animation,
        child: TaskRow(
          key: ValueKey(task.href),
          task: task,
          onUpdate: widget.onUpdate,
          onDelete: widget.onDelete,
        ),
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
                : AnimatedSwitcher(
                  duration: const Duration(milliseconds: App.animation),
                  child:
                      _tasks.isEmpty
                          ? const Text(
                            "No tasks to show",
                            key: ValueKey('empty'),
                          )
                          : ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 800),
                            child: AnimatedList(
                              key: _listKey,
                              initialItemCount: _tasks.length,
                              itemBuilder: (context, index, animation) {
                                if (index >= 0 && index < _tasks.length) {
                                  final task = _tasks[index];
                                  return _getCreatedObject(animation, task);
                                }
                                return Container();
                              },
                            ),
                          ),
                ),
      ),
    );
  }
}
