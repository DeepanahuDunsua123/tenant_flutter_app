import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/move_out_model.dart';
import '../../models/payment_model.dart';
import '../../utils/app_colors.dart';
import 'move_out_status_screen.dart';

class MoveOutRequestScreen extends StatefulWidget {
  const MoveOutRequestScreen({super.key});

  @override
  State<MoveOutRequestScreen> createState() => _MoveOutRequestScreenState();
}

class _MoveOutRequestScreenState extends State<MoveOutRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime? _requestedDate;
  String? _reason;
  bool _acknowledged = false;
  bool _submitting = false;

  final List<Map<String, String>> _reasons = [
    {'label': 'Relocating to another city', 'icon': 'Icons.location_city'},
    {'label': 'Job / work relocation', 'icon': 'Icons.business_center'},
    {'label': 'End of lease term', 'icon': 'Icons.calendar_month'},
    {'label': 'Purchasing own property', 'icon': 'Icons.home_work'},
    {'label': 'Family / personal reasons', 'icon': 'Icons.family_restroom'},
    {'label': 'Other', 'icon': 'Icons.more_horiz'},
  ];

  static const _tenantName = 'Aarav Sharma';
  static const _tenantPhone = '+91 98765 43210';
  static const _roomNumber = 'Room 204';
  static const _propertyAddress = '123 Main Street, Apt 204';
  static const _monthlyRent = 12000.0;
  static final _moveInDate = DateTime(2025, 9, 1);

  int get _noticeDays =>
      _requestedDate == null ? 0 : _requestedDate!.difference(DateTime.now()).inDays;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final firstAllowed = now.add(const Duration(days: 30));
    final picked = await showDatePicker(
      context: context,
      initialDate: _requestedDate ?? firstAllowed,
      firstDate: firstAllowed,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Select preferred move-out date',
    );
    if (picked != null) {
      setState(() => _requestedDate = picked);
    }
  }

  void _toast(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_requestedDate == null) {
      _toast('Please select a preferred move-out date', AppColors.error);
      return;
    }
    if (_reason == null) {
      _toast('Please select a reason for moving out', AppColors.error);
      return;
    }
    if (!_acknowledged) {
      _toast('Please acknowledge the notice period', AppColors.error);
      return;
    }
    setState(() => _submitting = true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      final request = MoveOutStore.instance.submitRequest(
        tenantName: _tenantName,
        tenantPhone: _tenantPhone,
        roomNumber: _roomNumber,
        propertyAddress: _propertyAddress,
        monthlyRent: _monthlyRent,
        moveInDate: _moveInDate,
        requestedMoveOutDate: _requestedDate!,
        reason: _reason!,
      );
      _showSuccess(request);
    });
  }

  void _showSuccess(MoveOutRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 42,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Move-Out Request Submitted',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your request is now pending. The owner has been notified and will review it.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MoveOutStatusScreen(request: request),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'View Request Status',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIntakeCard(),
                      const SizedBox(height: 16),
                      _buildDateCard(),
                      const SizedBox(height: 16),
                      _buildReasonCard(),
                      const SizedBox(height: 16),
                      _buildNoticeCard(),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: _submitting ? null : _submit,
                          icon: _submitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Icon(Icons.logout_rounded, size: 20),
                          label: Text(
                            _submitting ? 'Submitting...' : 'Submit Move-Out Request',
                            style: GoogleFonts.poppins(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'By submitting, the owner will be notified immediately. Your tenancy and payment history will always be preserved.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          height: 1.4,
                          color: AppColors.textHint,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
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
                  'Move-Out Request',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Intimate your intention to vacate',
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
        ],
      ),
    );
  }

  Widget _buildIntakeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _intakeRow(Icons.person_rounded, 'Tenant', _tenantName),
          const SizedBox(height: 12),
          _intakeRow(Icons.meeting_room_rounded, 'Room', _roomNumber),
          const SizedBox(height: 12),
          _intakeRow(Icons.location_on_outlined, 'Property', _propertyAddress),
          const SizedBox(height: 12),
          _intakeRow(
            Icons.currency_rupee_rounded,
            'Monthly Rent',
            formatRupees(_monthlyRent),
          ),
          const SizedBox(height: 12),
          _intakeRow(
            Icons.calendar_month_rounded,
            'Move-In Date',
            formatDateLabel(_moveInDate),
          ),
        ],
      ),
    );
  }

  Widget _intakeRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textHint),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferred Move-Out Date',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Minimum 30 days notice from today',
            style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textHint),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: _requestedDate == null
                      ? AppColors.border
                      : AppColors.primary.withValues(alpha: 0.5),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event_rounded,
                    size: 20,
                    color: _requestedDate == null
                        ? AppColors.textHint
                        : AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _requestedDate == null
                        ? 'Select date'
                        : formatDateLabel(_requestedDate!),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _requestedDate == null
                          ? AppColors.textHint
                          : AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textHint),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reason for Move-Out',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: _reasons.map((r) {
              final selected = _reason == r['label'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _reason = r['label']),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                        width: selected ? 1.4 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: selected ? AppColors.primary : AppColors.textHint,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            r['label']!,
                            style: GoogleFonts.poppins(
                              fontSize: 13.5,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                              color: selected ? AppColors.primary : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (selected)
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 19, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Notice Period',
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (_requestedDate != null)
                Text(
                  '$_noticeDays days',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => setState(() => _acknowledged = !_acknowledged),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: _acknowledged ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _acknowledged ? AppColors.primary : AppColors.textHint,
                      width: 1.6,
                    ),
                  ),
                  child: _acknowledged
                      ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'I understand the ${_requestedDate == null ? '30-day' : '$_noticeDays-day'} notice period and will vacate on the requested date.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      height: 1.4,
                      color: AppColors.textSecondary,
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
}