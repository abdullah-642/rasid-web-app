import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme.dart';

import 'screens/auth.dart';
import 'screens/shell.dart';
import 'screens/home.dart';
import 'screens/personal.dart';
import 'screens/tasks.dart';
import 'screens/profile.dart';
import 'screens/business.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://tosgyerejbeihgflrqbn.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRvc2d5ZXJlamJlaWhnZmxycWJuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk1ODQ0MjEsImV4cCI6MjA4NTE2MDQyMX0.eyQkJsuUcXJgpd-o0y0TSqWw1vFRbx12nz3jN6aGK6s',
  );

  // Rased App Entry Point - v1.0.2
  runApp(const ProviderScope(child: RasedApp()));
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    ShellRoute(
      builder: (context, state, child) {
        return ShellScreen(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const DashboardScreen(),
            transitionsBuilder: _fadeTransition,
          ),
        ),
        GoRoute(
          path: '/personal',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const PersonalFinanceScreen(),
            transitionsBuilder: _fadeTransition,
          ),
        ),
        GoRoute(
          path: '/tasks',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const TasksScreen(),
            transitionsBuilder: _fadeTransition,
          ),
        ),

        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const ProfileScreen(),
            transitionsBuilder: _fadeTransition,
          ),
        ),
        GoRoute(
          path: '/business',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const BusinessScreen(),
            transitionsBuilder: _fadeTransition,
          ),
        ),
      ],
    ),
  ],
  redirect: (context, state) {
    bool isAuth = Supabase.instance.client.auth.currentUser != null;
    if (!isAuth && state.uri.toString() != '/login') {
      return '/login';
    }
    if (isAuth && state.uri.toString() == '/login') {
      return '/';
    }
    return null;
  },
);

// Fast fade transition
Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
    child: child,
  );
}

class RasedApp extends ConsumerWidget {
  const RasedApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We strictly IGNORE the system theme and user preferences for now
    // to enforce the Premium Dark Mode globally.

    return MaterialApp.router(
      title: 'Rased - راصد',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,

      // ☀️ FORCE LIGHT THEME (Clean Design)
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme, // Force light even in dark mode
      themeMode: ThemeMode.light,

      scrollBehavior: CustomScrollBehavior(),

      // 🌍 Localization
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

// Custom ScrollBehavior to enable mouse wheel scrolling on web and desktop
class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
  };
}
