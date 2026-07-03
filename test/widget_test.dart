import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_grade_tracker/app/app.dart';
import 'package:student_grade_tracker/screens/home_shell.dart';

void main() {
  testWidgets('Add subject shows up in the Subject list', (tester) async {
    await tester.pumpWidget(const StudentGradeTrackerApp());
    await tester.pumpAndSettle();

    // Default tab is the Add screen.
    expect(find.byType(HomeShell), findsOneWidget);

    // Enter a valid subject.
    await tester.enterText(find.byType(TextFormField).at(0), 'Mathematics');
    await tester.enterText(find.byType(TextFormField).at(1), '85');
    await tester.tap(find.text('Add subject'));
    await tester.pumpAndSettle();

    // Switch to the Subjects tab.
    await tester.tap(find.text('Subjects'));
    await tester.pumpAndSettle();

    expect(find.text('Mathematics'), findsOneWidget);
    expect(find.text('Mark 85.0'), findsOneWidget);
    expect(find.text('A'), findsOneWidget); // grade chip

    // Switch to the Summary tab.
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();

    expect(find.text('Total subjects'), findsOneWidget);
    expect(find.text('1'), findsWidgets); // total count value
  });
}
