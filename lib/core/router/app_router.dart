import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/mock_data_service.dart';

// Feature page imports
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/user_dashboard/presentation/pages/user_dashboard_page.dart';
import '../../features/user_dashboard/presentation/pages/my_cvs_page.dart';
import '../../features/user_dashboard/presentation/pages/create_cv_page.dart';
import '../../features/user_dashboard/presentation/pages/cv_detail_page.dart';
import '../../features/developer_dashboard/presentation/pages/developer_dashboard_page.dart';
import '../../features/developer_dashboard/presentation/pages/assigned_works_page.dart';
import '../../features/developer_dashboard/presentation/pages/work_detail_page.dart';
import '../../features/developer_dashboard/presentation/pages/cv_submission_page.dart';
import '../../features/admin_dashboard/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin_dashboard/presentation/pages/user_management_page.dart';
import '../../features/admin_dashboard/presentation/pages/cv_request_management_page.dart';
import '../../features/admin_dashboard/presentation/pages/developer_management_page.dart';
import '../../features/admin_dashboard/presentation/pages/work_assignment_page.dart';
import '../../features/admin_dashboard/presentation/pages/cv_review_page.dart';
import '../../features/portfolio/presentation/pages/portfolios_page.dart';
import '../../features/portfolio/presentation/pages/create_portfolio_page.dart';
import '../../features/position_search/presentation/pages/position_search_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/user_dashboard/presentation/pages/user_shell.dart';
import '../../features/developer_dashboard/presentation/pages/developer_shell.dart';
import '../../features/admin_dashboard/presentation/pages/admin_shell.dart';

// Shell keys
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _userShellKey = GlobalKey<NavigatorState>();
final _devShellKey = GlobalKey<NavigatorState>();
final _adminShellKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(currentUserProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: user == null ? '/login' : _initialRouteForRole(user.role),
    redirect: (context, state) {
      final isLoggedIn = user != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return _initialRouteForRole(user.role);

      // Role-based route guards
      if (isLoggedIn) {
        final role = user.role;
        final path = state.matchedLocation;

        if (path.startsWith('/admin') && role != 'admin') {
          return _initialRouteForRole(role);
        }
        if (path.startsWith('/developer') && role != 'developer') {
          return _initialRouteForRole(role);
        }
        if (path.startsWith('/dashboard') && role != 'user') {
          return _initialRouteForRole(role);
        }
      }

      return null;
    },
    routes: [
      // ──── AUTH ROUTES ────
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // ──── USER DASHBOARD SHELL ────
      ShellRoute(
        navigatorKey: _userShellKey,
        builder: (context, state, child) => UserShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const UserDashboardPage(),
          ),
          GoRoute(
            path: '/dashboard/my-cvs',
            builder: (context, state) => const MyCvsPage(),
          ),
          GoRoute(
            path: '/dashboard/create-cv',
            builder: (context, state) => const CreateCvPage(),
          ),
          GoRoute(
            path: '/dashboard/cv/:id',
            builder: (context, state) => CvDetailPage(
              cvId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/dashboard/portfolios',
            builder: (context, state) => const PortfoliosPage(),
          ),
          GoRoute(
            path: '/dashboard/portfolios/create',
            builder: (context, state) => const CreatePortfolioPage(),
          ),
          GoRoute(
            path: '/dashboard/search',
            builder: (context, state) => const PositionSearchPage(),
          ),
          GoRoute(
            path: '/dashboard/notifications',
            builder: (context, state) => const NotificationsPage(),
          ),
        ],
      ),

      // ──── DEVELOPER DASHBOARD SHELL ────
      ShellRoute(
        navigatorKey: _devShellKey,
        builder: (context, state, child) => DeveloperShell(child: child),
        routes: [
          GoRoute(
            path: '/developer',
            builder: (context, state) => const DeveloperDashboardPage(),
          ),
          GoRoute(
            path: '/developer/assigned-works',
            builder: (context, state) => const AssignedWorksPage(),
          ),
          GoRoute(
            path: '/developer/work/:id',
            builder: (context, state) => WorkDetailPage(
              assignmentId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/developer/submit/:id',
            builder: (context, state) => CvSubmissionPage(
              assignmentId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/developer/notifications',
            builder: (context, state) => const NotificationsPage(),
          ),
        ],
      ),

      // ──── ADMIN DASHBOARD SHELL ────
      ShellRoute(
        navigatorKey: _adminShellKey,
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminDashboardPage(),
          ),
          GoRoute(
            path: '/admin/users',
            builder: (context, state) => const UserManagementPage(),
          ),
          GoRoute(
            path: '/admin/cv-requests',
            builder: (context, state) => const CvRequestManagementPage(),
          ),
          GoRoute(
            path: '/admin/developers',
            builder: (context, state) => const DeveloperManagementPage(),
          ),
          GoRoute(
            path: '/admin/assign-work',
            builder: (context, state) => const WorkAssignmentPage(),
          ),
          GoRoute(
            path: '/admin/review',
            builder: (context, state) => const CvReviewPage(),
          ),
          GoRoute(
            path: '/admin/notifications',
            builder: (context, state) => const NotificationsPage(),
          ),
        ],
      ),
    ],
  );
});

String _initialRouteForRole(String role) {
  switch (role) {
    case 'admin':
      return '/admin';
    case 'developer':
      return '/developer';
    default:
      return '/dashboard';
  }
}

