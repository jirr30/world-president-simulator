import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/country_select/country_select_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/game/map_game_screen.dart';
import '../../presentation/screens/policy/policy_screen.dart';
import '../../presentation/screens/buildings/buildings_screen.dart';
import '../../presentation/screens/event/event_screen.dart';
import '../../presentation/screens/game_over/game_over_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (_, state) => _fadePage(state, const SplashScreen()),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (_, state) => _slidePage(state, const HomeScreen()),
      ),
      GoRoute(
        path: '/select',
        pageBuilder: (_, state) => _slidePage(state, const CountrySelectScreen()),
      ),
      GoRoute(
        path: '/dashboard',
        pageBuilder: (_, state) => _slidePage(state, const MapGameScreen()),
      ),
      GoRoute(
        path: '/dashboard/classic',
        pageBuilder: (_, state) => _slidePage(state, const DashboardScreen()),
      ),
      GoRoute(
        path: '/policies',
        pageBuilder: (_, state) => _slidePage(state, const PolicyScreen()),
      ),
      GoRoute(
        path: '/buildings',
        pageBuilder: (_, state) => _slidePage(state, const BuildingsScreen()),
      ),
      GoRoute(
        path: '/event',
        pageBuilder: (_, state) => _fadePage(state, const EventScreen()),
      ),
      GoRoute(
        path: '/gameover',
        pageBuilder: (_, state) => _fadePage(state, GameOverScreen(reason: state.extra as String?)),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF0A0E2A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🌍', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.uri.path}',
              style: const TextStyle(color: Colors.white70, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

CustomTransitionPage<void> _slidePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero)
          .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeIn);
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (context, animation, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
      child: child,
    ),
  );
}
