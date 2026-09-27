import 'dart:convert';

import 'package:dating/data/localdatabase.dart';
import 'package:dating/presentation/screens/BottomNavBar/home_screen.dart';
import 'package:dating/presentation/screens/splash_bording/auth_screen.dart';
import 'package:dating/presentation/screens/splash_bording/onbording_screens.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class CorePwaHomeScreen extends StatefulWidget {
  const CorePwaHomeScreen({super.key});

  static const String routeName = "/corePwaHome";

  @override
  State<CorePwaHomeScreen> createState() => _CorePwaHomeScreenState();
}

class _CorePwaHomeScreenState extends State<CorePwaHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _redirect();
    });
  }

  Future<Map<String, dynamic>?> _loadSession() async {
    final raw = await Preferences.fetchUserDetails();
    if (raw.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return null;
  }

  Future<void> _redirect() async {
    final session = await _loadSession();
    if (!mounted) {
      return;
    }

    if (session != null) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        HomeScreen.homeScrennRoute,
        (route) => false,
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final bool onBording = prefs.getBool("Onbording") ?? true;
    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      onBording ? OnBoardingScreen.onBoardingScreenRoute : AuthScreen.authScreenRoute,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: const Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  "Loading your home experience...",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
