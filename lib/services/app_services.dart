import 'package:flutter/widgets.dart';

import 'auth_service.dart';
import 'inspection_repository.dart';
import 'menu_file_picker.dart';
import 'nutritional_audit_service.dart';

class AppServices extends InheritedWidget {
  const AppServices({
    super.key,
    required this.authService,
    required this.inspectionRepository,
    required this.nutritionalAuditService,
    required this.menuFilePicker,
    required super.child,
  });

  final AuthService authService;
  final InspectionRepository inspectionRepository;
  final NutritionalAuditService nutritionalAuditService;
  final MenuFilePicker menuFilePicker;

  static AppServices of(BuildContext context) {
    final services = context.dependOnInheritedWidgetOfExactType<AppServices>();
    assert(services != null, 'AppServices was not found in the widget tree.');
    return services!;
  }

  @override
  bool updateShouldNotify(AppServices oldWidget) {
    return authService != oldWidget.authService ||
        inspectionRepository != oldWidget.inspectionRepository ||
        nutritionalAuditService != oldWidget.nutritionalAuditService ||
        menuFilePicker != oldWidget.menuFilePicker;
  }
}
