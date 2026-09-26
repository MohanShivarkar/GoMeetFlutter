import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ── Core & shell screens ──
import '../../features/shell/screens/not_found_screen.dart';
import '../../presentation/screens/pwa/core_pwa_home_screen.dart';

// ── Auth screens (p2-auth-email-google) ──
import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/auth/screens/sign_up_screen.dart';
// import '../../features/profile/screens/profile_creation_screen.dart';
// import '../../features/discover/screens/discover_screen.dart';
// import '../../features/chat/screens/chat_list_screen.dart';
// import '../../features/chat/screens/chat_thread_screen.dart';
// import '../../features/profile/screens/profile_view_screen.dart';
// import '../../features/settings/screens/settings_screen.dart';

// ── Stub screens (delete each stub once its real import above is uncommented) ──

// _StubSignInScreen and _StubSignUpScreen removed — real screens wired (p2-auth-email-google).

class _StubProfileCreateScreen extends StatelessWidget {
  const _StubProfileCreateScreen();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Create Profile')));
}

class _StubDiscoverScreen extends StatelessWidget {
  const _StubDiscoverScreen();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Discover')));
}

class _StubChatListScreen extends StatelessWidget {
  const _StubChatListScreen();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Chat List')));
}

class _StubChatThreadScreen extends StatelessWidget {
  final String conversationId;
  const _StubChatThreadScreen({required this.conversationId});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('Chat: $conversationId')));
}

class _StubProfileViewScreen extends StatelessWidget {
  final String userId;
  const _StubProfileViewScreen({required this.userId});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('Profile: $userId')));
}

class _StubSettingsScreen extends StatelessWidget {
  const _StubSettingsScreen();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Settings')));
}

// ── Router ──

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  errorBuilder: (context, state) => const NotFoundScreen(),
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const CorePwaHomeScreen(),
    ),
    GoRoute(
      path: '/sign-in',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/sign-up',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/profile/create',
      builder: (context, state) => const _StubProfileCreateScreen(),
    ),
    GoRoute(
      path: '/discover',
      builder: (context, state) => const _StubDiscoverScreen(),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) => const _StubChatListScreen(),
      routes: [
        GoRoute(
          path: ':conversationId',
          builder: (context, state) => _StubChatThreadScreen(
            conversationId: state.pathParameters['conversationId']!,
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/profile/:userId',
      builder: (context, state) => _StubProfileViewScreen(
        userId: state.pathParameters['userId']!,
      ),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const _StubSettingsScreen(),
    ),
  ],
);
