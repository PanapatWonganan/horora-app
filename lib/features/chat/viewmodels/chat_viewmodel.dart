import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../repositories/chat_repository.dart';
import '../../../core/utils/zodiac_utils.dart';

enum ChatViewState {
  idle,
  loading,
  success,
  error,
}

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _repository = ChatRepository();
  
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
      _setState(ChatViewState.success);
    } catch (e) {
      _setError('Failed to initialize chat: $e');
    }
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
        _userZodiacSignThai = ZodiacUtils.getZodiacSignThai(
          DateTime(2000, 1, 1), // Dummy date, we already have the zodiac sign
          zodiacSign: _userZodiacSign,
        );
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
    // ข้อความเกี่ยวกับลักษณะเด่นของแต่ละราศี
    final Map<String, String> zodiacTraits = {
      'ราศีเมษ': 'คุณเป็นคนกล้าหาญ มีความเป็นผู้นำสูง และมีพลังงานเต็มเปี่ยม',
      'ราศีพฤษภ': 'คุณเป็นคนรักความมั่นคง มีความอดทนสูง และมีรสนิยมดี',
      'ราศีเมถุน': 'คุณเป็นคนช่างพูด มีความคิดสร้างสรรค์ และปรับตัวเก่ง',
      'ราศีกรกฎ': 'คุณเป็นคนมีความรู้สึกลึกซึ้ง เอาใจใส่ และมีความจงรักภักดี',
      'ราศีสิงห์': 'คุณเป็นคนมีเสน่ห์ มีความมั่นใจ และมีความกระตือรือร้น',
      'ราศีกันย์': 'คุณเป็นคนละเอียดรอบคอบ มีเหตุผล และชอบช่วยเหลือผู้อื่น',
      'ราศีตุลย์': 'คุณเป็นคนรักความสมดุล มีเสน่ห์ และมีความยุติธรรม',
      'ราศีพิจิก': 'คุณเป็นคนมีพลังและความมุ่งมั่นสูง มีความลึกลับ และมีสัญชาตญาณดี',
      'ราศีธนู': 'คุณเป็นคนมองโลกในแง่ดี รักอิสระ และชอบผจญภัย',
      'ราศีมังกร': 'คุณเป็นคนมีความทะเยอทะยาน มีวินัย และมีความรับผิดชอบสูง',
      'ราศีกุมภ์': 'คุณเป็นคนมีความคิดก้าวหน้า มีความเป็นตัวของตัวเอง และชอบช่วยเหลือสังคม',
      'ราศีมีน': 'คุณเป็นคนมีจินตนาการสูง มีความเห็นอกเห็นใจ และมีความอ่อนไหว',
    };
    
    // ข้อมูลธาตุของแต่ละราศี
    final Map<String, String> zodiacElements = {
      'ราศีเมษ': 'ธาตุไฟ',
      'ราศีพฤษภ': 'ธาตุดิน',
      'ราศีเมถุน': 'ธาตุลม',
      'ราศีกรกฎ': 'ธาตุน้ำ',
      'ราศีสิงห์': 'ธาตุไฟ',
      'ราศีกันย์': 'ธาตุดิน',
      'ราศีตุลย์': 'ธาตุลม',
      'ราศีพิจิก': 'ธาตุน้ำ',
      'ราศีธนู': 'ธาตุไฟ',
      'ราศีมังกร': 'ธาตุดิน',
      'ราศีกุมภ์': 'ธาตุลม',
      'ราศีมีน': 'ธาตุน้ำ',
    };
    
    // ดึงลักษณะเด่นของราศีของผู้ใช้
    final trait = zodiacTraits[_userZodiacSignThai] ?? 'คุณมีลักษณะเฉพาะตัวที่น่าสนใจ';
    
    // ดึงธาตุของราศีของผู้ใช้
    final element = zodiacElements[_userZodiacSignThai] ?? '';
    
    // ดึงช่วงวันที่ของราศี
    final dateRange = _userZodiacSign != null 
        ? ZodiacUtils.getZodiacDateRange(_userZodiacSign!) 
        : '';
    
    // สร้างข้อความที่น่าสนใจ
    final content = '''ฉันเห็นว่าคุณเกิด$_userZodiacSignThai ($element)
ช่วงวันที่: $dateRange

$trait

ฉันจะใช้ข้อมูลนี้เพื่อให้คำทำนายที่เฉพาะเจาะจงสำหรับคุณ''';
    
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
      _setError('Failed to send message: $e');
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
} 