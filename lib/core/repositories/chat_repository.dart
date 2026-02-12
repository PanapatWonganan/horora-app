import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../models/models.dart';
import '../utils/exceptions.dart';

class ChatRepository {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;
  
  // Key constants for SharedPreferences
  static const String _conversationsKey = 'chat_conversations';
  static const String _messagesKeyPrefix = 'chat_messages_';
  
  ChatRepository({
    required ApiClient apiClient,
    required SharedPreferences prefs,
  }) : _apiClient = apiClient, _prefs = prefs;
  
  // ดึงข้อมูลการสนทนาทั้งหมดของผู้ใช้
  Future<List<ChatConversation>> getUserConversations() async {
    try {
      // ดึงข้อมูลจาก API
      final response = await _apiClient.get('/chat/conversations');
      
      final List<ChatConversation> conversations = (response as List)
          .map((item) => ChatConversation.fromJson(item))
          .toList();
      
      // บันทึกข้อมูลลงในแคช
      await _prefs.setString(_conversationsKey, jsonEncode(conversations.map((conv) => conv.toJson()).toList()));
      
      return conversations;
    } on ApiException catch (e) {
      if (e is UnauthorizedException) {
        throw AuthException('User not authenticated');
      }
      rethrow;
    } catch (e) {
      // ถ้ามีข้อผิดพลาด แต่มีข้อมูลในแคช ให้ใช้ข้อมูลจากแคช
      final String? cachedData = _prefs.getString(_conversationsKey);
      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        return decoded.map((item) => ChatConversation.fromJson(item)).toList();
      }
      
      throw DataException('Failed to get user conversations: ${e.toString()}');
    }
  }
  
  // สร้างการสนทนาใหม่
  Future<ChatConversation> createConversation(String title) async {
    try {
      final data = {
        'title': title,
      };
      
      final response = await _apiClient.post('/chat/conversations', data: data);
      final conversation = ChatConversation.fromJson(response);
      
      // อัปเดตแคช
      await _addConversationToCache(conversation);
      
      return conversation;
    } on ApiException catch (e) {
      if (e is UnauthorizedException) {
        throw AuthException('User not authenticated');
      }
      rethrow;
    } catch (e) {
      throw DataException('Failed to create conversation: ${e.toString()}');
    }
  }
  
  // ดึงข้อมูลการสนทนาตาม ID
  Future<ChatConversation> getConversationById(int conversationId) async {
    try {
      final response = await _apiClient.get('/chat/conversations/$conversationId');
      return ChatConversation.fromJson(response);
    } on ApiException catch (e) {
      if (e is UnauthorizedException) {
        throw AuthException('User not authenticated');
      }
      rethrow;
    } catch (e) {
      throw DataException('Failed to get conversation: ${e.toString()}');
    }
  }
  
  // อัปเดตชื่อการสนทนา
  Future<ChatConversation> updateConversationTitle(int conversationId, String newTitle) async {
    try {
      final data = {
        'title': newTitle,
      };
      
      final response = await _apiClient.put('/chat/conversations/$conversationId', data: data);
      final updatedConversation = ChatConversation.fromJson(response);
      
      // อัปเดตแคช
      await _updateConversationInCache(updatedConversation);
      
      return updatedConversation;
    } on ApiException catch (e) {
      if (e is UnauthorizedException) {
        throw AuthException('User not authenticated');
      }
      rethrow;
    } catch (e) {
      throw DataException('Failed to update conversation title: ${e.toString()}');
    }
  }
  
  // ลบการสนทนา
  Future<void> deleteConversation(int conversationId) async {
    try {
      await _apiClient.delete('/chat/conversations/$conversationId');
      
      // อัปเดตแคช
      await _removeConversationFromCache(conversationId);
      await _prefs.remove('$_messagesKeyPrefix$conversationId');
    } on ApiException catch (e) {
      if (e is UnauthorizedException) {
        throw AuthException('User not authenticated');
      }
      rethrow;
    } catch (e) {
      throw DataException('Failed to delete conversation: ${e.toString()}');
    }
  }
  
  // ดึงข้อความในการสนทนา
  Future<List<ChatMessage>> getConversationMessages(int conversationId) async {
    try {
      // ดึงข้อมูลจาก API
      final String cacheKey = '$_messagesKeyPrefix$conversationId';
      final response = await _apiClient.get('/chat/conversations/$conversationId/messages');
      
      final List<ChatMessage> messages = (response as List)
          .map((item) => ChatMessage.fromJson(item))
          .toList();
      
      // บันทึกข้อมูลลงในแคช
      await _prefs.setString(cacheKey, jsonEncode(messages.map((msg) => msg.toJson()).toList()));
      
      return messages;
    } on ApiException catch (e) {
      if (e is UnauthorizedException) {
        throw AuthException('User not authenticated');
      }
      rethrow;
    } catch (e) {
      // ถ้ามีข้อผิดพลาด แต่มีข้อมูลในแคช ให้ใช้ข้อมูลจากแคช
      final String cacheKey = '$_messagesKeyPrefix$conversationId';
      final String? cachedData = _prefs.getString(cacheKey);
      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        return decoded.map((item) => ChatMessage.fromJson(item)).toList();
      }
      
      throw DataException('Failed to get conversation messages: ${e.toString()}');
    }
  }
  
  // ส่งข้อความใหม่
  Future<ChatMessage> sendMessage(int conversationId, String content) async {
    try {
      final data = {
        'content': content,
        'sender_type': 'user',
      };
      
      final response = await _apiClient.post('/chat/conversations/$conversationId/messages', data: data);
      final message = ChatMessage.fromJson(response);
      
      // อัปเดตแคช
      await _addMessageToCache(conversationId, message);
      
      return message;
    } on ApiException catch (e) {
      if (e is UnauthorizedException) {
        throw AuthException('User not authenticated');
      }
      rethrow;
    } catch (e) {
      throw DataException('Failed to send message: ${e.toString()}');
    }
  }
  
  // รับข้อความตอบกลับจาก AI
  Future<ChatMessage> getAiResponse(int conversationId) async {
    try {
      final response = await _apiClient.get('/chat/conversations/$conversationId/ai-response');
      final message = ChatMessage.fromJson(response);
      
      // อัปเดตแคช
      await _addMessageToCache(conversationId, message);
      
      return message;
    } on ApiException catch (e) {
      if (e is UnauthorizedException) {
        throw AuthException('User not authenticated');
      }
      rethrow;
    } catch (e) {
      throw DataException('Failed to get AI response: ${e.toString()}');
    }
  }
  
  // เพิ่มการสนทนาลงในแคช
  Future<void> _addConversationToCache(ChatConversation conversation) async {
    try {
      final String? cachedData = _prefs.getString(_conversationsKey);
      
      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        final List<ChatConversation> conversations = decoded.map((item) => ChatConversation.fromJson(item)).toList();
        
        conversations.add(conversation);
        
        await _prefs.setString(_conversationsKey, jsonEncode(conversations.map((conv) => conv.toJson()).toList()));
      } else {
        await _prefs.setString(_conversationsKey, jsonEncode([conversation.toJson()]));
      }
    } catch (e) {
      // ถ้ามีข้อผิดพลาดในการอัปเดตแคช ให้ข้ามไป
    }
  }
  
  // อัปเดตการสนทนาในแคช
  Future<void> _updateConversationInCache(ChatConversation updatedConversation) async {
    try {
      final String? cachedData = _prefs.getString(_conversationsKey);
      
      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        final List<ChatConversation> conversations = decoded.map((item) => ChatConversation.fromJson(item)).toList();
        
        final int index = conversations.indexWhere((conv) => conv.id == updatedConversation.id);
        
        if (index != -1) {
          conversations[index] = updatedConversation;
          await _prefs.setString(_conversationsKey, jsonEncode(conversations.map((conv) => conv.toJson()).toList()));
        }
      }
    } catch (e) {
      // ถ้ามีข้อผิดพลาดในการอัปเดตแคช ให้ข้ามไป
    }
  }
  
  // ลบการสนทนาออกจากแคช
  Future<void> _removeConversationFromCache(int conversationId) async {
    try {
      final String? cachedData = _prefs.getString(_conversationsKey);
      
      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        final List<ChatConversation> conversations = decoded.map((item) => ChatConversation.fromJson(item)).toList();
        
        conversations.removeWhere((conv) => conv.id == conversationId);
        
        await _prefs.setString(_conversationsKey, jsonEncode(conversations.map((conv) => conv.toJson()).toList()));
      }
    } catch (e) {
      // ถ้ามีข้อผิดพลาดในการลบจากแคช ให้ข้ามไป
    }
  }
  
  // เพิ่มข้อความลงในแคช
  Future<void> _addMessageToCache(int conversationId, ChatMessage message) async {
    try {
      final String cacheKey = '$_messagesKeyPrefix$conversationId';
      final String? cachedData = _prefs.getString(cacheKey);
      
      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        final List<ChatMessage> messages = decoded.map((item) => ChatMessage.fromJson(item)).toList();
        
        messages.add(message);
        
        await _prefs.setString(cacheKey, jsonEncode(messages.map((msg) => msg.toJson()).toList()));
      } else {
        await _prefs.setString(cacheKey, jsonEncode([message.toJson()]));
      }
    } catch (e) {
      // ถ้ามีข้อผิดพลาดในการอัปเดตแคช ให้ข้ามไป
    }
  }
  
  // ล้างแคชทั้งหมดของ ChatRepository
  Future<void> clearAllCache() async {
    try {
      await _prefs.remove(_conversationsKey);
      
      final Set<String> keys = _prefs.getKeys();
      
      for (final String key in keys) {
        if (key.startsWith(_messagesKeyPrefix)) {
          await _prefs.remove(key);
        }
      }
    } catch (e) {
      throw CacheException('Failed to clear chat cache: ${e.toString()}');
    }
  }
} 