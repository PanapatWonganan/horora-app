import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../models/models.dart';
import '../utils/exceptions.dart' as app_exceptions;

class TarotRepository {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;

  // Key constants for SharedPreferences
  static const String _tarotCardsKey = 'tarot_cards';
  static const String _userReadingsKey = 'user_tarot_readings';

  TarotRepository({
    required ApiClient apiClient,
    required SharedPreferences prefs,
  })  : _apiClient = apiClient,
        _prefs = prefs;

  // ดึงข้อมูลไพ่ทาโร่ทั้งหมด
  Future<List<TarotCard>> getAllTarotCards() async {
    try {
      // ตรวจสอบว่ามีข้อมูลในแคชหรือไม่
      final String? cachedData = _prefs.getString(_tarotCardsKey);

      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        return decoded.map((item) => TarotCard.fromJson(item)).toList();
      }

      // ถ้าไม่มีข้อมูลในแคช ให้ดึงจาก API
      final response = await _apiClient.get('/tarot/cards');

      final List<TarotCard> tarotCards =
          (response as List).map((item) => TarotCard.fromJson(item)).toList();

      // บันทึกข้อมูลลงในแคช
      await _prefs.setString(_tarotCardsKey,
          jsonEncode(tarotCards.map((card) => card.toJson()).toList()));

      return tarotCards;
    } catch (e) {
      throw app_exceptions.DataException(
          'Failed to get tarot cards: ${e.toString()}');
    }
  }

  // ดึงข้อมูลไพ่ทาโร่ตาม ID
  Future<TarotCard> getTarotCardById(int id) async {
    try {
      final List<TarotCard> allCards = await getAllTarotCards();

      final TarotCard card = allCards.firstWhere(
        (card) => card.id == id,
        orElse: () =>
            throw app_exceptions.DataException('Tarot card not found: $id'),
      );

      return card;
    } catch (e) {
      throw app_exceptions.DataException(
          'Failed to get tarot card: ${e.toString()}');
    }
  }

  // ดึงข้อมูลไพ่ทาโร่ตามชื่อ
  Future<TarotCard> getTarotCardByName(String name) async {
    try {
      final List<TarotCard> allCards = await getAllTarotCards();

      final TarotCard card = allCards.firstWhere(
        (card) =>
            card.name.toLowerCase() == name.toLowerCase() ||
            card.nameTh.toLowerCase() == name.toLowerCase(),
        orElse: () =>
            throw app_exceptions.DataException('Tarot card not found: $name'),
      );

      return card;
    } catch (e) {
      throw app_exceptions.DataException(
          'Failed to get tarot card: ${e.toString()}');
    }
  }

  // ดึงข้อมูลไพ่ทาโร่ตามชุด (suit)
  Future<List<TarotCard>> getTarotCardsBySuit(String suit) async {
    try {
      final List<TarotCard> allCards = await getAllTarotCards();

      return allCards
          .where((card) => card.suit.toLowerCase() == suit.toLowerCase())
          .toList();
    } catch (e) {
      throw app_exceptions.DataException(
          'Failed to get tarot cards by suit: ${e.toString()}');
    }
  }

  // สุ่มไพ่ทาโร่
  Future<TarotCard> getRandomTarotCard() async {
    try {
      final response = await _apiClient.get('/tarot/random');
      return TarotCard.fromJson(response);
    } catch (e) {
      throw app_exceptions.DataException(
          'Failed to get random tarot card: ${e.toString()}');
    }
  }

  // สุ่มไพ่ทาโร่หลายใบ
  Future<List<TarotCard>> getRandomTarotCards(int count) async {
    try {
      final response = await _apiClient.get('/tarot/random/$count');

      return (response as List)
          .map((item) => TarotCard.fromJson(item))
          .toList();
    } catch (e) {
      throw app_exceptions.DataException(
          'Failed to get random tarot cards: ${e.toString()}');
    }
  }

  // สร้างการอ่านไพ่ทาโร่ใหม่
  Future<TarotReading> createTarotReading({
    required String spreadType,
    required String question,
    required List<TarotCardPosition> cards,
  }) async {
    try {
      final data = {
        'spread_type': spreadType,
        'question': question,
        'cards': cards.map((card) => card.toJson()).toList(),
      };

      final response = await _apiClient.post('/tarot/readings', body: data);
      return TarotReading.fromJson(response);
    } on app_exceptions.ApiException catch (e) {
      if (e is app_exceptions.UnauthorizedException) {
        throw app_exceptions.AuthException('User not authenticated');
      }
      rethrow;
    } catch (e) {
      throw app_exceptions.DataException(
          'Failed to create tarot reading: ${e.toString()}');
    }
  }

  // ดึงข้อมูลการอ่านไพ่ทาโร่ของผู้ใช้
  Future<List<TarotReading>> getUserTarotReadings() async {
    try {
      // ดึงข้อมูลจาก API
      final response = await _apiClient.get('/tarot/readings');

      final List<TarotReading> readings = (response as List)
          .map((item) => TarotReading.fromJson(item))
          .toList();

      // บันทึกข้อมูลลงในแคช
      await _prefs.setString(_userReadingsKey,
          jsonEncode(readings.map((reading) => reading.toJson()).toList()));

      return readings;
    } on app_exceptions.ApiException catch (e) {
      if (e is app_exceptions.UnauthorizedException) {
        throw app_exceptions.AuthException('User not authenticated');
      }
      rethrow;
    } catch (e) {
      // ถ้ามีข้อผิดพลาด แต่มีข้อมูลในแคช ให้ใช้ข้อมูลจากแคช
      final String? cachedData = _prefs.getString(_userReadingsKey);
      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        return decoded.map((item) => TarotReading.fromJson(item)).toList();
      }

      throw app_exceptions.DataException(
          'Failed to get user tarot readings: ${e.toString()}');
    }
  }

  // ดึงข้อมูลการอ่านไพ่ทาโร่ตาม ID
  Future<TarotReading> getTarotReadingById(int id) async {
    try {
      final response = await _apiClient.get('/tarot/readings/$id');
      return TarotReading.fromJson(response);
    } on app_exceptions.ApiException catch (e) {
      if (e is app_exceptions.UnauthorizedException) {
        throw app_exceptions.AuthException('User not authenticated');
      }
      rethrow;
    } catch (e) {
      throw app_exceptions.DataException(
          'Failed to get tarot reading: ${e.toString()}');
    }
  }

  // บันทึกการอ่านไพ่ทาโร่
  Future<TarotReading> saveTarotReading(int readingId) async {
    try {
      final response = await _apiClient.put('/tarot/readings/$readingId/save');

      // อัปเดตแคช
      await _updateReadingInCache(TarotReading.fromJson(response));

      return TarotReading.fromJson(response);
    } on app_exceptions.ApiException catch (e) {
      if (e is app_exceptions.UnauthorizedException) {
        throw app_exceptions.AuthException('User not authenticated');
      }
      rethrow;
    } catch (e) {
      throw app_exceptions.DataException(
          'Failed to save tarot reading: ${e.toString()}');
    }
  }

  // ยกเลิกการบันทึกการอ่านไพ่ทาโร่
  Future<TarotReading> unsaveTarotReading(int readingId) async {
    try {
      final response =
          await _apiClient.put('/tarot/readings/$readingId/unsave');

      // อัปเดตแคช
      await _updateReadingInCache(TarotReading.fromJson(response));

      return TarotReading.fromJson(response);
    } on app_exceptions.ApiException catch (e) {
      if (e is app_exceptions.UnauthorizedException) {
        throw app_exceptions.AuthException('User not authenticated');
      }
      rethrow;
    } catch (e) {
      throw app_exceptions.DataException(
          'Failed to unsave tarot reading: ${e.toString()}');
    }
  }

  // ลบการอ่านไพ่ทาโร่
  Future<void> deleteTarotReading(int readingId) async {
    try {
      await _apiClient.delete('/tarot/readings/$readingId');

      // อัปเดตแคช
      await _removeReadingFromCache(readingId);
    } on app_exceptions.ApiException catch (e) {
      if (e is app_exceptions.UnauthorizedException) {
        throw app_exceptions.AuthException('User not authenticated');
      }
      rethrow;
    } catch (e) {
      throw app_exceptions.DataException(
          'Failed to delete tarot reading: ${e.toString()}');
    }
  }

  // อัปเดตการอ่านไพ่ทาโร่ในแคช
  Future<void> _updateReadingInCache(TarotReading updatedReading) async {
    try {
      final String? cachedData = _prefs.getString(_userReadingsKey);

      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        final List<TarotReading> readings =
            decoded.map((item) => TarotReading.fromJson(item)).toList();

        final int index =
            readings.indexWhere((reading) => reading.id == updatedReading.id);

        if (index != -1) {
          readings[index] = updatedReading;
          await _prefs.setString(_userReadingsKey,
              jsonEncode(readings.map((reading) => reading.toJson()).toList()));
        }
      }
    } catch (e) {
      // ถ้ามีข้อผิดพลาดในการอัปเดตแคช ให้ข้ามไป
    }
  }

  // ลบการอ่านไพ่ทาโร่ออกจากแคช
  Future<void> _removeReadingFromCache(int readingId) async {
    try {
      final String? cachedData = _prefs.getString(_userReadingsKey);

      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        final List<TarotReading> readings =
            decoded.map((item) => TarotReading.fromJson(item)).toList();

        readings.removeWhere((reading) => reading.id == readingId);

        await _prefs.setString(_userReadingsKey,
            jsonEncode(readings.map((reading) => reading.toJson()).toList()));
      }
    } catch (e) {
      // ถ้ามีข้อผิดพลาดในการลบจากแคช ให้ข้ามไป
    }
  }

  // ล้างแคชทั้งหมดของ TarotRepository
  Future<void> clearAllCache() async {
    try {
      await _prefs.remove(_tarotCardsKey);
      await _prefs.remove(_userReadingsKey);
    } catch (e) {
      throw app_exceptions.CacheException(
          'Failed to clear tarot cache: ${e.toString()}');
    }
  }
}
