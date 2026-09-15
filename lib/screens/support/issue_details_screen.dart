import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/support_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/support_widgets.dart';

class IssueDetailsScreen extends StatefulWidget {
  final Issue issue;
  final UserRole role;

  const IssueDetailsScreen({
    super.key,
    required this.issue,
    required this.role,
  });

  @override
  State<IssueDetailsScreen> createState() => _IssueDetailsScreenState();
}

class _IssueDetailsScreenState extends State<IssueDetailsScreen> {
  final bool _updating = false;

  bool get _isOwner => widget.role != UserRole.tenant;

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

  void _moveStatus(IssueStatus next, {String? note}) {
    final issue = widget.issue;
    final now = DateTime.now();
    issue.status = next;
    issue.lastUpdated = now;
    issue.timeline.add(TimelineEvent(status: next, timestamp: now, note: note));
    if (next == IssueStatus.resolved) {
      issue.resolutionNote = note;
    }
    if (next == IssueStatus.rejected) {
      issue.rejectionReason = note;
    }
    setState(() {});

    final message = switch (next) {
      IssueStatus.underReview => 'Issue is now under review',
      IssueStatus.inProgress => 'Your issue is now being worked on',
      IssueStatus.resolved => 'Your reported issue has been marked as resolved by the owner.',
      IssueStatus.rejected => 'Your reported issue was rejected by the owner.',
      _ => 'Issue status updated',
    };
    _toast(message, next.color);
  }

  Future<void> _confirmTransition(IssueStatus next) async {
    if (next == IssueStatus.rejected) {
      await _showRejectDialog();
      return;
    }
    if (next == IssueStatus.resolved) {
      await _showResolveDialog();
      return;
    }
    _moveStatus(next);
  }

