import 'package:flutter/material.dart';
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
    {
      'title': 'ดวงความรัก',
      'svgIcon': AppIcons.love,
      'color': Colors.pink,
    },
    {
      'title': 'ดวงการงาน',
      'svgIcon': AppIcons.career,
      'color': Colors.blue,
    },
    {
      'title': 'ดวงการเงิน',
      'svgIcon': AppIcons.finance,
      'color': Colors.green,
    },
    {
      'title': 'ดวงสุขภาพ',
      'svgIcon': AppIcons.health,
      'color': Colors.orange,
    },
    {
      'title': 'ดวงครอบครัว',
      'svgIcon': AppIcons.family,
      'color': Colors.purple,
    },
    {
      'title': 'ดวงการศึกษา',
      'svgIcon': AppIcons.education,
      'color': Colors.teal,
    },
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'เลือกหัวข้อที่ต้องการสนทนา',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'เลือกหัวข้อที่คุณต้องการปรึกษากับนักพยากรณ์',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
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
                          ? topic['color'].withValues(alpha: 0.2)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? topic['color']
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgIcon(
                          topic['svgIcon'],
                          size: 28,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          topic['title'],
                          style: TextStyle(
                            color: isSelected ? topic['color'] : Colors.white,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isCustomTopic
                        ? AppColors.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.add,
                      color: _isCustomTopic ? AppColors.primary : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'หัวข้ออื่นๆ',
                      style: TextStyle(
                        color: _isCustomTopic ? AppColors.primary : Colors.white,
                        fontWeight: _isCustomTopic ? FontWeight.bold : FontWeight.normal,
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
                decoration: InputDecoration(
                  hintText: 'ระบุหัวข้อที่ต้องการสนทนา',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
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
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'เริ่มการสนทนา',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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