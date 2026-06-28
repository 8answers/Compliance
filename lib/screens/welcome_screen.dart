import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/app_services.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/home_indicator.dart';
import 'dashboard_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  static const _designHeight = 844.0;
  static const _backgroundHeight = 585.0;
  static const _titleFontSize = 32.0;
  static const _bodyFontSize = 16.0;
  static const _buttonHeight = 56.0;
  static const _buttonRadius = 32.0;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  AuthService? _authService;
  StreamSubscription<bool>? _authSubscription;
  bool _isSigningIn = false;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final authService = AppServices.of(context).authService;
    if (_authService == authService) {
      return;
    }

    _authService = authService;
    _authSubscription?.cancel();
    _authSubscription = authService.signedInChanges.listen(
      (signedIn) {
        if (signedIn) {
          _openDashboard();
        } else if (mounted) {
          setState(() => _isSigningIn = false);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isSigningIn = false;
          _errorMessage = 'Google sign-in failed. Please try again.';
        });
      },
    );

    if (authService.hasSession) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openDashboard());
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    if (_isSigningIn) {
      return;
    }

    setState(() {
      _isSigningIn = true;
      _errorMessage = null;
    });

    try {
      await _authService!.signInWithGoogle();
      if (mounted) {
        setState(() => _isSigningIn = false);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSigningIn = false;
        _errorMessage = 'Google sign-in failed. Please try again.';
      });
    }
  }

  void _openDashboard() {
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const DashboardScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = designScale(context);
    final screenHeight = MediaQuery.sizeOf(context).height;
    final horizontalPadding = AppLayout.horizontalPadding * scale;
    final backgroundHeight =
        screenHeight *
        (WelcomeScreen._backgroundHeight / WelcomeScreen._designHeight);

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: backgroundHeight,
            child: SvgPicture.asset(
              'assets/images/welcome_background.svg',
              fit: BoxFit.fill,
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Text(
                    'Welcome',
                    style: GoogleFonts.borel(
                      fontSize: WelcomeScreen._titleFontSize * scale,
                      fontWeight: FontWeight.w400,
                      color: AppColors.white,
                      height: 0.9908,
                    ),
                  ),
                  SizedBox(height: 24 * scale),
                  Text(
                    'Upload your meal timetables and get an instant AI nutritional audit breakdown.',
                    style: GoogleFonts.nataSans(
                      fontSize: WelcomeScreen._bodyFontSize * scale,
                      fontWeight: FontWeight.w400,
                      color: AppColors.white,
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: 32 * scale),
                  _GoogleSignInButton(
                    scale: scale,
                    isLoading: _isSigningIn,
                    onTap: _isSigningIn ? null : _signInWithGoogle,
                  ),
                  if (_errorMessage != null) ...[
                    SizedBox(height: 12 * scale),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nataSans(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                        height: 1.35,
                      ),
                    ),
                  ],
                  SizedBox(height: 34 * scale),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: HomeIndicator(scale: scale),
          ),
        ],
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({
    required this.scale,
    required this.isLoading,
    required this.onTap,
  });

  final double scale;
  final bool isLoading;
  final VoidCallback? onTap;

  static const _buttonHeight = WelcomeScreen._buttonHeight;
  static const _buttonRadius = WelcomeScreen._buttonRadius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(_buttonRadius * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_buttonRadius * scale),
        child: SizedBox(
          height: _buttonHeight * scale,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/google_logo.svg',
                width: 24 * scale,
                height: 24 * scale,
              ),
              SizedBox(width: 16 * scale),
              if (isLoading)
                SizedBox(
                  width: 18 * scale,
                  height: 18 * scale,
                  child: CircularProgressIndicator(
                    strokeWidth: 2 * scale,
                    color: AppColors.black,
                  ),
                )
              else
                Text(
                  'Continue with Google',
                  style: GoogleFonts.nataSans(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                    height: 1.0,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
