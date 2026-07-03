import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_icons.dart';

class TopicSelectionDialog extends StatefulWidget {
  final Function(String) onTopicSelected;

  const TopicSelectionDialog({
    Key? key,
    required this.onTopicSelected,
  }) : super(key: key);

  @override
  State<TopicSelectionDialog> createState() => _TopicSelectionDialogState();
}

class _TopicSelectionDialogState extends State<TopicSelectionDialog> {
  final TextEditingController _customTopicController = TextEditingController();
  String? _selectedTopic;
  bool _isCustomTopic = false;

  final List<Map<String, dynamic>> _predefinedTopics = [
    {'title': 'ดวงความรัก', 'svgIcon': AppIcons.love},
    {'title': 'ดวงการงาน', 'svgIcon': AppIcons.career},
    {'title': 'ดวงการเงิน', 'svgIcon': AppIcons.finance},
    {'title': 'ดวงสุขภาพ', 'svgIcon': AppIcons.health},
    {'title': 'ดวงครอบครัว', 'svgIcon': AppIcons.family},
    {'title': 'ดวงการศึกษา', 'svgIcon': AppIcons.education},
  ];

  @override
  void dispose() {
    _customTopicController.dispose();
    super.dispose();
  }

  void _selectTopic(String topic) {
    setState(() {
      _selectedTopic = topic;
      _isCustomTopic = false;
    });
  }

  void _enableCustomTopic() {
    setState(() {
      _isCustomTopic = true;
      _selectedTopic = null;
    });
  }

  void _confirmSelection() {
    if (_isCustomTopic && _customTopicController.text.trim().isNotEmpty) {
      widget.onTopicSelected(_customTopicController.text.trim());
    } else if (_selectedTopic != null) {
      widget.onTopicSelected(_selectedTopic!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: AppColors.warmCardBorder.withValues(alpha: 0.7),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'เลือกหัวข้อที่ต้องการสนทนา',
              style: GoogleFonts.kanit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.deepText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'เลือกหัวข้อที่คุณต้องการปรึกษากับนักพยากรณ์',
              style: GoogleFonts.kanit(
                fontSize: 14,
                color: AppColors.mutedText,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _predefinedTopics.length,
              itemBuilder: (context, index) {
                final topic = _predefinedTopics[index];
                final isSelected = _selectedTopic == topic['title'] && !_isCustomTopic;
                
                return InkWell(
                  onTap: () => _selectTopic(topic['title']),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.candleGold.withValues(alpha: 0.16)
                          : AppColors.ricePaper,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.candleGold
                            : AppColors.warmCardBorder.withValues(alpha: 0.7),
                        width: isSelected ? 1.6 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgIcon(
                          topic['svgIcon'],
                          size: 28,
                          color: isSelected
                              ? AppColors.deepGoldBrown
                              : AppColors.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          topic['title'],
                          style: GoogleFonts.kanit(
                            color: isSelected
                                ? AppColors.deepGoldBrown
                                : AppColors.deepText,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _enableCustomTopic,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isCustomTopic
                      ? AppColors.candleGold.withValues(alpha: 0.16)
                      : AppColors.ricePaper,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isCustomTopic
                        ? AppColors.candleGold
                        : AppColors.warmCardBorder.withValues(alpha: 0.7),
                    width: _isCustomTopic ? 1.6 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.add,
                      color: _isCustomTopic
                          ? AppColors.deepGoldBrown
                          : AppColors.mutedText,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'หัวข้ออื่นๆ',
                      style: GoogleFonts.kanit(
                        color: _isCustomTopic
                            ? AppColors.deepGoldBrown
                            : AppColors.deepText,
                        fontWeight: _isCustomTopic
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isCustomTopic) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _customTopicController,
                cursorColor: AppColors.deepGoldBrown,
                decoration: InputDecoration(
                  hintText: 'ระบุหัวข้อที่ต้องการสนทนา',
                  hintStyle: GoogleFonts.kanit(
                    color: AppColors.softInk.withValues(alpha: 0.7),
                  ),
                  filled: true,
                  fillColor: AppColors.ricePaper,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.warmCardBorder,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.warmCardBorder.withValues(alpha: 0.8),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.candleGold,
                      width: 1.4,
                    ),
                  ),
                ),
                style: GoogleFonts.kanit(color: AppColors.deepText),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_isCustomTopic && _customTopicController.text.trim().isNotEmpty) ||
                          (!_isCustomTopic && _selectedTopic != null)
                    ? _confirmSelection
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.candleGold,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppColors.disabled.withValues(alpha: 0.6),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'เริ่มการสนทนา',
                  style: GoogleFonts.kanit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 