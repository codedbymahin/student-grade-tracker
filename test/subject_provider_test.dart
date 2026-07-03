import 'package:flutter_test/flutter_test.dart';
import 'package:student_grade_tracker/models/grade.dart';
import 'package:student_grade_tracker/models/subject.dart';
import 'package:student_grade_tracker/providers/subject_provider.dart';

void main() {
  group('Grade.fromMark', () {
    test('maps marks to the right letter at the boundaries', () {
      expect(Grade.fromMark(100), Grade.a);
      expect(Grade.fromMark(95), Grade.a);
      expect(Grade.fromMark(80), Grade.a);
      expect(Grade.fromMark(79.99), Grade.b);
      expect(Grade.fromMark(65), Grade.b);
      expect(Grade.fromMark(64.99), Grade.c);
      expect(Grade.fromMark(50), Grade.c);
      expect(Grade.fromMark(49.99), Grade.f);
      expect(Grade.fromMark(0), Grade.f);
    });

    test('clamps out-of-range and tolerates non-finite values', () {
      expect(Grade.fromMark(-5), Grade.f);
      expect(Grade.fromMark(150), Grade.a);
      expect(Grade.fromMark(double.nan), Grade.f);
      expect(Grade.fromMark(double.infinity), Grade.f);
    });
  });

  group('Subject.grade', () {
    test('returns the correct Grade for representative marks', () {
      expect(const Subject(id: '1', name: 'A', mark: 92).grade, Grade.a);
      expect(const Subject(id: '2', name: 'B', mark: 70).grade, Grade.b);
      expect(const Subject(id: '3', name: 'C', mark: 55).grade, Grade.c);
      expect(const Subject(id: '4', name: 'F', mark: 30).grade, Grade.f);
    });
  });

  group('SubjectProvider', () {
    test('addSubject grows the list, trims names, and notifies listeners', () {
      final provider = SubjectProvider();
      var notifications = 0;
      provider.addListener(() => notifications++);

      provider.addSubject(name: '  Math  ', mark: 85);
      provider.addSubject(name: '', mark: 90); // ignored
      provider.addSubject(name: 'Science', mark: 40);

      expect(provider.totalSubjects, 2);
      expect(provider.subjects.first.name, 'Math');
      expect(provider.subjects.first.mark, 85);
      expect(notifications, 2);
    });

    test('clamps marks to 0–100', () {
      final provider = SubjectProvider()
        ..addSubject(name: 'A', mark: 250)
        ..addSubject(name: 'B', mark: -10);

      expect(provider.subjects[0].mark, 100);
      expect(provider.subjects[1].mark, 0);
    });

    test('deleteById removes the subject and updates the averages', () {
      final provider = SubjectProvider()
        ..addSubject(name: 'Math', mark: 80)
        ..addSubject(name: 'Science', mark: 40);

      final removed = provider.deleteById(provider.subjects.first.id);

      expect(removed?.name, 'Math');
      expect(provider.totalSubjects, 1);
      expect(provider.averageMark, 40.0);
      expect(provider.passingCount, 0);
    });

    test('deleteById returns null for an unknown id', () {
      final provider = SubjectProvider()..addSubject(name: 'Math', mark: 80);
      expect(provider.deleteById('does-not-exist'), isNull);
    });

    test('restore re-inserts a previously deleted subject', () {
      final provider = SubjectProvider()
        ..addSubject(name: 'Math', mark: 80)
        ..addSubject(name: 'Science', mark: 40);
      final removed = provider.deleteById(provider.subjects[0].id);

      expect(provider.totalSubjects, 1);
      provider.restore(removed!, index: 0);
      expect(provider.totalSubjects, 2);
      expect(provider.subjects.first.name, 'Math');
      expect(provider.averageMark, 60.0);
      expect(provider.passingCount, 1);
    });

    test('restore is a no-op when the id is already present', () {
      final provider = SubjectProvider()..addSubject(name: 'Math', mark: 80);
      final duplicate = provider.subjects.first;
      provider.restore(duplicate, index: 0);
      expect(provider.totalSubjects, 1);
    });

    test('highest/lowest mark return null when empty', () {
      final provider = SubjectProvider();
      expect(provider.highestMark, isNull);
      expect(provider.lowestMark, isNull);
    });

    test('overallGrade returns null for empty list, else a Grade', () {
      final empty = SubjectProvider();
      expect(empty.overallGrade, isNull);

      final provider = SubjectProvider()
        ..addSubject(name: 'Math', mark: 80)
        ..addSubject(name: 'English', mark: 60);
      expect(provider.overallGrade, Grade.b);
    });

    test('passingCount counts marks >= 50', () {
      final provider = SubjectProvider()
        ..addSubject(name: 'A', mark: 49.99)
        ..addSubject(name: 'B', mark: 50)
        ..addSubject(name: 'C', mark: 90);
      expect(provider.passingCount, 2);
    });
  });
}
