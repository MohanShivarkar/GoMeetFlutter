import 'dart:ui';
import 'package:dating/Logic/cubits/auth_cubit/auth_cubit.dart';
import 'package:dating/Logic/cubits/auth_cubit/auth_state.dart';
import 'package:dating/core/ui.dart';
import 'package:dating/presentation/screens/splash_bording/creat_steps.dart';
import 'package:dating/presentation/screens/auth/login_screen.dart';
import 'package:dating/presentation/screens/splash_bording/onBordingProvider/onbording_provider.dart';
import 'package:dating/presentation/screens/BottomNavBar/home_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../Logic/cubits/onBording_cubit/onbording_cubit.dart';
import '../../../language/localization/app_localization.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  static const String authScreenRoute = "/authScreen";
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late OnBordingProvider onBordingProvider;
  late OnbordingCubit onbordingCubit;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<OnbordingCubit>(context).smstypeapi(context);
  }

  @override
  Widget build(BuildContext context) {
    onBordingProvider = Provider.of<OnBordingProvider>(context);
    onbordingCubit = Provider.of<OnbordingCubit>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D14),
      body: Stack(
        children: [
          // Background Hero: Option 3 Beach Romance
          Positioned.fill(
            child: Image.asset(
              'assets/Image/auth_option3.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          // Top Vignette Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 180,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xE60B0D14), // rgba(11, 13, 20, 0.90)
                    Color(0x8C0B0D14), // rgba(11, 13, 20, 0.55)
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Bottom Vignette Overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 280,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0xFF0B0D14), // solid bottom
                    Color(0xE00B0D14), // rgba(11, 13, 20, 0.88)
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Foreground Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),

                  // Option 3: Frosted Floating Pill Lockup
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xA60E1118), // rgba(14, 17, 24, 0.65)
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.14),
                            width: 1,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x73000000),
                              blurRadius: 28,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(13),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x66FF4458),
                                    blurRadius: 14,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: Image.asset(
                                  "assets/Image/lovecloud_badge.png",
                                  width: 42,
                                  height: 42,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RichText(
                                  text: const TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Love",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: -0.4,
                                          fontFamily: 'Satoshi-Bold',
                                        ),
                                      ),
                                      TextSpan(
                                        text: "Cloud",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFFFF4B6E), // Sunset coral
                                          letterSpacing: -0.4,
                                          fontFamily: 'Satoshi-Bold',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  "INFINITE MATCH",
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withOpacity(0.65),
                                    letterSpacing: 2.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Bottom Prompt
                  Text(
                    AppLocalizations.of(context)?.translate("Let's dive in into your account!") ?? "Let's dive in into your account!",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Color(0x80000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Option 3 Pill CTA Button
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF4B6E), Color(0xFFFF6584)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x59FF4B6E),
                          blurRadius: 24,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () {
                          onBordingProvider.updatestepsCount(0);
                          Navigator.pushNamed(context, CreatSteps.creatStepsRoute);
                        },
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)?.translate("Continue with Email/Mobile Number") ?? "Continue with Email/Mobile Number",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Login Link
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, LoginScreen.loginRoute);
                    },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: AppLocalizations.of(context)?.translate("I have an account? ") ?? "I have an account? ",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 13,
                            ),
                          ),
                          const TextSpan(
                            text: "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Auth State Consumer (Handles loading & routing)
          BlocConsumer<AuthCubit, AuthStates>(
            listener: (context, state) {
              if (state is AuthErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage)));
              }

              if (state is AuthLoggedInState) {
                Navigator.pushNamed(context, CreatSteps.creatStepsRoute);
                onBordingProvider.setDataInFildes(state.firebaseuser);
              }

              if (state is AuthUserHomeState) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  HomeScreen.homeScrennRoute,
                  (route) => false,
                );
              }
            },
            builder: (context, state) {
              if (state is AuthLoading) {
                return Center(child: CircularProgressIndicator(color: AppColors.appColor));
              } else {
                return const SizedBox();
              }
            },
          ),
        ],
      ),
    );
  }
}
