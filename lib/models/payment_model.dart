

enum PaymentStatus { rentDue, pendingVerification, rentPaid, rejected, resubmissionRequired }

enum PaymentMethod { cash, online }

extension PaymentStatusLabel on PaymentStatus {
  String get label {
    switch (this) {
      case PaymentStatus.rentDue:
        return 'Payment Due';
      case PaymentStatus.pendingVerification:
        return 'Pending Verification';
      case PaymentStatus.rentPaid:
        return 'Rent Paid';
      case PaymentStatus.rejected:
        return 'Payment Rejected';
      case PaymentStatus.resubmissionRequired:
        return 'Resubmission Required';
    }
  }
}

extension PaymentMethodLabel on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash Payment';
      case PaymentMethod.online:
        return 'Direct Online Payment';
    }
  }
}

class PaymentRecord {
  final String monthLabel;
  final String year;
  final double amountDue;
  final DateTime dueDate;
  final PaymentStatus status;
  final PaymentMethod? method;
  final double? paidAmount;
  final DateTime? paymentDate;
  final String? referenceNumber;
  final String? proofPath;
  final String? note;
  final DateTime? submittedAt;
  final DateTime? verificationDate;
  final String? rejectionReason;
  final String? resubmissionReason;
  final String? receiptNumber;
  final String? tenantName;
  final String? roomName;
  final String? ownerName;
  final String? ownerMobile;

  const PaymentRecord({
    required this.monthLabel,
    required this.year,
    required this.amountDue,
    required this.dueDate,
    required this.status,
    this.method,
    this.paidAmount,
    this.paymentDate,
    this.referenceNumber,
    this.proofPath,
    this.note,
    this.submittedAt,
    this.verificationDate,
    this.rejectionReason,
    this.resubmissionReason,
    this.receiptNumber,
    this.tenantName,
    this.roomName,
    this.ownerName,
    this.ownerMobile,
  });

  PaymentRecord copyWith({
    String? monthLabel,
    String? year,
    double? amountDue,
    DateTime? dueDate,
    PaymentStatus? status,
    PaymentMethod? method,
    double? paidAmount,
    DateTime? paymentDate,
    String? referenceNumber,
    String? proofPath,
    String? note,
    DateTime? submittedAt,
    DateTime? verificationDate,
    String? rejectionReason,
    String? resubmissionReason,
    String? receiptNumber,
    String? tenantName,
    String? roomName,
    String? ownerName,
    String? ownerMobile,
    bool clearProof = false,
    bool clearMethod = false,
  }) {
    return PaymentRecord(
      monthLabel: monthLabel ?? this.monthLabel,
      year: year ?? this.year,
      amountDue: amountDue ?? this.amountDue,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      method: clearMethod ? null : (method ?? this.method),
      paidAmount: paidAmount ?? this.paidAmount,
      paymentDate: paymentDate ?? this.paymentDate,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      proofPath: clearProof ? null : (proofPath ?? this.proofPath),
      note: note ?? this.note,
      submittedAt: submittedAt ?? this.submittedAt,
      verificationDate: verificationDate ?? this.verificationDate,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      resubmissionReason: resubmissionReason ?? this.resubmissionReason,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      tenantName: tenantName ?? this.tenantName,
      roomName: roomName ?? this.roomName,
      ownerName: ownerName ?? this.ownerName,
      ownerMobile: ownerMobile ?? this.ownerMobile,
    );
  }

  String get amountDueLabel => formatRupees(amountDue);

  String get paidAmountLabel {
    final v = paidAmount ?? amountDue;
    return formatRupees(v);
  }
}

String formatRupees(num value) {
  final s = value.toStringAsFixed(2);
  final parts = s.split('.');
  final integer = parts[0];
  final lastThree = integer.length > 3 ? integer.substring(integer.length - 3) : integer;
  final beforeLastThree = integer.length > 3 ? integer.substring(0, integer.length - 3) : '';
  String withCommas = '';
  if (beforeLastThree.isNotEmpty) {
    final chunks = beforeLastThree.split('').reversed.join();
    final grouped = _groupDigits(chunks);
    withCommas = '$grouped,$lastThree';
  } else {
    withCommas = lastThree;
  }
  return '\u20B9$withCommas';
}

String _groupDigits(String chunks) {
  final buffer = StringBuffer();
  for (var i = 0; i < chunks.length; i++) {
    if (i > 0 && i % 2 == 0) {
      buffer.write(',');
    }
    buffer.write(chunks[i]);
  }
  return buffer.toString().split('').reversed.join();
}

String formatDateLabel(DateTime date) {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}