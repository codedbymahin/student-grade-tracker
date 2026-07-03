import 'package:flutter/material.dart';

/// Maps a subject name to a representative [Material] icon.
///
/// Matching is case-insensitive and looks for the first keyword that
/// appears anywhere inside the subject name, so e.g. "Advanced
/// Mathematics" still gets the calculator icon.
IconData getSubjectIcon(String subjectName) {
  final name = subjectName.trim().toLowerCase();
  if (name.isEmpty) return _defaultIcon;

  for (final entry in _iconRules) {
    for (final keyword in entry.keywords) {
      if (name.contains(keyword)) return entry.icon;
    }
  }
  return _defaultIcon;
}

/// Default icon used when no keyword matches.
const IconData _defaultIcon = Icons.school_rounded;

/// Ordered list of (icon, keywords) rules. The first matching keyword
/// wins, so more specific keywords should be listed before broader ones.
final List<({IconData icon, List<String> keywords})> _iconRules = [
  (
    icon: Icons.calculate_rounded,
    keywords: const [
      'math',
      'calculus',
      'algebra',
      'geometry',
    ]
  ),
  (icon: Icons.science_rounded, keywords: const ['physics']),
  (icon: Icons.biotech_rounded, keywords: const ['chemistry', 'chem']),
  (icon: Icons.eco_rounded, keywords: const ['biology', 'bio']),
  (icon: Icons.menu_book_rounded, keywords: const ['english', 'literature']),
  (icon: Icons.code_rounded, keywords: const ['programming', 'coding']),
  (icon: Icons.history_edu_rounded, keywords: const ['history']),
  (icon: Icons.public_rounded, keywords: const ['geography', 'geo']),
  (
    icon: Icons.mosque_rounded,
    keywords: const [
      'religion',
      'islam',
      'religious',
    ]
  ),
  (icon: Icons.payments_rounded, keywords: const ['economics', 'finance']),
  (
    icon: Icons.business_center_rounded,
    keywords: const [
      'business',
      'commerce',
    ]
  ),
  // Broader computer-related keywords go last so 'programming' matches first.
  (icon: Icons.computer_rounded, keywords: const ['ict', 'computer']),
];
