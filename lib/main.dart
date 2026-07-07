import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'services/notification_service.dart';
import 'providers/auth_provider.dart';
import 'providers/routine_provider.dart';
import 'providers/product_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/article_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Notification Service
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAutoLogin()),
        ChangeNotifierProvider(create: (_) => RoutineProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ArticleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Le Soie App',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const MainScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    // Wait for the next frame so context is fully available
    await Future.delayed(Duration.zero);
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    
    // If the provider is still loading, wait or check
    if (authProvider.isLoading) {
      authProvider.addListener(_onAuthStatusChanged);
    } else {
      _navigate(authProvider.isLoggedIn);
    }
  }

  void _onAuthStatusChanged() {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoading) {
      authProvider.removeListener(_onAuthStatusChanged);
      _navigate(authProvider.isLoggedIn);
    }
  }

  void _navigate(bool isLoggedIn) {
    if (mounted) {
      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFAF7F2),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2D4A3E),
        ),
      ),
    );
  }
}
