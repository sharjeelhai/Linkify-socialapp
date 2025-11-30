import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// ignore: always_use_package_imports
import '../features/auth/providers/auth_provider.dart';
// ignore: always_use_package_imports
import '../features/splash/splash_screen.dart';
// ignore: always_use_package_imports
import '../features/auth/screens/login_screen.dart';
// ignore: always_use_package_imports
import '../features/auth/screens/signup_screen.dart';
// ignore: always_use_package_imports
import '../features/auth/screens/forgot_password_screen.dart';
// ignore: always_use_package_imports
import '../features/home/screens/home_screen.dart';
// ignore: always_use_package_imports
import '../features/profile/screens/profile_screen.dart';
import 'package:linkify/features/settings/screens/settings_screen.dart';
// ignore: always_use_package_imports
import '../features/main/main_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isInitializing = authState.isLoading;
      final isLoggedIn = authState.value != null;

      final isSplash = state.matchedLocation == '/splash';
      final isAuth = state.matchedLocation.startsWith('/auth');

      if (isInitializing && !isSplash) {
        return '/splash';
      }

      if (!isInitializing && isSplash) {
        return isLoggedIn ? '/home' : '/auth/login';
      }

      if (!isLoggedIn && !isAuth && !isSplash) {
        return '/auth/login';
      }

      if (isLoggedIn && isAuth) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/profile/:userId',
            builder: (context, state) {
              final userId = state.pathParameters['userId']!;
              return ProfileScreen(userId: userId);
            },
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
    ],
  );
});

class EditProfileScreen extends StatelessWidget {
  // ignore: use_super_parameters
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: const Center(child: Text('Edit Profile Screen')),
    );
  }
}
