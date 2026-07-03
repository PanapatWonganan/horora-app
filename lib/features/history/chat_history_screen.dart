import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/services/auth_guard.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/sacred_ui.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  List<Map<String, dynamic>> _chatHistory = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // History เป็นข้อมูลส่วนตัว (token-gated) — guard ก่อนเรียก API
    // เพื่อไม่ให้ guest เห็นหน้าว่างแบบงง ๆ และไม่ยิง request ที่จะถูก reject
    WidgetsBinding.instance.addPostFrameCallback((_) => _guardAndLoad());
  }

  Future<void> _guardAndLoad() async {
    final ok = await AuthGuard.requireAuth(context);
    if (!mounted) return;
    if (!ok) {
      // guest ยกเลิกการสมัคร → ออกจากหน้า history (กลับไปหน้าก่อนหน้า)
      Navigator.of(context).pop();
      return;
    }
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final apiClient = ApiClient();
      final response = await apiClient.get('/chat/history');
      final List<dynamic> data =
          response is List ? response : (response?['data'] ?? []);

      setState(() {
        _chatHistory = data.map((e) => Map<String, dynamic>.from(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SacredScaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SacredHeader(
              title: 'ประวัติการสนทนากับนักพยากรณ์',
              overline: 'CHAT HISTORY',
            ),
            Expanded(
              child: _isLoading
                  ? const SacredLoader.large()
                  : _hasError
                      ? _buildErrorState()
                      : _chatHistory.isEmpty
                          ? _buildEmptyState()
                          : _buildHistoryList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'โหลดข้อมูลไม่สำเร็จ',
              style: SacredText.kanit(
                color: AppColors.onBackdrop,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'ลองอีกครั้งเพื่อดูประวัติการสนทนาของคุณ',
              style: SacredText.kanit(
                color: AppColors.onBackdropMuted,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SacredPrimaryButton(
              label: 'ลองใหม่อีกครั้ง',
              onTap: _loadChatHistory,
              filled: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              color: AppColors.candleGold.withValues(alpha: 0.6),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'ยังไม่มีประวัติการสนทนา',
              style: SacredText.kanit(
                color: AppColors.onBackdrop,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'เมื่อคุณสนทนากับนักพยากรณ์ ประวัติจะปรากฏที่นี่',
              style: SacredText.kanit(
                color: AppColors.onBackdropMuted,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return RefreshIndicator(
      onRefresh: _loadChatHistory,
      color: AppColors.deepGoldBrown,
      backgroundColor: AppColors.ivorySilk,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _chatHistory.length,
        itemBuilder: (context, index) {
          return _buildHistoryItem(_chatHistory[index]);
        },
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final date =
        DateTime.parse(item['date'] ?? DateTime.now().toIso8601String());
    final formattedDate = '${date.day}/${date.month}/${date.year}';
    final astrologer = item['astrologer'] ?? 'ไม่ระบุ';
    final topic = item['topic'] ?? 'ไม่ระบุหัวข้อ';
    final summary = item['summary'] ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SacredCard(
        radius: 18,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  astrologer,
                  style: SacredText.kanit(
                    color: AppColors.deepText,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  formattedDate,
                  style: SacredText.kanit(
                    fontSize: 14.0,
                    color: AppColors.mutedText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              decoration: BoxDecoration(
                color: AppColors.candleGold.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                topic,
                style: SacredText.kanit(
                  fontSize: 12.0,
                  color: AppColors.deepGoldBrown,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (summary.isNotEmpty) ...[
              const SizedBox(height: 16.0),
              Text(
                'สรุปการสนทนา',
                style: SacredText.kanit(
                  color: AppColors.deepGoldBrown,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                summary,
                style: SacredText.kanit(
                  color: AppColors.deepText,
                  fontSize: 14.0,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
