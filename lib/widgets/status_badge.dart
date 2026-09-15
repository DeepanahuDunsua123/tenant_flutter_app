import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum BadgeType { success, warning, error, info }

class StatusBadge extends StatelessWidget {
  final String text;
  final BadgeType type;

  const StatusBadge({
    super.key,
    required this.text,
    required this.type,
  });

  Color _getBackgroundColor() {
    switch (type) {
      case BadgeType.success:
        return const Color(0xFF22C55E).withValues(alpha: 0.1);
      case BadgeType.warning:
        return const Color(0xFFF59E0B).withValues(alpha: 0.1);
      case BadgeType.error:
        return const Color(0xFFEF4444).withValues(alpha: 0.1);
      case BadgeType.info:
        return const Color(0xFF3B82F6).withValues(alpha: 0.1);
    }
  }

  Color _getTextColor() {
    switch (type) {
      case BadgeType.success:
        return const Color(0xFF22C55E);
      case BadgeType.warning:
        return const Color(0xFFF59E0B);
      case BadgeType.error:
        return const Color(0xFFEF4444);
      case BadgeType.info:
        return const Color(0xFF3B82F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _getTextColor(),
        ),
      ),
    );
  }
}
