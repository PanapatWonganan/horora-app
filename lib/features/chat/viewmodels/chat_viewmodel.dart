import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../repositories/chat_repository.dart';

enum ChatViewState {
  idle,
  loading,
  success,
  error,
}

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _repository = ChatRepository();

  bool _disposed = false;

  // State variables
  ChatViewState _state = ChatViewState.idle;
  String? _errorMessage;
  List<ChatSession> _chatHistory = [];
  ChatSession? _currentSession;
  bool _isTyping = false;
  String? _userZodiacSign;
  String? _userZodiacSignThai;
  
  // Getters
  ChatViewState get state => _state;
  String? get errorMessage => _errorMessage;
  List<ChatSession> get chatHistory => _chatHistory;
  ChatSession? get currentSession => _currentSession;
  List<ChatMessage> get messages => _currentSession?.messages ?? [];
  bool get isTyping => _isTyping;
  String? get userZodiacSign => _userZodiacSign;
  String? get userZodiacSignThai => _userZodiacSignThai;
  
  // Initialize ViewModel
  Future<void> initialize() async {
    _setState(ChatViewState.loading);
    try {
      await _loadChatHistory();
      await _loadUserZodiacSign();
    } catch (e) {
      debugPrint('Chat initialize warning (non-fatal): $e');
    }
    // เข้าหน้าแชทได้เสมอ แม้ API จะล้มเหลว
    _setState(ChatViewState.success);
  }
  
  // Load chat history
  Future<void> _loadChatHistory() async {
    try {
      _chatHistory = await _repository.getChatHistory();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading chat history: $e');
      _chatHistory = [];
    }
  }
  
  // Load user's zodiac sign
  Future<void> _loadUserZodiacSign() async {
    try {
      _userZodiacSign = await _repository.getUserZodiacSign();
      
      if (_userZodiacSign != null) {
        // _userZodiacSign ตอนนี้คือ Thai animal แล้ว เช่น "มะเมีย"
        // ไม่ต้องแปลงอะไรอีก เพียงแค่ใช้เป็น Thai name
        _userZodiacSignThai = 'ปี$_userZodiacSign';
        debugPrint('ChatViewModel: Loaded Thai zodiac - $_userZodiacSignThai');
      } else {
        debugPrint('ChatViewModel: No Thai zodiac sign found');
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user zodiac sign: $e');
    }
  }
  
  // Create new chat session
  void createNewSession(String topic) {
    final newSession = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      topic: topic,
      createdAt: DateTime.now(),
      messages: [],
      duration: 0,
    );
    
    _currentSession = newSession;
    notifyListeners();
    
    // เพิ่มข้อความต้อนรับจากระบบ
    final welcomeMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: 'ยินดีต้อนรับสู่การสนทนากับนักพยากรณ์ดวงดาว\nหัวข้อ: $topic',
      timestamp: DateTime.now(),
      isUser: false,
      isSystemMessage: true,
    );
    
    final updatedMessages = [...messages, welcomeMessage];
    _updateSessionMessages(updatedMessages);
    
    // ดึงข้อมูลราศีและเพิ่มข้อความเกี่ยวกับราศีของผู้ใช้
    _loadUserZodiacSign().then((_) {
      if (_userZodiacSignThai != null) {
        // สร้างข้อความที่น่าสนใจเกี่ยวกับราศีของผู้ใช้
        final zodiacMessage = _createZodiacMessage();
        
        final updatedMessagesWithZodiac = [..._currentSession!.messages, zodiacMessage];
        _updateSessionMessages(updatedMessagesWithZodiac);
      }
    });
  }
  
  // สร้างข้อความที่น่าสนใจเกี่ยวกับราศีของผู้ใช้
  ChatMessage _createZodiacMessage() {
    // ข้อมูลลักษณะเด่นของแต่ละปีนักษัตรไทย
    final Map<String, String> thaiZodiacTraits = {
      'ปีชวด': 'คุณเป็นคนขยัน อดทน รอบคอบ มีไหวพริบ และเก็บเงินเก่ง',
      'ปีฉลู': 'คุณเป็นคนอดทน มั่นคง เชื่อถือได้ ทำงานหนัก และรักความมั่นคง',
      'ปีขาล': 'คุณเป็นคนกล้าหาญ มีความเป็นผู้นำ อิสระ และชอบการผจญภัย',
      'ปีเถาะ': 'คุณเป็นคนอ่อนโยน มีมารยาท รักสันติ และชอบความงาม',
      'ปีมะโรง': 'คุณเป็นคนทะเยอทะยาน มีพลัง มั่นใจ และชอบเป็นที่สนใจ',
      'ปีมะเส็ง': 'คุณเป็นคนลึกซึ้ง ปัญญาดี ชอบการเรียนรู้ และมีสัญชาตญาณ',
      'ปีมะเมีย': 'คุณเป็นคนกระฉับกระเฉง รักเสรีภาพ ตรงไปตรงมา และชอบเดินทาง',
      'ปีมะแม': 'คุณเป็นคนอ่อนโยน ศิลปิน ชอบความงาม และมีจิตใจนุ่มนวล',
      'ปีวอก': 'คุณเป็นคนฉลาด เก่ง มีไหวพริบ ชอบเปลี่ยนแปลง และมีจิตใจเปิดกว้าง',
      'ปีระกา': 'คุณเป็นคนตรงไปตรงมา รักความสะอาด มีระเบียบแบบแผน และชอบความสวยงาม',
      'ปีจอ': 'คุณเป็นคนซื่อสัตย์ จริงใจ มีความรับผิดชอบสูง และรักครอบครัว',
      'ปีกุน': 'คุณเป็นคนใจกว้าง เอื้อเฟื้อ มีน้ำใจ และรักความสุขสบาย',
    };
    
    // ข้อมูลธาตุของแต่ละปีนักษัตรไทย (ขึ้นอยู่กับปีเกิด)
    final Map<String, String> thaiZodiacElements = {
      'ปีชวด': 'ธาตุทอง',
      'ปีฉลู': 'ธาตุทอง', 
      'ปีขาล': 'ธาตุน้ำ',
      'ปีเถาะ': 'ธาตุน้ำ',
      'ปีมะโรง': 'ธาตุไม้',
      'ปีมะเส็ง': 'ธาตุไม้',
      'ปีมะเมีย': 'ธาตุไฟ',
      'ปีมะแม': 'ธาตุไฟ',
      'ปีวอก': 'ธาตุดิน',
      'ปีระกา': 'ธาตุดิน',
      'ปีจอ': 'ธาตุทอง',
      'ปีกุน': 'ธาตุทอง',
    };
    
    // ดึงลักษณะเด่นของปีนักษัตรของผู้ใช้
    final trait = thaiZodiacTraits[_userZodiacSignThai] ?? 'คุณมีลักษณะเฉพาะตัวที่น่าสนใจ';
    
    // ดึงธาตุของปีนักษัตรของผู้ใช้ (แต่ธาตุจริงควรคำนวณจากปีเกิด)
    final element = thaiZodiacElements[_userZodiacSignThai] ?? '';
    
    // สร้างข้อความที่น่าสนใจ
    final elementText = element.isNotEmpty ? ' ($element)' : '';
    final content = '''ฉันเห็นว่าคุณเกิด$_userZodiacSignThai$elementText

$trait

ฉันจะใช้ข้อมูลปีนักษัตรไทยนี้เพื่อให้คำทำนายที่เฉพาะเจาะจงสำหรับคุณ โดยอิงจากลักษณะเฉพาะของคนเกิด$_userZodiacSignThai และธาตุประจำปี''';
    
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      timestamp: DateTime.now(),
      isUser: false,
      isSystemMessage: true,
    );
  }
  
  // Load existing session
  void loadSession(String sessionId) {
    final session = _chatHistory.firstWhere(
      (session) => session.id == sessionId,
      orElse: () => throw Exception('Session not found'),
    );
    
    _currentSession = session;
    notifyListeners();
  }
  
  // Send message
  Future<void> sendMessage(String message) async {
    if (_currentSession == null) {
      _setError('No active chat session');
      return;
    }
    
    // Create user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message,
      timestamp: DateTime.now(),
      isUser: true,
    );
    
    // Add user message to current session
    final updatedMessages = [...messages, userMessage];
    _updateSessionMessages(updatedMessages);
    
    // Set typing indicator
    _isTyping = true;
    notifyListeners();
    
    try {
      // Send message to API
      final assistantMessage = await _repository.sendMessage(
        message: message,
        history: messages,
        topic: _currentSession!.topic,
      );
      
      // Add assistant message to current session
      final finalMessages = [...updatedMessages, assistantMessage];
      _updateSessionMessages(finalMessages);
      
      // Save session to database
      await _saveCurrentSession();
      
      _isTyping = false;
      notifyListeners();
    } catch (e) {
      _isTyping = false;
      // แสดง error เป็นข้อความในแชท แทนที่จะเปลี่ยน state ทั้งหน้า
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'ขออภัย ไม่สามารถเชื่อมต่อกับนักพยากรณ์ได้ในขณะนี้ กรุณาลองใหม่อีกครั้ง',
        timestamp: DateTime.now(),
        isUser: false,
        isSystemMessage: true,
      );
      final errorMessages = [...updatedMessages, errorMessage];
      _updateSessionMessages(errorMessages);
      debugPrint('Failed to send message: $e');
    }
  }
  
  // Update session messages
  void _updateSessionMessages(List<ChatMessage> updatedMessages) {
    if (_currentSession == null) return;
    
    _currentSession = ChatSession(
      id: _currentSession!.id,
      topic: _currentSession!.topic,
      createdAt: _currentSession!.createdAt,
      lastMessageAt: DateTime.now(),
      messages: updatedMessages,
      duration: _calculateSessionDuration(),
    );
    
    notifyListeners();
  }
  
  // Calculate session duration in minutes
  int _calculateSessionDuration() {
    if (_currentSession == null) return 0;
    
    final now = DateTime.now();
    final start = _currentSession!.createdAt;
    final difference = now.difference(start);
    
    return difference.inMinutes;
  }
  
  // Save current session
  Future<void> _saveCurrentSession() async {
    if (_currentSession == null) return;
    
    try {
      await _repository.saveChatSession(_currentSession!);
      await _loadChatHistory(); // Refresh history
    } catch (e) {
      debugPrint('Error saving chat session: $e');
    }
  }
  
  // End current session
  Future<void> endSession() async {
    if (_currentSession == null) return;
    
    try {
      await _saveCurrentSession();
      _currentSession = null;
      notifyListeners();
    } catch (e) {
      _setError('Failed to end session: $e');
    }
  }
  
  // Helper methods for state management
  void _setState(ChatViewState newState) {
    _state = newState;
    _errorMessage = null;
    notifyListeners();
  }
  
  void _setError(String message) {
    _state = ChatViewState.error;
    _errorMessage = message;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}