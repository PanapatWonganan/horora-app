import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../shared/widgets/gradient_button.dart';

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
      'flag': '🇹🇭',
      'native_name': 'ภาษาไทย',
    },
    {
      'code': 'en',
      'name': 'English',
      'flag': '🇬🇧',
      'native_name': 'English',
    },
    {
      'code': 'zh',
      'name': 'Chinese',
      'flag': '🇨🇳',
      'native_name': '中文',
    },
    {
      'code': 'ja',
      'name': 'Japanese',
      'flag': '🇯🇵',
      'native_name': '日本語',
    },
    {
      'code': 'ko',
      'name': 'Korean',
      'flag': '🇰🇷',
      'native_name': '한국어',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ภาษา',
          style: TextStyle(
            color: AppColors.lightText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: AppColors.lightText,
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.darkBackground,
              const Color(0xFF1A1A2E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'เลือกภาษา',
                        style: TextStyle(
                          color: AppColors.lightText,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'เลือกภาษาที่คุณต้องการใช้ในแอปพลิเคชัน',
                        style: TextStyle(
                          color: AppColors.lightText.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ..._supportedLanguages.map((language) => _buildLanguageItem(language)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: GradientButton(
                  text: 'บันทึกการตั้งค่า',
                  onPressed: _saveLanguage,
                  gradient: LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  width: double.infinity,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageItem(Map<String, dynamic> language) {
    final isSelected = language['code'] == _selectedLanguage;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedLanguage = language['code'];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.darkSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: Text(
                language['flag'],
                style: const TextStyle(
                  fontSize: 24,
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
                    style: TextStyle(
                      color: AppColors.lightText,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    language['name'],
                    style: TextStyle(
                      color: AppColors.lightText.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
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
        backgroundColor: Colors.green,
      ),
    );
    
    Navigator.of(context).pop();
  }
} 