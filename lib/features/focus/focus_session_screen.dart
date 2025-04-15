import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/theme/app_colors.dart';
import 'widgets/cosmic_background.dart';
import 'widgets/meditation_timer.dart';
import 'widgets/sound_control.dart';
import 'services/focus_audio_service.dart';

// เฟสการหายใจทั้ง 3 แบบของเทคนิค 4-7-8
enum BreathingPhase {
  inhale, // หายใจเข้า
  hold, // กลั้นหายใจ
  exhale, // หายใจออก
}

class FocusSessionScreen extends StatefulWidget {
  const FocusSessionScreen({Key? key}) : super(key: key);

  @override
  State<FocusSessionScreen> createState() => _FocusSessionScreenState();
}

class _FocusSessionScreenState extends State<FocusSessionScreen>
    with TickerProviderStateMixin {
  // Timer related variables
  int _selectedDuration = 10; // Default 10 minutes
  bool _isSessionActive = false;
  bool _isPaused = false;
  int _remainingSeconds = 0;
  late Timer _timer;

  // Animation controllers
  late AnimationController _breathingAnimationController;
  late AnimationController _backgroundAnimationController;

  // Breathing phase tracking
  BreathingPhase _currentBreathingPhase = BreathingPhase.inhale;

  // Sound related variables
  String _selectedSoundscape =
      'guided_5min'; // แก้ไขค่าเริ่มต้นให้ตรงกับ service
  bool _isSoundOn = true;
  double _volume = 0.7;
  late FocusAudioService _audioService;

  final List<Map<String, dynamic>> _availableDurations = [
    {'label': '5 นาที', 'value': 5},
    {'label': '10 นาที', 'value': 10},
    {'label': '15 นาที', 'value': 15},
    {'label': '20 นาที', 'value': 20},
    {'label': '30 นาที', 'value': 30},
    {'label': '45 นาที', 'value': 45},
    {'label': '60 นาที', 'value': 60},
  ];

  @override
  void initState() {
    super.initState();

    // Initialize audio service
    _audioService = FocusAudioService();

    // Initialize breathing animation controller for 4-7-8 technique
    _setupBreathingAnimation();

    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(minutes: 3),
    )..repeat(reverse: false);
  }

  void _setupBreathingAnimation() {
    // สร้าง animation controller ใหม่สำหรับการเริ่มต้นเฟสการหายใจเข้า
    _breathingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // หายใจเข้า 4 วินาที
    );

    // ตั้งค่า listener เพื่อจัดการกับเฟสการหายใจทั้ง 3 เฟส (เข้า-กลั้น-ออก)
    _breathingAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // เมื่อหายใจเข้าเสร็จ (4 วินาที) ให้เริ่มเฟสกลั้นหายใจ
        if (_currentBreathingPhase == BreathingPhase.inhale) {
          setState(() {
            _currentBreathingPhase = BreathingPhase.hold;
          });

          // กลั้นหายใจ 7 วินาที แล้วค่อยเริ่มหายใจออก
          Future.delayed(const Duration(seconds: 7), () {
            if (mounted && _isSessionActive && !_isPaused) {
              setState(() {
                _currentBreathingPhase = BreathingPhase.exhale;
              });

              // เริ่มหายใจออก 8 วินาที
              _breathingAnimationController.duration =
                  const Duration(seconds: 8);
              _breathingAnimationController.reverse();
            }
          });
        }
      } else if (status == AnimationStatus.dismissed) {
        // เมื่อหายใจออกเสร็จ (8 วินาที) ให้เริ่มวงจรใหม่
        if (_currentBreathingPhase == BreathingPhase.exhale &&
            mounted &&
            _isSessionActive &&
            !_isPaused) {
          setState(() {
            _currentBreathingPhase = BreathingPhase.inhale;
          });

          // เตรียมพร้อมสำหรับการหายใจเข้ารอบใหม่
          _breathingAnimationController.duration = const Duration(seconds: 4);
          _breathingAnimationController.forward();
        }
      }
    });

    // เริ่มต้นวงจรการหายใจ
    _breathingAnimationController.forward();
  }

  @override
  void dispose() {
    if (_isSessionActive) {
      _timer.cancel();
    }
    _breathingAnimationController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  void _startSession() {
    setState(() {
      _isSessionActive = true;
      _isPaused = false;
      _remainingSeconds = _selectedDuration * 60;
      _currentBreathingPhase = BreathingPhase.inhale;
    });

    // เล่นเสียงที่เลือก
    _audioService.playAudio(_selectedSoundscape);

    // รีเซ็ตและเริ่ม animation การหายใจใหม่
    _breathingAnimationController.stop();
    _setupBreathingAnimation();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _completeSession();
        }
      });
    });
  }

  void _pauseSession() {
    if (_isSessionActive) {
      if (_isPaused) {
        // Resume
        _audioService.resumeAudio();

        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            if (_remainingSeconds > 0) {
              _remainingSeconds--;
            } else {
              _completeSession();
            }
          });
        });

        _breathingAnimationController.forward();

        setState(() {
          _isPaused = false;
        });
      } else {
        // Pause
        _audioService.pauseAudio();
        _timer.cancel();
        _breathingAnimationController.stop();
        setState(() {
          _isPaused = true;
        });
      }
    }
  }

  void _stopSession() {
    if (_isSessionActive) {
      _timer.cancel();
      _audioService.pauseAudio();
      setState(() {
        _isSessionActive = false;
        _isPaused = false;
      });

      // Show dialog asking if user wants to save the session
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('ยกเลิกการนั่งสมาธิ'),
          content:
              const Text('คุณต้องการบันทึกช่วงเวลาการนั่งสมาธินี้หรือไม่?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ไม่บันทึก'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Save session data
                Navigator.pop(context);
              },
              child: const Text('บันทึก'),
            ),
          ],
        ),
      );
    }
  }

  void _completeSession() {
    _timer.cancel();
    _audioService.pauseAudio();
    setState(() {
      _isSessionActive = false;
    });

    // Navigate to insights screen
    // TODO: Navigate to insights screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('การนั่งสมาธิเสร็จสมบูรณ์'),
        content: const Text(
            'ขอแสดงความยินดี! คุณได้ใช้เวลาในการนั่งสมาธิอย่างมีสติ ต้องการดูข้อมูลเชิงลึกหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to insights screen
              Navigator.pop(context);
            },
            child: const Text('ดูข้อมูลเชิงลึก'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Cosmic animated background
          CosmicBackground(
            animationController: _backgroundAnimationController,
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // App bar with minimal controls
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.arrow_back, color: Colors.white70),
                        onPressed: () {
                          if (_isSessionActive) {
                            // Show confirmation dialog
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('ออกจากการนั่งสมาธิ'),
                                content: const Text(
                                    'คุณแน่ใจหรือไม่ว่าต้องการออกจากการนั่งสมาธิ? ความคืบหน้าของคุณจะหายไป'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('ยกเลิก'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close dialog
                                      Navigator.pop(context); // Go back
                                    },
                                    child: const Text('ออก'),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ),
                      if (!_isSessionActive)
                        IconButton(
                          icon: const Icon(Icons.help_outline,
                              color: Colors.white70),
                          onPressed: () {
                            // Show help dialog
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('วิธีการนั่งสมาธิ'),
                                content: const SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                          '1. เลือกระยะเวลาที่ต้องการนั่งสมาธิ'),
                                      Text(
                                          '2. เลือกเสียงพื้นหลังที่ช่วยให้คุณผ่อนคลาย'),
                                      Text(
                                          '3. กดปุ่มเริ่มเพื่อเริ่มการนั่งสมาธิ'),
                                      Text(
                                          '4. หายใจเข้าและออกตามจังหวะของวงกลม'),
                                      Text(
                                          '5. ปล่อยให้ความคิดของคุณล่องลอยไปและกลับมาโฟกัสที่ลมหายใจ'),
                                      SizedBox(height: 16),
                                      Text('ขอให้มีความสุขในการนั่งสมาธิ!'),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('เข้าใจแล้ว'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),

                // Main content area
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Session title
                      if (!_isSessionActive)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 32.0),
                          child: Text(
                            'โหมดสมาธิ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      // Timer display or duration selector
                      if (_isSessionActive)
                        MeditationTimer(
                          remainingTime: _formatTime(_remainingSeconds),
                          animationController: _breathingAnimationController,
                          breathingPhase: _currentBreathingPhase,
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Column(
                            children: [
                              const Text(
                                'เลือกระยะเวลา',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16.0,
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                alignment: WrapAlignment.center,
                                children: _availableDurations.map((duration) {
                                  bool isSelected =
                                      duration['value'] == _selectedDuration;
                                  return ChoiceChip(
                                    label: Text(duration['label']),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() {
                                        _selectedDuration = duration['value'];
                                      });
                                    },
                                    backgroundColor: Colors.black38,
                                    selectedColor:
                                        AppColors.primary.withOpacity(0.6),
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white70,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 32.0),

                      // Sound controls
                      if (!_isSessionActive)
                        SoundControl(
                          availableSoundscapes:
                              _audioService.availableSoundscapes,
                          selectedSoundscape: _selectedSoundscape,
                          isSoundOn: _isSoundOn,
                          volume: _volume,
                          onSoundscapeChanged: (value) {
                            setState(() {
                              _selectedSoundscape = value;
                            });
                          },
                          onSoundToggled: (value) {
                            setState(() {
                              _isSoundOn = value;
                            });
                            _audioService.setSoundOn(value);
                          },
                          onVolumeChanged: (value) {
                            setState(() {
                              _volume = value;
                            });
                            _audioService.setVolume(value);
                          },
                        ),
                    ],
                  ),
                ),

                // Bottom controls
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isSessionActive) ...[
                        // Stop button
                        FloatingActionButton(
                          heroTag: 'stop',
                          onPressed: _stopSession,
                          backgroundColor: Colors.red.withOpacity(0.8),
                          child: const Icon(Icons.stop),
                        ),
                        const SizedBox(width: 24.0),
                        // Pause/Resume button
                        FloatingActionButton(
                          heroTag: 'pause',
                          onPressed: _pauseSession,
                          backgroundColor: AppColors.primary.withOpacity(0.8),
                          child:
                              Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                        ),
                      ] else
                        // Start button
                        SizedBox(
                          width: 80.0,
                          height: 80.0,
                          child: FloatingActionButton(
                            heroTag: 'start',
                            onPressed: _startSession,
                            backgroundColor: AppColors.primary.withOpacity(0.8),
                            child: const Icon(Icons.play_arrow, size: 40.0),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
