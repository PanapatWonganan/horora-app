import 'package:flutter/foundation.dart';
import '../../../core/services/openai_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/laravel_auth_service.dart';
import '../../../core/services/thai_zodiac_service.dart';
import '../../../core/api/api_client.dart';
import '../../../config/constants.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';

class ChatRepository {
  final OpenAIService _openaiService = OpenAIService.instance;
  final AuthService _authService = AuthService.instance;
  final ApiClient _apiClient = LaravelAuthService.instance.apiClient;

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

      debugPrint("ChatRepository: profile = $profile");

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

  // Send message to OpenAI API
  Future<ChatMessage> sendMessage({
    required String message,
    required List<ChatMessage> history,
    required String topic,
  }) async {
    try {
      // Format history for OpenAI API
      final formattedHistory = history
          .map((msg) => {
                'isUser': msg.isUser,
                'content': msg.content,
              })
          .toList();

      // Get user's Thai zodiac sign
      final userThaiAnimal = await getUserZodiacSign();
      final zodiacInfo = userThaiAnimal != null
          ? 'ผู้ใช้เกิดปี$userThaiAnimal'
          : 'ไม่ทราบปีนักษัตรของผู้ใช้';

      // Create system prompt with Thai astrology context and user's zodiac sign
      final systemPrompt = '''
      คุณเป็นนักพยากรณ์ดวงชะตาไทยที่มีความเชี่ยวชาญในด้านปีนักษัตรไทย 12 ปี ไพ่ทาโร่ และโหราศาสตร์ไทย

      ข้อมูลผู้ใช้:
      $zodiacInfo

      หัวข้อการสนทนา: $topic

      ความรู้เกี่ยวกับปีนักษัตรไทย:
      - 12 ปี ได้แก่: ชวด, ฉลู, ขาล, เถาะ, มะโรง, มะเส็ง, มะเมีย, มะแม, วอก, ระกา, จอ, กุน
      - 5 ธาตุ ได้แก่: ทอง, น้ำ, ไม้, ไฟ, ดิน

      กฎในการตอบ:
      1. ตอบด้วยภาษาไทยเสมอ
      2. ใช้ความรู้เกี่ยวกับปีนักษัตรไทยในการทำนาย
      3. ให้คำแนะนำที่เป็นประโยชน์และเชิงบวก
      4. อธิบายเหตุผลทางโหราศาสตร์ไทยประกอบคำทำนาย
      5. ไม่ให้คำทำนายที่เป็นลางร้ายหรือทำให้ผู้ใช้กังวล
      6. ไม่แนะนำให้ผู้ใช้ตัดสินใจทางการเงินหรือสุขภาพโดยอิงจากคำทำนายเพียงอย่างเดียว
      7. ใช้ข้อมูลปีนักษัตรของผู้ใช้ในการให้คำแนะนำที่เฉพาะเจาะจงมากขึ้น

      ตอบคำถามต่อไปนี้โดยใช้ความรู้ด้านโหราศาสตร์ไทยและไพ่ทาโร่:
      ''';

      // Combine system prompt with user message
      final fullPrompt = '$systemPrompt\n\n$message';

      // Send to OpenAI API
      final response = await _openaiService.sendMessage(
        prompt: fullPrompt,
        history: formattedHistory,
        model: 'gpt-4o',
        temperature: 0.7,
      );

      // Extract assistant's response
      final assistantMessage = response['content'][0]['text'];

      // Create and return ChatMessage
      return ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: assistantMessage,
        timestamp: DateTime.now(),
        isUser: false,
      );
    } catch (e) {
      debugPrint('Error sending message to OpenAI: $e');
      throw Exception('Failed to get response from assistant');
    }
  }
}
