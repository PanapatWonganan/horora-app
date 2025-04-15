import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../models/models.dart';
import '../utils/exceptions.dart';

class FocusRepository {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;
  
  // Key constants for SharedPreferences
  static const String _focusSessionsKey = 'focus_sessions';
  static const String _focusThemesKey = 'focus_themes';
  static const String _activeSessionKey = 'active_focus_session';
  
  FocusRepository({
    required ApiClient apiClient,
    required SharedPreferences prefs,
  }) : _apiClient = apiClient, _prefs = prefs;
  
  // ดึงข้อมูลธีมสมาธิทั้งหมด
  Future<List<FocusTheme>> getAllFocusThemes() async {
    try {
      // ตรวจสอบว่ามีข้อมูลในแคชหรือไม่
      final String? cachedData = _prefs.getString(_focusThemesKey);
      
      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        return decoded.map((item) => FocusTheme.fromJson(item)).toList();
      }
      
      // ถ้าไม่มีข้อมูลในแคช ให้ดึงจาก API
      final response = await _apiClient.get('/focus/themes');
      
      final List<FocusTheme> themes = (response as List)
          .map((item) => FocusTheme.fromJson(item))
          .toList();
      
      // บันทึกข้อมูลลงในแคช
      await _prefs.setString(_focusThemesKey, jsonEncode(themes.map((theme) => theme.toJson()).toList()));
      
      return themes;
    } catch (e) {
      throw DataException('Failed to get focus themes: ${e.toString()}');
    }
  }
  
  // ดึงข้อมูลธีมสมาธิตามชื่อ
  Future<FocusTheme> getFocusThemeByName(String name) async {
    try {
      final List<FocusTheme> allThemes = await getAllFocusThemes();
      
      final FocusTheme theme = allThemes.firstWhere(
        (theme) => theme.name.toLowerCase() == name.toLowerCase(),
        orElse: () => throw DataException('Focus theme not found: $name'),
      );
      
      return theme;
    } catch (e) {
      throw DataException('Failed to get focus theme: ${e.toString()}');
    }
  }
  
  // ดึงข้อมูลเซสชันสมาธิทั้งหมดของผู้ใช้
  Future<List<FocusSession>> getUserFocusSessions() async {
    try {
      // ตรวจสอบว่ามีข้อมูลในแคชหรือไม่
      final String? cachedData = _prefs.getString(_focusSessionsKey);
      List<FocusSession>? cachedSessions;
      
      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        cachedSessions = decoded.map((item) => FocusSession.fromJson(item)).toList();
      }
      
      // ดึงข้อมูลจาก API
      final response = await _apiClient.get('/focus/sessions');
      
      final List<FocusSession> sessions = (response as List)
          .map((item) => FocusSession.fromJson(item))
          .toList();
      
      // บันทึกข้อมูลลงในแคช
      await _prefs.setString(_focusSessionsKey, jsonEncode(sessions.map((session) => session.toJson()).toList()));
      
      return sessions;
    } on ApiException catch (e) {
      if (e is UnauthorizedException) {
        throw AuthException('User not authenticated');
      }
      rethrow;
    } catch (e) {
      // ถ้ามีข้อผิดพลาด แต่มีข้อมูลในแคช ให้ใช้ข้อมูลจากแคช
      final String? cachedData = _prefs.getString(_focusSessionsKey);
      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        return decoded.map((item) => FocusSession.fromJson(item)).toList();
      }
      
      throw DataException('Failed to get user focus sessions: ${e.toString()}');
    }
  }
  
  // สร้างเซสชันสมาธิใหม่
  Future<FocusSession> createFocusSession({
    required int durationMinutes,
    required String theme,
  }) async {
    try {
      final data = {
        'duration_minutes': durationMinutes,
        'theme': theme,
      };
      
      final response = await _apiClient.post('/focus/sessions', data: data);
      final session = FocusSession.fromJson(response);
      
      // บันทึกเซสชันที่กำลังใช้งาน
      await _prefs.setString(_activeSessionKey, jsonEncode(session.toJson()));
      
      // อัปเดตแคช
      await _addSessionToCache(session);
      
      return session;
    } on ApiException catch (e) {
      if (e is UnauthorizedException) {
        throw AuthException('User not authenticated');
      }
      rethrow;
    } catch (e) {
      throw DataException('Failed to create focus session: ${e.toString()}');
    }
  }
  
  // ดึงข้อมูลเซสชันสมาธิตาม ID
  Future<FocusSession> getFocusSessionById(int sessionId) async {
    try {
      final response = await _apiClient.get('/focus/sessions/$sessionId');
      return FocusSession.fromJson(response);
    } on ApiException catch (e) {
      if (e is UnauthorizedException) {
        throw AuthException('User not authenticated');
      }
      rethrow;
    } catch (e) {
      throw DataException('Failed to get focus session: ${e.toString()}');
    }
  }
  
  // เสร็จสิ้นเซสชันสมาธิ
  Future<FocusSession> completeFocusSession(int sessionId, {String? notes}) async {
    try {
      final data = {
        'completed': true,
        'notes': notes,
      };
      
      final response = await _apiClient.put('/focus/sessions/$sessionId/complete', data: data);
      final completedSession = FocusSession.fromJson(response);
      
      // ล้างเซสชันที่กำลังใช้งาน
      await _prefs.remove(_activeSessionKey);
      
      // อัปเดตแคช
      await _updateSessionInCache(completedSession);
      
      return completedSession;
    } on ApiException catch (e) {
      if (e is UnauthorizedException) {
        throw AuthException('User not authenticated');
      }
      rethrow;
    } catch (e) {
      throw DataException('Failed to complete focus session: ${e.toString()}');
    }
  }
  
  // อัปเดตบันทึกของเซสชันสมาธิ
  Future<FocusSession> updateFocusSessionNotes(int sessionId, String notes) async {
    try {
      final data = {
        'notes': notes,
      };
      
      final response = await _apiClient.put('/focus/sessions/$sessionId', data: data);
      final updatedSession = FocusSession.fromJson(response);
      
      // อัปเดตแคช
      await _updateSessionInCache(updatedSession);
      
      return updatedSession;
    } on ApiException catch (e) {
      if (e is UnauthorizedException) {
        throw AuthException('User not authenticated');
      }
      rethrow;
    } catch (e) {
      throw DataException('Failed to update focus session notes: ${e.toString()}');
    }
  }
  
  // ลบเซสชันสมาธิ
  Future<void> deleteFocusSession(int sessionId) async {
    try {
      await _apiClient.delete('/focus/sessions/$sessionId');
      
      // ตรวจสอบว่าเป็นเซสชันที่กำลังใช้งานหรือไม่
      final String? activeSessionData = _prefs.getString(_activeSessionKey);
      if (activeSessionData != null) {
        final FocusSession activeSession = FocusSession.fromJson(jsonDecode(activeSessionData));
        if (activeSession.id == sessionId) {
          await _prefs.remove(_activeSessionKey);
        }
      }
      
      // อัปเดตแคช
      await _removeSessionFromCache(sessionId);
    } on ApiException catch (e) {
      if (e is UnauthorizedException) {
        throw AuthException('User not authenticated');
      }
      rethrow;
    } catch (e) {
      throw DataException('Failed to delete focus session: ${e.toString()}');
    }
  }
  
  // ดึงข้อมูลเซสชันสมาธิที่กำลังใช้งาน
  Future<FocusSession?> getActiveSession() async {
    try {
      final String? activeSessionData = _prefs.getString(_activeSessionKey);
      
      if (activeSessionData != null) {
        final FocusSession activeSession = FocusSession.fromJson(jsonDecode(activeSessionData));
        
        // ตรวจสอบว่าเซสชันยังใช้งานอยู่หรือไม่
        if (!activeSession.completed && activeSession.getRemainingTime() > 0) {
          return activeSession;
        } else {
          // ถ้าเซสชันหมดเวลาแล้ว ให้ล้างข้อมูล
          await _prefs.remove(_activeSessionKey);
          return null;
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // เพิ่มเซสชันสมาธิลงในแคช
  Future<void> _addSessionToCache(FocusSession session) async {
    try {
      final String? cachedData = _prefs.getString(_focusSessionsKey);
      
      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        final List<FocusSession> sessions = decoded.map((item) => FocusSession.fromJson(item)).toList();
        
        sessions.add(session);
        
        await _prefs.setString(_focusSessionsKey, jsonEncode(sessions.map((session) => session.toJson()).toList()));
      } else {
        await _prefs.setString(_focusSessionsKey, jsonEncode([session.toJson()]));
      }
    } catch (e) {
      // ถ้ามีข้อผิดพลาดในการอัปเดตแคช ให้ข้ามไป
    }
  }
  
  // อัปเดตเซสชันสมาธิในแคช
  Future<void> _updateSessionInCache(FocusSession updatedSession) async {
    try {
      final String? cachedData = _prefs.getString(_focusSessionsKey);
      
      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        final List<FocusSession> sessions = decoded.map((item) => FocusSession.fromJson(item)).toList();
        
        final int index = sessions.indexWhere((session) => session.id == updatedSession.id);
        
        if (index != -1) {
          sessions[index] = updatedSession;
          await _prefs.setString(_focusSessionsKey, jsonEncode(sessions.map((session) => session.toJson()).toList()));
        }
      }
    } catch (e) {
      // ถ้ามีข้อผิดพลาดในการอัปเดตแคช ให้ข้ามไป
    }
  }
  
  // ลบเซสชันสมาธิออกจากแคช
  Future<void> _removeSessionFromCache(int sessionId) async {
    try {
      final String? cachedData = _prefs.getString(_focusSessionsKey);
      
      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        final List<FocusSession> sessions = decoded.map((item) => FocusSession.fromJson(item)).toList();
        
        sessions.removeWhere((session) => session.id == sessionId);
        
        await _prefs.setString(_focusSessionsKey, jsonEncode(sessions.map((session) => session.toJson()).toList()));
      }
    } catch (e) {
      // ถ้ามีข้อผิดพลาดในการลบจากแคช ให้ข้ามไป
    }
  }
  
  // ล้างแคชทั้งหมดของ FocusRepository
  Future<void> clearAllCache() async {
    try {
      await _prefs.remove(_focusSessionsKey);
      await _prefs.remove(_focusThemesKey);
      await _prefs.remove(_activeSessionKey);
    } catch (e) {
      throw CacheException('Failed to clear focus cache: ${e.toString()}');
    }
  }
} 