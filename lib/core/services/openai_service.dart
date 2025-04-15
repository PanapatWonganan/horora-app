import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class OpenAIService {
  static OpenAIService? _instance;
  late final Dio _dio;

  // Singleton pattern
  static OpenAIService get instance {
    _instance ??= OpenAIService._();
    return _instance!;
  }

  OpenAIService._() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://api.openai.com/v1',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${dotenv.env['OPENAI_API_KEY'] ?? ''}',
      },
    ));
  }

  // Method to send a message to OpenAI
  Future<Map<String, dynamic>> sendMessage({
    required String prompt,
    required List<Map<String, dynamic>> history,
    String model = 'gpt-4o',
    double temperature = 1.0,
    int maxTokens = 1000,
  }) async {
    try {
      // Format the conversation history for OpenAI
      final messages = _formatConversationHistory(history);

      // Add the current user message
      messages.add({
        'role': 'user',
        'content': prompt,
      });

      // Prepare the request payload
      final payload = {
        'model': model,
        'messages': messages,
        'max_tokens': maxTokens,
        'temperature': temperature,
      };

      debugPrint('Sending request to OpenAI API');

      // Send the request to OpenAI API
      final response = await _dio.post(
        '/chat/completions',
        data: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        // Transform OpenAI response to match the format expected by the app
        final openaiResponse = response.data;
        final assistantMessage =
            openaiResponse['choices'][0]['message']['content'];

        return {
          'content': [
            {'text': assistantMessage, 'type': 'text'}
          ]
        };
      } else {
        throw Exception(
            'Failed to get response from OpenAI: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error communicating with OpenAI: $e');
    }
  }

  // Helper method to format conversation history
  List<Map<String, dynamic>> _formatConversationHistory(
      List<Map<String, dynamic>> history) {
    final formattedHistory = <Map<String, dynamic>>[];

    for (final message in history) {
      formattedHistory.add({
        'role': message['isUser'] ? 'user' : 'assistant',
        'content': message['content'],
      });
    }

    return formattedHistory;
  }

  // Method to generate a horoscope reading
  Future<Map<String, dynamic>> generateHoroscopeReading({
    required String zodiacSign,
    required String timeframe,
    String language = 'thai',
  }) async {
    final prompt = '''
    ช่วยสร้างคำทำนายดวงชะตาสำหรับราศี $zodiacSign สำหรับ$timeframe
    
    โปรดรวมข้อมูลต่อไปนี้:
    1. ภาพรวมทั่วไป
    2. ความรัก (คะแนน 1-5)
    3. การงาน (คะแนน 1-5)
    4. การเงิน (คะแนน 1-5)
    5. สุขภาพ (คะแนน 1-5)
    6. เลขนำโชค
    7. สีมงคล
    8. คำแนะนำพิเศษ
    
    ตอบในรูปแบบ JSON ที่มีฟิลด์ดังนี้: overview, love, career, finance, health, loveRating, careerRating, financeRating, healthRating, luckyNumbers, luckyColors, advice
    ''';

    final response = await sendMessage(
      prompt: prompt,
      history: [],
      temperature: 1.0,
    );

    // Extract the JSON from the response
    final content = response['content'][0]['text'];

    // Parse the JSON content
    try {
      // Find JSON in the response (it might be wrapped in markdown code blocks)
      final jsonRegExp = RegExp(r'{[\s\S]*}');
      final match = jsonRegExp.firstMatch(content);

      if (match != null) {
        final jsonStr = match.group(0);
        return jsonDecode(jsonStr!);
      } else {
        throw Exception('Could not extract JSON from response');
      }
    } catch (e) {
      throw Exception('Failed to parse horoscope response: $e');
    }
  }

  // Method to generate a tarot reading
  Future<Map<String, dynamic>> generateTarotReading({
    required List<String> cards,
    required String question,
    String spreadType = 'three-card',
    String language = 'thai',
    String? userZodiacSign,
  }) async {
    final cardsStr = cards.join(', ');

    // เพิ่มข้อมูลราศีในคำขอ
    final zodiacInfo =
        userZodiacSign != null ? '\nราศีของผู้ใช้: $userZodiacSign' : '';

    final prompt = '''
    ช่วยตีความไพ่ทาโร่ต่อไปนี้: $cardsStr
    
    รูปแบบการเปิดไพ่: $spreadType
    คำถามหรือประเด็นที่ต้องการคำตอบ: $question$zodiacInfo
    
    โปรดให้คำอธิบายสำหรับแต่ละใบ และการตีความโดยรวม รวมถึงคำแนะนำที่เป็นประโยชน์${userZodiacSign != null ? ' โดยคำนึงถึงลักษณะเฉพาะของราศี $userZodiacSign' : ''}
    
    ในการตีความ โปรดคำนึงถึง:
    1. ความหมายเชิงสัญลักษณ์ของไพ่แต่ละใบ
    2. ความสัมพันธ์ระหว่างไพ่ในตำแหน่งต่างๆ
    3. บริบทของคำถามและสถานการณ์ปัจจุบัน
    4. ${userZodiacSign != null ? 'อิทธิพลของราศี $userZodiacSign ต่อการตีความ' : 'อิทธิพลของดวงดาวและพลังงานในปัจจุบัน'}
    5. ข้อควรระวังและโอกาสที่ควรใช้ประโยชน์
    
    ตอบในรูปแบบ JSON ที่มีฟิลด์ดังนี้: 
    {
      "overall": "การตีความโดยรวม",
      "cards": [
        {
          "name": "ชื่อไพ่",
          "position": "ตำแหน่งในการอ่าน",
          "interpretation": "การตีความไพ่ใบนี้",
          "symbolic_meaning": "ความหมายเชิงสัญลักษณ์",
          "practical_advice": "คำแนะนำเชิงปฏิบัติ"
        }
      ],
      "advice": "คำแนะนำโดยรวม",
      "warnings": "ข้อควรระวัง",
      "opportunities": "โอกาสที่ควรใช้ประโยชน์"${userZodiacSign != null ? ',\n      "zodiac_influence": "อิทธิพลของราศี $userZodiacSign ต่อการตีความไพ่"' : ''}
    }
    ''';

    try {
      final response = await _dio.post(
        '/chat/completions',
        data: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system',
              'content':
                  'คุณเป็นนักพยากรณ์ไพ่ทาโร่ที่เชี่ยวชาญ มีความรู้ลึกซึ้งเกี่ยวกับความหมายของไพ่และความสัมพันธ์กับโหราศาสตร์'
            },
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 1000,
          'temperature': 0.9,
          'response_format': {'type': 'json_object'},
        }),
      );

      final content = response.data['choices'][0]['message']['content'];
      if (content == null) {
        throw Exception('No content in response');
      }

      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to generate tarot reading: ${e.toString()}');
    }
  }
}
