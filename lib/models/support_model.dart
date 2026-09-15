import 'package:flutter/material.dart';

enum UserRole { tenant, owner }

enum AnnouncementSource { system, owner }

enum AnnouncementPriority { normal, important, urgent }

enum IssueStatus {
  pendingReview,
  underReview,
  inProgress,
  resolved,
  rejected,
  closed,
}

enum IssueCategory {
  plumbing,
  electricity,
  internet,
  cleaning,
  furniture,
  appliance,
  security,
  waterSupply,
  propertyDamage,
  other,
}

enum IssuePriority { low, medium, high, urgent }

extension UserRoleLabel on UserRole {
  String get label {
    switch (this) {
      case UserRole.tenant:
        return 'Tenant';
      case UserRole.owner:
        return 'Owner';
    }
  }
}

extension AnnouncementSourceLabel on AnnouncementSource {
  String get label => this == AnnouncementSource.system ? 'SYSTEM' : 'OWNER';

  Color get color =>
      this == AnnouncementSource.system ? const Color(0xFF3B82F6) : const Color(0xFF10B981);
}

extension AnnouncementPriorityLabel on AnnouncementPriority {
  String get label {
    switch (this) {
      case AnnouncementPriority.normal:
        return 'Normal';
      case AnnouncementPriority.important:
        return 'Important';
      case AnnouncementPriority.urgent:
        return 'High Priority';
    }
  }

  Color get color {
    switch (this) {
      case AnnouncementPriority.normal:
        return const Color(0xFF6B7280);
      case AnnouncementPriority.important:
        return const Color(0xFFF59E0B);
      case AnnouncementPriority.urgent:
        return const Color(0xFFEF4444);
    }
  }
}

extension IssueStatusLabel on IssueStatus {
  String get label {
    switch (this) {
      case IssueStatus.pendingReview:
        return 'Pending Review';
      case IssueStatus.underReview:
        return 'Under Review';
      case IssueStatus.inProgress:
        return 'In Progress';
      case IssueStatus.resolved:
        return 'Resolved';
      case IssueStatus.rejected:
        return 'Rejected';
      case IssueStatus.closed:
        return 'Closed';
    }
  }

  Color get color {
    switch (this) {
      case IssueStatus.pendingReview:
        return const Color(0xFFF97316);
      case IssueStatus.underReview:
        return const Color(0xFF3B82F6);
      case IssueStatus.inProgress:
        return const Color(0xFF6C63FF);
      case IssueStatus.resolved:
        return const Color(0xFF10B981);
      case IssueStatus.rejected:
        return const Color(0xFFEF4444);
      case IssueStatus.closed:
        return const Color(0xFF6B7280);
    }
  }

  Color get background => color.withValues(alpha: 0.12);
}

extension IssueCategoryLabel on IssueCategory {
  String get label {
    switch (this) {
      case IssueCategory.plumbing:
        return 'Plumbing';
      case IssueCategory.electricity:
        return 'Electricity';
      case IssueCategory.internet:
        return 'Internet';
      case IssueCategory.cleaning:
        return 'Cleaning';
      case IssueCategory.furniture:
        return 'Furniture';
      case IssueCategory.appliance:
        return 'Appliance';
      case IssueCategory.security:
        return 'Security';
      case IssueCategory.waterSupply:
        return 'Water Supply';
      case IssueCategory.propertyDamage:
        return 'Property Damage';
      case IssueCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case IssueCategory.plumbing:
        return Icons.water_drop_rounded;
      case IssueCategory.electricity:
        return Icons.bolt_rounded;
      case IssueCategory.internet:
        return Icons.wifi_rounded;
      case IssueCategory.cleaning:
        return Icons.cleaning_services_rounded;
      case IssueCategory.furniture:
        return Icons.chair_rounded;
      case IssueCategory.appliance:
        return Icons.kitchen_rounded;
      case IssueCategory.security:
        return Icons.security_rounded;
      case IssueCategory.waterSupply:
        return Icons.water_rounded;
      case IssueCategory.propertyDamage:
        return Icons.home_work_rounded;
      case IssueCategory.other:
        return Icons.handyman_rounded;
    }
  }
}

extension IssuePriorityLabel on IssuePriority {
  String get label {
    switch (this) {
      case IssuePriority.low:
        return 'Low';
      case IssuePriority.medium:
        return 'Medium';
      case IssuePriority.high:
        return 'High';
      case IssuePriority.urgent:
        return 'Urgent';
    }
  }

  Color get color {
    switch (this) {
      case IssuePriority.low:
        return const Color(0xFF6B7280);
      case IssuePriority.medium:
        return const Color(0xFF3B82F6);
      case IssuePriority.high:
        return const Color(0xFFF59E0B);
      case IssuePriority.urgent:
        return const Color(0xFFEF4444);
    }
  }
}

