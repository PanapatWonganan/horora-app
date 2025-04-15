import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

/// บริการสำหรับจัดการการเล่นไฟล์เสียงในโหมดสมาธิ
class FocusAudioService {
  /// AudioPlayer instance สำหรับเล่นไฟล์เสียง
  late AudioPlayer _audioPlayer;

  /// ความดังเสียงปัจจุบัน (0.0 - 1.0)
  double _volume = 0.7;

  /// สถานะว่าเสียงเปิดอยู่หรือไม่
  bool _isSoundOn = true;

  /// ชื่อไฟล์เสียงที่กำลังเล่นอยู่
  String? _currentAudioFile;

  /// รายการไฟล์เสียงที่มี
  final List<Map<String, dynamic>> availableSoundscapes = [
    {
      'label': 'นั่งสมาธิ 5 นาที',
      'value': 'guided_5min',
      'icon': Icons.self_improvement,
      'file': 'assets/audio/guided/guided_meditation_5min.mp3'
    },
    {
      'label': 'นั่งสมาธิ 10 นาที',
      'value': 'guided_10min',
      'icon': Icons.self_improvement,
      'file': 'assets/audio/guided/guided_meditation_10min.mp3'
    },
    {
      'label': 'นั่งสมาธิ 15 นาที',
      'value': 'guided_15min',
      'icon': Icons.self_improvement,
      'file': 'assets/audio/guided/guided_meditation_15min.mp3'
    },
  ];

  /// สร้าง singleton instance
  static final FocusAudioService _instance = FocusAudioService._internal();

  /// Constructor สำหรับเรียกใช้ singleton
  factory FocusAudioService() {
    return _instance;
  }

  /// Internal constructor
  FocusAudioService._internal() {
    _initAudioPlayer();
  }

  /// สร้าง AudioPlayer instance
  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer();
    debugPrint('FocusAudioService initialized');
  }

  /// ตั้งค่าความดังเสียง
  Future<void> setVolume(double volume) async {
    _volume = volume;
    if (_isSoundOn) {
      await _audioPlayer.setVolume(volume);
    }
  }

  /// ตั้งค่าการเปิด/ปิดเสียง
  Future<void> setSoundOn(bool isOn) async {
    _isSoundOn = isOn;
    if (!isOn) {
      await _audioPlayer.pause();
    } else if (_currentAudioFile != null) {
      await _audioPlayer.play();
    }
  }

  /// เล่นไฟล์เสียงจาก value
  Future<void> playAudio(String soundscapeValue) async {
    if (!_isSoundOn) return;

    String? audioFile;
    for (final soundscape in availableSoundscapes) {
      if (soundscape['value'] == soundscapeValue) {
        audioFile = soundscape['file'];
        break;
      }
    }

    if (audioFile != null) {
      await _playAudioFromAsset(audioFile);
    }
  }

  /// เล่นไฟล์เสียงจากพาธไฟล์โดยตรง
  Future<void> playAudioFromPath(String audioPath) async {
    if (!_isSoundOn) return;
    await _playAudioFromAsset(audioPath);
  }

  /// ฟังก์ชันภายในสำหรับเล่นไฟล์เสียง
  Future<void> _playAudioFromAsset(String assetPath) async {
    try {
      // หยุดการเล่นเดิม (ถ้ามี)
      await _stopAudio();

      // เก็บพาธไฟล์ที่กำลังเล่น
      _currentAudioFile = assetPath;

      // รีเซ็ต player
      _audioPlayer = AudioPlayer();
      debugPrint('New AudioPlayer instance created');

      // แสดงข้อความกำลังเตรียมไฟล์
      debugPrint('Attempting to load asset: $assetPath');

      // ตั้งค่า AudioSource และโหลดไฟล์
      try {
        await _audioPlayer.setAudioSource(
          AudioSource.asset(assetPath),
          initialPosition: Duration.zero,
        );
        debugPrint('Audio source set successfully');
      } catch (e) {
        debugPrint('Error setting audio source: $e');
        throw Exception('Failed to load audio file: $e');
      }

      // ตั้งค่าความดัง
      await _audioPlayer.setVolume(_volume);
      debugPrint('Volume set to $_volume');

      // เริ่มเล่นเสียง
      await _audioPlayer.play();
      debugPrint('Audio playback started for: $assetPath');
    } catch (e) {
      debugPrint('❌ Error playing audio: $e');

      // ลองเล่นไฟล์ยังอีกวิธี (เผื่อการโหลดแบบ AudioSource ไม่ทำงาน)
      try {
        debugPrint('Trying alternative method...');
        await _audioPlayer.setAsset(assetPath);
        await _audioPlayer.setVolume(_volume);
        await _audioPlayer.play();
        debugPrint('Alternative method successful');
      } catch (e2) {
        debugPrint('❌ Alternative method also failed: $e2');
        _initAudioPlayer(); // รีเซ็ต player หากทั้งสองวิธีล้มเหลว
      }
    }
  }

  /// หยุดเล่นชั่วคราว
  Future<void> pauseAudio() async {
    try {
      await _audioPlayer.pause();
      debugPrint('Audio paused');
    } catch (e) {
      debugPrint('Error pausing audio: $e');
    }
  }

  /// เล่นต่อหลังจากหยุดชั่วคราว
  Future<void> resumeAudio() async {
    if (!_isSoundOn || _currentAudioFile == null) return;

    try {
      await _audioPlayer.play();
      debugPrint('Audio resumed');
    } catch (e) {
      debugPrint('Error resuming audio: $e');
    }
  }

  /// หยุดเล่นเสียง
  Future<void> _stopAudio() async {
    if (_audioPlayer.processingState == ProcessingState.idle) {
      debugPrint('Player already in idle state, no need to stop');
      return;
    }

    try {
      debugPrint('Attempting to stop audio playback');
      await _audioPlayer.stop();
      _currentAudioFile = null;
      debugPrint('Audio stopped successfully');
    } catch (e) {
      debugPrint('Error stopping audio: $e');
      // ทำการสร้าง player ใหม่ในกรณีที่มีปัญหา
      try {
        await _audioPlayer.dispose();
      } catch (_) {}
      _initAudioPlayer();
    }
  }

  /// หยุดและทำความสะอาด resource
  Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
      debugPrint('FocusAudioService disposed');
    } catch (e) {
      debugPrint('Error disposing audio player: $e');
    }
  }

  /// ดูว่าเสียงกำลังเล่นอยู่หรือไม่
  bool get isPlaying => _audioPlayer.playing;

  /// ดูว่าเสียงเปิดอยู่หรือไม่
  bool get isSoundOn => _isSoundOn;

  /// ดูความดังเสียงปัจจุบัน
  double get volume => _volume;
}
