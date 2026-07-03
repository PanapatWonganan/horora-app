import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../core/theme/sacred_ui.dart';
import '../../core/utils/app_icons.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({Key? key}) : super(key: key);

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  // ภาษาที่เลือกในปัจจุบัน
  String _selectedLanguage = 'th'; // ค่าเริ่มต้นเป็นภาษาไทย

  // รายการภาษาที่รองรับ
  final List<Map<String, dynamic>> _supportedLanguages = [
    {
      'code': 'th',
      'name': 'ไทย',
      'flagSvg': AppIcons.flagTh,
      'native_name': 'ภาษาไทย',
    },
    {
      'code': 'en',
      'name': 'English',
      'flagSvg': AppIcons.flagGb,
      'native_name': 'English',
    },
    {
      'code': 'zh',
      'name': 'Chinese',
      'flagSvg': AppIcons.flagCn,
      'native_name': '中文',
    },
    {
      'code': 'ja',
      'name': 'Japanese',
      'flagSvg': AppIcons.flagJp,
      'native_name': '日本語',
    },
    {
      'code': 'ko',
      'name': 'Korean',
      'flagSvg': AppIcons.flagKr,
      'native_name': '한국어',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SacredScaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SacredHeader(
              title: 'ภาษา',
              overline: 'LANGUAGE',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'เลือกภาษา',
                      style: SacredText.kanit(
                        color: AppColors.onBackdrop,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'เลือกภาษาที่คุณต้องการใช้ในแอปพลิเคชัน',
                      style: SacredText.kanit(
                        color: AppColors.onBackdropMuted,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ..._supportedLanguages
                        .map((language) => _buildLanguageItem(language)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SacredPrimaryButton(
                label: 'บันทึกการตั้งค่า',
                onTap: _saveLanguage,
                filled: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageItem(Map<String, dynamic> language) {
    final isSelected = language['code'] == _selectedLanguage;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SacredCard(
        radius: 16,
        highlight: isSelected,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onTap: () {
          setState(() {
            _selectedLanguage = language['code'];
          });
        },
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SvgIcon(
                  language['flagSvg'],
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language['native_name'],
                    style: SacredText.kanit(
                      color: AppColors.deepText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    language['name'],
                    style: SacredText.kanit(
                      color: AppColors.mutedText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const SvgIcon(
                AppIcons.check,
                size: 20,
                color: AppColors.deepGoldBrown,
              ),
          ],
        ),
      ),
    );
  }

  void _saveLanguage() {
    // ในแอปจริง ควรบันทึกการตั้งค่าภาษาลงใน SharedPreferences หรือฐานข้อมูล
    // และอัปเดตภาษาของแอปพลิเคชัน

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('บันทึกการตั้งค่าภาษาเรียบร้อยแล้ว'),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.of(context).pop();
  }
}
