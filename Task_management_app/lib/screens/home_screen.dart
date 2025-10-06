import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';
import '../widgets/loading_indicator.dart';
import '../constants/app_constants.dart';
import '../models/task_model.dart';
import 'task_detail_screen.dart';
import 'user_list_screen.dart';
import 'profile_screen.dart';
import '../constants/app_colors.dart';

enum TaskFilter { all, pending, completed, highPriority }
enum SortOrder { dueDate, priority, title }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = "";
  TaskFilter _filter = TaskFilter.all;
  SortOrder _sortOrder = SortOrder.dueDate;

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    // ✅ Use theme colors
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final lowerCaseQuery = _searchQuery.toLowerCase();
    final filteredTasks = taskProvider.tasks.where((task) {
      final matchesSearch = task.title.toLowerCase().contains(lowerCaseQuery) ||
          task.description.toLowerCase().contains(lowerCaseQuery);

      final matchesFilter = _filter == TaskFilter.all ||
          (_filter == TaskFilter.pending && !task.isCompleted) ||
          (_filter == TaskFilter.completed && task.isCompleted) ||
          (_filter == TaskFilter.highPriority && task.priority == "High");
      return matchesSearch && matchesFilter;
    }).toList();

    filteredTasks.sort(_sortTasks);

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(
          'My Tasks',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: colors.onPrimary,
          ),
        ),
        centerTitle: false,
        backgroundColor: colors.primary,
        elevation: 0,
        toolbarHeight: 80,
        actions: [
          // ✅ Notification Status Indicator (Coming Soon)
          IconButton(
            icon: Stack(
              children: [
                Icon(
                  Icons.notifications_none,
                  color: colors.onPrimary,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              _showSnackBar("Notifications feature coming soon!");
            },
            tooltip: 'Notifications (Coming Soon)',
          ),
          // ✅ Profile Button
          IconButton(
            icon: Icon(Icons.person, color: colors.onPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            tooltip: 'View Profile',
          ),
          // ✅ Users button
          IconButton(
            icon: Icon(Icons.people, color: colors.onPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserListScreen()),
              );
            },
            tooltip: 'View Users',
          ),
          IconButton(
            icon: Icon(Icons.sort, color: colors.onPrimary),
            onPressed: _showSortOptions,
            tooltip: 'Sort Options',
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: colors.onPrimary),
            onPressed: _showMoreOptions,
            tooltip: 'More Options',
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.primary, colors.primaryContainer],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await taskProvider.initialize();
        },
        child: CustomScrollView(
          slivers: [
            // ✅ Stats
            Consumer<TaskProvider>(
              builder: (context, provider, child) {
                final totalTasks = provider.tasks.length;
                if (totalTasks == 0) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
                final completedTasks = provider.tasks.where((task) => task.isCompleted).length;
                final pendingTasks = totalTasks - completedTasks;
                final highPriorityTasks = provider.tasks.where((task) => task.priority == "High").length;
                final tasksWithDueDates = provider.tasks.where((task) => task.dueDate != null).length;

                return SliverToBoxAdapter(
                  child: _buildStatisticsCards(
                      totalTasks, completedTasks, pendingTasks, highPriorityTasks, tasksWithDueDates, colors),
                );
              },
            ),

            // ✅ Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                  vertical: 8,
                ),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: TextStyle(color: colors.onSurface),
                  decoration: InputDecoration(
                    hintText: "Search tasks...",
                    hintStyle: TextStyle(color: colors.onSurface.withAlpha(128)),
                    prefixIcon: Icon(Icons.search, color: colors.secondary),
                    filled: true,
                    fillColor: colors.surfaceContainerHighest.withAlpha(128),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.clear,
                          color: colors.onSurface.withAlpha(128)),
                      onPressed: () =>
                          setState(() => _searchQuery = ""),
                    )
                        : null,
                  ),
                ),
              ),
            ),

            // ✅ Filter chips
            const SliverToBoxAdapter(
              child: SizedBox(height: 8),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding),
                  children: [
                    _buildFilterChip("All", TaskFilter.all, Icons.list, colors),
                    _buildFilterChip(
                        "Pending", TaskFilter.pending, Icons.pending_actions, colors),
                    _buildFilterChip(
                        "Completed", TaskFilter.completed, Icons.check_circle, colors),
                    _buildFilterChip("High Priority", TaskFilter.highPriority,
                        Icons.priority_high, colors),
                  ],
                ),
              ),
            ),

            // ✅ Sort info
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding),
                child: Row(
                  children: [
                    Icon(Icons.sort, size: 16, color: colors.onSurface.withAlpha(128)),
                    const SizedBox(width: 4),
                    Text(
                      "Sorted by: ${_getSortOrderText()}",
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurface.withAlpha(128),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // ✅ Task header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Tasks (${filteredTasks.length})",
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: colors.onSurface,
                      ),
                    ),
                    if (filteredTasks.isNotEmpty)
                      TextButton(
                        onPressed: _clearCompleted,
                        child: Text(
                          "Clear Completed",
                          style: TextStyle(color: colors.secondary),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // ✅ Task list
            SliverPadding(
              padding: const EdgeInsets.only(
                left: AppConstants.defaultPadding,
                right: AppConstants.defaultPadding,
                top: AppConstants.defaultPadding,
                bottom: 80,
              ),
              sliver: Builder(
                builder: (_) {
                  if (taskProvider.isLoading) {
                    return const SliverFillRemaining(child: LoadingIndicator());
                  }

                  if (filteredTasks.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.task,
                              size: 64,
                              color: colors.onSurface.withAlpha(128),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? "No tasks found for '$_searchQuery'"
                                  : "No tasks yet. Add your first task!",
                              style: TextStyle(
                                fontSize: 18,
                                color: colors.onSurface.withAlpha(128),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (_searchQuery.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: ElevatedButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const TaskDetailScreen()),
                                  ),
                                  child: const Text("Create Task"),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final task = filteredTasks[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: TaskTile(
                            task: task,
                          ),
                        );
                      },
                      childCount: filteredTasks.length,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TaskDetailScreen()),
          ),
          backgroundColor: colors.secondary,
          foregroundColor: colors.onSecondary,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                AppConstants.defaultBorderRadius * 2),
          ),
          icon: const Icon(Icons.add),
          label: const Text("Add Task"),
        ),
      ),
    );
  }

  int _sortTasks(Task a, Task b) {
    switch (_sortOrder) {
      case SortOrder.dueDate:
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      case SortOrder.priority:
        final priorityOrder = {"High": 1, "Medium": 2, "Low": 3};
        return (priorityOrder[a.priority] ?? 4)
            .compareTo(priorityOrder[b.priority] ?? 4);
      case SortOrder.title:
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    }
  }

  String _getSortOrderText() {
    switch (_sortOrder) {
      case SortOrder.dueDate:
        return "Due Date";
      case SortOrder.priority:
        return "Priority";
      case SortOrder.title:
        return "Title";
    }
  }

  // Updated statistics cards
  Widget _buildStatisticsCards(
      int total, int completed, int pending, int highPriority, int withDueDates, ColorScheme colors) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding, vertical: 8),
      child: Row(
        children: [
          _buildStatCard("Total", total.toString(), Icons.list_alt, colors.primary, colors),
          const SizedBox(width: 8),
          _buildStatCard("Completed", completed.toString(), Icons.check_circle, Colors.green, colors),
          const SizedBox(width: 8),
          _buildStatCard("Pending", pending.toString(), Icons.pending, Colors.amber, colors),
          const SizedBox(width: 8),
          _buildStatCard("High Priority", highPriority.toString(), Icons.priority_high, Colors.red, colors),
          const SizedBox(width: 8),
          _buildStatCard("With Due Dates", withDueDates.toString(), Icons.calendar_today, Colors.purple, colors),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, ColorScheme colors) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colors.surfaceContainerHighest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(128),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: colors.onSurface.withAlpha(128),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      String label, TaskFilter filter, IconData icon, ColorScheme colors) {
    final isSelected = _filter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? colors.onPrimary : colors.primary),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => setState(() => _filter = filter),
        backgroundColor: colors.surfaceContainerHighest,
        selectedColor: colors.primary,
        labelStyle: TextStyle(
          color: isSelected ? colors.onPrimary : colors.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Sort by",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSurface
                )),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.date_range, color: Theme.of(context).colorScheme.primary),
              title: Text("Due Date", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              onTap: () {
                Navigator.pop(context);
                setState(() => _sortOrder = SortOrder.dueDate);
                _showSnackBar("Sorted by Due Date");
              },
            ),
            ListTile(
              leading: Icon(Icons.priority_high, color: Theme.of(context).colorScheme.primary),
              title: Text("Priority", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              onTap: () {
                Navigator.pop(context);
                setState(() => _sortOrder = SortOrder.priority);
                _showSnackBar("Sorted by Priority");
              },
            ),
            ListTile(
              leading: Icon(Icons.text_fields, color: Theme.of(context).colorScheme.primary),
              title: Text("Title", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              onTap: () {
                Navigator.pop(context);
                setState(() => _sortOrder = SortOrder.title);
                _showSnackBar("Sorted by Title");
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              "More Options",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurface
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.delete_sweep, color: Theme.of(context).colorScheme.primary),
              title: Text("Clear All Completed", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              onTap: () {
                Navigator.pop(context);
                _clearCompleted();
              },
            ),
            // Notification Settings option (Coming Soon)
            ListTile(
              leading: Icon(Icons.notifications_active, color: Theme.of(context).colorScheme.primary),
              title: Text("Notification Settings", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar("Notification settings coming soon!");
              },
            ),
            ListTile(
              leading: Icon(Icons.import_export, color: Theme.of(context).colorScheme.primary),
              title: Text("Export Tasks", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar("Export feature coming soon!");
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.info, color: Theme.of(context).colorScheme.primary),
              title: Text("About", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("About Task Manager", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("A beautiful task management app built with Flutter.",
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text("Features:", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            Text("• Create, edit, delete tasks", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            Text("• Filter by status and priority", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            Text("• Search functionality", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            Text("• Statistics and analytics", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            Text("• Smart notifications (coming soon)", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCompleted() async {
    if (!mounted) return;
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    final completedTasks = taskProvider.tasks.where((task) => task.isCompleted).toList();
    if (completedTasks.isEmpty) {
      _showSnackBar("No completed tasks to clear");
      return;
    }

    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Clear Completed Tasks", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Text("Are you sure you want to clear ${completedTasks.length} completed tasks?",
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text("Clear All"),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (shouldClear ?? false) {
      // Delete tasks
      for (final task in completedTasks) {
        taskProvider.deleteTask(task.id);
      }
      _showSnackBar("Cleared ${completedTasks.length} completed tasks");
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }
}