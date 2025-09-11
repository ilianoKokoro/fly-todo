import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fly_todo/components/task_column.dart';
import 'package:fly_todo/core/modal.dart';
import 'package:fly_todo/core/constants.dart';
import 'package:fly_todo/models/task.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> _tasks = [];
  bool _loading = false;
  Task? _lastUpdatedTask;
  Timer? _updateDebounce;

  @override
  void initState() {
    super.initState();
    _getTasks();
  }

  @override
  void dispose() {
    _updateDebounce?.cancel();
    super.dispose();
  }

  Future<void> _getTasks() async {
    setState(() {
      _loading = true;
    });
    try {
      // TODO get tasks
      // User savedUser = await _datastoreRepository.getUser();
      // var tasks = await savedUser.getTasks();
      setState(() {
        _tasks = [];
      });

      setState(() {
        _loading = false;
      });
    } on Exception catch (err) {
      if (mounted) {
        Modal.showError(err, context);
      }
    }
  }

  Future<void> _logOut() async {
    setState(() {
      _loading = true;
    });

    try {
      await FirebaseAuth.instance.signOut();
    } on Exception catch (err) {
      if (mounted) {
        Modal.showError(err, context);
      }
    }
  }

  Future<void> _createTask() async {
    try {
      Task newTask = await Task.create();
      setState(() {
        _tasks.add(newTask);
      });
    } on Exception catch (err) {
      if (mounted) {
        Modal.showError(err, context);
      }
    }
  }

  Future<void> _onTaskUpdate(Task updatedTask) async {
    try {
      int index = _tasks.indexWhere((item) => item.href == updatedTask.href);
      if (index != -1) {
        setState(() {
          _tasks[index] = updatedTask;
        });
      }

      if (_updateDebounce?.isActive ?? false) {
        if (updatedTask.href != _lastUpdatedTask?.href) {
          _lastUpdatedTask?.update();
        }
        _updateDebounce?.cancel();
      }

      _updateDebounce = Timer(
        const Duration(milliseconds: App.debounceMs),
        () async {
          await updatedTask.update();
        },
      );
      _lastUpdatedTask = updatedTask;
    } on Exception catch (err) {
      if (mounted) {
        Modal.showError(err, context);
      }
    }
  }

  Future<void> _onTaskDelete(Task taskToDelete) async {
    try {
      setState(() {
        _tasks.remove(taskToDelete);
      });
      await taskToDelete.delete();
    } on Exception catch (err) {
      if (mounted) {
        Modal.showError(err, context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {
            _logOut();
          },
        ),
        centerTitle: true,
        title: const Text(App.title),
      ),
      floatingActionButton:
          _loading
              ? null
              : FloatingActionButton(
                onPressed: () async => {_createTask()},
                enableFeedback: true,
                child: const Icon(Icons.add),
              ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: DefaultTabController(
            initialIndex: 0,
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                bottom: const TabBar(
                  tabs: <Widget>[
                    Tab(icon: Text("Tasks TODO")),
                    Tab(icon: Text("All tasks")),
                  ],
                ),
              ),
              body: TabBarView(
                children: <Widget>[
                  TaskColumn(
                    tasks: _tasks.where((model) => !model.isCompleted).toList(),
                    onDelete: _onTaskDelete,
                    onUpdate: _onTaskUpdate,
                    loading: _loading,
                  ),
                  TaskColumn(
                    tasks: _tasks,
                    onUpdate: _onTaskUpdate,
                    onDelete: _onTaskDelete,
                    loading: _loading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
