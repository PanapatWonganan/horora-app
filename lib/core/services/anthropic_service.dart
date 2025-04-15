import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AnthropicService {
  static AnthropicService? _instance;
  late final Dio _dio;
  
  // Singleton pattern
  static AnthropicService get instance {
    _instance ??= AnthropicService._();
    return _instance!;
  }
  
  AnthropicService._() {
    // Use a CORS proxy to avoid CORS issues when running on web
    final apiUrl = dotenv.env['ANTHROPIC_API_URL'] ?? 'https://api.anthropic.com/v1/messages';
    const corsProxyUrl = 'https://cors-anywhere.herokuapp.com/';
    
    _dio = Dio(BaseOptions(
      baseUrl: kIsWeb ? corsProxyUrl + apiUrl : apiUrl,
      headers: {
        'Content-Type': 'text/plain',
        'x-api-key': dotenv.env['ANTHROPIC_API_KEY'] ?? '',
        'anthropic-version': '2023-06-01',
        'Origin': 'http://localhost',
      },
    ));
  }
  
  // Method to send a message to Claude
  Future<Map<String, dynamic>> sendMessage({
    required String prompt,
    required List<Map<String, dynamic>> history,
    String model = 'claude-3-opus-20240229',
    double temperature = 0.7,
    int maxTokens = 1000,
  }) async {
    try {
      // Format the conversation history for Claude
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
      
      // Send the request to Anthropic API
      final response = await _dio.post(
        '',
        data: jsonEncode(payload),
      );
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to get response from Claude: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error communicating with Claude: $e');
    }
  }
  
  // Helper method to format conversation history
  List<Map<String, dynamic>> _formatConversationHistory(List<Map<String, dynamic>> history) {
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
      temperature: 0.8,
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
  }) async {
    final cardsStr = cards.join(', ');
    
    final prompt = '''
    ช่วยตีความไพ่ทาโร่ต่อไปนี้: $cardsStr
    
    รูปแบบการเปิดไพ่: $spreadType
    คำถามหรือประเด็นที่ต้องการคำตอบ: $question
    
    โปรดให้คำอธิบายสำหรับแต่ละใบ และการตีความโดยรวม รวมถึงคำแนะนำที่เป็นประโยชน์
    
    ตอบในรูปแบบ JSON ที่มีฟิลด์ดังนี้: 
    {
      "overall": "การตีความโดยรวม",
      "cards": [
        {
          "name": "ชื่อไพ่",
          "position": "ตำแหน่งในการอ่าน",
          "interpretation": "การตีความไพ่ใบนี้"
        }
      ],
      "advice": "คำแนะนำ"
    }
    ''';
    
    final response = await sendMessage(
      prompt: prompt,
      history: [],
      temperature: 0.7,
    );
    
    // Extract the JSON from the response
    final content = response['content'][0]['text'];
    
    // Parse the JSON content
    try {
      // Find JSON in the response
      final jsonRegExp = RegExp(r'{[\s\S]*}');
      final match = jsonRegExp.firstMatch(content);
      
      if (match != null) {
        final jsonStr = match.group(0);
        return jsonDecode(jsonStr!);
      } else {
        throw Exception('Could not extract JSON from response');
      }
    } catch (e) {
      throw Exception('Failed to parse tarot response: $e');
    }
  }
} 