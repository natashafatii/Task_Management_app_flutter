// widgets/task_stats_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../constants/app_colors.dart';

class TaskStatsCard extends StatelessWidget {
  const TaskStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        // Use direct properties instead of getStatistics() to avoid type issues
        final total = taskProvider.totalTasks;
        final completed = taskProvider.completedTasksCount;
        final pending = taskProvider.pendingTasksCount;
        final highPriority = taskProvider.highPriorityCount;
        final overdue = taskProvider.overdueCount;
        final dueToday = taskProvider.dueTodayCount;

        // Ensure progress is a double
        final double progress = total > 0 ? completed / total : 0.0;

        return Card(
          margin: const EdgeInsets.all(16),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Progress indicator
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: AppColors.primaryLight,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getProgressColor(progress),
                        ),
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Stats grid - using direct properties
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.2,
                  children: [
                    _buildStatItem('Total', total, Icons.list_alt, AppColors.primary),
                    _buildStatItem('Done', completed, Icons.check_circle, AppColors.success),
                    _buildStatItem('Pending', pending, Icons.access_time, AppColors.warning),
                    _buildStatItem('High', highPriority, Icons.flag, AppColors.error),
                    _buildStatItem('Overdue', overdue, Icons.error, AppColors.error),
                    _buildStatItem('Today', dueToday, Icons.today, AppColors.info),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, int count, IconData icon, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) return AppColors.error;
    if (progress < 0.7) return AppColors.warning;
    return AppColors.success;
  }
}