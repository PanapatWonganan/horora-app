import 'package:flutter/material.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/guest_session_service.dart';
import '../welcome/welcome_screen.dart';
import '../home/home_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _authService = AuthService.instance;
  final _guestSession = GuestSessionService.instance;
  bool _isLoading = true;
  bool _isAuthenticated = false;
  // guest ที่ทำ onboarding เสร็จแล้ว → ให้เข้า Home ได้โดยไม่ต้อง login
  bool _onboardingCompleted = false;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      // คง behavior เดิม: validate token ของ user จริง
      final isLoggedIn = await _authService.isLoggedIn();
      // guest-first: เช็คว่า onboarding เสร็จแล้วหรือยัง
      final onboardingCompleted = await _guestSession.isOnboardingCompleted();
      if (mounted) {
        setState(() {
          _isAuthenticated = isLoggedIn;
          _onboardingCompleted = onboardingCompleted;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _onboardingCompleted = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // logged-in หรือ guest ที่ onboarding เสร็จแล้ว → Home
    if (_isAuthenticated || _onboardingCompleted) {
      return const HomeScreen();
    } else {
      return const WelcomeScreen();
    }
  }
}
