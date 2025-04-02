import 'package:flutter/material.dart';
import 'package:fly_todo/components/task_row.dart';
import 'package:fly_todo/core/modal.dart';
import 'package:fly_todo/core/constants.dart';
import 'package:fly_todo/models/task.dart';
import 'package:fly_todo/models/user.dart';
import 'package:fly_todo/repositories/auth_repository.dart';
import 'package:fly_todo/repositories/datastore_repository.dart';
import 'package:fly_todo/repositories/task_repository.dart';
import 'package:fly_todo/screens/auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatastoreRepository _datastoreRepository = DatastoreRepository();
  final AuthRepository _authRepository = AuthRepository();
  final TaskRepository _taskRepository = TaskRepository();

  List<Task> _tasks = [];
  bool _loading = false;
  bool _floatingButtonLoading = false;

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

  void _logOut() {
    setState(() {
      _loading = true;
    });

    try {
      _authRepository.logOut();
    } catch (_) {
    } finally {
      _returnToAuth();
    }
  }

  Future<void> _createTask() async {
    if (_floatingButtonLoading == true) {
      return;
    }
    try {
      setState(() {
        _floatingButtonLoading = true;
      });
      Task newTask = await _taskRepository.createTask();
      setState(() {
        _tasks.add(newTask);
      });
    } on Exception catch (err) {
      if (context.mounted) {
        Modal.showError(err, context);
      }
    } finally {
      setState(() {
        _floatingButtonLoading = false;
      });
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
        child:
            _floatingButtonLoading
                ? CircularProgressIndicator(
                  constraints: BoxConstraints(maxHeight: 10, maxWidth: 10),
                )
                : const Icon(Icons.add),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Center(
          child:
              _loading
                  ? CircularProgressIndicator()
                  : _tasks.isEmpty
                  ? Text("No tasks created")
                  : SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 800),
                      child: Column(
                        children: [
                          ..._tasks
                              .where((model) => !model.isCompleted)
                              .map((model) => TaskRow(task: model)),
                        ],
                      ),
                    ),
                  ),
        ),
      ),
    );
  }
}
