
import 'package:flutter/material.dart';

void main() {
  runApp(const TaskFlowApp());
}

const Color primaryBlue = Color(0xFF3157D5);
const Color inkBlack = Color(0xFF111827);
const Color softBackground = Color(0xFFF5F7FC);

class Task {
  String title;
  bool isCompleted;

  Task({
    required this.title,
    this.isCompleted = false,
  });
}

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: softBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          primary: primaryBlue,
        ),
        fontFamily: 'Roboto',
      ),
      home: const TaskHomePage(),
    );
  }
}

class TaskHomePage extends StatefulWidget {
  const TaskHomePage({super.key});

  @override
  State<TaskHomePage> createState() => _TaskHomePageState();
}

class _TaskHomePageState extends State<TaskHomePage> {
  final List<Task> tasks = [
    Task(title: 'Complete Flutter assignment'),
    Task(title: 'Study Dart programming'),
    Task(title: 'Prepare project presentation'),
    Task(title: 'Review project documentation', isCompleted: true),
  ];

  int get totalTasks => tasks.length;

  int get completedTasks =>
      tasks.where((task) => task.isCompleted).length;

  int get pendingTasks => totalTasks - completedTasks;

  void toggleTask(int index, bool? value) {
    setState(() {
      tasks[index].isCompleted = value ?? false;
    });
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task deleted')),
    );
  }

  void addTask(String title) {
    if (title.trim().isEmpty) return;

    setState(() {
      tasks.insert(0, Task(title: title.trim()));
    });
  }

  void showAddTaskDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Add New Task',
            style: TextStyle(
              color: inkBlack,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Enter task name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: primaryBlue),
              ),
            ),
            onSubmitted: (value) {
              addTask(value);
              Navigator.pop(dialogContext);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: primaryBlue,
              ),
              onPressed: () {
                addTask(controller.text);
                Navigator.pop(dialogContext);
              },
              child: const Text('Add Task'),
            ),
          ],
        );
      },
    ).then((_) => controller.dispose());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildHeader(),
                  const SizedBox(height: 32),
                  const Text(
                    'Stay organised.',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: inkBlack,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Manage your daily tasks and get things done.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 28),
                  buildStatistics(),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Today's Tasks",
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: inkBlack,
                        ),
                      ),
                      Text(
                        '$pendingTasks pending',
                        style: const TextStyle(
                          color: primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: tasks.isEmpty
                        ? buildEmptyState()
                        : ListView.separated(
                            itemCount: tasks.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              return buildTaskCard(index);
                            },
                          ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: showAddTaskDialog,
                      icon: const Icon(Icons.add),
                      label: const Text(
                        'Add New Task',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Row(
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: primaryBlue,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.checklist_rounded,
            color: Colors.white,
            size: 27,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'TaskFlow',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: inkBlack,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'MY TASKS',
            style: TextStyle(
              color: primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildStatistics() {
    return Row(
      children: [
        Expanded(
          child: buildStatCard(
            'Total Tasks',
            totalTasks,
            Icons.checklist_rounded,
            const Color(0xFFEAF0FF),
            primaryBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: buildStatCard(
            'Completed',
            completedTasks,
            Icons.check_circle_outline,
            const Color(0xFFEAF7EF),
            const Color(0xFF16834A),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: buildStatCard(
            'Pending',
            pendingTasks,
            Icons.schedule,
            const Color(0xFFFFF4E5),
            const Color(0xFFB76A12),
          ),
        ),
      ],
    );
  }

  Widget buildStatCard(
    String label,
    int count,
    IconData icon,
    Color background,
    Color foreground,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foreground, size: 22),
          const SizedBox(height: 12),
          Text(
            '$count',
            style: TextStyle(
              color: foreground,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget buildTaskCard(int index) {
    final task = tasks[index];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE9ECF3)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: task.isCompleted,
            activeColor: primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            onChanged: (value) => toggleTask(index, value),
          ),
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: task.isCompleted
                    ? Colors.black45
                    : inkBlack,
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Delete task',
            onPressed: () => deleteTask(index),
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.task_alt,
            size: 60,
            color: primaryBlue,
          ),
          SizedBox(height: 12),
          Text(
            'No tasks yet!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: inkBlack,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Add a task to get started.',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
