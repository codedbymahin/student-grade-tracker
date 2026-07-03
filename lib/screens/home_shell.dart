import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/navigation_provider.dart';
import '../providers/theme_provider.dart';
import 'add_subject_screen.dart';
import 'subject_list_screen.dart';
import 'summary_screen.dart';

/// Hosts the three screens behind a persistent AppBar and bottom
/// navigation bar. Using [IndexedStack] keeps each tab's state
/// (form fields, scroll position, animations) intact when the user
/// switches tabs.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  static const _pages = <Widget>[
    AddSubjectScreen(),
    SubjectListScreen(),
    SummaryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();
    final index = nav.currentIndex;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Grade Tracker'),
        actions: [
          Selector<ThemeProvider, ThemeMode>(
            selector: (_, p) => p.mode,
            builder: (context, mode, _) {
              final icon = switch (mode) {
                ThemeMode.light => Icons.dark_mode_outlined,
                ThemeMode.dark => Icons.brightness_auto_outlined,
                ThemeMode.system => Icons.light_mode_outlined,
              };
              final tooltip = switch (mode) {
                ThemeMode.light => 'Switch to dark theme',
                ThemeMode.dark => 'Use system theme',
                ThemeMode.system => 'Switch to light theme',
              };
              return IconButton(
                tooltip: tooltip,
                icon: Icon(icon),
                onPressed: () => context.read<ThemeProvider>().cycle(),
              );
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: KeyedSubtree(
          key: ValueKey<int>(index),
          child: IndexedStack(index: index, children: _pages),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => context.read<NavigationProvider>().setIndex(i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Subjects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights_outlined),
            activeIcon: Icon(Icons.insights),
            label: 'Summary',
          ),
        ],
      ),
    );
  }
}
