import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/payment_model.dart';
import '../../utils/app_colors.dart';
import 'payment_method_sheet.dart';
import 'cash_payment_screen.dart';
import 'online_payment_screen.dart';
import 'rent_receipt_screen.dart';

class RentPaymentScreen extends StatefulWidget {
  const RentPaymentScreen({super.key});

  @override
  State<RentPaymentScreen> createState() => _RentPaymentScreenState();
}

class _RentPaymentScreenState extends State<RentPaymentScreen> {
  PaymentRecord _record = PaymentRecord(
    monthLabel: 'September',
    year: '2026',
    amountDue: 12000,
    dueDate: DateTime(2026, 9, 10),
    status: PaymentStatus.rentDue,
    tenantName: 'Aarav Sharma',
    roomName: 'Room 204',
    ownerName: 'Rakesh Verma',
    ownerMobile: '+91 98765 43210',
  );

  final List<Map<String, String>> _previousPayments = [
    {'month': 'August 2026', 'amount': '\u20B912,000', 'status': 'Paid', 'date': '5 Aug 2026'},
    {'month': 'July 2026', 'amount': '\u20B912,000', 'status': 'Paid', 'date': '4 Jul 2026'},
    {'month': 'June 2026', 'amount': '\u20B912,000', 'status': 'Paid', 'date': '6 Jun 2026'},
  ];

  bool _devExpanded = false;

  Color get _statusColor {
    switch (_record.status) {
      case PaymentStatus.rentDue:
        return AppColors.pending;
      case PaymentStatus.pendingVerification:
        return AppColors.warning;
      case PaymentStatus.rentPaid:
        return AppColors.success;
      case PaymentStatus.rejected:
        return AppColors.error;
      case PaymentStatus.resubmissionRequired:
        return AppColors.pending;
    }
  }

