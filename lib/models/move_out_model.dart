import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'payment_model.dart';

enum MoveOutStatus { pending, approved, released, rejected }

extension MoveOutStatusLabel on MoveOutStatus {
  String get label {
    switch (this) {
      case MoveOutStatus.pending:
        return 'Pending Approval';
      case MoveOutStatus.approved:
        return 'Release Approved';
      case MoveOutStatus.released:
        return 'Released';
      case MoveOutStatus.rejected:
        return 'Rejected';
    }
  }

  String get shortLabel {
    switch (this) {
      case MoveOutStatus.pending:
        return 'Pending';
      case MoveOutStatus.approved:
        return 'Approved';
      case MoveOutStatus.released:
        return 'Released';
      case MoveOutStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case MoveOutStatus.pending:
        return const Color(0xFFF97316);
      case MoveOutStatus.approved:
        return const Color(0xFF3B82F6);
      case MoveOutStatus.released:
        return const Color(0xFF10B981);
      case MoveOutStatus.rejected:
        return const Color(0xFFEF4444);
    }
  }

  Color get background => color.withValues(alpha: 0.12);

  IconData get icon {
    switch (this) {
      case MoveOutStatus.pending:
        return Icons.schedule_rounded;
      case MoveOutStatus.approved:
        return Icons.verified_rounded;
      case MoveOutStatus.released:
        return Icons.check_circle_rounded;
      case MoveOutStatus.rejected:
        return Icons.cancel_rounded;
    }
  }
}

enum RoomStatus { occupied, releaseApproved, available }

extension RoomStatusLabel on RoomStatus {
  String get label {
    switch (this) {
      case RoomStatus.occupied:
        return 'Occupied';
      case RoomStatus.releaseApproved:
        return 'Release Approved';
      case RoomStatus.available:
        return 'Available';
    }
  }

  Color get color {
    switch (this) {
      case RoomStatus.occupied:
        return AppColors.primary;
      case RoomStatus.releaseApproved:
        return const Color(0xFF3B82F6);
      case RoomStatus.available:
        return AppColors.success;
    }
  }
}

class MoveOutEvent {
  final MoveOutStatus status;
  final String? note;
  final DateTime timestamp;

  const MoveOutEvent({
    required this.status,
    required this.timestamp,
    this.note,
  });
}

class MoveOutRequest {
  final String id;
  final String tenantName;
  final String tenantPhone;
  final String roomNumber;
  final String propertyAddress;
  final double monthlyRent;
  final DateTime moveInDate;
  final DateTime requestedMoveOutDate;
  final String reason;
  final int noticePeriodDays;
  final DateTime submittedAt;

  MoveOutStatus status;
  DateTime? decidedAt;
  String? rejectedBy;
  String? rejectionReason;
  DateTime? releasedDate;
  String? resolvedBy;
  DateTime? statementGeneratedAt;
  final List<MoveOutEvent> timeline;

  MoveOutRequest({
    required this.id,
    required this.tenantName,
    required this.tenantPhone,
    required this.roomNumber,
    required this.propertyAddress,
    required this.monthlyRent,
    required this.moveInDate,
    required this.requestedMoveOutDate,
    required this.reason,
    required this.noticePeriodDays,
    required this.submittedAt,
    required this.status,
    required this.timeline,
    this.decidedAt,
    this.rejectedBy,
    this.rejectionReason,
    this.releasedDate,
    this.resolvedBy,
    this.statementGeneratedAt,
  });

  int get stayDurationMonths {
    final months =
        (releasedDate ?? moveInDate).difference(moveInDate).inDays ~/ 30;
    return months < 1 ? 1 : months;
  }
}

class Room {
  final String roomNumber;
  final String propertyAddress;
  RoomStatus status;
  final String? currentTenantName;
  final double monthlyRent;

  Room({
    required this.roomNumber,
    required this.propertyAddress,
    required this.status,
    required this.monthlyRent,
    this.currentTenantName,
  });
}

class Settlement {
  final double totalDue;
  final double totalPaid;
  final double outstanding;
  final double securityDeposit;
  final double deductions;
  final double refundAmount;

  const Settlement({
    required this.totalDue,
    required this.totalPaid,
    required this.outstanding,
    required this.securityDeposit,
    required this.deductions,
    required this.refundAmount,
  });
}

class MoveOutStore {
  MoveOutStore._();
  static final MoveOutStore instance = MoveOutStore._();

  final List<MoveOutRequest> _requests = _seedRequests();
  final List<Room> _rooms = _seedRooms();

  List<MoveOutRequest> get requests => List.unmodifiable(_requests);
  List<Room> get rooms => List.unmodifiable(_rooms);

  MoveOutRequest? get currentTenantRequest {
    for (final r in _requests) {
      if (r.tenantName == 'Aarav Sharma' && r.roomNumber == 'Room 204') {
        return r;
      }
    }
    return null;
  }

