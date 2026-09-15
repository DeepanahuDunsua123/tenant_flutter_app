import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/move_out_model.dart';
import '../../models/payment_model.dart';
import '../../utils/app_colors.dart';

class MoveOutRequestDetailScreen extends StatefulWidget {
  final MoveOutRequest request;

  const MoveOutRequestDetailScreen({super.key, required this.request});

  @override
  State<MoveOutRequestDetailScreen> createState() => _MoveOutRequestDetailScreenState();
}

class _MoveOutRequestDetailScreenState extends State<MoveOutRequestDetailScreen> {
  MoveOutRequest get _request => widget.request;

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

  Future<void> _showApproveFlow() async {
    final request = _request;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ApproveSheet(
        request: request,
        onConfirm: (releaseDate) {
          setState(() {
            MoveOutStore.instance.approveRequest(request, releaseDate);
          });
          _toast('Move-out approved. Release scheduled.', AppColors.success);
        },
      ),
    );
  }

  Future<void> _confirmRelease() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Confirm Room Release?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'This will mark ${_request.tenantName} as released from ${_request.roomNumber}, change the room status to Available, preserve the tenancy history, and automatically generate the final settlement statement.',
          style: GoogleFonts.poppins(fontSize: 13, height: 1.4, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Confirm Release',
              style: GoogleFonts.poppins(color: AppColors.success, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() {
        MoveOutStore.instance.releaseRequest(_request);
      });
      _toast(
        'Room released. Room ${_request.roomNumber} is now Available. Statement generated.',
        AppColors.success,
      );
    }
  }

  Future<void> _showRejectFlow() async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reject Move-Out Request',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          style: GoogleFonts.poppins(fontSize: 13.5),
          decoration: InputDecoration(
            hintText: 'Enter reason for rejection...',
            hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.textHint),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a rejection reason', style: GoogleFonts.poppins()),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              Navigator.pop(context, true);
              setState(() {
                MoveOutStore.instance.rejectRequest(
                  _request,
                  reasonController.text.trim(),
                );
              });
              _toast('Move-out request rejected.', AppColors.error);
            },
            child: Text(
              'Reject Request',
              style: GoogleFonts.poppins(color: AppColors.error, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    if (confirmed != null) {}
  }

  @override
  Widget build(BuildContext context) {
    final room = MoveOutStore.instance.roomFor(_request);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusBanner(),
                    const SizedBox(height: 16),
                    _buildTenantCard(),
                    const SizedBox(height: 16),
                    _buildRequestCard(),
                    const SizedBox(height: 16),
                    _buildTimelineCard(),
                    if (room != null) ...[
                      const SizedBox(height: 16),
                      _buildRoomStatusCard(room),
                    ],
                    const SizedBox(height: 20),
                    _buildOwnerActions(room),
                    const SizedBox(height: 30),
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
    final isResolved = _request.status == MoveOutStatus.approved ||
        _request.status == MoveOutStatus.released ||
        _request.status == MoveOutStatus.rejected;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (isResolved) {
                Navigator.pop(context, true);
              } else {
                Navigator.pop(context);
              }
            },
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
                  '${_request.id} • ${_request.roomNumber}',
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _request.status.background,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _request.status.shortLabel,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _request.status.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    final status = _request.status;
    final (title, subtitle, icon) = switch (status) {
      MoveOutStatus.pending => (
          'Awaiting Your Decision',
          'This tenant has requested to move out. Review the details and approve or reject.',
          Icons.hourglass_top_rounded,
        ),
      MoveOutStatus.approved => (
          'Release Approved',
          'Release scheduled for ${_request.releasedDate == null ? 'the requested date' : formatDateLabel(_request.releasedDate!)}. Confirm release to make the room available.',
          Icons.verified_rounded,
        ),
      MoveOutStatus.released => (
          'Room Released',
          'The room is now Available. Final settlement statement has been generated for the tenant.',
          Icons.check_circle_rounded,
        ),
      MoveOutStatus.rejected => (
          'Request Rejected',
          'You have rejected this request. The tenant has been notified.',
          Icons.cancel_rounded,
        ),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: status.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: status.color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 25, color: status.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    height: 1.4,
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

  Widget _buildTenantCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tenant Details',
            style: GoogleFonts.poppins(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _detailRow(Icons.person_rounded, 'Tenant', _request.tenantName),
          _detailRow(Icons.phone_rounded, 'Contact', _request.tenantPhone),
          _detailRow(Icons.meeting_room_rounded, 'Room', _request.roomNumber),
          _detailRow(Icons.currency_rupee_rounded, 'Monthly Rent', formatRupees(_request.monthlyRent)),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.textHint),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard() {
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
            'Request Information',
            style: GoogleFonts.poppins(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _infoRow('Move-In Date', formatDateLabel(_request.moveInDate)),
          _infoRow('Requested Move-Out', formatDateLabel(_request.requestedMoveOutDate)),
          if (_request.releasedDate != null)
            _infoRow('Release Date', formatDateLabel(_request.releasedDate!)),
          _infoRow('Notice Period', '${_request.noticePeriodDays} days'),
          _infoRow('Submitted On', formatDateLabel(_request.submittedAt)),
          _infoRow('Reason', _request.reason),
          if (_request.rejectionReason != null) ...[
            const Divider(height: 22),
            _infoRow('Rejection Reason', _request.rejectionReason!, color: AppColors.error),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.textHint),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: color ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard() {
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
            'Activity Timeline',
            style: GoogleFonts.poppins(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < _request.timeline.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _request.timeline[i].status.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _request.timeline[i].status.color,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      _request.timeline[i].status.icon,
                      size: 13,
                      color: _request.timeline[i].status.color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _request.timeline[i].status.label,
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (_request.timeline[i].note != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            _request.timeline[i].note!,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              height: 1.35,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRoomStatusCard(Room room) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: room.status.color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: room.status.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            room.status == RoomStatus.available
                ? Icons.check_circle_rounded
                : Icons.meeting_room_rounded,
            color: room.status.color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${room.roomNumber} — ${room.propertyAddress}',
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  room.status == RoomStatus.available
                      ? 'This room is now Available for a new tenant.'
                      : 'Room status: ${room.status.label}',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerActions(Room? room) {
    switch (_request.status) {
      case MoveOutStatus.pending:
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _showApproveFlow,
                icon: const Icon(Icons.check_circle_rounded, size: 20),
                label: Text(
                  'Approve & Schedule Release',
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _showRejectFlow,
                icon: const Icon(Icons.cancel_rounded, size: 20),
                label: Text(
                  'Reject Request',
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error, width: 1.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        );
      case MoveOutStatus.approved:
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _confirmRelease,
                icon: const Icon(Icons.meeting_room_rounded, size: 20),
                label: Text(
                  'Confirm Room Release',
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (room != null)
              Text(
                'Room ${room.roomNumber} remains ${room.status.label} until release is confirmed.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textHint),
              ),
          ],
        );
      case MoveOutStatus.released:
      case MoveOutStatus.rejected:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(
                _request.status == MoveOutStatus.released
                    ? Icons.verified_rounded
                    : Icons.info_outline_rounded,
                color: _request.status.color,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _request.status == MoveOutStatus.released
                      ? 'This request is fully completed. The final statement is available to the tenant.'
                      : 'This request has been rejected. No further action is required.',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}

class _ApproveSheet extends StatefulWidget {
  final MoveOutRequest request;
  final ValueChanged<DateTime> onConfirm;

  const _ApproveSheet({required this.request, required this.onConfirm});

  @override
  State<_ApproveSheet> createState() => _ApproveSheetState();
}

class _ApproveSheetState extends State<_ApproveSheet> {
  DateTime? _releaseDate;

  @override
  void initState() {
    super.initState();
    _releaseDate = widget.request.requestedMoveOutDate;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _releaseDate!,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _releaseDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Approve Move-Out',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Approve the release of ${widget.request.roomNumber} for ${widget.request.tenantName} with the scheduled move-out date below.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Move-Out / Release Date',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: AppColors.border, width: 1.2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_rounded, size: 20, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        formatDateLabel(_releaseDate!),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.edit_rounded, size: 18, color: AppColors.textHint),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 19, color: AppColors.success),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Once approved, the room will be marked for release. It becomes Available after release is confirmed, and the final statement is auto-generated.',
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
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onConfirm(_releaseDate!);
                  },
                  icon: const Icon(Icons.check_circle_rounded, size: 20),
                  label: Text(
                    'Approve Request',
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}