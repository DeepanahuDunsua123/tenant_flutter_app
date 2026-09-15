import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/support_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/support_widgets.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  final UserRole role;
  final Announcement? editAnnouncement;

  const CreateAnnouncementScreen({
    super.key,
    required this.role,
    this.editAnnouncement,
  });

  @override
  State<CreateAnnouncementScreen> createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _titleController;
  late final TextEditingController _messageController;

  late AnnouncementPriority _priority;
  String? _imagePath;
  DateTime? _expiryDate;
  bool _isPublishing = false;
  bool _isSavingDraft = false;
  bool _isSystem = false;

  bool get _isEditing => widget.editAnnouncement != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.editAnnouncement;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _messageController = TextEditingController(text: existing?.message ?? '');
    _priority = existing?.priority ?? AnnouncementPriority.normal;
    _imagePath = existing?.imagePath;
    _isSystem = existing?.source == AnnouncementSource.system;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (file != null && mounted) {
        setState(() => _imagePath = file.path);
      }
    } catch (_) {
      _toast('Unable to select the image', AppColors.error);
    }
  }

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _expiryDate = picked);
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

  Announcement _buildAnnouncement({required bool isDraft}) {
    final now = DateTime.now();
    final existing = widget.editAnnouncement;
    return Announcement(
      id: existing?.id ?? 'SA-${now.millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      message: _messageController.text.trim(),
      source: _isSystem
          ? AnnouncementSource.system
          : AnnouncementSource.owner,
      priority: _priority,
      imagePath: _imagePath,
      publishedAt: now,
      author: 'Rakesh Verma',
      expiryDate: _expiryDate == null
          ? null
          : '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}',
      isRead: false,
      isDraft: isDraft,
    );
  }

  void _publish() {
    if (!_formKey.currentState!.validate()) return;
    if (_messageController.text.trim().length < 10) {
      _toast('Announcement message should be at least 10 characters', AppColors.error);
      return;
    }
    setState(() => _isPublishing = true);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      Navigator.pop(context, _buildAnnouncement(isDraft: false));
    });
  }

  void _saveDraft() {
    setState(() => _isSavingDraft = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      Navigator.pop(context, _buildAnnouncement(isDraft: true));
    });
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
                      _buildFormCard(_isSystem),
                      const SizedBox(height: 20),
                      _buildActions(),
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
                  _isEditing ? 'Edit Announcement' : 'Create Announcement',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _isSystem
                      ? 'Manage a platform-wide announcement'
                      : 'Report an important update to your tenants',
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

  Widget _buildSourceToggle(bool isSystem) {
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isSystem ? Icons.dns_rounded : Icons.home_work_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSystem ? 'System Announcement' : 'Owner Announcement',
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isSystem
                      ? 'Shown to all tenants as a platform notice'
                      : 'Shown to your tenants as an owner update',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isSystem,
            activeTrackColor: AppColors.primary,
            activeThumbColor: Colors.white,
            inactiveThumbColor: AppColors.textSecondary,
            inactiveTrackColor: AppColors.border,
            onChanged: (v) => setState(() => _isSystem = v),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(bool isSystem) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSourceToggle(isSystem),
          const SizedBox(height: 18),
          Text(
            'Announcement Title',
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _titleController,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Title is required'
                : null,
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
            decoration: _inputDecoration('e.g. Water Supply Maintenance'),
          ),
          const SizedBox(height: 18),
          Text(
            'Announcement Message',
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _messageController,
            maxLines: 5,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Message is required'
                : null,
            style: GoogleFonts.poppins(fontSize: 14, height: 1.4),
            decoration: _inputDecoration('Write the announcement message...'),
          ),
          const SizedBox(height: 18),
          Text(
            'Priority',
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: AnnouncementPriority.values.map((p) {
              final selected = _priority == p;
              return ChoiceChip(
                label: Text(
                  p.label,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: selected ? Colors.white : p.color,
                  ),
                ),
                selected: selected,
                selectedColor: p.color,
                backgroundColor: p.color.withValues(alpha: 0.08),
                onSelected: (_) => setState(() => _priority = p),
                showCheckmark: false,
                side: BorderSide.none,
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          Text(
            'Optional Image / Attachment',
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _buildImagePicker(),
          const SizedBox(height: 18),
          Text(
            'Expiry Date (optional)',
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickExpiryDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: AppColors.border, width: 1.2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_rounded, size: 20, color: AppColors.textHint),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _expiryDate == null
                          ? 'Select expiry date'
                          : 'Expires ${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        color: _expiryDate == null ? AppColors.textHint : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (_expiryDate != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => _expiryDate = null),
                      child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textHint),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 13.5, color: AppColors.textHint),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: AppColors.border, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: AppColors.border, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
      ),
      errorStyle: GoogleFonts.poppins(fontSize: 12),
    );
  }

  Widget _buildImagePicker() {
    if (_imagePath == null) {
      return GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 1.3),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.image_outlined, color: AppColors.primary, size: 30),
              const SizedBox(height: 8),
              Text(
                'Tap to attach an image',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(
              File(_imagePath!),
              height: 130,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 130,
                color: AppColors.background,
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported_outlined, size: 28),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _smallAction(Icons.refresh_rounded, 'Replace', _pickImage),
        const SizedBox(width: 8),
        _smallAction(
          Icons.delete_outline_rounded,
          'Remove',
          () => setState(() => _imagePath = null),
        ),
      ],
    );
  }

  Widget _smallAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 9.5, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        ModuleButton(
          text: _isEditing ? 'Update Announcement' : 'Publish Announcement',
          onPressed: _publish,
          icon: Icons.campaign_rounded,
          color: AppColors.primary,
          isLoading: _isPublishing,
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: _isSavingDraft ? null : _saveDraft,
            icon: _isSavingDraft
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Icon(Icons.save_outlined, size: 19),
            label: Text(
              'Save as Draft',
              style: GoogleFonts.poppins(fontSize: 14.5, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.border, width: 1.4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        if (widget.role == UserRole.owner)
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text(
              'Draft announcements are visible only to you until published.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                color: AppColors.textHint,
              ),
            ),
          ),
      ],
    );
  }
}