  Room? roomFor(MoveOutRequest request) {
    for (final room in _rooms) {
      if (room.roomNumber == request.roomNumber) return room;
    }
    return null;
  }

  int get pendingCount =>
      _requests.where((r) => r.status == MoveOutStatus.pending).length;

  MoveOutRequest submitRequest({
    required String tenantName,
    required String tenantPhone,
    required String roomNumber,
    required String propertyAddress,
    required double monthlyRent,
    required DateTime moveInDate,
    required DateTime requestedMoveOutDate,
    required String reason,
  }) {
    final now = DateTime.now();
    final request = MoveOutRequest(
      id: 'MO-${_requests.length + 1}${now.millisecondsSinceEpoch % 1000}',
      tenantName: tenantName,
      tenantPhone: tenantPhone,
      roomNumber: roomNumber,
      propertyAddress: propertyAddress,
      monthlyRent: monthlyRent,
      moveInDate: moveInDate,
      requestedMoveOutDate: requestedMoveOutDate,
      reason: reason,
      noticePeriodDays: requestedMoveOutDate.difference(now).inDays,
      submittedAt: now,
      status: MoveOutStatus.pending,
      timeline: [
        MoveOutEvent(
          status: MoveOutStatus.pending,
          timestamp: now,
          note: 'Move-out request submitted by tenant',
        ),
      ],
    );
    _requests.insert(0, request);
    _refreshRooms();
    return request;
  }

  void approveRequest(MoveOutRequest request, DateTime releaseDate) {
    request.status = MoveOutStatus.approved;
    request.decidedAt = DateTime.now();
    request.releasedDate = releaseDate;
    request.resolvedBy = 'Rakesh Verma (Owner)';
    request.timeline.add(
      MoveOutEvent(
        status: MoveOutStatus.approved,
        timestamp: DateTime.now(),
        note: 'Approved by owner. Release scheduled on ${formatDateLabel(releaseDate)}',
      ),
    );
    _refreshRooms();
  }

  void releaseRequest(MoveOutRequest request) {
    request.status = MoveOutStatus.released;
    request.decidedAt = DateTime.now();
    request.statementGeneratedAt = DateTime.now();
    request.timeline.add(
      MoveOutEvent(
        status: MoveOutStatus.released,
        timestamp: DateTime.now(),
        note: 'Room released and final settlement statement generated',
      ),
    );
    _refreshRooms();
  }

  void rejectRequest(MoveOutRequest request, String reason) {
    request.status = MoveOutStatus.rejected;
    request.decidedAt = DateTime.now();
    request.rejectedBy = 'Rakesh Verma (Owner)';
    request.rejectionReason = reason;
    request.timeline.add(
      MoveOutEvent(
        status: MoveOutStatus.rejected,
        timestamp: DateTime.now(),
        note: 'Request rejected by owner',
      ),
    );
    _refreshRooms();
  }

  void _refreshRooms() {
    for (final room in _rooms) {
      final request = _requests
          .where((r) => r.roomNumber == room.roomNumber)
          .cast<MoveOutRequest?>()
          .firstWhere((r) => r != null, orElse: () => null);
      if (request == null) {
        room.status = RoomStatus.available;
      } else {
        switch (request.status) {
          case MoveOutStatus.pending:
          case MoveOutStatus.rejected:
            room.status = RoomStatus.occupied;
          case MoveOutStatus.approved:
            room.status = RoomStatus.releaseApproved;
          case MoveOutStatus.released:
            room.status = RoomStatus.available;
        }
      }
    }
  }
}

