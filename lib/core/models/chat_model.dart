class ChatConversation {
  final int id;
  final int userId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatMessage>? messages;

  ChatConversation({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messages,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    List<ChatMessage>? messages;
    if (json['messages'] != null) {
      messages = (json['messages'] as List)
          .map((messageJson) => ChatMessage.fromJson(messageJson))
          .toList();
    }

    return ChatConversation(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      messages: messages,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'user_id': userId,
      'title': title,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };

    if (messages != null) {
      data['messages'] = messages!.map((message) => message.toJson()).toList();
    }

    return data;
  }
}

class ChatMessage {
  final int id;
  final int conversationId;
  final String senderType;
  final String content;
  final bool hasAttachments;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderType,
    required this.content,
    required this.hasAttachments,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      conversationId: json['conversation_id'],
      senderType: json['sender_type'],
      content: json['content'],
      hasAttachments: json['has_attachments'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_type': senderType,
      'content': content,
      'has_attachments': hasAttachments,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isUser => senderType == 'user';
  bool get isAi => senderType == 'ai';
} 