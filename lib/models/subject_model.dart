import '../enums/app_enums.dart';

class Subject {
  final SubjectId id;
  final String name;
  final String code;
  final String description;
  final String schedule;
  final String room;
  final String instructor;
  final String colorHex;
  final String iconEmoji;

  const Subject({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.schedule,
    required this.room,
    required this.instructor,
    required this.colorHex,
    required this.iconEmoji,
  });
}

// ── Static subject catalogue ──────────────────────────────────────────────────
const List<Subject> kSubjects = [
  Subject(
    id: SubjectId.mobileAppDev,
    name: 'Mobile App Development',
    code: 'CS-401',
    description:
        'An in-depth exploration of cross-platform mobile development using Flutter '
        'and Dart. Topics cover widget trees, state management, REST APIs, local '
        'storage, and publishing apps to the Play Store and App Store. Students '
        'build real-world projects throughout the semester.',
    schedule: 'Monday & Wednesday  |  10:00 AM – 11:30 AM',
    room: 'Lab 3 – Block B',
    instructor: 'Dr. Ayesha Siddiqui',
    colorHex: '6C63FF',
    iconEmoji: '📱',
  ),
  Subject(
    id: SubjectId.softwareReengineering,
    name: 'Software Re-engineering',
    code: 'CS-412',
    description:
        'Covers systematic approaches to modernising legacy systems. Students learn '
        'refactoring techniques, reverse engineering, code smell identification, '
        'design pattern application, and migration strategies. Emphasis is placed '
        'on maintaining functionality while improving structure.',
    schedule: 'Tuesday & Thursday  |  02:00 PM – 03:30 PM',
    room: 'Room 204 – Block A',
    instructor: 'Prof. Imran Khan',
    colorHex: '43AA8B',
    iconEmoji: '🔧',
  ),
  Subject(
    id: SubjectId.mis,
    name: 'Management Information Systems',
    code: 'BIT-301',
    description:
        'Examines how information systems support managerial decision-making and '
        'business operations. Topics include ERP systems, data warehousing, '
        'business intelligence dashboards, and IT governance frameworks. Case '
        'studies from Pakistani organisations are analysed throughout.',
    schedule: 'Friday  |  09:00 AM – 12:00 PM',
    room: 'Seminar Hall 1',
    instructor: 'Ms. Sana Mirza',
    colorHex: 'FF6B6B',
    iconEmoji: '📊',
  ),
];