import 'package:flutter/foundation.dart';
import '../../../core/services/openai_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/zodiac_utils.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';

class ChatRepository {
  final OpenAIService _openaiService = OpenAIService.instance;
  final SupabaseService _supabaseService = SupabaseService.instance;
  final AuthService _authService = AuthService.instance;

  // Get chat history from Supabase
  Future<List<ChatSession>> getChatHistory() async {
    try {
      final response = await _supabaseService.getChatHistory();

      return response.map((data) => ChatSession.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error getting chat history: $e');
      return [];
    }
  }

  // Save chat session to Supabase
  Future<void> saveChatSession(ChatSession session) async {
    try {
      await _supabaseService.saveChatSession(session.toJson());
    } catch (e) {
      debugPrint('Error saving chat session: $e');
      throw Exception('Failed to save chat session');
    }
  }

  // Get user's zodiac sign from profile
  Future<String?> getUserZodiacSign() async {
    try {
      // ดึงข้อมูลผู้ใช้ปัจจุบันจาก Supabase Auth
      final currentUser = _authService.currentUser;

      debugPrint(
          "ChatRepository.getUserZodiacSign: current user = ${currentUser?.id}");

      if (currentUser != null) {
        // ดึงข้อมูลราศีจาก user_metadata โดยตรง
        if (currentUser.userMetadata?['zodiac_sign'] != null) {
          final sign = currentUser.userMetadata!['zodiac_sign'] as String;
          debugPrint("ChatRepository: found zodiac_sign in metadata: $sign");
          return sign;
        }

        // ถ้าไม่มีราศีแต่มีวันเกิด ให้คำนวณราศีจากวันเกิด
        if (currentUser.userMetadata?['birth_date'] != null) {
          final birthDate =
              DateTime.parse(currentUser.userMetadata!['birth_date'] as String);
          final sign = ZodiacUtils.getZodiacSign(birthDate);
          debugPrint(
              "ChatRepository: calculated zodiac from birth_date: $sign");
          return sign;
        }
      }

      // ถ้าไม่มีข้อมูลใน user_metadata ให้ลองดึงจาก profiles table (วิธีเดิม)
      final profile = await _authService.getUserProfile();

      debugPrint("ChatRepository: profile = $profile");

      if (profile != null) {
        // ถ้ามีข้อมูลราศีในโปรไฟล์
        if (profile['zodiac_sign'] != null) {
          final sign = profile['zodiac_sign'];
          debugPrint("ChatRepository: found zodiac_sign in profile: $sign");
          return sign;
        }

        // ถ้าไม่มีราศีแต่มีวันเกิด ให้คำนวณราศีจากวันเกิด
        if (profile['birth_date'] != null) {
          final birthDate = DateTime.parse(profile['birth_date']);
          final sign = ZodiacUtils.getZodiacSign(birthDate);
          debugPrint(
              "ChatRepository: calculated zodiac from profile birth_date: $sign");
          return sign;
        }
      }

      debugPrint("ChatRepository: no zodiac sign found");
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

      // Get user's zodiac sign
      final userZodiacSign = await getUserZodiacSign();
      final zodiacInfo = userZodiacSign != null
          ? 'ผู้ใช้เกิดราศี: ${ZodiacUtils.getZodiacSignThai(DateTime(2000, 1, 1), zodiacSign: userZodiacSign)}'
          : 'ไม่ทราบราศีของผู้ใช้';

      // Create system prompt with astrology context and user's zodiac sign
      final systemPrompt = '''
      คุณเป็นนักพยากรณ์ดวงชะตาที่มีความเชี่ยวชาญในด้านโหราศาสตร์ ไพ่ทาโร่ และศาสตร์แห่งดวงดาว
      
      ข้อมูลผู้ใช้:
      $zodiacInfo
      
      หัวข้อการสนทนา: $topic
      
      กฎในการตอบ:
      1. ตอบด้วยภาษาไทยเสมอ
      2. ให้คำแนะนำที่เป็นประโยชน์และเชิงบวก
      3. อธิบายเหตุผลทางโหราศาสตร์ประกอบคำทำนาย
      4. ไม่ให้คำทำนายที่เป็นลางร้ายหรือทำให้ผู้ใช้กังวล
      5. ไม่แนะนำให้ผู้ใช้ตัดสินใจทางการเงินหรือสุขภาพโดยอิงจากคำทำนายเพียงอย่างเดียว
      6. ใช้ข้อมูลราศีของผู้ใช้ในการให้คำแนะนำที่เฉพาะเจาะจงมากขึ้น
      
      ตอบคำถามต่อไปนี้โดยใช้ความรู้ด้านโหราศาสตร์และไพ่ทาโร่:
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
