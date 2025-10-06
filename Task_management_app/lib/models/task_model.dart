// models/task.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class Task {
  final String id;
  String title;
  String description;
  final DateTime createdAt;
  DateTime? updatedAt;
  bool isCompleted;
  String priority;
  DateTime? dueDate;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.updatedAt,
    this.isCompleted = false,
    this.priority = 'Medium',
    this.dueDate,
  });

  /// Convert Task to Map (for storage, e.g., shared preferences or database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
      'priority': priority,
      'dueDate': dueDate?.millisecondsSinceEpoch,
    };
  }

  /// Create a Task object from Map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
      isCompleted: map['isCompleted'] ?? false,
      priority: map['priority'] ?? 'Medium',
      dueDate: map['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'])
          : null,
    );
  }

  /// Copy a task with updated fields (useful for EditTaskScreen)
  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCompleted,
    String? priority,
    DateTime? dueDate,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  /// Get priority color for UI using AppColors
  Color get priorityColor {
    switch (priority) {
      case 'High':
        return AppColors.error; // Red for high priority
      case 'Medium':
        return AppColors.warning; // Orange/Yellow for medium priority
      case 'Low':
        return AppColors.success; // Green for low priority
      default:
        return AppColors.textSecondary; // Grey for default
    }
  }

  /// Get priority background color for chips/badges
  Color get priorityBackgroundColor {
    switch (priority) {
      case 'High':
        return AppColors.error.withOpacity(0.1);
      case 'Medium':
        return AppColors.warning.withOpacity(0.1);
      case 'Low':
        return AppColors.success.withOpacity(0.1);
      default:
        return AppColors.primaryLight;
    }
  }

  /// Get priority icon for UI
  IconData get priorityIcon {
    switch (priority) {
      case 'High':
        return Icons.flag;
      case 'Medium':
        return Icons.flag_outlined;
      case 'Low':
        return Icons.outlined_flag;
      default:
        return Icons.flag;
    }
  }

  /// Get completion status color
  Color get statusColor {
    if (isCompleted) return AppColors.success;
    if (isOverdue) return AppColors.error;
    return AppColors.primary;
  }

  /// Get completion status icon
  IconData get statusIcon {
    if (isCompleted) return Icons.check_circle;
    if (isOverdue) return Icons.error;
    return Icons.radio_button_unchecked;
  }

  /// Check if task is overdue
  bool get isOverdue {
    if (dueDate == null) return false;
    return !isCompleted && dueDate!.isBefore(DateTime.now());
  }

  /// Get days until due (negative if overdue)
  int get daysUntilDue {
    if (dueDate == null) return 999; // No due date = far future
    final now = DateTime.now();
    final difference = dueDate!.difference(now);
    return difference.inDays;
  }

  /// Format due date for display
  String get formattedDueDate {
    if (dueDate == null) return 'No due date';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);

    final difference = dueDay.difference(today).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference == -1) return 'Yesterday';
    if (difference < 0) return '${difference.abs()} days ago';
    if (difference < 7) return 'In $difference days';

    return '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}';
  }

  /// Get due date text style based on status
  TextStyle get dueDateTextStyle {
    if (isCompleted) {
      return const TextStyle(
        color: AppColors.textSecondary,
        decoration: TextDecoration.lineThrough,
        fontSize: 12,
      );
    }

    if (isOverdue) {
      return const TextStyle(
        color: AppColors.error,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      );
    }

    if (daysUntilDue == 0) {
      return const TextStyle(
        color: AppColors.warning,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      );
    }

    return const TextStyle(
      color: AppColors.textSecondary,
      fontSize: 12,
    );
  }

  /// Get task title style based on completion status
  TextStyle get titleTextStyle {
    if (isCompleted) {
      return const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        decoration: TextDecoration.lineThrough,
        color: AppColors.textSecondary,
      );
    }

    if (isOverdue) {
      return const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.error,
      );
    }

    return const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    );
  }

  /// Get task description style based on completion status
  TextStyle get descriptionTextStyle {
    if (isCompleted) {
      return const TextStyle(
        fontSize: 14,
        decoration: TextDecoration.lineThrough,
        color: AppColors.textSecondary,
      );
    }

    return const TextStyle(
      fontSize: 14,
      color: AppColors.textSecondary,
    );
  }

  /// Get priority text for display
  String get priorityText {
    return '$priority Priority';
  }

  /// Get completion status text
  String get statusText {
    if (isCompleted) return 'Completed';
    if (isOverdue) return 'Overdue';
    if (daysUntilDue == 0) return 'Due Today';
    if (daysUntilDue == 1) return 'Due Tomorrow';
    if (daysUntilDue > 0) return 'Due in $daysUntilDue days';
    return 'Overdue by ${daysUntilDue.abs()} days';
  }

  /// Get completion status color
  Color get statusTextColor {
    if (isCompleted) return AppColors.success;
    if (isOverdue) return AppColors.error;
    if (daysUntilDue == 0) return AppColors.warning;
    if (daysUntilDue <= 2) return AppColors.warning;
    return AppColors.textSecondary;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Task(id: $id, title: $title, completed: $isCompleted, priority: $priority, due: $formattedDueDate)';
  }

  /// Helper method to check if task matches search query
  bool matchesQuery(String query) {
    if (query.isEmpty) return true;
    final lowerQuery = query.toLowerCase();
    return title.toLowerCase().contains(lowerQuery) ||
        description.toLowerCase().contains(lowerQuery) ||
        priority.toLowerCase().contains(lowerQuery);
  }

  /// Helper method to get creation date formatted
  String get formattedCreatedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  /// Get gradient colors for task card based on priority and status
  List<Color> get cardGradient {
    if (isCompleted) {
      return [AppColors.background, AppColors.background];
    }

    if (isOverdue) {
      return [
        AppColors.error.withOpacity(0.05),
        AppColors.error.withOpacity(0.02),
      ];
    }

    switch (priority) {
      case 'High':
        return [
          AppColors.error.withOpacity(0.05),
          AppColors.background,
        ];
      case 'Medium':
        return [
          AppColors.warning.withOpacity(0.05),
          AppColors.background,
        ];
      case 'Low':
        return [
          AppColors.success.withOpacity(0.05),
          AppColors.background,
        ];
      default:
        return [AppColors.background, AppColors.background];
    }
  }

  /// Get border color for task card
  Color get cardBorderColor {
    if (isCompleted) return AppColors.success.withOpacity(0.3);
    if (isOverdue) return AppColors.error.withOpacity(0.3);

    switch (priority) {
      case 'High':
        return AppColors.error.withOpacity(0.3);
      case 'Medium':
        return AppColors.warning.withOpacity(0.3);
      case 'Low':
        return AppColors.success.withOpacity(0.3);
      default:
        return AppColors.primaryLight;
    }
  }
}