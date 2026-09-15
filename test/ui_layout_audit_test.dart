import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenant_flutter_application/models/move_out_model.dart';
import 'package:tenant_flutter_application/models/support_model.dart';
import 'package:tenant_flutter_application/screens/dashboard_screen.dart';
import 'package:tenant_flutter_application/screens/login_screen.dart';
import 'package:tenant_flutter_application/screens/move_out/move_out_request_detail_screen.dart';
import 'package:tenant_flutter_application/screens/move_out/move_out_request_screen.dart';
import 'package:tenant_flutter_application/screens/move_out/move_out_statement_screen.dart';
import 'package:tenant_flutter_application/screens/move_out/move_out_status_screen.dart';
import 'package:tenant_flutter_application/screens/notifications_screen.dart';
import 'package:tenant_flutter_application/screens/onboarding_screen.dart';
import 'package:tenant_flutter_application/screens/otp_verification_screen.dart';
import 'package:tenant_flutter_application/screens/payment/cash_payment_screen.dart';
import 'package:tenant_flutter_application/screens/payment/online_payment_screen.dart';
import 'package:tenant_flutter_application/screens/payment/rent_payment_screen.dart';
import 'package:tenant_flutter_application/screens/payment/rent_receipt_screen.dart';
import 'package:tenant_flutter_application/screens/splash_screen.dart';
import 'package:tenant_flutter_application/screens/support/announcement_details_screen.dart';
import 'package:tenant_flutter_application/screens/support/create_announcement_screen.dart';
import 'package:tenant_flutter_application/screens/support/issue_details_screen.dart';
import 'package:tenant_flutter_application/screens/support/maintenance_support_screen.dart';
import 'package:tenant_flutter_application/screens/support/report_issue_screen.dart';
import 'package:tenant_flutter_application/screens/tenant_profile_screen.dart';

const _sizes = [
  Size(360, 640),
  Size(390, 844),
  Size(430, 932),
];

void main() {
  Widget host(Widget home, {Map<String, WidgetBuilder> routes = const {}}) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: home,
      routes: routes,
    );
  }

  final released = MoveOutStore.instance.requests
      .firstWhere((r) => r.status == MoveOutStatus.released);
  final pending = MoveOutStore.instance.requests
      .firstWhere((r) => r.status == MoveOutStatus.pending);

  final cases = <String, Widget Function()>{
    'Splash': () => const SplashScreen(),
    'Login': () => const LoginScreen(),
    'Onboarding': () => const OnboardingScreen(),
    'OTP': () => const OtpVerificationScreen(email: 'aarav@gmail.com'),
    'Dashboard': () => const DashboardScreen(),
    'Notifications': () => const NotificationsScreen(),
    'Profile': () => const TenantProfileScreen(),
    'RentPayment': () => const RentPaymentScreen(),
    'Receipt': () => RentReceiptScreen(record: seedPaymentLedger().first),
    'CashPayment': () => CashPaymentScreen(baseRecord: seedPaymentLedger().last),
    'OnlinePayment': () => OnlinePaymentScreen(baseRecord: seedPaymentLedger().last),
    'MaintenanceSupport': () => const MaintenanceSupportScreen(),
    'ReportIssue': () => const ReportIssueScreen(),
    'IssueDetails': () => IssueDetailsScreen(
        issue: seedIssues().first, role: UserRole.tenant),
    'AnnouncementDetails': () => AnnouncementDetailsScreen(
        announcement: seedAnnouncements().first),
    'CreateAnnouncement': () =>
        const CreateAnnouncementScreen(role: UserRole.owner),
    'MoveOutRequest': () => const MoveOutRequestScreen(),
    'MoveOutStatusPending': () => MoveOutStatusScreen(request: pending),
    'MoveOutStatusReleased': () => MoveOutStatusScreen(request: released),
    'MoveOutStatement': () => MoveOutStatementScreen(request: released),
    'MoveOutOwnerDetail': () => MoveOutRequestDetailScreen(request: pending),
    'IssueHistory': () => const IssueHistoryScreen(),
  };

  for (final entry in cases.entries) {
    for (final size in _sizes) {
      testWidgets('Layout: ${entry.key} @ ${size.width.toInt()}x${size.height.toInt()}',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final needsRoutes = entry.key == 'Splash';
        await tester.pumpWidget(
          needsRoutes
              ? host(entry.value(), routes: {
                  '/onboarding': (_) => const OnboardingScreen(),
                  '/login': (_) => const LoginScreen(),
                  '/dashboard': (_) => const DashboardScreen(),
                })
              : host(entry.value()),
        );
        await tester.pump(const Duration(milliseconds: 120));
        if (entry.key == 'MaintenanceSupport') {
          await tester.pump(const Duration(seconds: 1));
          await tester.pumpAndSettle();
        }
        if (entry.key == 'Splash') {
          await tester.pump(const Duration(seconds: 4));
          await tester.pumpAndSettle();
        }
      });
    }
  }
}