class Announcement {
  final String id;
  final String title;
  final String message;
  final AnnouncementSource source;
  final AnnouncementPriority priority;
  final String? imagePath;
  final DateTime publishedAt;
  final String author;
  final String? expiryDate;
  final bool isRead;
  final bool isDraft;

  const Announcement({
    required this.id,
    required this.title,
    required this.message,
    required this.source,
    required this.priority,
    required this.publishedAt,
    required this.author,
    this.imagePath,
    this.expiryDate,
    this.isRead = false,
    this.isDraft = false,
  });

  Announcement copyWith({
    String? title,
    String? message,
    AnnouncementSource? source,
    AnnouncementPriority? priority,
    String? imagePath,
    DateTime? publishedAt,
    String? author,
    String? expiryDate,
    bool? isRead,
    bool? isDraft,
  }) {
    return Announcement(
      id: id,
      title: title ?? this.title,
      message: message ?? this.message,
      source: source ?? this.source,
      priority: priority ?? this.priority,
      imagePath: imagePath ?? this.imagePath,
      publishedAt: publishedAt ?? this.publishedAt,
      author: author ?? this.author,
      expiryDate: expiryDate ?? this.expiryDate,
      isRead: isRead ?? this.isRead,
      isDraft: isDraft ?? this.isDraft,
    );
  }
}

class TimelineEvent {
  final IssueStatus status;
  final String? note;
  final DateTime timestamp;

  const TimelineEvent({
    required this.status,
    required this.timestamp,
    this.note,
  });
}

class Issue {
  final String id;
  final String tenantName;
  final String room;
  final String message;
  final List<String> photos;
  final IssueCategory category;
  final String location;
  final IssuePriority priority;
  final DateTime createdAt;
  IssueStatus status;
  final List<TimelineEvent> timeline;
  String? rejectionReason;
  String? resolutionNote;
  DateTime lastUpdated;

  Issue({
    required this.id,
    required this.tenantName,
    required this.room,
    required this.message,
    required this.photos,
    required this.category,
    required this.location,
    required this.priority,
    required this.createdAt,
    required this.status,
    required this.timeline,
    required this.lastUpdated,
    this.rejectionReason,
    this.resolutionNote,
  });
}

List<Announcement> seedAnnouncements() {
  return [
    Announcement(
      id: 'SA-001',
      title: 'Water Supply Maintenance',
      message:
          'Water supply will be unavailable from 10:00 AM to 2:00 PM due to scheduled pipeline maintenance. Please store water in advance. We apologise for the inconvenience caused.',
      source: AnnouncementSource.owner,
      priority: AnnouncementPriority.important,
      publishedAt: DateTime(2026, 9, 12, 9, 30),
      author: 'Rakesh Verma',
      expiryDate: '15 Sep 2026',
    ),
    Announcement(
      id: 'SA-002',
      title: 'Scheduled System Maintenance',
      message:
          'The application will be temporarily unavailable during scheduled maintenance from 11:00 PM to 1:00 AM. Your data and payment history will remain safe. Thank you for your patience.',
      source: AnnouncementSource.system,
      priority: AnnouncementPriority.important,
      publishedAt: DateTime(2026, 9, 10, 18, 0),
      author: 'TenantHub System',
      expiryDate: '11 Sep 2026',
    ),
    Announcement(
      id: 'SA-003',
      title: 'Monthly Property Inspection',
      message:
          'The monthly routine property inspection will be conducted this Saturday between 10:00 AM and 4:00 PM. Please ensure someone is available at your room or inform the caretaker in advance.',
      source: AnnouncementSource.owner,
      priority: AnnouncementPriority.normal,
      publishedAt: DateTime(2026, 9, 8, 11, 15),
      author: 'Rakesh Verma',
      isRead: true,
      expiryDate: '12 Sep 2026',
    ),
    Announcement(
      id: 'SA-004',
      title: 'Cleaning Schedule Update',
      message:
          'Common areas will be cleaned every alternate day from next week. Please keep the corridors clear of personal items during cleaning hours.',
      source: AnnouncementSource.owner,
      priority: AnnouncementPriority.normal,
      publishedAt: DateTime(2026, 9, 5, 8, 45),
      author: 'Rakesh Verma',
      isRead: true,
    ),
    Announcement(
      id: 'SA-005',
      title: 'Emergency Notice: Lift Out of Service',
      message:
          'The lift will be out of service today due to a technical fault. A technician has been called. We will update you once it is restored. Use the staircase until then.',
      source: AnnouncementSource.system,
      priority: AnnouncementPriority.urgent,
      publishedAt: DateTime(2026, 9, 1, 7, 0),
      author: 'TenantHub System',
      isRead: true,
    ),
  ];
}

