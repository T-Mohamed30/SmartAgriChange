import 'package:flutter/material.dart';

enum Priority {
  high,
  medium,
  low,
}

extension PriorityExtension on Priority {
  String get name {
    switch (this) {
      case Priority.high:
        return 'Haute priorité';
      case Priority.medium:
        return 'Moyenne priorité';
      case Priority.low:
        return 'Basse priorité';
      default:
        return '';
    }
  }

  Color get color {
    switch (this) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class RecommendedAction {
  final Priority priority;
  final String description;

  RecommendedAction({
    required this.priority,
    required this.description,
  });
}
