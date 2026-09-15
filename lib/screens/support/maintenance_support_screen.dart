import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/support_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/support_widgets.dart';
import 'announcement_details_screen.dart';
import 'create_announcement_screen.dart';
import 'issue_details_screen.dart';
import 'report_issue_screen.dart';

class MaintenanceSupportScreen extends StatefulWidget {
  const MaintenanceSupportScreen({super.key});

  @override
  State<MaintenanceSupportScreen> createState() => _MaintenanceSupportScreenState();
}

class _MaintenanceSupportScreenState extends State<MaintenanceSupportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  UserRole _role = UserRole.tenant;
  late List<Announcement> _announcements;
  late List<Issue> _issues;

  bool _initialLoading = true;
  bool _hasError = false;

  int _announcementFilter = 0; // 0 all, 1 system, 2 owner
  String _tenantIssueFilter = 'All';
  String _ownerIssueFilter = 'All';
  String _issueSearch = '';

  static const _tenantFilters = ['All', 'Pending', 'In Progress', 'Resolved', 'Rejected'];
  static const _ownerFilters = [
    'All',
    'Pending Review',
    'Under Review',
    'In Progress',
    'Resolved',
    'Rejected',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && mounted) {
        setState(() {});
      }
    });
    _announcements = [...seedAnnouncements()];
    _issues = seedIssues();
    _simulateInitialLoad();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _simulateInitialLoad() {
    setState(() {
      _initialLoading = true;
      _hasError = false;
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _initialLoading = false;
      });
    });
  }

  List<Issue> get _myIssues =>
      _issues.where((i) => i.tenantName == 'Aarav Sharma').toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  void _changeRole(UserRole role) {
    setState(() => _role = role);
  }

  Future<void> _openAnnouncements() async {
    final result = await Navigator.push<Announcement>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateAnnouncementScreen(
          role: _role,
          editAnnouncement: null,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() => _announcements = [result, ..._announcements]);
    }
  }

  Future<void> _editAnnouncement(Announcement announcement) async {
    final result = await Navigator.push<Announcement>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateAnnouncementScreen(
          role: _role,
          editAnnouncement: announcement,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _announcements = [
          for (final a in _announcements) a.id == result.id ? result : a,
        ];
        _announcements.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      });
    }
  }

  void _confirmDeleteAnnouncement(Announcement announcement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Announcement?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'This will permanently delete "${announcement.title}". This action cannot be undone.',
          style: GoogleFonts.poppins(fontSize: 13.5, color: AppColors.textSecondary),
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
              Navigator.pop(context);
              setState(() {
                _announcements =
                    _announcements.where((a) => a.id != announcement.id).toList();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Announcement deleted', style: GoogleFonts.poppins()),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAnnouncement(Announcement announcement) async {
    if (!announcement.isRead && !announcement.isDraft) {
      setState(() {
        _announcements = [
          for (final a in _announcements)
            a.id == announcement.id ? a.copyWith(isRead: true) : a,
        ];
      });
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnnouncementDetailsScreen(announcement: announcement),
      ),
    );
  }

  Future<void> _reportIssue() async {
    final result = await Navigator.push<Issue>(
      context,
      MaterialPageRoute(builder: (_) => const ReportIssueScreen()),
    );
    if (result != null && mounted) {
      setState(() {
        _issues = [result, ..._issues];
        _tenantIssueFilter = 'All';
      });
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
            _buildTabs(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAnnouncementsTab(),
                  _buildIssuesTab(),
                ],
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
                  'Maintenance & Support',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Announcements & issue management',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showRoleSwitcher,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_user_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 5),
                  Text(
                    _role.label,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.arrow_drop_down_rounded, size: 17, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRoleSwitcher() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 16),
              Text(
                'View as',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Switch role to preview different views',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              for (final role in UserRole.values)
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _role == role
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      switch (role) {
                        UserRole.tenant => Icons.person_rounded,
                        UserRole.owner => Icons.home_work_rounded,
                      },
                      color: _role == role ? AppColors.primary : AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    role.label,
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    switch (role) {
                      UserRole.tenant => 'View announcements & report issues',
                      UserRole.owner => 'Manage & resolve all issues',
                    },
                    style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                  trailing: _role == role
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20)
                      : const Icon(Icons.circle_outlined, color: AppColors.textHint, size: 20),
                  onTap: () {
                    Navigator.pop(context);
                    _changeRole(role);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 6, 20, 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(11),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
        tabs: [
          Tab(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.campaign_rounded, size: 17),
                  SizedBox(width: 6),
                  Text('Announcements'),
                ],
              ),
            ),
          ),
          Tab(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.report_problem_outlined, size: 17),
                  SizedBox(width: 6),
                  Text('Issues'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ANNOUNCEMENTS TAB
  // ---------------------------------------------------------------------------
  Widget _buildAnnouncementsTab() {
    if (_initialLoading) return _loadingState();
    if (_hasError) return _errorState(_retryAnnouncements);
    if (_role == UserRole.tenant) {
      return _buildTenantAnnouncements();
    }
    return _buildManagementAnnouncements();
  }

  void _retryAnnouncements() {
    _simulateInitialLoad();
  }

  Widget _buildTenantAnnouncements() {
    var list = _announcements.where((a) => !a.isDraft).toList();
    if (_announcementFilter == 1) {
      list = list.where((a) => a.source == AnnouncementSource.system).toList();
    } else if (_announcementFilter == 2) {
      list = list.where((a) => a.source == AnnouncementSource.owner).toList();
    }
    list.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _announcementFilterChip('All', 0),
                      _announcementFilterChip('System', 1),
                      _announcementFilterChip('Owner', 2),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Refresh will reload announcements', style: GoogleFonts.poppins()),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                  _simulateInitialLoad();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.refresh_rounded, size: 20, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: list.isEmpty
              ? const EmptyState(
                  asset: 'assets/images/setting.svg',
                  title: 'No announcements',
                  subtitle: "You don't have any announcements at the moment.",
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: list.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _announcementLegend(),
                        );
                      }
                      final announcement = list[index - 1];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AnnouncementCard(
                          announcement: announcement,
                          onTap: () => _openAnnouncement(announcement),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _announcementLegend() {
    return Row(
      children: [
        _legend('System', AnnouncementSource.system.color),
        const SizedBox(width: 14),
        _legend('Owner', AnnouncementSource.owner.color),
        const Spacer(),
      ],
    );
  }

  Widget _legend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _announcementFilterChip(String label, int value) {
    final selected = _announcementFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _announcementFilter = value),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildManagementAnnouncements() {
    final published = _announcements
        .where((a) => !a.isDraft)
        .toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    final drafts = _announcements.where((a) => a.isDraft).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: ModuleButton(
            text: 'Create Announcement',
            onPressed: _openAnnouncements,
            icon: Icons.add_rounded,
          ),
        ),
        if (drafts.isNotEmpty) ...[
          _managementSectionTitle('Drafts (${drafts.length})'),
          for (final draft in drafts)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ManagementAnnouncementCard(
                announcement: draft,
                isDraft: true,
                onTap: () => _editAnnouncement(draft),
                onEdit: () => _editAnnouncement(draft),
                onDelete: () => _confirmDeleteAnnouncement(draft),
              ),
            ),
          const SizedBox(height: 8),
        ],
        _managementSectionTitle('Published (${published.length})'),
        if (published.isEmpty)
          const EmptyState(
            asset: 'assets/images/setting.svg',
            title: 'No published announcements',
            subtitle: 'Create an announcement to share updates with your tenants.',
          )
        else
          for (final announcement in published)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ManagementAnnouncementCard(
                announcement: announcement,
                isDraft: false,
                onTap: () => _openAnnouncement(announcement),
                onEdit: () => _editAnnouncement(announcement),
                onDelete: () => _confirmDeleteAnnouncement(announcement),
              ),
            ),
      ],
    );
  }

  Widget _managementSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ISSUES TAB
  // ---------------------------------------------------------------------------
  Widget _buildIssuesTab() {
    if (_initialLoading) return _loadingState();
    if (_hasError) return _errorState(() {});
    if (_role == UserRole.tenant) {
      return _buildTenantIssues();
    }
    return _buildOwnerIssues();
  }

  Widget _buildTenantIssues() {
    var issues = _myIssues;
    if (_tenantIssueFilter != 'All') {
      issues = issues.where((i) {
        switch (_tenantIssueFilter) {
          case 'Pending':
            return i.status == IssueStatus.pendingReview;
          case 'In Progress':
            return i.status == IssueStatus.inProgress;
          case 'Resolved':
            return i.status == IssueStatus.resolved;
          case 'Rejected':
            return i.status == IssueStatus.rejected;
          default:
            return true;
        }
      }).toList();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ModuleButton(
            text: 'Report an Issue',
            onPressed: _reportIssue,
            icon: Icons.add_alert_rounded,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: _tenantFilters.map((label) {
              final selected = _tenantIssueFilter == label;
              return GestureDetector(
                onTap: () => setState(() => _tenantIssueFilter = label),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: selected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                'My Issues',
                style: GoogleFonts.poppins(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${issues.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(builder: (_) => const IssueHistoryScreen()),
                  );
                  if (result == true && mounted) _simulateInitialLoad();
                },
                child: Text(
                  'Full History',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: issues.isEmpty
              ? const EmptyState(
                  asset: 'assets/images/help_center_icon.svg',
                  title: 'No issues reported',
                  subtitle: "You haven't reported any maintenance issues yet.",
                  actionLabel: 'Report an Issue',
                  onAction: null,
                )
              : ListView.builder(
                  itemCount: issues.length,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemBuilder: (context, index) {
                    final issue = issues[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TenantIssueCard(
                        issue: issue,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => IssueDetailsScreen(
                              issue: issue,
                              role: _role,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildOwnerIssues() {
    final filtered = _issues.where((i) {
      final matchesSearch = _issueSearch.isEmpty ||
          i.message.toLowerCase().contains(_issueSearch.toLowerCase()) ||
          i.tenantName.toLowerCase().contains(_issueSearch.toLowerCase()) ||
          i.id.toLowerCase().contains(_issueSearch.toLowerCase());
      final matchesFilter =
          _ownerIssueFilter == 'All' || i.status.label == _ownerIssueFilter;
      return matchesSearch && matchesFilter;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const SvgIcon(
                        asset: 'assets/images/search.svg',
                        size: 18,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: (v) => setState(() => _issueSearch = v),
                          style: GoogleFonts.poppins(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Search issues...',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.textHint,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showOwnerFilterSheet(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Center(
                    child: SvgIcon(
                      asset: 'assets/images/filter_icon.svg',
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                'All Issues',
                style: GoogleFonts.poppins(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${filtered.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: filtered.isEmpty
              ? const EmptyState(
                  asset: 'assets/images/setting.svg',
                  title: 'No issues found',
                  subtitle: "You're all caught up. There are no pending issues requiring your attention.",
                )
              : ListView.builder(
                  itemCount: filtered.length,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemBuilder: (context, index) {
                    final issue = filtered[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _OwnerIssueCard(
                        issue: issue,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => IssueDetailsScreen(
                              issue: issue,
                              role: _role,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showOwnerFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 16),
              Text(
                'Filter by Status',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              for (final filter in _ownerFilters)
                ListTile(
                  title: Text(
                    filter,
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  trailing: _ownerIssueFilter == filter
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20)
                      : const Icon(Icons.circle_outlined, color: AppColors.textHint, size: 20),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _ownerIssueFilter = filter);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 14),
          Text('Loading...'),
        ],
      ),
    );
  }

  Widget _errorState(VoidCallback retry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cloud_off_rounded, size: 40, color: AppColors.error),
          ),
          const SizedBox(height: 18),
          Text(
            'Unable to load',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Something went wrong. Please try again.',
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 180,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: retry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'Try Again',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final VoidCallback onTap;

  const _AnnouncementCard({required this.announcement, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPriority = announcement.priority != AnnouncementPriority.normal;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPriority
                ? announcement.priority.color.withValues(alpha: 0.45)
                : AppColors.border,
          ),
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
            Row(
              children: [
                SourceBadge(source: announcement.source),
                const SizedBox(width: 8),
                PriorityChip(priority: announcement.priority),
                const Spacer(),
                if (!announcement.isRead)
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  Text(
                    'Read',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              announcement.title,
              style: GoogleFonts.poppins(
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
                height: 1.25,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              announcement.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.schedule_rounded, size: 14, color: AppColors.textHint),
                const SizedBox(width: 5),
                Text(
                  formatIssueDate(announcement.publishedAt),
                  style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textHint),
                ),
                const SizedBox(width: 14),
                if (announcement.imagePath != null) ...[
                  const Icon(Icons.image_outlined, size: 14, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text(
                    'Attachment',
                    style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textHint),
                  ),
                  const SizedBox(width: 6),
                ],
                const Spacer(),
                const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ManagementAnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final bool isDraft;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ManagementAnnouncementCard({
    required this.announcement,
    required this.isDraft,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDraft ? AppColors.warning.withValues(alpha: 0.4) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SourceBadge(source: announcement.source),
                      const SizedBox(width: 8),
                      PriorityChip(priority: announcement.priority),
                      if (isDraft) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'DRAFT',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    announcement.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isDraft
                        ? 'Draft created ${formatIssueDate(announcement.publishedAt)}'
                        : 'Published ${formatIssueDate(announcement.publishedAt)}',
                    style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textHint),
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const SvgIcon(
                    asset: 'assets/images/edit_icon.svg',
                    size: 17,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TenantIssueCard extends StatelessWidget {
  final Issue issue;
  final VoidCallback onTap;

  const _TenantIssueCard({required this.issue, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
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
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
child: Icon(
                    _categoryIcon(issue.category),
                    color: AppColors.primary,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    issue.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (issue.photos.isNotEmpty) ...[
                  const Icon(Icons.photo_camera_outlined, size: 14, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Photo attached',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textHint),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Flexible(
                  child: Text(
                    'Reported: ${formatIssueDate(issue.createdAt)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textHint),
                  ),
                ),
                const SizedBox(width: 8),
                IssueStatusBadge(status: issue.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                PriorityPill(priority: issue.priority),
                const SizedBox(width: 8),
                CategoryChip(category: issue.category),
                const Spacer(),
                Flexible(
                  child: Text(
                    'Updated ${formatIssueDate(issue.lastUpdated)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textHint),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(IssueCategory category) => category.icon;
}

class _OwnerIssueCard extends StatelessWidget {
  final Issue issue;
  final VoidCallback onTap;

  const _OwnerIssueCard({required this.issue, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    issue.id,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const Spacer(),
                IssueStatusBadge(status: issue.status),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${issue.tenantName} \u2022 ${issue.room}',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              issue.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 13,
                height: 1.35,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                PriorityPill(priority: issue.priority),
                const SizedBox(width: 6),
                CategoryChip(category: issue.category),
                if (issue.photos.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.photo_library_outlined, size: 16, color: AppColors.textHint),
                ],
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    formatIssueDate(issue.createdAt),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textHint),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class IssueHistoryScreen extends StatelessWidget {
  const IssueHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: const BoxDecoration(color: Colors.white),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context, true),
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
                          'Issue History',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'All issues you have reported',
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
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _summaryStrip(),
                  const SizedBox(height: 16),
                  Text(
                    'Recent Issues',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...seedIssues()
                      .where((i) => i.tenantName == 'Aarav Sharma')
                      .map(
                        (issue) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _TenantIssueCard(
                            issue: issue,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => IssueDetailsScreen(
                                  issue: issue,
                                  role: UserRole.tenant,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryStrip() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _summaryItem('1', 'Open'),
          _summaryDivider(),
          _summaryItem('0', 'In Progress'),
          _summaryDivider(),
          _summaryItem('1', 'Resolved'),
          _summaryDivider(),
          _summaryItem('0', 'Rejected'),
        ],
      ),
    );
  }

  Widget _summaryItem(String count, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            count,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryDivider() {
    return Container(
      width: 1,
      height: 30,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }
}