List<Issue> seedIssues() {
  return [
    Issue(
      id: 'ISS-1024',
      tenantName: 'Aarav Sharma',
      room: 'Room 204',
      message: 'Bathroom tap is leaking continuously. Water is wasting and the floor is getting wet.',
      photos: const ['assets/images/bath_icon.svg', 'assets/images/detail_image.png'],
      category: IssueCategory.plumbing,
      location: 'Bathroom',
      priority: IssuePriority.high,
      createdAt: DateTime(2026, 9, 12, 10, 30),
      status: IssueStatus.pendingReview,
      timeline: [
        TimelineEvent(
          status: IssueStatus.pendingReview,
          timestamp: DateTime(2026, 9, 12, 10, 31),
          note: 'Issue reported by tenant',
        ),
      ],
      lastUpdated: DateTime(2026, 9, 12, 10, 31),
    ),
    Issue(
      id: 'ISS-1009',
      tenantName: 'Aarav Sharma',
      room: 'Room 204',
      message: 'AC is not cooling properly. It runs but the room temperature does not come down.',
      photos: const ['assets/images/detail_image.png'],
      category: IssueCategory.appliance,
      location: 'Bedroom',
      priority: IssuePriority.urgent,
      createdAt: DateTime(2026, 9, 8, 15, 0),
      status: IssueStatus.inProgress,
      timeline: [
        TimelineEvent(
          status: IssueStatus.pendingReview,
          timestamp: DateTime(2026, 9, 8, 15, 1),
          note: 'Issue reported by tenant',
        ),
        TimelineEvent(
          status: IssueStatus.underReview,
          timestamp: DateTime(2026, 9, 9, 14, 15),
          note: 'Owner started reviewing the issue',
        ),
        TimelineEvent(
          status: IssueStatus.inProgress,
          timestamp: DateTime(2026, 9, 10, 9, 0),
          note: 'Technician assigned. In progress',
        ),
      ],
      lastUpdated: DateTime(2026, 9, 10, 9, 0),
    ),
    Issue(
      id: 'ISS-0995',
      tenantName: 'Aarav Sharma',
      room: 'Room 204',
      message: 'Room light and power socket are not working since yesterday evening.',
      photos: const [],
      category: IssueCategory.electricity,
      location: 'Bedroom',
      priority: IssuePriority.medium,
      createdAt: DateTime(2026, 9, 2, 19, 20),
      status: IssueStatus.resolved,
      timeline: [
        TimelineEvent(
          status: IssueStatus.pendingReview,
          timestamp: DateTime(2026, 9, 2, 19, 21),
          note: 'Issue reported by tenant',
        ),
        TimelineEvent(
          status: IssueStatus.underReview,
          timestamp: DateTime(2026, 9, 3, 10, 0),
          note: 'Owner started reviewing the issue',
        ),
        TimelineEvent(
          status: IssueStatus.inProgress,
          timestamp: DateTime(2026, 9, 3, 12, 30),
          note: 'Electrician visited the room',
        ),
        TimelineEvent(
          status: IssueStatus.resolved,
          timestamp: DateTime(2026, 9, 4, 16, 30),
          note: 'Socket and light replaced',
        ),
      ],
      resolutionNote: 'Replaced the faulty socket and fixed the light wiring.',
      lastUpdated: DateTime(2026, 9, 4, 16, 30),
    ),
    Issue(
      id: 'ISS-0871',
      tenantName: 'Meera Nair',
      room: 'Room 108',
      message: 'Window glass is cracked and needs replacement before the rainy season.',
      photos: const ['assets/images/detail_image.png'],
      category: IssueCategory.propertyDamage,
      location: 'Living Room',
      priority: IssuePriority.high,
      createdAt: DateTime(2026, 8, 20, 9, 10),
      status: IssueStatus.rejected,
      timeline: [
        TimelineEvent(
          status: IssueStatus.pendingReview,
          timestamp: DateTime(2026, 8, 20, 9, 11),
          note: 'Issue reported by tenant',
        ),
        TimelineEvent(
          status: IssueStatus.rejected,
          timestamp: DateTime(2026, 8, 21, 11, 0),
          note: 'Rejected by owner',
        ),
      ],
      rejectionReason: 'The glass was inspected and found to be in good condition. No replacement needed.',
      lastUpdated: DateTime(2026, 8, 21, 11, 0),
    ),
  ];
}

String formatIssueTimestamp(DateTime dt) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
  final minute = dt.minute.toString().padLeft(2, '0');
  final ampm = dt.hour >= 12 ? 'PM' : 'AM';
  return '${dt.day} ${months[dt.month - 1]}, $hour:$minute $ampm';
}

String formatIssueDate(DateTime dt) {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
}