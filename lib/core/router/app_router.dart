import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/country_select/country_select_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/game/map_game_screen.dart';
import '../../presentation/screens/policy/policy_screen.dart';
import '../../presentation/screens/event/event_screen.dart';
import '../../presentation/screens/game_over/game_over_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/select', builder: (_, __) => const CountrySelectScreen()),
      GoRoute(path: '/dashboard', builder: (_, __) => const MapGameScreen()),
      GoRoute(path: '/dashboard/classic', builder: (_, __) => const DashboardScreen()),
      GoRoute(path: '/policies', builder: (_, __) => const PolicyScreen()),
      GoRoute(path: '/event', builder: (_, __) => const EventScreen()),
      GoRoute(path: '/gameover', builder: (_, __) => const GameOverScreen()),
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
