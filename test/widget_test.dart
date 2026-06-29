import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

import 'package:compliance/main.dart';
import 'package:compliance/models/inspection_draft.dart';
import 'package:compliance/models/menu_file_selection.dart';
import 'package:compliance/services/auth_service.dart';
import 'package:compliance/services/inspection_repository.dart';
import 'package:compliance/services/menu_file_picker.dart';

ComplianceApp _testApp({
  _FakeAuthService? authService,
  _FakeInspectionRepository? inspectionRepository,
  _FakeMenuFilePicker? menuFilePicker,
}) {
  return ComplianceApp(
    authService: authService ?? _FakeAuthService(),
    inspectionRepository: inspectionRepository ?? _FakeInspectionRepository(),
    menuFilePicker: menuFilePicker ?? _FakeMenuFilePicker(),
  );
}

class _FakeAuthService implements AuthService {
  final _signedInController = StreamController<bool>.broadcast();
  bool _hasSession = false;

  @override
  String? get currentUserId => _hasSession ? 'test-user-id' : null;

  @override
  bool get hasSession => _hasSession;

  @override
  Stream<bool> get signedInChanges => _signedInController.stream;

  @override
  Future<void> signInWithGoogle() async {
    _hasSession = true;
    _signedInController.add(true);
  }
}

class _FakeInspectionRepository implements InspectionRepository {
  final savedDrafts = <InspectionDraft>[];

  @override
  Future<void> createInspection(InspectionDraft draft) async {
    savedDrafts.add(draft);
  }
}

class _FakeMenuFilePicker implements MenuFilePicker {
  @override
  Future<MenuFileSelection?> pickMenuFile() async {
    return const MenuFileSelection(
      name: 'image1020443.png',
      sizeBytes: 4 * 1024 * 1024,
    );
  }
}

Future<void> _openMenuUploadScreen(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Continue with Google'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('New Nutritional Audit'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Education'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('13–18 Years'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Vegetarian'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Breakfast'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('North India'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Home screen shows Compliance subtitle', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pump();

    expect(find.text('Compliance'), findsOneWidget);
  });

  testWidgets('Home screen navigates to Terms after 5 seconds', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pump();

    expect(find.text('Terms and Conditions'), findsNothing);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.text('Terms and Conditions'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('Terms Next button opens Welcome screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('Google sign in opens Dashboard screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    expect(find.text('Recent'), findsOneWidget);
    expect(find.text('No audits available'), findsOneWidget);
    expect(find.text('New Nutritional Audit'), findsOneWidget);
  });

  testWidgets('New audit actions open New Inspection screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('New Nutritional Audit'));
    await tester.pumpAndSettle();

    expect(find.text('New Inspection'), findsOneWidget);
    expect(find.text('Select Institution Type'), findsOneWidget);
    expect(find.text('Education'), findsOneWidget);
  });

  testWidgets('Institution Next opens age group screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('New Nutritional Audit'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Education'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Select Age Group(s)'), findsOneWidget);
    expect(find.text('You can select multiple groups'), findsOneWidget);
    expect(find.text('Step 2 of 6'), findsOneWidget);
  });

  testWidgets('Age group Next opens diet type screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('New Nutritional Audit'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Education'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('13–18 Years'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Select Diet Type'), findsOneWidget);
    expect(find.text('You can select multiple diet options'), findsOneWidget);
    expect(find.text('Vegetarian'), findsOneWidget);
    expect(find.text('Step 3 of 6'), findsOneWidget);
  });

  testWidgets('Diet type Next opens meals served screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('New Nutritional Audit'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Education'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('13–18 Years'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Vegetarian'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Select Meals Served'), findsOneWidget);
    expect(find.text('You can select multiple options'), findsOneWidget);
    expect(find.text('Breakfast'), findsOneWidget);
    expect(find.text('Step 4 of 6'), findsOneWidget);
  });

  testWidgets('Meals served Next opens region screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('New Nutritional Audit'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Education'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('13–18 Years'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Vegetarian'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Breakfast'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Select Region'), findsOneWidget);
    expect(find.text('North India'), findsOneWidget);
    expect(find.text('South India'), findsOneWidget);
    expect(find.text('North-East India'), findsOneWidget);
    expect(find.text('Step 5 of 6'), findsOneWidget);
  });

  testWidgets('Region Next opens menu upload screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('New Nutritional Audit'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Education'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('13–18 Years'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Vegetarian'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Breakfast'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('North India'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Upload or Enter Menu'), findsOneWidget);
    expect(find.text('Step 6 of 6'), findsOneWidget);
    expect(find.text('Upload File'), findsOneWidget);
    expect(find.text('Browse File'), findsOneWidget);
  });

  testWidgets(
    'Uploaded menu summary generates inspection and returns Dashboard',
    (WidgetTester tester) async {
      final inspectionRepository = _FakeInspectionRepository();
      final menuFilePicker = _FakeMenuFilePicker();

      await tester.pumpWidget(
        _testApp(
          inspectionRepository: inspectionRepository,
          menuFilePicker: menuFilePicker,
        ),
      );
      await _openMenuUploadScreen(tester);

      await tester.tap(find.text('Browse File'));
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Summary'), findsOneWidget);
      expect(find.text('Generate Audit'), findsOneWidget);
      expect(find.text('image1020443.png'), findsOneWidget);

      await tester.tap(find.text('Generate Audit'));
      await tester.pumpAndSettle();

      expect(inspectionRepository.savedDrafts, hasLength(1));
      expect(
        inspectionRepository.savedDrafts.single.institutionType,
        'Education',
      );
      expect(inspectionRepository.savedDrafts.single.ageGroups, [
        '13–18 Years',
      ]);
      expect(inspectionRepository.savedDrafts.single.dietTypes, ['Vegetarian']);
      expect(inspectionRepository.savedDrafts.single.mealsServed, [
        'Breakfast',
      ]);
      expect(inspectionRepository.savedDrafts.single.region, 'North India');
      expect(
        inspectionRepository.savedDrafts.single.menuEntryMethod,
        InspectionDraft.uploadFileMethod,
      );
      expect(
        inspectionRepository.savedDrafts.single.menuFileName,
        'image1020443.png',
      );
      expect(
        inspectionRepository.savedDrafts.single.menuFileSizeBytes,
        4 * 1024 * 1024,
      );
      expect(find.text('Recent'), findsOneWidget);
    },
  );

  testWidgets('Typed menu summary generates inspection and returns Dashboard', (
    WidgetTester tester,
  ) async {
    final inspectionRepository = _FakeInspectionRepository();

    await tester.pumpWidget(
      _testApp(inspectionRepository: inspectionRepository),
    );
    await _openMenuUploadScreen(tester);

    await tester.tap(find.text('Type Menu'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), 'M');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Summary'), findsOneWidget);
    expect(find.text('Generate Audit'), findsOneWidget);
    expect(find.text('M'), findsOneWidget);

    await tester.tap(find.text('Generate Audit'));
    await tester.pumpAndSettle();

    expect(inspectionRepository.savedDrafts, hasLength(1));
    expect(
      inspectionRepository.savedDrafts.single.menuEntryMethod,
      InspectionDraft.typedMenuMethod,
    );
    expect(inspectionRepository.savedDrafts.single.menuText, 'M');
    expect(find.text('Recent'), findsOneWidget);
  });
}
