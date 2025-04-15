enum NotificationType {
  dailyHoroscope,
  tarotReading,
  focusSession,
  chatMessage,
  systemUpdate,
  promotion,
}

class UserNotification {
  final int id;
  final int userId;
  final String title;
  final String message;
  final NotificationType type;
  final String? imageUrl;
  final String? actionRoute;
  final Map<String, dynamic>? actionParams;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  UserNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.imageUrl,
    this.actionRoute,
    this.actionParams,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      message: json['message'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => NotificationType.systemUpdate,
      ),
      imageUrl: json['image_url'],
      actionRoute: json['action_route'],
      actionParams: json['action_params'] != null
          ? Map<String, dynamic>.from(json['action_params'])
          : null,
      isRead: json['is_read'],
      createdAt: DateTime.parse(json['created_at']),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'image_url': imageUrl,
      'action_route': actionRoute,
      'action_params': actionParams,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }

  // สร้างสำเนาของการแจ้งเตือนที่ถูกอ่านแล้ว
  UserNotification markAsRead() {
    if (isRead) {
      return this;
    }
    
    return UserNotification(
      id: id,
      userId: userId,
      title: title,
      message: message,
      type: type,
      imageUrl: imageUrl,
      actionRoute: actionRoute,
      actionParams: actionParams,
      isRead: true,
      createdAt: createdAt,
      readAt: DateTime.now(),
    );
  }

  // ตรวจสอบว่าการแจ้งเตือนนี้เกี่ยวข้องกับดวงชะตาหรือไม่
  bool get isAstrologyRelated => 
      type == NotificationType.dailyHoroscope || 
      type == NotificationType.tarotReading;

  // ตรวจสอบว่าการแจ้งเตือนนี้เกี่ยวข้องกับระบบหรือไม่
  bool get isSystemRelated => 
      type == NotificationType.systemUpdate || 
      type == NotificationType.promotion;

  // ตรวจสอบว่าการแจ้งเตือนนี้มีการกระทำที่เกี่ยวข้องหรือไม่
  bool get hasAction => actionRoute != null;

  // ตรวจสอบว่าการแจ้งเตือนนี้มีรูปภาพหรือไม่
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  // ตรวจสอบว่าการแจ้งเตือนนี้เป็นการแจ้งเตือนใหม่หรือไม่ (ไม่เกิน 24 ชั่วโมง)
  bool get isNew {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(createdAt);
    return difference.inHours < 24;
  }
}

// คลาสสำหรับการจัดการการแจ้งเตือนแบบกลุ่ม
class NotificationGroup {
  final NotificationType type;
  final List<UserNotification> notifications;

  NotificationGroup({
    required this.type,
    required this.notifications,
  });

  // จำนวนการแจ้งเตือนที่ยังไม่ได้อ่าน
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  // การแจ้งเตือนล่าสุดในกลุ่ม
  UserNotification? get latestNotification => 
      notifications.isNotEmpty ? 
      notifications.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b) : 
      null;

  // ตรวจสอบว่ามีการแจ้งเตือนที่ยังไม่ได้อ่านหรือไม่
  bool get hasUnread => unreadCount > 0;
} 