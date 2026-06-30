import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/saved_nutritional_audit.dart';
import '../services/app_services.dart';
import '../services/inspection_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/app_svg.dart';
import '../widgets/home_indicator.dart';
import 'account_screen.dart';
import 'new_inspection_screen.dart';
import 'nutritional_audit_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static const _headerHeight = 64.0;
  static const _searchHeight = 48.0;
  static const _buttonHeight = 56.0;
  static const _buttonRadius = 32.0;
  static const _navBarWidth = 172.0;
  static const _fabHeight = 64.0;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  InspectionRepository? _inspectionRepository;
  Future<List<SavedNutritionalAudit>>? _auditsFuture;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final repository = AppServices.of(context).inspectionRepository;
    if (_inspectionRepository == repository) {
      return;
    }

    _inspectionRepository = repository;
    _loadAudits();
  }

  void _loadAudits() {
    setState(() {
      _auditsFuture = _inspectionRepository!.fetchSavedAudits();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = designScale(context);
    final horizontalPadding = AppLayout.horizontalPadding * scale;

    Future<void> openNewInspection() async {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const NewInspectionScreen()),
      );
      if (mounted) {
        _loadAudits();
      }
    }

    void openAccount() {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const AccountScreen()));
    }

    return Scaffold(
      backgroundColor: AppColors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: DashboardScreen._headerHeight * scale,
                    width: double.infinity,
                    child: AppSvg(
                      asset: 'assets/images/header_logo.svg',
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                    child: _SearchBar(
                      scale: scale,
                      controller: _searchController,
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                    ),
                  ),
                  SizedBox(height: 16 * scale),
                  Padding(
                    padding: EdgeInsets.only(left: 24 * scale),
                    child: Text(
                      'Recent',
                      style: GoogleFonts.nataSans(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w500,
                        color: AppColors.recentLabel,
                        height: 1.0,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _RecentAudits(
                      scale: scale,
                      auditsFuture: _auditsFuture,
                      searchQuery: _searchQuery,
                      onOpenAudit: (audit) async {
                        final deleted = await Navigator.of(context).push<bool>(
                          MaterialPageRoute<bool>(
                            builder: (_) => NutritionalAuditScreen(
                              report: audit.report,
                              savedAuditId: audit.id,
                            ),
                          ),
                        );
                        if (deleted == true && mounted) {
                          _loadAudits();
                        }
                      },
                      onCreateAudit: openNewInspection,
                    ),
                  ),
                  SizedBox(height: 96 * scale),
                ],
              ),
              Positioned(
                left: horizontalPadding,
                right: horizontalPadding,
                bottom: 34 * scale,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _BottomNavBar(scale: scale, onProfileTap: openAccount),
                    _FabButton(scale: scale, onTap: openNewInspection),
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
      ),
    );
  }
}

class _RecentAudits extends StatelessWidget {
  const _RecentAudits({
    required this.scale,
    required this.auditsFuture,
    required this.searchQuery,
    required this.onOpenAudit,
    required this.onCreateAudit,
  });

  final double scale;
  final Future<List<SavedNutritionalAudit>>? auditsFuture;
  final String searchQuery;
  final ValueChanged<SavedNutritionalAudit> onOpenAudit;
  final VoidCallback onCreateAudit;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SavedNutritionalAudit>>(
      future: auditsFuture,
      builder: (context, snapshot) {
        final audits = snapshot.data ?? const <SavedNutritionalAudit>[];
        final normalizedQuery = searchQuery.trim();
        final visibleAudits = normalizedQuery.isEmpty
            ? audits
            : audits
                  .where(
                    (audit) =>
                        audit.auditNumber.toString().contains(normalizedQuery),
                  )
                  .toList();

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.green),
          );
        }

        if (audits.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                child: Text(
                  'No audits available',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nataSans(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w500,
                    color: AppColors.white,
                    height: 1.0,
                  ),
                ),
              ),
              SizedBox(height: 16 * scale),
              _NewAuditButton(scale: scale, onTap: onCreateAudit),
            ],
          );
        }

        if (visibleAudits.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16 * scale),
              child: Text(
                'No matching audits found',
                textAlign: TextAlign.center,
                style: GoogleFonts.nataSans(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white,
                  height: 1.0,
                ),
              ),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.fromLTRB(24 * scale, 24 * scale, 24 * scale, 0),
          itemCount: visibleAudits.length,
          separatorBuilder: (_, _) => SizedBox(height: 16 * scale),
          itemBuilder: (context, index) {
            final audit = visibleAudits[index];
            return _AuditCard(
              scale: scale,
              audit: audit,
              onTap: () => onOpenAudit(audit),
            );
          },
        );
      },
    );
  }
}

