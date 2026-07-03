import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/navigation_provider.dart';
import '../providers/subject_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/home_shell.dart';
import 'app_theme.dart';

/// Root widget. Wires up [MultiProvider] and rebuilds [MaterialApp]
/// whenever the theme provider fires.
class StudentGradeTrackerApp extends StatelessWidget {
  const StudentGradeTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SubjectProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: Selector<ThemeProvider, ThemeMode>(
        selector: (_, p) => p.mode,
        builder: (context, mode, _) {
          return MaterialApp(
            title: 'Student Grade Tracker',
            debugShowCheckedModeBanner: false,
            themeMode: mode,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            home: const HomeShell(),
          );
        },
      ),
    );
  }
}
