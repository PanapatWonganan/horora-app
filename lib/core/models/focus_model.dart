class FocusSession {
  final int id;
  final int userId;
  final int durationMinutes;
  final String theme;
  final DateTime startTime;
  final DateTime? endTime;
  final bool completed;
  final String? notes;
  final String? insights;
  final DateTime createdAt;
  final DateTime updatedAt;

  FocusSession({
    required this.id,
    required this.userId,
    required this.durationMinutes,
    required this.theme,
    required this.startTime,
    this.endTime,
    required this.completed,
    this.notes,
    this.insights,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      id: json['id'],
      userId: json['user_id'],
      durationMinutes: json['duration_minutes'],
      theme: json['theme'],
      startTime: DateTime.parse(json['start_time']),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      completed: json['completed'],
      notes: json['notes'],
      insights: json['insights'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'duration_minutes': durationMinutes,
      'theme': theme,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'completed': completed,
      'notes': notes,
      'insights': insights,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // คำนวณเวลาที่เหลือในเซสชัน (ในวินาที)
  int getRemainingTime() {
    if (completed || endTime != null) {
      return 0;
    }

    final DateTime now = DateTime.now();
    final DateTime expectedEndTime = startTime.add(Duration(minutes: durationMinutes));

    if (now.isAfter(expectedEndTime)) {
      return 0;
    }

    return expectedEndTime.difference(now).inSeconds;
  }

  // คำนวณเปอร์เซ็นต์ความคืบหน้าของเซสชัน (0-100)
  double getProgressPercentage() {
    if (completed) {
      return 100.0;
    }

    final int totalDurationSeconds = durationMinutes * 60;
    final int elapsedSeconds = DateTime.now().difference(startTime).inSeconds;

    if (elapsedSeconds >= totalDurationSeconds) {
      return 100.0;
    }

    return (elapsedSeconds / totalDurationSeconds) * 100;
  }

  // สร้างเซสชันใหม่
  factory FocusSession.create({
    required int userId,
    required int durationMinutes,
    required String theme,
  }) {
    final DateTime now = DateTime.now();
    return FocusSession(
      id: 0, // จะถูกกำหนดโดยเซิร์ฟเวอร์
      userId: userId,
      durationMinutes: durationMinutes,
      theme: theme,
      startTime: now,
      endTime: null,
      completed: false,
      notes: null,
      insights: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  // สร้างเซสชันที่เสร็จสิ้นแล้ว
  FocusSession complete({String? notes}) {
    final DateTime now = DateTime.now();
    return FocusSession(
      id: id,
      userId: userId,
      durationMinutes: durationMinutes,
      theme: theme,
      startTime: startTime,
      endTime: now,
      completed: true,
      notes: notes ?? this.notes,
      insights: insights,
      createdAt: createdAt,
      updatedAt: now,
    );
  }
}

class FocusTheme {
  final String name;
  final String description;
  final String imagePath;
  final String soundPath;

  FocusTheme({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.soundPath,
  });

  factory FocusTheme.fromJson(Map<String, dynamic> json) {
    return FocusTheme(
      name: json['name'],
      description: json['description'],
      imagePath: json['image'],
      soundPath: json['sound'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'image': imagePath,
      'sound': soundPath,
    };
  }
} 