class _AuditCard extends StatelessWidget {
  const _AuditCard({
    required this.scale,
    required this.audit,
    required this.onTap,
  });

  final double scale;
  final SavedNutritionalAudit audit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final grade = audit.report.grade;
    final gradeColor = NutritionalAuditScreen.gradeColor(grade);

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16 * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16 * scale),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16 * scale,
            vertical: 8 * scale,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Nutritional Audit',
                      style: GoogleFonts.nataSans(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w700,
                        color: AppColors.green,
                        height: 1.0,
                      ),
                    ),
                  ),
                  Text(
                    audit.auditNumber.toString(),
                    style: GoogleFonts.nataSans(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.green,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18 * scale),
              Text(
                'Grade: $grade',
                style: GoogleFonts.nataSans(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w700,
                  color: gradeColor,
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

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.scale,
    required this.controller,
    required this.onChanged,
  });

  final double scale;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  static const _searchHeight = DashboardScreen._searchHeight;
  static const _buttonRadius = DashboardScreen._buttonRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _searchHeight * scale,
      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
      decoration: BoxDecoration(
        color: AppColors.searchBackground,
        borderRadius: BorderRadius.circular(_buttonRadius * scale),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.search,
              cursorColor: AppColors.green,
              style: GoogleFonts.nataSans(
                fontSize: 16 * scale,
                fontWeight: FontWeight.w500,
                color: AppColors.white,
                height: 1.0,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: 'Search audit number',
                hintStyle: GoogleFonts.nataSans(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w500,
                  color: AppColors.searchPlaceholder,
                  height: 1.0,
                ),
              ),
            ),
          ),
          AppSvg(
            asset: 'assets/images/search_icon.svg',
            width: 24 * scale,
            height: 24 * scale,
          ),
        ],
      ),
    );
  }
}

class _NewAuditButton extends StatelessWidget {
  const _NewAuditButton({required this.scale, required this.onTap});

  final double scale;
  final VoidCallback onTap;

  static const _buttonHeight = DashboardScreen._buttonHeight;
  static const _buttonRadius = DashboardScreen._buttonRadius;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final buttonWidth = (342 * scale).clamp(0.0, screenWidth - (48 * scale));

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(_buttonRadius * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_buttonRadius * scale),
        child: SizedBox(
          height: _buttonHeight * scale,
          width: buttonWidth,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * scale),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'New Nutritional Audit',
                    style: GoogleFonts.nataSans(
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.green,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(width: 18 * scale),
                  AppSvg(
                    asset: 'assets/images/plus_icon.svg',
                    width: 20 * scale,
                    height: 20 * scale,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.scale, required this.onProfileTap});

  final double scale;
  final VoidCallback onProfileTap;

  static const _navBarWidth = DashboardScreen._navBarWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _navBarWidth * scale,
      padding: EdgeInsets.all(8 * scale),
      decoration: BoxDecoration(
        color: AppColors.navBackground,
        borderRadius: BorderRadius.circular(32 * scale),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppSvg(
            asset: 'assets/images/nav_home.svg',
            width: 71 * scale,
            height: 48 * scale,
          ),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24 * scale),
            child: InkWell(
              key: const Key('dashboard_profile_nav'),
              onTap: onProfileTap,
              borderRadius: BorderRadius.circular(24 * scale),
              child: AppSvg(
                asset: 'assets/images/nav_profile.svg',
                width: 71 * scale,
                height: 48 * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FabButton extends StatelessWidget {
  const _FabButton({required this.scale, required this.onTap});

  final double scale;
  final VoidCallback onTap;

  static const _fabHeight = DashboardScreen._fabHeight;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.navBackground,
      borderRadius: BorderRadius.circular(32 * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32 * scale),
        child: Container(
          height: _fabHeight * scale,
          padding: EdgeInsets.all(8 * scale),
          child: AppSvg(
            asset: 'assets/images/fab_plus.svg',
            width: 71 * scale,
            height: 48 * scale,
          ),
        ),
      ),
    );
  }
}
