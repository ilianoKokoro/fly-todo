import 'package:flutter/material.dart';
import 'package:fly_todo/components/task_row.dart';
import 'package:fly_todo/core/Modal.dart';
import 'package:fly_todo/core/constants.dart';
import 'package:fly_todo/models/task.dart';
import 'package:fly_todo/models/user.dart';
import 'package:fly_todo/repositories/auth_repository.dart';
import 'package:fly_todo/repositories/datastore_repository.dart';
import 'package:fly_todo/screens/auth_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  final DatastoreRepository datastoreRepository = DatastoreRepository();
  final AuthRepository authRepository = AuthRepository();

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await tryAutomaticAuth();
    });
  }

  Future<void> tryAutomaticAuth() async {
    try {
      User savedUser = await widget.datastoreRepository.getUser();
      _tasks = await savedUser.getTasks();
    } catch (_) {
      _logOut();
    }
  }

  void _logOut({bool showMessage = false}) {
    try {
      try {
        widget.authRepository.logOut();
      } finally {
        widget.datastoreRepository.clearDatastore();
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => AuthScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: Duration(milliseconds: Transitions.duration),
          ),
        );
        if (showMessage) {
          Modal.showInfo(
            "Log out successful",
            "Successfully logged out",
            context,
          );
        }
      }
    } on Exception catch (err) {
      if (context.mounted) {
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
        title: const Text(App.title),
      ),
      body: Center(
        child:
            _tasks.isEmpty
                ? Text("No tasks created")
                : SingleChildScrollView(
                  child: Column(
                    children: [
                      ..._tasks.map(
                        (model) =>
                            TaskRow(task: model, onTaskUpdated: (p0) => {}),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
