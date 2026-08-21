import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/idea_check/presentation/idea_input_screen.dart';
import '../../features/idea_check/presentation/analysis_result_screen.dart';
import '../../features/idea_check/presentation/idea_history_screen.dart';
import '../../features/market_gap/presentation/market_gap_screen.dart';
import '../../features/market_gap/presentation/gap_result_screen.dart';
import '../../features/ai_chat/presentation/chat_screen.dart';
import '../../features/product_photo/presentation/photo_editor_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }
      if (isLoggedIn && isAuthRoute) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/idea-check',
        name: 'ideaCheck',
        builder: (context, state) => const IdeaInputScreen(),
      ),
      GoRoute(
        path: '/idea-check/result/:id',
        name: 'ideaResult',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AnalysisResultScreen(analysisId: id);
        },
      ),
      GoRoute(
        path: '/idea-check/history',
        name: 'ideaHistory',
        builder: (context, state) => const IdeaHistoryScreen(),
      ),
      GoRoute(
        path: '/market-gap',
        name: 'marketGap',
        builder: (context, state) => const MarketGapScreen(),
      ),
      GoRoute(
        path: '/market-gap/result/:id',
        name: 'gapResult',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return GapResultScreen(scanId: id);
        },
      ),
      GoRoute(
        path: '/ai-chat',
        name: 'aiChat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/product-photo',
        name: 'productPhoto',
        builder: (context, state) => const PhotoEditorScreen(),
      ),
    ],
  );
}
