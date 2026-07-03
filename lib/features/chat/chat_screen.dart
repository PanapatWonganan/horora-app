import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/sacred_ui.dart';
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
      child: SacredScaffold(
        showSpecks: false,
        body: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Consumer<ChatViewModel>(
                builder: (context, viewModel, _) {
                  return SacredHeader(
                    overline: 'DUANGJAI ORACLE',
                    title: viewModel.currentSession?.topic ??
                        'สนทนากับนักพยากรณ์',
                    onBack: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.home);
                    },
                    trailing: _SacredHeaderAction(
                      icon: Icons.more_vert,
                      onTap: _showOptionsMenu,
                    ),
                  );
                },
              ),
            ),
            // Messages list
            Expanded(
              child: Consumer<ChatViewModel>(
                builder: (context, viewModel, _) {
                  if (viewModel.state == ChatViewState.loading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.candleGold,
                      ),
                    );
                  }

                  if (viewModel.state == ChatViewState.error) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          viewModel.errorMessage ?? 'เกิดข้อผิดพลาด',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.kanit(
                            color: AppColors.error,
                            fontSize: 14,
                          ),
                        ),
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
                            color: AppColors.onBackdrop.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'เริ่มสนทนากับนักพยากรณ์',
                            style: GoogleFonts.kanit(
                              color: AppColors.onBackdropMuted,
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
        bottomNavigationBar: const AppBottomNavigation(currentIndex: 3),
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              ListTile(
                leading:
                    const Icon(Icons.refresh, color: AppColors.deepGoldBrown),
                title: Text(
                  'เริ่มการสนทนาใหม่',
                  style: GoogleFonts.kanit(color: AppColors.deepText),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _viewModel.endSession();
                  _showTopicSelectionDialog();
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.history, color: AppColors.deepGoldBrown),
                title: Text(
                  'ประวัติการสนทนา',
                  style: GoogleFonts.kanit(color: AppColors.deepText),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, AppRoutes.historyChat);
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline,
                    color: AppColors.deepGoldBrown),
                title: Text(
                  'วิธีใช้งาน',
                  style: GoogleFonts.kanit(color: AppColors.deepText),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showHelpDialog();
                },
              ),
              const Divider(height: 1, color: AppColors.divider),
              ListTile(
                leading: const Icon(Icons.flag, color: AppColors.error),
                title: Text(
                  'รายงานเนื้อหา',
                  style: GoogleFonts.kanit(color: AppColors.deepText),
                ),
                subtitle: Text(
                  'รายงาน AI content ที่ไม่เหมาะสม',
                  style: GoogleFonts.kanit(
                    color: AppColors.mutedText,
                    fontSize: 12,
                  ),
                ),
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
        final bodyStyle = GoogleFonts.kanit(
          color: AppColors.deepText,
          fontSize: 14,
          height: 1.5,
        );
        return AlertDialog(
          backgroundColor: AppColors.lightSurface,
          // Shape intentionally omitted so this inherits dialogTheme's
          // AppRadius.dialog (24) instead of a hardcoded mismatched radius.
          title: Text(
            'วิธีใช้งานการสนทนากับนักพยากรณ์',
            style: GoogleFonts.kanit(
              color: AppColors.deepText,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    '1. เลือกหัวข้อที่ต้องการสนทนา เช่น ความรัก การงาน สุขภาพ',
                    style: bodyStyle),
                const SizedBox(height: 8),
                Text('2. พิมพ์คำถามที่ต้องการถาม', style: bodyStyle),
                const SizedBox(height: 8),
                Text('3. นักพยากรณ์ AI จะวิเคราะห์และตอบคำถามของคุณ',
                    style: bodyStyle),
                const SizedBox(height: 8),
                Text('4. คุณสามารถถามคำถามเพิ่มเติมได้ตลอดการสนทนา',
                    style: bodyStyle),
                const SizedBox(height: 8),
                Text(
                    '5. เมื่อต้องการเริ่มการสนทนาใหม่ ให้กดที่เมนูและเลือก "เริ่มการสนทนาใหม่"',
                    style: bodyStyle),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'เข้าใจแล้ว',
                style: GoogleFonts.kanit(
                  color: AppColors.deepGoldBrown,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
        backgroundColor: AppColors.lightSurface,
        // Shape intentionally omitted so this inherits dialogTheme's
        // AppRadius.dialog (24) instead of a hardcoded mismatched radius.
        title: Row(
          children: [
            const Icon(Icons.flag, color: AppColors.error),
            const SizedBox(width: 8),
            Text(
              'รายงานเนื้อหา AI',
              style: GoogleFonts.kanit(
                color: AppColors.deepText,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'คุณต้องการรายงานข้อความใด?',
              style: GoogleFonts.kanit(
                color: AppColors.deepText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text('• กดไอคอนธงในข้อความ AI ที่ต้องการรายงาน',
                style: GoogleFonts.kanit(color: AppColors.mutedText)),
            const SizedBox(height: 8),
            Text('• หรือรายงานการสนทนาทั้งหมด',
                style: GoogleFonts.kanit(color: AppColors.mutedText)),
            const SizedBox(height: 16),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ยกเลิก',
              style: GoogleFonts.kanit(color: AppColors.mutedText),
            ),
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
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'รายงานข้อความล่าสุด',
              style: GoogleFonts.kanit(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
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

/// Calm header icon action drawn on the indigo backdrop — a faint ivory chip
/// matching the Sacred back chip, used for the chat options menu.
class _SacredHeaderAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SacredHeaderAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.onBackdrop.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: AppColors.onBackdrop.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: Icon(icon, size: 20, color: AppColors.onBackdrop),
      ),
    );
  }
}
