import 'package:flutter/material.dart';
import 'package:roamio_frontend/screens/authentication/authentication_screen.dart';
import 'package:roamio_frontend/screens/createTrip/create_screen.dart';
import 'package:roamio_frontend/screens/friends/friend_screen.dart';
import 'package:roamio_frontend/screens/leaderborad/leaderboard_screen.dart';
import 'package:roamio_frontend/screens/profile/profile_screen.dart';
import 'package:roamio_frontend/screens/home/home_screen.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:roamio_frontend/screens/authentication/animated_roamio_logo.dart';
import 'package:roamio_frontend/widgets/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roamio_frontend/widgets/bottom_nav_bar.dart';

void main() {
  runApp(const RoamiOApp());
}

class RoamiOApp extends StatelessWidget {
  const RoamiOApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RoamiO',
      home: const SplashScreen(),
      routes: {'/home': (context) => const MyHomePage(title: 'RoamiO')},
    );
  }
}

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _play();
  }

  Future<void> _play() async {
    await _controller.forward();

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();

    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    final nextScreen = isLoggedIn
        ? const MyHomePage(title: 'RoamiO')
        : const AuthenticationScreen();

    await Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => nextScreen,
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _opacity,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AnimatedRoamiOLogo(width: 145, height: 155),

                    const SizedBox(height: 8),

                    const Text(
                      'RoamiO',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'Your journey, together.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final tabs = [
    HomeScreen(),
    LeaderboardScreen(),
    CreateTripScreen(),
    FriendScreen(),
    ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tabs[_currentIndex],
      bottomNavigationBar: RoamiOBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
