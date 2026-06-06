import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/routes.dart';
import '../../core/services/auth_guard.dart';
import '../shared/widgets/app_bottom_navigation.dart';
import 'viewmodels/chat_viewmodel.dart';
import 'widgets/chat_message_item.dart';
import 'widgets/chat_input.dart';
import 'widgets/topic_selection_dialog.dart';
import '../report/report_dialog.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatViewModel _viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = ChatViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  Future<void> _initializeChat() async {
    // Chat AI ต้อง login (ทุก /chat/* ต้อง token) — gate ที่ทางเข้า
    if (!mounted) return;
    final allowed = await AuthGuard.requireAuth(context, intentLabel: 'chat');
    if (!mounted) return;
    if (!allowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เข้าสู่ระบบเพื่อพูดคุยกับนักพยากรณ์ได้นะ'),
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.home);
      return;
    }

    await _viewModel.initialize();
    if (!mounted) return;

    // If no active session, show topic selection dialog
    if (_viewModel.currentSession == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showTopicSelectionDialog();
      });
    }
  }

  void _showTopicSelectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TopicSelectionDialog(
        onTopicSelected: (topic) {
          _viewModel.createNewSession(topic);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            },
          ),
          title: Consumer<ChatViewModel>(
            builder: (context, viewModel, _) {
              return Text(
                viewModel.currentSession?.topic ?? 'สนทนากับนักพยากรณ์',
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                _showOptionsMenu();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Messages list
            Expanded(
              child: Consumer<ChatViewModel>(
                builder: (context, viewModel, _) {
                  if (viewModel.state == ChatViewState.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (viewModel.state == ChatViewState.error) {
                    return Center(
                      child: Text(
                        viewModel.errorMessage ?? 'เกิดข้อผิดพลาด',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (viewModel.messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: AppColors.primary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'เริ่มสนทนากับนักพยากรณ์',
                            style: TextStyle(
                              color: AppColors.lightText.withValues(alpha: 0.7),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: viewModel.messages.length +
                        (viewModel.isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == viewModel.messages.length) {
                        // Typing indicator
                        return const ChatMessageItem(
                          message: '',
                          isUser: false,
                          isTyping: true,
                        );
                      }

                      final message = viewModel.messages[index];
                      return ChatMessageItem(
                        message: message.content,
                        isUser: message.isUser,
                        isTyping: false,
                        isSystemMessage: message.isSystemMessage,
                        messageId: message.id,
                      );
                    },
                  );
                },
              ),
            ),

            // Input area
            Consumer<ChatViewModel>(
              builder: (context, viewModel, _) {
                return ChatInput(
                  onSendMessage: (message) {
                    viewModel.sendMessage(message);
                  },
                  isTyping: viewModel.isTyping,
                );
              },
            ),
          ],
        ),
        bottomNavigationBar: const AppBottomNavigation(currentIndex: 2),
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('เริ่มการสนทนาใหม่'),
                onTap: () {
                  Navigator.pop(context);
                  _viewModel.endSession();
                  _showTopicSelectionDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('ประวัติการสนทนา'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, AppRoutes.historyChat);
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('วิธีใช้งาน'),
                onTap: () {
                  Navigator.pop(context);
                  _showHelpDialog();
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.flag, color: Colors.red.shade400),
                title: const Text('รายงานเนื้อหา'),
                subtitle: const Text('รายงาน AI content ที่ไม่เหมาะสม'),
                onTap: () {
                  Navigator.pop(context);
                  _showReportOptions();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('วิธีใช้งานการสนทนากับนักพยากรณ์'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    '1. เลือกหัวข้อที่ต้องการสนทนา เช่น ความรัก การงาน สุขภาพ'),
                SizedBox(height: 8),
                Text('2. พิมพ์คำถามที่ต้องการถาม'),
                SizedBox(height: 8),
                Text('3. นักพยากรณ์ AI จะวิเคราะห์และตอบคำถามของคุณ'),
                SizedBox(height: 8),
                Text('4. คุณสามารถถามคำถามเพิ่มเติมได้ตลอดการสนทนา'),
                SizedBox(height: 8),
                Text(
                    '5. เมื่อต้องการเริ่มการสนทนาใหม่ ให้กดที่เมนูและเลือก "เริ่มการสนทนาใหม่"'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('เข้าใจแล้ว'),
            ),
          ],
        );
      },
    );
  }

  void _showReportOptions() {
    if (_viewModel.messages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ยังไม่มีข้อความที่จะรายงาน'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.flag, color: Colors.red.shade700),
            const SizedBox(width: 8),
            const Text('รายงานเนื้อหา AI'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'คุณต้องการรายงานข้อความใด?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('• กดไอคอนธงในข้อความ AI ที่ต้องการรายงาน'),
            SizedBox(height: 8),
            Text('• หรือรายงานการสนทนาทั้งหมด'),
            SizedBox(height: 16),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // รายงานข้อความล่าสุดของ AI
              final aiMessages = _viewModel.messages.where((m) => !m.isUser).toList();
              if (aiMessages.isNotEmpty) {
                final lastAiMessage = aiMessages.last;
                showReportDialog(
                  context,
                  contentId: 'chat_${lastAiMessage.id}',
                  contentType: 'chat_message',
                  contentSnapshot: lastAiMessage.content.substring(
                    0, 
                    lastAiMessage.content.length > 200 ? 200 : lastAiMessage.content.length
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('รายงานข้อความล่าสุด'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }
}