  int get _activeStep {
    switch (_record.status) {
      case PaymentStatus.rentDue:
        return 0;
      case PaymentStatus.pendingVerification:
        return 2;
      case PaymentStatus.rentPaid:
        return 3;
      case PaymentStatus.rejected:
      case PaymentStatus.resubmissionRequired:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFlowSteps(),
                    const SizedBox(height: 18),
                    _buildRentSummaryCard(),
                    const SizedBox(height: 16),
                    _buildStatusSection(),
                    const SizedBox(height: 16),
                    _buildPreviousPayments(),
                    const SizedBox(height: 16),
                    _buildDeveloperPreview(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payments',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Rent payments & verification',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              size: 22,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowSteps() {
    const labels = ['Rent Due', 'Pay', 'Verify', 'Receipt'];
    final active = _activeStep;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: List.generate(4, (index) {
          final done = index < active;
          final isActive = index == active;
          return Expanded(
            child: Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done
                        ? AppColors.success
                        : (isActive ? AppColors.primary : AppColors.border),
                  ),
                  child: Center(
                    child: done
                        ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                        : Text(
                            '${index + 1}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isActive ? Colors.white : AppColors.textHint,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  labels[index],
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: isActive || done ? FontWeight.w600 : FontWeight.w400,
                    color: isActive || done ? AppColors.textPrimary : AppColors.textHint,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRentSummaryCard() {
    final status = _record.status;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${_record.monthLabel} Rent',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(statusLabel: status.label, color: _statusColor),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  _record.amountDueLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '/ month',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Due: ${formatDateLabel(_record.dueDate)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    switch (_record.status) {
      case PaymentStatus.rentDue:
        return _buildRentDueCard();
      case PaymentStatus.pendingVerification:
        return _buildPendingVerificationCard();
      case PaymentStatus.rentPaid:
        return _buildRentPaidCard();
      case PaymentStatus.rejected:
        return _buildRejectedCard();
      case PaymentStatus.resubmissionRequired:
        return _buildResubmissionRequiredCard();
    }
  }

  Widget _buildRentDueCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.pending.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.pending,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your September rent is due',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Pay ${_record.amountDueLabel} before ${formatDateLabel(_record.dueDate)}.',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _onPayRent,
              icon: const Icon(Icons.currency_rupee_rounded, size: 20),
              label: Text(
                'Pay Rent',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                shadowColor: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingVerificationCard() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Waiting for owner verification',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'We will notify you once your payment is confirmed.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _buildSubmittedDetailsCard(showNote: false),
      ],
    );
  }

  Widget _buildSubmittedDetailsCard({bool showNote = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                'Submitted Payment Details',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DetailRow(
            label: 'Amount',
            value: _record.paidAmountLabel,
            highlight: true,
          ),
          _DetailRow(
            label: 'Payment Date',
            value: formatDateLabel(_record.paymentDate ?? DateTime.now()),
          ),
          _DetailRow(
            label: 'Payment Method',
            value: _record.method?.label ?? '-',
          ),
          if (_record.referenceNumber != null)
            _DetailRow(
              label: 'Transaction / Ref. No.',
              value: _record.referenceNumber!,
            ),
          if (showNote && _record.note != null && _record.note!.isNotEmpty)
            _DetailRow(label: 'Note', value: _record.note!),
          if (_record.proofPath != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(_record.proofPath!),
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _missingProof(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _missingProof() {
    return Container(
      height: 140,
      color: AppColors.background,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image_not_supported_outlined, color: AppColors.textHint, size: 32),
          const SizedBox(height: 6),
          Text(
            'Payment screenshot unavailable',
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  Widget _buildRentPaidCard() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF059669),
                  size: 38,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Rent Paid!',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your ${_record.monthLabel} rent has been received and verified.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 18),
              _PaidInfoChip(label: 'Amount', value: _record.paidAmountLabel),
              _PaidInfoChip(
                label: 'Paid On',
                value: formatDateLabel(_record.paymentDate ?? _record.dueDate),
              ),
              _PaidInfoChip(label: 'Method', value: _record.method?.label ?? '-'),
              if (_record.verificationDate != null)
                _PaidInfoChip(
                  label: 'Verified On',
                  value: formatDateLabel(_record.verificationDate!),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.receipt_long_rounded, color: AppColors.success, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your rent receipt is ready',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Auto-generated on ${formatDateLabel(_record.verificationDate ?? DateTime.now())}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () => _goToReceipt(),
            icon: const Icon(Icons.receipt_rounded, size: 20),
            label: Text(
              'View Rent Receipt',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 4,
              shadowColor: AppColors.success.withValues(alpha: 0.3),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Receipt downloaded', style: GoogleFonts.poppins()),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            icon: const Icon(Icons.download_rounded, size: 20),
            label: Text(
              'Download Receipt',
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.success,
              side: const BorderSide(color: AppColors.success, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRejectedCard() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: AppColors.error.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.cancel_rounded, color: AppColors.error, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Rejected',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                        Text(
                          'Owner did not approve this payment.',
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_record.rejectionReason != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.error, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _record.rejectionReason!,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _buildResubmitButton(AppColors.error),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _buildSubmittedDetailsCard(showNote: true),
      ],
    );
  }

  Widget _buildResubmissionRequiredCard() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.pending.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: AppColors.pending.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.pending.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.update_rounded, color: AppColors.pending, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resubmission Required',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.pending,
                          ),
                        ),
                        Text(
                          'Your submission needs correction.',
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_record.resubmissionReason != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.pending.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.fact_check_outlined, color: AppColors.pending, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _record.resubmissionReason!,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _buildResubmitButton(AppColors.pending),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _buildSubmittedDetailsCard(showNote: true),
      ],
    );
  }

  Widget _buildResubmitButton(Color color) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _onResubmit,
        icon: const Icon(Icons.replay_rounded, size: 20),
        label: Text(
          'Resubmit Payment',
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 3,
          shadowColor: color.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildPreviousPayments() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Previous Payments',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.history_rounded, size: 20, color: AppColors.textHint),
            ],
          ),
          const SizedBox(height: 10),
          for (final payment in _previousPayments)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment['month']!,
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Paid on ${payment['date']}',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Text(
                      payment['amount']!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeveloperPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _devExpanded = !_devExpanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.developer_mode_rounded, size: 20, color: AppColors.textHint),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Preview payment states (demo)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _devExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  size: 20,
                  color: AppColors.textHint,
                ),
              ],
            ),
          ),
        ),
        if (_devExpanded) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final status in PaymentStatus.values)
                  FilterChip(
                    avatar: Icon(
                      Icons.circle,
                      size: 12,
                      color: _previewColor(status),
                    ),
                    label: Text(
                      status.label,
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    selected: _record.status == status,
                    onSelected: (_) => setState(() {
                      _record = _demoRecord(status);
                    }),
                    selectedColor: _previewColor(status).withValues(alpha: 0.15),
                    showCheckmark: false,
                    side: BorderSide(
                      color: AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Color _previewColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.rentDue:
        return AppColors.pending;
      case PaymentStatus.pendingVerification:
        return AppColors.warning;
      case PaymentStatus.rentPaid:
        return AppColors.success;
      case PaymentStatus.rejected:
        return AppColors.error;
      case PaymentStatus.resubmissionRequired:
        return AppColors.pending;
    }
  }

  PaymentRecord _demoRecord(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.rentDue:
        return _record.copyWith(
          status: status,
          method: null,
          paidAmount: null,
          paymentDate: null,
          referenceNumber: null,
          proofPath: null,
          note: null,
          rejectionReason: null,
          resubmissionReason: null,
          verificationDate: null,
          receiptNumber: null,
        );
      case PaymentStatus.pendingVerification:
        return _record.copyWith(
          status: status,
          method: PaymentMethod.online,
          paidAmount: 12000,
          paymentDate: DateTime(2026, 9, 14),
          referenceNumber: 'UTRX-7382910456',
          note: 'Paid via UPI',
          submittedAt: DateTime(2026, 9, 14, 18, 30),
          rejectionReason: null,
          resubmissionReason: null,
          verificationDate: null,
          receiptNumber: null,
        );
      case PaymentStatus.rentPaid:
        return _record.copyWith(
          status: status,
          method: PaymentMethod.online,
          paidAmount: 12000,
          paymentDate: DateTime(2026, 9, 9),
          referenceNumber: 'UTRX-7382910456',
          note: 'Paid via UPI',
          submittedAt: DateTime(2026, 9, 9, 10, 12),
          verificationDate: DateTime(2026, 9, 10, 9, 45),
          receiptNumber: 'TH-RCPT-2026-0910-204',
          rejectionReason: null,
          resubmissionReason: null,
        );
      case PaymentStatus.rejected:
        return _record.copyWith(
          status: status,
          method: PaymentMethod.cash,
          paidAmount: 12000,
          paymentDate: DateTime(2026, 9, 5),
          rejectionReason: 'The owner could not find the cash payment at the property. Please confirm the amount and the person who collected it, then resubmit.',
          resubmissionReason: null,
          verificationDate: null,
          receiptNumber: null,
        );
      case PaymentStatus.resubmissionRequired:
        return _record.copyWith(
          status: status,
          method: PaymentMethod.online,
          paidAmount: 12000,
          paymentDate: DateTime(2026, 9, 6),
          referenceNumber: 'UTRX-1112223334',
          resubmissionReason: 'The transaction reference number could not be verified. Please confirm the exact reference number from your bank/UPI app and upload a clear payment screenshot.',
          rejectionReason: null,
          verificationDate: null,
          receiptNumber: null,
        );
    }
  }

  Future<void> _onPayRent() async {
    final method = await showPaymentMethodSheet(context);
    if (method == null || !mounted) return;
    await _runPaymentFlow(method, resubmitting: false);
  }

  Future<void> _onResubmit() async {
    final method = await showPaymentMethodSheet(
      context,
      title: 'Resubmit Payment',
    );
    if (method == null || !mounted) return;
    await _runPaymentFlow(method, resubmitting: true);
  }

  Future<void> _runPaymentFlow(PaymentMethod method, {required bool resubmitting}) async {
    if (method == PaymentMethod.cash) {
      final result = await Navigator.push<PaymentRecord>(
        context,
        MaterialPageRoute(
          builder: (_) => CashPaymentScreen(
            baseRecord: _record,
            isResubmission: resubmitting,
          ),
        ),
      );
      if (result != null && mounted) {
        setState(() => _record = result);
      }
      return;
    }

    final result = await Navigator.push<PaymentRecord>(
      context,
      MaterialPageRoute(
        builder: (_) => OnlinePaymentScreen(
          baseRecord: _record,
          isResubmission: resubmitting,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() => _record = result);
    }
  }

  void _goToReceipt() {
    final receiptRecord = _record.receiptNumber == null
        ? _record.copyWith(
            receiptNumber: 'TH-RCPT-${_record.year}-09-204',
            verificationDate: _record.verificationDate ?? DateTime.now(),
          )
        : _record;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RentReceiptScreen(record: receiptRecord)),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String statusLabel;
  final Color color;

  const _StatusBadge({required this.statusLabel, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 6),
          Text(
            statusLabel,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _DetailRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                color: highlight ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaidInfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _PaidInfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}