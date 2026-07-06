import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/sacred_ui.dart';
import '../../core/routes/routes.dart';
import '../../core/services/auth_guard.dart';
import '../shared/widgets/app_bottom_navigation.dart';
import '../journey/services/faith_points_service.dart';
import 'viewmodels/chat_viewmodel.dart';
import 'widgets/chat_empty_state.dart';
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

  // Message ids that have already played (or been instantly rendered without)
  // their typewriter reveal. Lives on the View's State — NOT on
  // ChatMessageItem — so rebuilding/scrolling the list never re-triggers the
  // animation for a message once it has been seen. Populated eagerly for
  // every message that exists the moment a session is (re)loaded, so history
  // never animates; only a message that arrives *after* that point is new.
  final Set<String> _seenMessageIds = {};
  String? _lastSessionId;

  @override
  void initState() {
    super.initState();
    _viewModel = ChatViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  /// Returns true only the first time this is asked about a given message id
  /// while that message belongs to the current session's already-known set.
  /// Called from the builder, so it must be idempotent per id (checking
  /// membership, not mutating on every call for the same id).
  bool _isNewlyArrived(String sessionId, String messageId) {
    if (_lastSessionId != sessionId) {
      // Session changed (new topic / loaded a different history) — every
      // message currently in it is "history" as far as animation goes.
      _lastSessionId = sessionId;
      _seenMessageIds
        ..clear()
        ..addAll(_viewModel.messages.map((m) => m.id));
      return false;
    }
    if (_seenMessageIds.contains(messageId)) return false;
    _seenMessageIds.add(messageId);
    return true;
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

  // Lighter-weight autoscroll used on every typewriter reveal tick (can fire
  // dozens of times/sec) — an immediate jump instead of re-triggering a new
  // 300ms animateTo on top of an already-running one.
  void _jumpToBottom() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    if (_scrollController.offset < max) {
      _scrollController.jumpTo(max);
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
                    title:
                        viewModel.currentSession?.topic ?? 'สนทนากับนักพยากรณ์',
                    onBack: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.home);
                    },
                    trailing: _SacredHeaderAction(
                      icon: Icons.more_vert,
                      onTap: _showOptionsMenu,
                      semanticLabel: 'ตัวเลือกเพิ่มเติม',
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
                    return const SacredLoader.large();
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
                    return ChatEmptyState(
                      onQuestionTap: (question) {
                        viewModel.sendMessage(question);
                        // พลังศรัทธา: ถาม AI วันละครั้ง (fire-and-forget)
                        FaithPointsService.instance
                            .awardDailyActivity('ai_chat');
                      },
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
                      final sessionId = viewModel.currentSession?.id ?? '';
                      final animate = !message.isUser &&
                          !message.isSystemMessage &&
                          _isNewlyArrived(sessionId, message.id);
                      return ChatMessageItem(
                        key: ValueKey(message.id),
                        message: message.content,
                        isUser: message.isUser,
                        isTyping: false,
                        isSystemMessage: message.isSystemMessage,
                        messageId: message.id,
                        animateReveal: animate,
                        onRevealTick: _jumpToBottom,
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
                    // พลังศรัทธา: ถาม AI วันละครั้ง (fire-and-forget)
                    FaithPointsService.instance.awardDailyActivity('ai_chat');
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
                  Navigator.pushReplacementNamed(
                      context, AppRoutes.historyChat);
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
                Text('1. เลือกหัวข้อที่ต้องการสนทนา เช่น ความรัก การงาน สุขภาพ',
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
              final aiMessages =
                  _viewModel.messages.where((m) => !m.isUser).toList();
              if (aiMessages.isNotEmpty) {
                final lastAiMessage = aiMessages.last;
                showReportDialog(
                  context,
                  contentId: 'chat_${lastAiMessage.id}',
                  contentType: 'chat_message',
                  contentSnapshot: lastAiMessage.content.substring(
                      0,
                      lastAiMessage.content.length > 200
                          ? 200
                          : lastAiMessage.content.length),
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

  /// Thai, action-phrased label for screen readers — this chip is icon-only.
  final String semanticLabel;

  const _SacredHeaderAction({
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: SizedBox(
        // Host is a real 44x44 (matches SacredHeader's back chip, which has
        // the same padding room to absorb it without the header growing
        // visibly). The 40x40 visual chip is centered inside.
        width: 44,
        height: 44,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Center(
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
          ),
        ),
      ),
    );
  }
}

// The chat empty-state widget was extracted to
// lib/features/chat/widgets/chat_empty_state.dart (see ChatEmptyState) so it
// can be unit-tested directly without needing the full ChatViewModel/backend
// session boundary this screen requires.
