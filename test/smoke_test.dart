import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mototrack/app.dart';

Future<void> _signInAdmin(WidgetTester tester) async {
  await tester.pumpWidget(const MotoTrackApp());
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Admin: sign in → dashboard → Jobs → open job → tabs',
      (tester) async {
    await _signInAdmin(tester);

    // Admin dashboard loaded from the mock repo.
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('JOBS BY STATUS'), findsOneWidget);

    // Go to the Jobs list via bottom navigation.
    await tester.tap(find.text('Jobs'));
    await tester.pumpAndSettle();
    expect(find.text('All Jobs'), findsOneWidget);

    // Priority job MT-1042 sorts to the top; open it.
    expect(find.text('MT-1042'), findsWidgets);
    await tester.tap(find.text('MT-1042').first);
    await tester.pumpAndSettle();

    // Job detail with the three tabs.
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Workspace'), findsOneWidget);
    expect(find.text('Timeline'), findsOneWidget);
  });

  testWidgets('Mechanic: sign in → My Workspace with assigned job',
      (tester) async {
    await tester.pumpWidget(const MotoTrackApp());
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byType(TextFormField).first, 'ravi@bikerzedge.com');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('My Workspace'), findsWidgets);
    expect(find.text('MT-1042'), findsWidgets);
  });

  testWidgets('Admin: advance a job status via the workflow',
      (tester) async {
    await _signInAdmin(tester);

    await tester.tap(find.text('Jobs'));
    await tester.pumpAndSettle();

    // Find the freshly-received job (may be below the fold).
    await tester.scrollUntilVisible(
      find.text('MT-1044'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('MT-1044').first);
    await tester.pumpAndSettle();

    final advance = find.textContaining('Move to');
    expect(advance, findsOneWidget);
    await tester.tap(advance);
    await tester.pumpAndSettle();

    expect(find.textContaining('Status updated'), findsOneWidget);
  });

  testWidgets('Create job flow saves and returns to the list',
      (tester) async {
    await _signInAdmin(tester);

    await tester.tap(find.text('Jobs'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();
    expect(find.text('New service job'), findsOneWidget);

    Future<void> fill(String label, String value) async {
      final field = find.widgetWithText(TextFormField, label);
      await tester.scrollUntilVisible(
        field,
        120,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.enterText(field, value);
    }

    await fill('Owner name', 'Test Rider');
    await fill('Contact number', '9999999999');
    await fill('Make', 'Hero');
    await fill('Model', 'Splendor');
    await fill('Registration number', 'TN99XX0001');
    await fill('Odometer (km)', '12000');
    await fill('What needs attention?', 'Routine service');

    final submit = find.widgetWithText(FilledButton, 'Create job (Received)');
    await tester.scrollUntilVisible(
      submit,
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.ensureVisible(submit);
    await tester.pumpAndSettle();
    await tester.tap(submit);
    await tester.pumpAndSettle();

    // Back on the list with a confirmation.
    expect(find.text('All Jobs'), findsOneWidget);
    expect(find.textContaining('Job created'), findsOneWidget);
  });
}
