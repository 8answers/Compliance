import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/app_services.dart';
import '../theme/app_theme.dart';
import '../widgets/home_indicator.dart';
import 'home_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _isDeleting = false;
  String? _errorMessage;

  Future<void> _confirmDeleteAccount() async {
    if (_isDeleting) {
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.black,
          title: Text(
            'Delete account?',
            style: GoogleFonts.nataSans(
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          content: Text(
            'This will permanently delete your account and all saved audit reports.',
            style: GoogleFonts.nataSans(color: AppColors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.nataSans(color: AppColors.white),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Delete',
                style: GoogleFonts.nataSans(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFF0606),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _deleteAccount();
    }
  }

  Future<void> _deleteAccount() async {
    setState(() {
      _isDeleting = true;
      _errorMessage = null;
    });

    try {
      await AppServices.of(context).authService.deleteAccount();
      if (!mounted) {
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isDeleting = false;
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = designScale(context);

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 8 * scale),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Account',
                        style: GoogleFonts.nataSans(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                          height: 1.0,
                        ),
                      ),
                      Material(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(32 * scale),
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(32 * scale),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16 * scale,
                              vertical: 8 * scale,
                            ),
                            child: Text(
                              'Close',
                              style: GoogleFonts.nataSans(
                                fontSize: 16 * scale,
                                fontWeight: FontWeight.w500,
                                color: AppColors.white,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Material(
                    color: const Color(0xFFFF0606),
                    borderRadius: BorderRadius.circular(32 * scale),
                    child: InkWell(
                      onTap: _isDeleting ? null : _confirmDeleteAccount,
                      borderRadius: BorderRadius.circular(32 * scale),
                      child: SizedBox(
                        height: 56 * scale,
                        child: Center(
                          child: _isDeleting
                              ? SizedBox(
                                  width: 22 * scale,
                                  height: 22 * scale,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.white,
                                  ),
                                )
                              : Text(
                                  'Delete Account',
                                  style: GoogleFonts.nataSans(
                                    fontSize: 20 * scale,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.white,
                                    height: 1.0,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    SizedBox(height: 12 * scale),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nataSans(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFF0606),
                        height: 1.25,
                      ),
                    ),
                  ],
                  SizedBox(height: 96 * scale),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: HomeIndicator(scale: scale),
            ),
          ],
        ),
      ),
    );
  }
}
