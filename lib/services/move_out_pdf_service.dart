import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/move_out_model.dart';
import '../models/payment_model.dart';

String _rs(num value) => 'Rs ${value.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}';

String _date(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

Future<Uint8List> buildMoveOutStatementPdf({
  required MoveOutRequest request,
  required List<PaymentRecord> ledger,
  required Settlement settlement,
}) async {
  final doc = pw.Document();

  final base = pw.Font.helvetica();
  final bold = pw.Font.helveticaBold();
  final italic = pw.Font.helveticaOblique();

  const primary = PdfColor.fromInt(0xFF6C63FF);
  const dark = PdfColor.fromInt(0xFF1A1A2E);
  const muted = PdfColor.fromInt(0xFF6B7280);
  const line = PdfColor.fromInt(0xFFE5E7EB);
  const success = PdfColor.fromInt(0xFF10B981);
  const warning = PdfColor.fromInt(0xFFF59E0B);

  pw.Widget header(pw.Context context) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'TenantHub',
                  style: pw.TextStyle(font: bold, fontSize: 22, color: primary),
                ),
                pw.Text(
                  'Property Management',
                  style: pw.TextStyle(font: base, fontSize: 9, color: muted),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'FINAL SETTLEMENT STATEMENT',
                  style: pw.TextStyle(font: bold, fontSize: 12, color: dark),
                ),
                pw.Text(
                  'Statement No: ${request.id}',
                  style: pw.TextStyle(font: base, fontSize: 9, color: muted),
                ),
                pw.Text(
                  'Generated: ${_date(DateTime.now())}',
                  style: pw.TextStyle(font: base, fontSize: 9, color: muted),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Container(
          height: 2,
          color: primary,
        ),
      ],
    );
  }

  pw.Widget sectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 14, bottom: 6),
      child: pw.Text(
        title,
        style: pw.TextStyle(font: bold, fontSize: 11, color: primary),
      ),
    );
  }

  pw.Widget keyValue(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: pw.TextStyle(font: base, fontSize: 9.5, color: muted)),
        pw.Spacer(),
        pw.Text(
          value,
          style: pw.TextStyle(font: base, fontSize: 9.5, color: dark),
        ),
      ],
    );
  }

  pw.Widget detailsBox() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: line),
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        children: [
          keyValue('Tenant', request.tenantName),
          keyValue('Contact', request.tenantPhone),
          keyValue('Room', request.roomNumber),
          keyValue('Property', request.propertyAddress),
          keyValue(
            'Monthly Rent',
            _rs(request.monthlyRent),
          ),
          keyValue(
            'Move-In Date',
            _date(request.moveInDate),
          ),
          keyValue(
            'Move-Out / Release Date',
            request.releasedDate == null ? 'Pending' : _date(request.releasedDate!),
          ),
          keyValue(
            'Stay Duration',
            '${request.stayDurationMonths} month${request.stayDurationMonths == 1 ? '' : 's'}',
          ),
          keyValue('Reason', request.reason),
        ],
      ),
    );
  }

  final rows = <List<String>>[];
  for (final record in ledger) {
    final paid = record.status == PaymentStatus.rentPaid;
    rows.add([
      '${record.monthLabel} ${record.year}',
      _rs(record.amountDue),
      paid ? _rs(record.paidAmount ?? record.amountDue) : '-',
      record.paymentDate != null ? _date(record.paymentDate!) : '-',
      record.status.label,
      record.receiptNumber ?? '-',
    ]);
  }

  pw.Table ledgerTable() {
    return pw.TableHelper.fromTextArray(
      headers: ['Month', 'Rent Due', 'Paid', 'Payment Date', 'Status', 'Receipt No'],
      data: rows,
      headerStyle: pw.TextStyle(
        font: bold,
        fontSize: 8,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: primary),
      cellStyle: pw.TextStyle(font: base, fontSize: 8, color: dark),
      border: pw.TableBorder.all(color: line, width: 0.4),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      cellAlignment: pw.Alignment.centerLeft,
      columnWidths: {
        0: const pw.FixedColumnWidth(70),
        1: const pw.FixedColumnWidth(55),
        2: const pw.FixedColumnWidth(55),
        3: const pw.FixedColumnWidth(65),
        4: const pw.FixedColumnWidth(80),
        5: const pw.FixedColumnWidth(70),
      },
    );
  }

  pw.Widget settlementBox() {
    final isRefund = settlement.refundAmount > 0;
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: primary, width: 1),
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            children: [
              pw.Text(
                'Total Rent Charged',
                style: pw.TextStyle(font: base, fontSize: 9.5, color: muted),
              ),
              pw.Spacer(),
              pw.Text(_rs(settlement.totalDue), style: pw.TextStyle(font: base, fontSize: 9.5)),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              pw.Text(
                'Total Amount Paid',
                style: pw.TextStyle(font: base, fontSize: 9.5, color: muted),
              ),
              pw.Spacer(),
              pw.Text(_rs(settlement.totalPaid), style: pw.TextStyle(font: base, fontSize: 9.5)),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              pw.Text(
                'Outstanding Amount',
                style: pw.TextStyle(font: base, fontSize: 9.5, color: muted),
              ),
              pw.Spacer(),
              pw.Text(
                _rs(settlement.outstanding),
                style: pw.TextStyle(font: base, fontSize: 9.5, color: warning),
              ),
            ],
          ),
          pw.Divider(),
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              pw.Text(
                'Security Deposit',
                style: pw.TextStyle(font: base, fontSize: 9.5, color: muted),
              ),
              pw.Spacer(),
              pw.Text(_rs(settlement.securityDeposit), style: pw.TextStyle(font: base, fontSize: 9.5)),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              pw.Text(
                'Deductions',
                style: pw.TextStyle(font: base, fontSize: 9.5, color: muted),
              ),
              pw.Spacer(),
              pw.Text(_rs(settlement.deductions), style: pw.TextStyle(font: base, fontSize: 9.5)),
            ],
          ),
          pw.Divider(thickness: 1.5, color: primary),
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              pw.Text(
                isRefund ? 'NET REFUND PAYABLE' : 'NET PAYABLE',
                style: pw.TextStyle(font: bold, fontSize: 11, color: dark),
              ),
              pw.Spacer(),
              pw.Text(
                '${isRefund ? '+ ' : ''}${_rs(settlement.refundAmount)}',
                style: pw.TextStyle(font: bold, fontSize: 11, color: success),
              ),
            ],
          ),
        ],
      ),
    );
  }

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      theme: pw.ThemeData.withFont(base: base, bold: bold, italic: italic),
      header: header,
      footer: (context) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text(
            'This is a system-generated statement. Tenancy & payment history is preserved.',
            style: pw.TextStyle(font: base, fontSize: 8, color: muted),
          ),
        ],
      ),
      build: (context) => [
        detailsBox(),
        sectionTitle('Month-wise Payment Ledger'),
        pw.Text(
          'Fetched automatically from existing payment records.',
          style: pw.TextStyle(font: italic, fontSize: 8.5, color: muted),
        ),
        pw.SizedBox(height: 6),
        ledgerTable(),
        sectionTitle('Final Settlement Summary'),
        settlementBox(),
        pw.SizedBox(height: 12),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              request.tenantName,
              style: pw.TextStyle(font: base, fontSize: 9, color: muted),
            ),
            pw.Text(
              'Owner: Rakesh Verma',
              style: pw.TextStyle(font: base, fontSize: 9, color: muted),
            ),
          ],
        ),
      ],
    ),
  );

  return doc.save();
}

Future<void> previewAndSaveMoveOutPdf(Uint8List bytes, String filename) async {
  await Printing.layoutPdf(onLayout: (_) async => bytes);
}