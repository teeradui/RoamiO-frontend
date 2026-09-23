import 'package:flutter/material.dart';
import 'package:roamio_frontend/screens/authentication/animated_roamio_logo.dart';
import 'package:roamio_frontend/theme/colors.dart';

import 'register_screen.dart';
import 'sign_in_screen.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  bool _isSignIn = true;

  void _selectTab(bool isSignIn) {
    if (_isSignIn == isSignIn) return;

    setState(() {
      _isSignIn = isSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Logo
              _buildLogo(),

              const SizedBox(height: 20),

              // Welcome title
              Text(
                'Welcome to RoamiO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  _isSignIn
                      ? 'Sign in to start your journey with us'
                      : 'Create your account to begin your journey',
                  key: ValueKey(_isSignIn),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Tab selection
              _buildTabSelector(),

              const SizedBox(height: 12),

              // Form
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  final offsetAnimation =
                      Tween<Offset>(
                        begin: const Offset(0.15, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        ),
                      );

                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    ),
                  );
                },
                child: _isSignIn
                    ? const SignInScreen(key: ValueKey('sign-in'))
                    : RegisterScreen(
                        key: const ValueKey('sign-up'),
                        onRegistered: () {
                          _selectTab(true);
                        },
                      ),
              ),

              const SizedBox(height: 20),

              // Bottom switch text
              _buildBottomSwitch(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return const AnimatedRoamiOLogo(width: 145, height: 155);
  }

  Widget _buildTabSelector() {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.filterInactiveBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / 2;

          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: _isSignIn ? 0 : tabWidth,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.filterActiveBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: _buildTab(
                      title: 'Sign In',
                      selected: _isSignIn,
                      onTap: () => _selectTab(true),
                    ),
                  ),
                  Expanded(
                    child: _buildTab(
                      title: 'Sign Up',
                      selected: !_isSignIn,
                      onTap: () => _selectTab(false),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTab({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: selected
                ? AppColors.filterActiveText
                : AppColors.filterInactiveText,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          child: Text(title),
        ),
      ),
    );
  }

  Widget _buildBottomSwitch() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Row(
        key: ValueKey(_isSignIn),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isSignIn ? "Don't have an account?" : 'Already have an account?',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          TextButton(
            onPressed: () {
              _selectTab(!_isSignIn);
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.only(left: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              _isSignIn ? "Let's Sign up" : "Let's Sign in",
              style: TextStyle(
                color: AppColors.btnPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
