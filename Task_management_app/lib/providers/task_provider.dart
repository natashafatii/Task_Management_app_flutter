import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();
  List<Task> get tasks => _taskService.tasks;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Additional computed properties for statistics
  List<Task> get completedTasks => _taskService.tasks.where((task) => task.isCompleted).toList();
  List<Task> get pendingTasks => _taskService.tasks.where((task) => !task.isCompleted).toList();
  List<Task> get highPriorityTasks => _taskService.tasks.where((task) => task.priority == 'High').toList();
  List<Task> get mediumPriorityTasks => _taskService.tasks.where((task) => task.priority == 'Medium').toList();
  List<Task> get lowPriorityTasks => _taskService.tasks.where((task) => task.priority == 'Low').toList();
  List<Task> get overdueTasks => _taskService.tasks.where((task) => task.isOverdue).toList();

  List<Task> get tasksDueToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _taskService.tasks.where((task) {
      if (task.dueDate == null) return false;
      final dueDay = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
      return dueDay == today && !task.isCompleted;
    }).toList();
  }

  // Statistics properties
  int get totalTasks => _taskService.tasks.length;
  int get completedTasksCount => completedTasks.length;
  int get pendingTasksCount => pendingTasks.length;
  int get highPriorityCount => highPriorityTasks.length;
  int get mediumPriorityCount => mediumPriorityTasks.length;
  int get lowPriorityCount => lowPriorityTasks.length;
  int get overdueCount => overdueTasks.length;
  int get dueTodayCount => tasksDueToday.length;

  // Statistics method
  Map<String, dynamic> getStatistics() {
    return {
      'total': totalTasks,
      'completed': completedTasksCount,
      'pending': pendingTasksCount,
      'highPriority': highPriorityCount,
      'mediumPriority': mediumPriorityCount,
      'lowPriority': lowPriorityCount,
      'overdue': overdueCount,
      'dueToday': dueTodayCount,
    };
  }

  // Sorting methods
  void sortTasks(String sortBy) {
    switch (sortBy) {
      case 'priority':
        _taskService.tasks.sort((a, b) {
          final priorityOrder = {'High': 0, 'Medium': 1, 'Low': 2};
          return priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
        });
        break;
      case 'dueDate':
        _taskService.tasks.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case 'title':
        _taskService.tasks.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'createdAt':
      default:
        _taskService.tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    notifyListeners();
  }

  // Filtering methods
  List<Task> filterByPriority(String priority) {
    return _taskService.tasks.where((task) => task.priority == priority).toList();
  }

  List<Task> filterByCompletion(bool completed) {
    return _taskService.tasks.where((task) => task.isCompleted == completed).toList();
  }

  // Search method
  List<Task> searchTasks(String query) {
    if (query.isEmpty) return _taskService.tasks;
    return _taskService.tasks.where((task) {
      return task.title.toLowerCase().contains(query.toLowerCase()) ||
          task.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Enhanced task management methods
  Future<void> addTaskWithDetails({
    required String title,
    required String description,
    String priority = 'Medium',
    DateTime? dueDate,
  }) async {
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      priority: priority,
      dueDate: dueDate,
    );

    await _taskService.addTask(newTask);
    notifyListeners();
  }

  Future<void> updateTaskWithDetails({
    required String taskId,
    required String title,
    required String description,
    String? priority,
    DateTime? dueDate,
  }) async {
    final existingTask = _taskService.tasks.firstWhere((t) => t.id == taskId);
    final updatedTask = existingTask.copyWith(
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      updatedAt: DateTime.now(),
    );

    await _taskService.updateTask(updatedTask);
    notifyListeners();
  }

  Future<void> updateTaskPriority(String taskId, String priority) async {
    final existingTask = _taskService.tasks.firstWhere((t) => t.id == taskId);
    final updatedTask = existingTask.copyWith(
      priority: priority,
      updatedAt: DateTime.now(),
    );

    await _taskService.updateTask(updatedTask);
    notifyListeners();
  }

  Future<void> updateTaskDueDate(String taskId, DateTime? dueDate) async {
    final existingTask = _taskService.tasks.firstWhere((t) => t.id == taskId);
    final updatedTask = existingTask.copyWith(
      dueDate: dueDate,
      updatedAt: DateTime.now(),
    );

    await _taskService.updateTask(updatedTask);
    notifyListeners();
  }

  // Clear completed tasks
  Future<void> clearCompletedTasks() async {
    final completedTaskIds = completedTasks.map((task) => task.id).toList();

    for (final taskId in completedTaskIds) {
      await _taskService.deleteTask(taskId);
    }

    notifyListeners();
  }

  // Get task by ID
  Task? getTaskById(String taskId) {
    try {
      return _taskService.tasks.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }

  // Load sample tasks
  Future<void> loadSampleTasks() async {
    _isLoading = true;
    notifyListeners();

    final now = DateTime.now();
    final sampleTasks = [
      Task(
        id: '1',
        title: 'Complete Flutter Project',
        description: 'Finish the task management app with Provider',
        createdAt: now.subtract(const Duration(days: 2)),
        priority: 'High',
        dueDate: now.add(const Duration(days: 1)),
      ),
      Task(
        id: '2',
        title: 'Learn Provider State Management',
        description: 'Understand how to use Provider for state management',
        createdAt: now.subtract(const Duration(days: 1)),
        isCompleted: true,
        priority: 'Medium',
        dueDate: now.subtract(const Duration(days: 1)),
      ),
      Task(
        id: '3',
        title: 'Design App UI/UX',
        description: 'Create beautiful and responsive user interfaces',
        createdAt: now,
        priority: 'Medium',
        dueDate: now.add(const Duration(days: 3)),
      ),
      Task(
        id: '4',
        title: 'Write Documentation',
        description: 'Document the code and create user guides',
        createdAt: now,
        priority: 'Low',
        dueDate: now.add(const Duration(days: 7)),
      ),
    ];

    // Clear existing tasks and add sample tasks
    for (final task in _taskService.tasks.toList()) {
      await _taskService.deleteTask(task.id);
    }

    for (final task in sampleTasks) {
      await _taskService.addTask(task);
    }

    _isLoading = false;
    notifyListeners();
  }

  // Your existing methods (keeping them intact)
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    await _taskService.loadTasks();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await _taskService.addTask(task);
    notifyListeners();
  }

  Future<void> updateTask(Task updatedTask) async {
    await _taskService.updateTask(updatedTask);
    notifyListeners();
  }

  Future<void> deleteTask(String taskId) async {
    await _taskService.deleteTask(taskId);
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    await _taskService.toggleTaskCompletion(taskId);
    notifyListeners();
  }
}