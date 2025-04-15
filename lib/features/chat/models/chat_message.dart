import 'package:json_annotation/json_annotation.dart';

part 'chat_message.g.dart';

@JsonSerializable()
class ChatMessage {
  final String id;
  final String content;
  final DateTime timestamp;
  final bool isUser;
  final bool isSystemMessage;

  ChatMessage({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.isUser,
    this.isSystemMessage = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);
  
  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);
} 