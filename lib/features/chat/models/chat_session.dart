import 'package:json_annotation/json_annotation.dart';
import 'chat_message.dart';

part 'chat_session.g.dart';

@JsonSerializable()
class ChatSession {
  final String id;
  final String topic;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final List<ChatMessage> messages;
  final int duration; // Duration in minutes

  ChatSession({
    required this.id,
    required this.topic,
    required this.createdAt,
    this.lastMessageAt,
    required this.messages,
    required this.duration,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) => _$ChatSessionFromJson(json);
  
  Map<String, dynamic> toJson() => _$ChatSessionToJson(this);
} 