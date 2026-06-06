import 'package:flutter/foundation.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/laravel_auth_service.dart';
import '../../../core/services/thai_zodiac_service.dart';
import '../../../core/api/api_client.dart';
import '../../../config/constants.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';

class ChatRepository {
  final AuthService _authService = AuthService.instance;
  final ApiClient _apiClient = LaravelAuthService.instance.apiClient;

  // เก็บ session id ของ backend ที่สร้างแบบ lazy ไว้ใช้ซ้ำ
  // (system prompt + AI ถูกจัดการฝั่ง backend แล้ว)
  String? _backendSessionId;

  // Get chat history from Laravel API
  Future<List<ChatSession>> getChatHistory() async {
    try {
      final response = await _apiClient.get('/chat/sessions');
      final List<dynamic> data = response as List;
      return data.map((json) => ChatSession.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting chat history: $e');
      return [];
    }
  }

  // Save chat session to Laravel API
  Future<void> saveChatSession(ChatSession session) async {
    try {
      await _apiClient.post('/chat/sessions', data: session.toJson());
    } catch (e) {
      debugPrint('Error saving chat session: $e');
      throw Exception('Failed to save chat session');
    }
  }

  // Get user's Thai zodiac animal from profile
  Future<String?> getUserZodiacSign() async {
    try {
      // ดึงข้อมูลผู้ใช้ปัจจุบันจาก Laravel Auth
      final currentUser = _authService.currentUser;

      debugPrint(
          "ChatRepository.getUserZodiacSign: current user = ${currentUser?.id}");

      if (currentUser != null) {
        // ลองดึงข้อมูล thai_animal จาก user data
        if (currentUser.thaiAnimal != null) {
          final animal = currentUser.thaiAnimal;
          debugPrint("ChatRepository: found thai_animal: $animal");
          return animal;
        }

        // ถ้าไม่มี thai_animal แต่มี birthDate ให้คำนวณจากวันเกิด
        if (currentUser.birthDate != null) {
          final thaiZodiac = ThaiZodiacService.getThaiZodiacFromDate(currentUser.birthDate!);
          debugPrint(
              "ChatRepository: calculated Thai zodiac from birth_date: ${thaiZodiac.animalName}");
          return thaiZodiac.animalName;
        }
      }

      // ถ้าไม่มีข้อมูลใน currentUser ให้ลองดึงจาก API
      final profile = await _authService.getUserProfile();

      debugPrint("ChatRepository: profile fetched (keys: ${profile?.keys.join(', ')})"); // PII removed

      if (profile != null) {
        // ลองหา thai_animal ในโปรไฟล์ก่อน
        if (profile['thai_animal'] != null) {
          final animal = profile['thai_animal'];
          debugPrint("ChatRepository: found thai_animal in profile: $animal");
          return animal;
        }

        // ถ้าไม่มี thai_animal แต่มี birth_date ให้คำนวณจากวันเกิด
        if (profile['birth_date'] != null) {
          final birthDate = DateTime.parse(profile['birth_date']);
          final thaiZodiac = ThaiZodiacService.getThaiZodiacFromDate(birthDate);
          debugPrint(
              "ChatRepository: calculated Thai zodiac from profile birth_date: ${thaiZodiac.animalName}");
          return thaiZodiac.animalName;
        }
      }

      debugPrint("ChatRepository: no Thai zodiac animal found");
      return null;
    } catch (e) {
      debugPrint('Error getting user zodiac sign: $e');
      return null;
    }
  }

  // ส่งข้อความผ่าน backend chat (AI proxied — system prompt สร้างฝั่ง backend)
  // - สร้าง session แบบ lazy ในข้อความแรก แล้วใช้ซ้ำ
  // - ดึงคำตอบจาก ai_message.content
  Future<ChatMessage> sendMessage({
    required String message,
    required List<ChatMessage> history,
    required String topic,
  }) async {
    try {
      final sessionId = await _ensureSession(topic);

      final response = Map<String, dynamic>.from(
        await _apiClient.post(
          '${ApiConstants.chatSessionsPath}/$sessionId/messages',
          data: {'content': message},
        ),
      );

      // คำตอบของผู้ช่วยอยู่ใน ai_message.content
      final aiMessage =
          Map<String, dynamic>.from(response['ai_message'] as Map);
      final assistantMessage = (aiMessage['content'] as String?) ?? '';

      return ChatMessage(
        id: aiMessage['id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        content: assistantMessage,
        timestamp: DateTime.now(),
        isUser: false,
      );
    } catch (e) {
      debugPrint('Error sending message to backend chat: $e');
      throw Exception('Failed to get response from assistant');
    }
  }

  // สร้าง backend session แบบ lazy (ถ้ายังไม่มี) แล้วคืน session id
  Future<String> _ensureSession(String topic) async {
    if (_backendSessionId != null) {
      return _backendSessionId!;
    }

    final created = Map<String, dynamic>.from(
      await _apiClient.post(
        ApiConstants.chatSessionsPath,
        data: {'topic': topic.isNotEmpty ? topic : 'การสนทนาใหม่'},
      ),
    );

    _backendSessionId = created['id'].toString();
    return _backendSessionId!;
  }
}
