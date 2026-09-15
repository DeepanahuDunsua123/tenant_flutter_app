import 'package:flutter_test/flutter_test.dart';
import 'package:tenant_flutter_application/models/move_out_model.dart';
import 'package:tenant_flutter_application/services/move_out_pdf_service.dart';

void main() {
  test('buildMoveOutStatementPdf returns a valid non-empty PDF', () async {
    final request = MoveOutRequest(
      id: 'MO-204-001',
      tenantName: 'Aarav Sharma',
      tenantPhone: '+91 98765 43210',
      roomNumber: 'Room 204',
      propertyAddress: '123 Main Street, Apt 204',
      monthlyRent: 12000,
      moveInDate: DateTime(2025, 9, 1),
      requestedMoveOutDate: DateTime(2026, 9, 30),
      reason: 'Relocation to another city',
      noticePeriodDays: 30,
      submittedAt: DateTime(2026, 8, 15),
      status: MoveOutStatus.released,
      releasedDate: DateTime(2026, 9, 30),
      resolvedBy: 'Rakesh Verma',
      statementGeneratedAt: DateTime(2026, 9, 30, 10),
      timeline: const [],
    );

    final pdf = await buildMoveOutStatementPdf(
      request: request,
      ledger: seedPaymentLedger(),
      settlement: const Settlement(
        totalDue: 156000,
        totalPaid: 144000,
        outstanding: 12000,
        securityDeposit: 24000,
        deductions: 0,
        refundAmount: 12000,
      ),
    );

    expect(pdf, isNotEmpty);
    expect(String.fromCharCodes(pdf.take(4)), '%PDF');
  });
}