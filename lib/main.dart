import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/home_screen.dart';
import 'services/app_services.dart';
import 'services/auth_service.dart';
import 'services/inspection_repository.dart';
import 'services/menu_file_picker.dart';
import 'services/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const ComplianceApp());
}

class ComplianceApp extends StatelessWidget {
  const ComplianceApp({
    super.key,
    this.authService = const SupabaseAuthService(),
    this.inspectionRepository = const SupabaseInspectionRepository(),
    this.menuFilePicker = const NativeMenuFilePicker(),
  });

  final AuthService authService;
  final InspectionRepository inspectionRepository;
  final MenuFilePicker menuFilePicker;

  @override
  Widget build(BuildContext context) {
    return AppServices(
      authService: authService,
      inspectionRepository: inspectionRepository,
      menuFilePicker: menuFilePicker,
      child: MaterialApp(
        title: 'Compliance',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
