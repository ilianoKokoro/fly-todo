import 'package:flutter/material.dart';
import 'package:fly_todo/components/task_column.dart';
import 'package:fly_todo/core/modal.dart';
import 'package:fly_todo/core/constants.dart';
import 'package:fly_todo/models/task.dart';
import 'package:fly_todo/models/user.dart';
import 'package:fly_todo/repositories/auth_repository.dart';
import 'package:fly_todo/repositories/datastore_repository.dart';
import 'package:fly_todo/screens/auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatastoreRepository _datastoreRepository = DatastoreRepository();
  final AuthRepository _authRepository = AuthRepository();

  List<Task> _tasks = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getTasks();
    });
  }

  Future<void> getTasks() async {
    setState(() {
      _loading = true;
    });

    try {
      User savedUser = await _datastoreRepository.getUser();
      var tasks = await savedUser.getTasks();
      setState(() {
        _tasks = tasks;
      });

      setState(() {
        _loading = false;
      });
    } catch (_) {
      _returnToAuth();
    }
  }

  void _returnToAuth({showMessage = false}) {
    _datastoreRepository.clearDatastore();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AuthScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: Duration(milliseconds: Transitions.duration),
      ),
    );

    if (showMessage) {
      Modal.showInfo("Log out successful", "Successfully logged out", context);
    }
  }

  void _logOut() async {
    setState(() {
      _loading = true;
    });

    try {
      await _authRepository.logOut();
    } on Exception catch (err) {
      if (context.mounted) {
        Modal.showError(err, context);
      }
    } finally {
      _returnToAuth();
    }
  }

  Future<void> _createTask() async {
    try {
      Task newTask = await Task.create();
      setState(() {
        _tasks.add(newTask);
      });
    } on Exception catch (err) {
      if (context.mounted) {
        Modal.showError(err, context);
      }
    }
  }

  Future<void> _onTaskUpdate(Task updatedTask) async {
    try {
      await updatedTask.update();

      int index = _tasks.indexWhere((item) => item.href == updatedTask.href);
      if (index != -1) {
        setState(() {
          _tasks[index] = updatedTask;
        });
      }
    } on Exception catch (err) {
      Modal.showError(err, context);
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
      body: DefaultTabController(
        initialIndex: 1,
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('TabBar Sample'),
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
                onUpdate: _onTaskUpdate,
                loading: _loading,
              ),
              TaskColumn(
                tasks: _tasks,
                onUpdate: _onTaskUpdate,
                loading: _loading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
