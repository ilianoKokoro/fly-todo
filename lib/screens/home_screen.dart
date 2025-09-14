import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
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
  Task? _lastUpdatedTask;
  Timer? _updateDebounce;

  @override
  void dispose() {
    _updateDebounce?.cancel();
    super.dispose();
  }

  Future<void> _logOut() async {
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
      await Task.create();
    } on Exception catch (err) {
      if (mounted) {
        Modal.showError(err, context);
      }
    }
  }

  Future<void> _onTaskUpdate(Task updatedTask) async {
    try {
      if (_updateDebounce?.isActive ?? false) {
        if (updatedTask.id != _lastUpdatedTask?.id) {
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async => {_createTask()},
        enableFeedback: true,
        child: const Icon(Icons.add),
      ),
      body: Center(
        child: StreamBuilder(
          stream:
              FirebaseFirestore.instance
                  .collection("tasks")
                  .where(
                    "creator",
                    isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                  )
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            try {
              if (!snapshot.hasData) {
                throw Exception();
              }
              snapshot.data!.docs;
            } catch (e) {
              return const Text("No tasks");
            }
            final tasks = snapshot.data!.docs;
            final uncompletedTasks = tasks.where(
              (task) => task.data()["isCompleted"] == "false",
            );

            return ConstrainedBox(
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
                        tasks: Task.listFromDocuments(uncompletedTasks),
                        onDelete: _onTaskDelete,
                        onUpdate: _onTaskUpdate,
                        loading: false,
                      ),
                      TaskColumn(
                        tasks: Task.listFromDocuments(tasks),
                        onUpdate: _onTaskUpdate,
                        onDelete: _onTaskDelete,
                        loading: false,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
