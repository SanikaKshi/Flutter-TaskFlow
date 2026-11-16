import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// SUPABASE CONFIGURATION
const String supabaseUrl = 'https://nfdohbkucdzbeicopssz.supabase.co';

const String supabasePublishableKey =
    'sb_publishable_VW6OZK-yo5tuyZ8iIuZVBA_N--_EZ0F';

// APP COLORS
const Color primaryBlue = Color(0xFF3157D5);
const Color inkBlack = Color(0xFF111827);
const Color softBackground = Color(0xFFF5F7FC);

final supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabasePublishableKey,
  );

  runApp(const TaskFlowApp());
}

// TASK MODEL
class Task {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'].toString(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isCompleted: map['is_completed'] ?? false,
    );
  }
}

// MAIN APP
class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TaskFlow',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: softBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          primary: primaryBlue,
          surface: Colors.white,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

// AUTHENTICATION GATE
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final user = supabase.auth.currentUser;

        if (user != null) {
          return TaskHomePage(userId: user.id);
        }

        return const AuthPage();
      },
    );
  }
}

// LOGIN AND REGISTRATION SCREEN
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLogin = true;
  bool isLoading = false;
  bool obscurePassword = true;

  Future<void> authenticate() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showMessage('Please enter email and password.');
      return;
    }

    if (password.length < 6) {
      showMessage('Password must be at least 6 characters.');
      return;
    }

    setState(() => isLoading = true);

    try {
      if (isLogin) {
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        showMessage('Login successful!');
      } else {
        final response = await supabase.auth.signUp(
          email: email,
          password: password,
        );

        if (response.session == null) {
          showMessage(
            'Registration successful! Please verify your email, then log in.',
          );
        } else {
          showMessage('Account created successfully!');
        }
      }
    } on AuthException catch (error) {
      showMessage(error.message);
    } catch (error) {
      showMessage('Something went wrong: $error');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 58,
                  color: primaryBlue,
                ),
                const SizedBox(height: 12),
                const Text(
                  'TaskFlow',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: inkBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isLogin
                      ? 'Welcome back! Sign in to continue.'
                      : 'Create an account to manage your tasks.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : authenticate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            isLogin ? 'Login' : 'Register',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      isLogin = !isLogin;
                    });
                  },
                  child: Text(
                    isLogin
                        ? "Don't have an account? Register"
                        : 'Already have an account? Login',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// TASK DASHBOARD
class TaskHomePage extends StatefulWidget {
  final String userId;

  const TaskHomePage({
    super.key,
    required this.userId,
  });

  @override
  State<TaskHomePage> createState() => _TaskHomePageState();
}

class _TaskHomePageState extends State<TaskHomePage> {
  final Set<String> deletingTaskIds = {};

  Stream<List<Map<String, dynamic>>> get taskStream {
    return supabase
        .from('tasks')
        .stream(primaryKey: ['id'])
        .eq('user_id', widget.userId)
        .order('created_at', ascending: false);
  }

  // ADD AND EDIT TASK
  Future<void> showTaskDialog({Task? task}) async {
    final titleController = TextEditingController(
      text: task?.title ?? '',
    );

    final descriptionController = TextEditingController(
      text: task?.description ?? '',
    );

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            task == null ? 'Add New Task' : 'Edit Task',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task title',
                    hintText: 'Enter task title',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter task description',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final description = descriptionController.text.trim();

                if (title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a task title.'),
                    ),
                  );
                  return;
                }

                try {
                  if (task == null) {
                    await supabase.from('tasks').insert({
                      'user_id': widget.userId,
                      'title': title,
                      'description': description,
                      'is_completed': false,
                    });
                  } else {
                    await supabase
                        .from('tasks')
                        .update({
                          'title': title,
                          'description': description,
                        })
                        .eq('id', task.id)
                        .eq('user_id', widget.userId);
                  }

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }

                  showMessage(
                    task == null
                        ? 'Task added successfully!'
                        : 'Task updated successfully!',
                  );
                } catch (error) {
                  showMessage('Unable to save task: $error');
                }
              },
              child: Text(
                task == null ? 'Add Task' : 'Update',
              ),
            ),
          ],
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();
  }

  // DELETE TASK - IMMEDIATE UI UPDATE
  Future<void> deleteTask(Task task) async {
    setState(() {
      deletingTaskIds.add(task.id);
    });

    try {
      final deletedRows = await supabase
          .from('tasks')
          .delete()
          .eq('id', task.id)
          .eq('user_id', widget.userId)
          .select();

      if (!mounted) return;

      if (deletedRows.isEmpty) {
        setState(() {
          deletingTaskIds.remove(task.id);
        });

        showMessage('Task could not be deleted. Please try again.');
        return;
      }

      showMessage('Task deleted successfully!');
    } catch (error) {
      if (!mounted) return;

      setState(() {
        deletingTaskIds.remove(task.id);
      });

      showMessage('Unable to delete task: $error');
    }
  }

  // MARK TASK AS COMPLETED OR PENDING
  Future<void> toggleTask(Task task, bool value) async {
    try {
      await supabase
          .from('tasks')
          .update({'is_completed': value})
          .eq('id', task.id)
          .eq('user_id', widget.userId);
    } catch (error) {
      showMessage('Unable to update task: $error');
    }
  }

  // LOGOUT
  Future<void> logout() async {
    try {
      await supabase.auth.signOut();
    } catch (error) {
      showMessage('Logout failed: $error');
    }
  }

  // SNACKBAR MESSAGE
  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // DASHBOARD UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        title: const Text(
          'TaskFlow',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      // ADD TASK BUTTON
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showTaskDialog(),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),

      // REAL-TIME TASK LIST
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: taskStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load tasks: ${snapshot.error}',
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryBlue,
              ),
            );
          }

          final allTasks =
              (snapshot.data ?? []).map((item) => Task.fromMap(item)).toList();

          final tasks = allTasks
              .where(
                (task) => !deletingTaskIds.contains(task.id),
              )
              .toList();

          final total = tasks.length;

          final completed = tasks.where((task) => task.isCompleted).length;

          final pending = total - completed;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              100,
            ),
            children: [
              const Text(
                'My Tasks',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: inkBlack,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Organise your day and get things done.',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: buildStatCard(
                      'Total',
                      total.toString(),
                      Icons.list_alt,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: buildStatCard(
                      'Pending',
                      pending.toString(),
                      Icons.pending_actions,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: buildStatCard(
                      'Done',
                      completed.toString(),
                      Icons.check_circle_outline,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Tasks',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: inkBlack,
                    ),
                  ),
                  Text(
                    '$total tasks',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              if (tasks.isEmpty)
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.task_alt,
                        size: 55,
                        color: primaryBlue,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No tasks yet',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Tap Add Task to create your first task.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

              ...tasks.map((task) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.035),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: task.isCompleted,
                        activeColor: primaryBlue,
                        onChanged: (value) {
                          if (value != null) {
                            toggleTask(task, value);
                          }
                        },
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: inkBlack,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            if (task.description.isNotEmpty) ...[
                              const SizedBox(height: 5),
                              Text(
                                task.description,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                            const SizedBox(height: 5),
                            Text(
                              task.isCompleted ? 'Completed' : 'Pending',
                              style: TextStyle(
                                fontSize: 12,
                                color: task.isCompleted
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        tooltip: 'Edit task',
                        onPressed: () => showTaskDialog(task: task),
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: primaryBlue,
                        ),
                      ),

                      IconButton(
                        tooltip: 'Delete task',
                        onPressed: () => deleteTask(task),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget buildStatCard(
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: primaryBlue,
            size: 23,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: inkBlack,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