List<MoveOutRequest> _seedRequests() {
  return [
    MoveOutRequest(
      id: 'MO-1042',
      tenantName: 'Meera Nair',
      tenantPhone: '+91 98111 23456',
      roomNumber: 'Room 108',
      propertyAddress: '123 Main Street, Apt 108',
      monthlyRent: 10000,
      moveInDate: DateTime(2025, 2, 1),
      requestedMoveOutDate: DateTime(2026, 9, 30),
      reason: 'Relocating to another city for work',
      noticePeriodDays: 21,
      submittedAt: DateTime(2026, 9, 9, 11, 20),
      status: MoveOutStatus.pending,
      timeline: [
        MoveOutEvent(
          status: MoveOutStatus.pending,
          timestamp: DateTime(2026, 9, 9, 11, 20),
          note: 'Move-out request submitted by tenant',
        ),
      ],
    ),
    MoveOutRequest(
      id: 'MO-0991',
      tenantName: 'Rohit Kumar',
      tenantPhone: '+91 99000 11223',
      roomNumber: 'Room 305',
      propertyAddress: '123 Main Street, Apt 305',
      monthlyRent: 12500,
      moveInDate: DateTime(2024, 7, 1),
      requestedMoveOutDate: DateTime(2026, 8, 31),
      reason: 'End of lease term',
      noticePeriodDays: 30,
      submittedAt: DateTime(2026, 7, 20, 9, 5),
      status: MoveOutStatus.released,
      decidedAt: DateTime(2026, 7, 25, 14, 0),
      releasedDate: DateTime(2026, 8, 31),
      resolvedBy: 'Rakesh Verma (Owner)',
      statementGeneratedAt: DateTime(2026, 8, 31, 18, 0),
      timeline: [
        MoveOutEvent(
          status: MoveOutStatus.pending,
          timestamp: DateTime(2026, 7, 20, 9, 5),
          note: 'Move-out request submitted by tenant',
        ),
        MoveOutEvent(
          status: MoveOutStatus.approved,
          timestamp: DateTime(2026, 7, 25, 14, 0),
          note: 'Approved by owner. Release scheduled on 31 Aug 2026',
        ),
        MoveOutEvent(
          status: MoveOutStatus.released,
          timestamp: DateTime(2026, 8, 31, 18, 0),
          note: 'Room released and final settlement statement generated',
        ),
      ],
    ),
  ];
}

List<Room> _seedRooms() {
  return [
    Room(
      roomNumber: 'Room 204',
      propertyAddress: '123 Main Street, Apt 204',
      status: RoomStatus.occupied,
      currentTenantName: 'Aarav Sharma',
      monthlyRent: 12000,
    ),
    Room(
      roomNumber: 'Room 108',
      propertyAddress: '123 Main Street, Apt 108',
      status: RoomStatus.occupied,
      currentTenantName: 'Meera Nair',
      monthlyRent: 10000,
    ),
    Room(
      roomNumber: 'Room 305',
      propertyAddress: '123 Main Street, Apt 305',
      status: RoomStatus.available,
      monthlyRent: 12500,
    ),
    Room(
      roomNumber: 'Room 101',
      propertyAddress: '123 Main Street, Apt 101',
      status: RoomStatus.available,
      monthlyRent: 11000,
    ),
  ];
}