  Future<void> _showRejectDialog() async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reject Issue',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.error,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please provide a valid reason for rejecting this issue.',
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              style: GoogleFonts.poppins(fontSize: 13.5),
              decoration: InputDecoration(
                hintText: 'Rejection reason...',
                hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.error, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) {
                _toast('Rejection reason is required', AppColors.error);
                return;
              }
              Navigator.pop(context, text);
            },
            child: Text(
              'Confirm Rejection',
              style: GoogleFonts.poppins(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (reason != null && reason.isNotEmpty) {
      _moveStatus(IssueStatus.rejected, note: reason);
    }
  }

  Future<void> _showResolveDialog() async {
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Mark as Resolved',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.success,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add a resolution note (optional).',
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              style: GoogleFonts.poppins(fontSize: 13.5),
              decoration: InputDecoration(
                hintText: 'e.g. Bathroom tap replaced successfully',
                hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.success, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(
              'Mark as Resolved',
              style: GoogleFonts.poppins(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    _moveStatus(
      IssueStatus.resolved,
      note: (note == null || note.isEmpty) ? 'Issue resolved' : note,
    );
  }

  @override
  Widget build(BuildContext context) {
    final issue = widget.issue;
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
                    _buildStatusBanner(issue),
                    const SizedBox(height: 16),
                    if (_isOwner) ...[
                      _buildTenantInfo(issue),
                      const SizedBox(height: 16),
                    ],
                    if (issue.rejectionReason != null && issue.status == IssueStatus.rejected) ...[
                      _buildRejectionBox(issue),
                      const SizedBox(height: 16),
                    ],
                    if (issue.resolutionNote != null && issue.status == IssueStatus.resolved) ...[
                      _buildResolutionBox(issue),
                      const SizedBox(height: 16),
                    ],
                    _buildIssueInfo(issue),
                    const SizedBox(height: 16),
                    _buildTimeline(issue),
                    const SizedBox(height: 16),
                    if (_isOwner) _buildOwnerActions(issue),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Issue Details',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                widget.issue.id,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(Issue issue) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: issue.status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: issue.status.color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: issue.status.color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(_statusIcon(issue.status), color: issue.status.color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  issue.status.label,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: issue.status.color,
                  ),
                ),
                Text(
                  'Last updated ${formatIssueTimestamp(issue.lastUpdated)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _isOwner && issue.status == IssueStatus.pendingReview
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Action needed',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  IconData _statusIcon(IssueStatus status) {
    return switch (status) {
      IssueStatus.pendingReview => Icons.schedule_rounded,
      IssueStatus.underReview => Icons.search_rounded,
      IssueStatus.inProgress => Icons.build_circle_rounded,
      IssueStatus.resolved => Icons.check_circle_rounded,
      IssueStatus.rejected => Icons.cancel_rounded,
      IssueStatus.closed => Icons.lock_outline_rounded,
    };
  }

  Widget _buildTenantInfo(Issue issue) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Tenant Information'),
          const SizedBox(height: 6),
          _infoRow(Icons.person_rounded, 'Tenant', issue.tenantName),
          _infoRow(Icons.meeting_room_rounded, 'Room', issue.room),
          _infoRow(Icons.phone_outlined, 'Contact', '+91 98765 43210'),
        ],
      ),
    );
  }

  Widget _buildRejectionBox(Issue issue) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rejection Reason',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  issue.rejectionReason!,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResolutionBox(Issue issue) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.build_rounded, color: AppColors.success, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resolution Note',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  issue.resolutionNote!,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueInfo(Issue issue) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Issue Information'),
          const SizedBox(height: 6),
          Text(
            issue.message,
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.55,
              color: AppColors.textPrimary,
            ),
          ),
          if (issue.photos.isNotEmpty) ...[
            const SizedBox(height: 14),
            _buildPhotoGrid(issue),
          ],
          const SizedBox(height: 14),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 10),
          _chipRow(issue),
          const SizedBox(height: 10),
          _infoRow(Icons.calendar_today_rounded, 'Reported', formatIssueTimestamp(issue.createdAt)),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(Issue issue) {
    return GridView.count(
      crossAxisCount: issue.photos.length > 1 ? 3 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: issue.photos.map((path) => _issuePhoto(path)).toList(),
    );
  }

  Widget _issuePhoto(String path) {
    Widget image;
    if (path.endsWith('.svg')) {
      image = Container(
        color: AppColors.background,
        alignment: Alignment.center,
        child: SvgIcon(asset: path, size: 44, color: AppColors.primary),
      );
    } else if (path.startsWith('assets/')) {
      image = Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _imageFallback(),
      );
    } else {
      image = Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _imageFallback(),
      );
    }
    return ClipRRect(borderRadius: BorderRadius.circular(14), child: image);
  }

  Widget _imageFallback() {
    return Container(
      color: AppColors.background,
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image_outlined, size: 30, color: AppColors.textHint),
    );
  }

  Widget _chipRow(Issue issue) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        CategoryChip(category: issue.category),
        PriorityPill(priority: issue.priority),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on_outlined, size: 12, color: AppColors.primary),
              const SizedBox(width: 3),
              Text(
                issue.location,
                style: GoogleFonts.poppins(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline(Issue issue) {
    final events = issue.timeline;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Status History'),
          const SizedBox(height: 6),
          if (events.isEmpty)
            Text(
              'No updates yet.',
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textHint),
            )
          else
            Column(
              children: List.generate(events.length, (index) {
                final event = events[index];
                final isLast = index == events.length - 1;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isLast
                                ? event.status.color
                                : Colors.white,
                            border: Border.all(color: event.status.color, width: 2),
                          ),
                          child: Center(
                            child: Icon(
                              _statusIcon(event.status),
                              size: 12,
                              color: isLast
                                  ? Colors.white
                                  : event.status.color,
                            ),
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 42,
                            color: event.status.color.withValues(alpha: 0.25),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    event.status.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.5,
                                      fontWeight: isLast
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isLast
                                          ? event.status.color
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    formatIssueTimestamp(event.timestamp),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.5,
                                      color: AppColors.textHint,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (event.note != null &&
                                event.note!.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                event.note!,
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
                    ),
                  ],
                );
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildOwnerActions(Issue issue) {
    final status = issue.status;
    if (status == IssueStatus.resolved ||
        status == IssueStatus.rejected ||
        status == IssueStatus.closed) {
      return const SizedBox.shrink();
    }
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Update Issue Status'),
          const SizedBox(height: 12),
          if (_updating)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          else
            Column(
              children: [
                if (status == IssueStatus.pendingReview) ...[
                  _statusActionButton(
                    'Under Review',
                    Icons.search_rounded,
                    const Color(0xFF3B82F6),
                    IssueStatus.underReview,
                  ),
                  const SizedBox(height: 8),
                ],
                if (status == IssueStatus.underReview ||
                    status == IssueStatus.pendingReview) ...[
                  _statusActionButton(
                    'In Progress',
                    Icons.build_circle_rounded,
                    AppColors.primary,
                    IssueStatus.inProgress,
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Expanded(
                      child: _statusActionButton(
                        _statusLabel(IssueStatus.resolved),
                        Icons.check_circle_rounded,
                        AppColors.success,
                        IssueStatus.resolved,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _statusActionButton(
                        'Reject',
                        Icons.cancel_rounded,
                        AppColors.error,
                        IssueStatus.rejected,
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _statusLabel(IssueStatus status) => status.label;

  Widget _statusActionButton(
    String label,
    IconData icon,
    Color color,
    IssueStatus next,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton.icon(
        onPressed: () => _confirmTransition(next),
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.6), width: 1.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textHint),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
}