import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

enum NotificationCategory { rent, payment, announcement, issue, moveOut }

extension NotificationCategoryLabel on NotificationCategory {
  String get label {
    switch (this) {
      case NotificationCategory.rent:
        return 'Rent';
      case NotificationCategory.payment:
        return 'Payment';
      case NotificationCategory.announcement:
        return 'Announcement';
      case NotificationCategory.issue:
        return 'Issue';
      case NotificationCategory.moveOut:
        return 'Move-Out';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationCategory.rent:
        return Icons.home_work_rounded;
      case NotificationCategory.payment:
        return Icons.receipt_long_rounded;
      case NotificationCategory.announcement:
        return Icons.campaign_rounded;
      case NotificationCategory.issue:
        return Icons.report_problem_outlined;
      case NotificationCategory.moveOut:
        return Icons.logout_rounded;
    }
  }

  Color get color {
    switch (this) {
      case NotificationCategory.rent:
        return AppColors.primary;
      case NotificationCategory.payment:
        return AppColors.success;
      case NotificationCategory.announcement:
        return AppColors.accent;
      case NotificationCategory.issue:
        return AppColors.warning;
      case NotificationCategory.moveOut:
        return AppColors.secondary;
    }
  }
}

class NotificationItem {
  final String id;
  final NotificationCategory category;
  final String title;
  final String body;
  final DateTime timestamp;
  bool read;

  NotificationItem({
    required this.id,
    required this.category,
    required this.title,
    required this.body,
    required this.timestamp,
    this.read = false,
  });
}

class NotificationStore {
  NotificationStore._();
  static final NotificationStore instance = NotificationStore._();

  static final List<NotificationItem> _seed = [
    NotificationItem(
      id: 'NT-001',
      category: NotificationCategory.rent,
      title: 'Rent due in 5 days',
      body: 'Your rent of ₹12,000 for September 2026 is due on 25 September 2026. Please make the payment on time.',
      timestamp: DateTime(2026, 9, 15, 9, 30),
    ),
    NotificationItem(
      id: 'NT-002',
      category: NotificationCategory.issue,
      title: 'Issue resolved: Water leakage in kitchen',
      body: 'The maintenance team has completed the repair work for your reported water leakage issue.',
      timestamp: DateTime(2026, 9, 12, 18, 5),
    ),
    NotificationItem(
      id: 'NT-003',
      category: NotificationCategory.announcement,
      title: 'Scheduled water supply maintenance',
      body: 'Water supply will be interrupted on 20 September from 10 AM to 2 PM for tank cleaning.',
      timestamp: DateTime(2026, 9, 11, 11, 0),
    ),
    NotificationItem(
      id: 'NT-004',
      category: NotificationCategory.moveOut,
      title: 'Move-out request update',
      body: 'Your move-out request is under owner review. You will be notified once a decision is made.',
      timestamp: DateTime(2026, 9, 8, 15, 45),
    ),
    NotificationItem(
      id: 'NT-005',
      category: NotificationCategory.payment,
      title: 'Payment received',
      body: 'Rent for August 2026 (₹12,000) was received successfully. Receipt RCP-204-2026-08 has been generated.',
      timestamp: DateTime(2026, 9, 2, 10, 20),
      read: true,
    ),
    NotificationItem(
      id: 'NT-006',
      category: NotificationCategory.announcement,
      title: 'Owner circular: Festival notice',
      body: 'Common area will be decorated for upcoming festivals. Please avoid parking in the main courtyard on 25 to 28 September.',
      timestamp: DateTime(2026, 9, 1, 14, 0),
      read: true,
    ),
  ];

  final List<NotificationItem> _notifications = List.of(_seed);

  List<NotificationItem> get notifications =>
      List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.read).length;

  void markRead(String id) {
    final item = _notifications.where((n) => n.id == id).firstOrNull;
    if (item != null && !item.read) {
      item.read = true;
    }
  }

  void markAllRead() {
    for (final item in _notifications) {
      item.read = true;
    }
  }
}