List<PaymentRecord> seedPaymentLedger() {
  const rent = 12000.0;
  return [
    PaymentRecord(
      monthLabel: 'September', year: '2025', amountDue: rent,
      dueDate: DateTime(2025, 9, 10),
      status: PaymentStatus.rentPaid, method: PaymentMethod.cash,
      paidAmount: rent, paymentDate: DateTime(2025, 9, 4),
      receiptNumber: 'RCP-2025-0901', referenceNumber: 'CSH-2025-0901',
      tenantName: 'Aarav Sharma', roomName: 'Room 204',
      ownerName: 'Rakesh Verma',
    ),
    PaymentRecord(
      monthLabel: 'October', year: '2025', amountDue: rent,
      dueDate: DateTime(2025, 10, 10),
      status: PaymentStatus.rentPaid, method: PaymentMethod.online,
      paidAmount: rent, paymentDate: DateTime(2025, 10, 3),
      receiptNumber: 'RCP-2025-1001', referenceNumber: 'TXN-8126540912',
      tenantName: 'Aarav Sharma', roomName: 'Room 204',
      ownerName: 'Rakesh Verma',
    ),
    PaymentRecord(
      monthLabel: 'November', year: '2025', amountDue: rent,
      dueDate: DateTime(2025, 11, 10),
      status: PaymentStatus.rentPaid, method: PaymentMethod.cash,
      paidAmount: rent, paymentDate: DateTime(2025, 11, 5),
      receiptNumber: 'RCP-2025-1101', referenceNumber: 'CSH-2025-1101',
      tenantName: 'Aarav Sharma', roomName: 'Room 204',
      ownerName: 'Rakesh Verma',
    ),
    PaymentRecord(
      monthLabel: 'December', year: '2025', amountDue: rent,
      dueDate: DateTime(2025, 12, 10),
      status: PaymentStatus.rentPaid, method: PaymentMethod.online,
      paidAmount: rent, paymentDate: DateTime(2025, 12, 2),
      receiptNumber: 'RCP-2025-1201', referenceNumber: 'TXN-8126540913',
      tenantName: 'Aarav Sharma', roomName: 'Room 204',
      ownerName: 'Rakesh Verma',
    ),
    PaymentRecord(
      monthLabel: 'January', year: '2026', amountDue: rent,
      dueDate: DateTime(2026, 1, 10),
      status: PaymentStatus.rentPaid, method: PaymentMethod.cash,
      paidAmount: rent, paymentDate: DateTime(2026, 1, 6),
      receiptNumber: 'RCP-2026-0101', referenceNumber: 'CSH-2026-0101',
      tenantName: 'Aarav Sharma', roomName: 'Room 204',
      ownerName: 'Rakesh Verma',
    ),
    PaymentRecord(
      monthLabel: 'February', year: '2026', amountDue: rent,
      dueDate: DateTime(2026, 2, 10),
      status: PaymentStatus.rentPaid, method: PaymentMethod.online,
      paidAmount: rent, paymentDate: DateTime(2026, 2, 4),
      receiptNumber: 'RCP-2026-0201', referenceNumber: 'TXN-8126540914',
      tenantName: 'Aarav Sharma', roomName: 'Room 204',
      ownerName: 'Rakesh Verma',
    ),
    PaymentRecord(
      monthLabel: 'March', year: '2026', amountDue: rent,
      dueDate: DateTime(2026, 3, 10),
      status: PaymentStatus.rentPaid, method: PaymentMethod.cash,
      paidAmount: rent, paymentDate: DateTime(2026, 3, 5),
      receiptNumber: 'RCP-2026-0301', referenceNumber: 'CSH-2026-0301',
      tenantName: 'Aarav Sharma', roomName: 'Room 204',
      ownerName: 'Rakesh Verma',
    ),
    PaymentRecord(
      monthLabel: 'April', year: '2026', amountDue: rent,
      dueDate: DateTime(2026, 4, 10),
      status: PaymentStatus.rentPaid, method: PaymentMethod.online,
      paidAmount: rent, paymentDate: DateTime(2026, 4, 3),
      receiptNumber: 'RCP-2026-0401', referenceNumber: 'TXN-8126540915',
      tenantName: 'Aarav Sharma', roomName: 'Room 204',
      ownerName: 'Rakesh Verma',
    ),
    PaymentRecord(
      monthLabel: 'May', year: '2026', amountDue: rent,
      dueDate: DateTime(2026, 5, 10),
      status: PaymentStatus.rentPaid, method: PaymentMethod.cash,
      paidAmount: rent, paymentDate: DateTime(2026, 5, 4),
      receiptNumber: 'RCP-2026-0501', referenceNumber: 'CSH-2026-0501',
      tenantName: 'Aarav Sharma', roomName: 'Room 204',
      ownerName: 'Rakesh Verma',
    ),
    PaymentRecord(
      monthLabel: 'June', year: '2026', amountDue: rent,
      dueDate: DateTime(2026, 6, 10),
      status: PaymentStatus.rentPaid, method: PaymentMethod.online,
      paidAmount: rent, paymentDate: DateTime(2026, 6, 6),
      receiptNumber: 'RCP-2026-0601', referenceNumber: 'TXN-8126540916',
      tenantName: 'Aarav Sharma', roomName: 'Room 204',
      ownerName: 'Rakesh Verma',
    ),
    PaymentRecord(
      monthLabel: 'July', year: '2026', amountDue: rent,
      dueDate: DateTime(2026, 7, 10),
      status: PaymentStatus.rentPaid, method: PaymentMethod.cash,
      paidAmount: rent, paymentDate: DateTime(2026, 7, 5),
      receiptNumber: 'RCP-2026-0701', referenceNumber: 'CSH-2026-0701',
      tenantName: 'Aarav Sharma', roomName: 'Room 204',
      ownerName: 'Rakesh Verma',
    ),
    PaymentRecord(
      monthLabel: 'August', year: '2026', amountDue: rent,
      dueDate: DateTime(2026, 8, 10),
      status: PaymentStatus.rentPaid, method: PaymentMethod.online,
      paidAmount: rent, paymentDate: DateTime(2026, 8, 4),
      receiptNumber: 'RCP-2026-0801', referenceNumber: 'TXN-8126540917',
      tenantName: 'Aarav Sharma', roomName: 'Room 204',
      ownerName: 'Rakesh Verma',
    ),
    PaymentRecord(
      monthLabel: 'September', year: '2026', amountDue: rent,
      dueDate: DateTime(2026, 9, 25),
      status: PaymentStatus.rentDue, method: null,
      tenantName: 'Aarav Sharma', roomName: 'Room 204',
      ownerName: 'Rakesh Verma',
    ),
  ];
}

Settlement computeSettlement({
  required List<PaymentRecord> ledger,
  required double securityDeposit,
  required double deductions,
}) {
  double totalPaid = 0;
  double outstanding = 0;
  double totalDue = 0;
  for (final record in ledger) {
    totalDue += record.amountDue;
    if (record.status == PaymentStatus.rentPaid) {
      totalPaid += record.paidAmount ?? record.amountDue;
    } else {
      outstanding += record.amountDue;
    }
  }
  final refund = (securityDeposit - deductions) - outstanding;
  return Settlement(
    totalDue: totalDue,
    totalPaid: totalPaid,
    outstanding: outstanding,
    securityDeposit: securityDeposit,
    deductions: deductions,
    refundAmount: refund < 0 ? 0 : refund,
  );
}