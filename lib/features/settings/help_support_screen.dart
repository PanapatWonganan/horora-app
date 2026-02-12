import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ช่วยเหลือและสนับสนุน',
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('คำถามที่พบบ่อย'),
                const SizedBox(height: 16),
                _buildFAQItem(
                  context,
                  'ฉันจะดูดวงประจำวันได้อย่างไร?',
                  'คุณสามารถดูดวงประจำวันได้โดยไปที่หน้า "ดวงชะตา" และเลือกราศีของคุณ หรือหากคุณได้ตั้งค่าวันเกิดในโปรไฟล์แล้ว ระบบจะแสดงดวงประจำวันของคุณโดยอัตโนมัติ',
                ),
                _buildFAQItem(
                  context,
                  'ฉันจะอ่านไพ่ทาโรต์ได้อย่างไร?',
                  'คุณสามารถอ่านไพ่ทาโรต์ได้โดยไปที่หน้า "ไพ่ทาโรต์" และเลือกรูปแบบการอ่านไพ่ที่คุณต้องการ เช่น การอ่านไพ่ 1 ใบ, 3 ใบ หรือการอ่านไพ่แบบเซลติก',
                ),
                _buildFAQItem(
                  context,
                  'ฉันจะสนทนากับนักพยากรณ์ได้อย่างไร?',
                  'คุณสามารถสนทนากับนักพยากรณ์ได้โดยไปที่หน้า "สนทนา" และเลือกนักพยากรณ์ที่คุณต้องการสนทนาด้วย หากคุณเป็นสมาชิกพรีเมียม คุณจะได้รับสิทธิ์ในการสนทนากับนักพยากรณ์ได้ไม่จำกัด',
                ),
                _buildFAQItem(
                  context,
                  'ฉันจะอัปเกรดเป็นสมาชิกพรีเมียมได้อย่างไร?',
                  'คุณสามารถอัปเกรดเป็นสมาชิกพรีเมียมได้โดยไปที่หน้า "โปรไฟล์" และเลือก "อัปเกรดเป็นพรีเมียม" จากนั้นเลือกแพ็กเกจที่คุณต้องการและชำระเงิน',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('ติดต่อเรา'),
                const SizedBox(height: 16),
                _buildContactItem(
                  icon: Icons.email_outlined,
                  title: 'อีเมล',
                  subtitle: 'support@astrologyapp.com',
                  onTap: () => _launchEmail('support@astrologyapp.com'),
                ),
                _buildContactItem(
                  icon: Icons.phone_outlined,
                  title: 'โทรศัพท์',
                  subtitle: '02-123-4567',
                  onTap: () => _launchPhone('021234567'),
                ),
                _buildContactItem(
                  icon: Icons.chat_outlined,
                  title: 'แชท',
                  subtitle: 'แชทกับเจ้าหน้าที่',
                  onTap: () => _openLiveChat(context),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('ติดตามเรา'),
                const SizedBox(height: 16),
                _buildSocialMediaLinks(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.lightText,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(
            color: AppColors.lightText,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.lightText.withValues(alpha: 0.7),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(
                color: AppColors.lightText.withValues(alpha: 0.7),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.lightText,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.lightText.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.lightText.withValues(alpha: 0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialMediaLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSocialMediaButton(
          icon: Icons.facebook,
          color: const Color(0xFF1877F2),
          onTap: () => _launchURL('https://facebook.com'),
        ),
        _buildSocialMediaButton(
          icon: Icons.camera_alt_outlined,
          color: const Color(0xFFE1306C),
          onTap: () => _launchURL('https://instagram.com'),
        ),
        _buildSocialMediaButton(
          icon: Icons.chat_bubble_outline,
          color: const Color(0xFF00B900),
          onTap: () => _launchURL('https://line.me'),
        ),
        _buildSocialMediaButton(
          icon: Icons.language,
          color: AppColors.primary,
          onTap: () => _launchURL('https://astrologyapp.com'),
        ),
      ],
    );
  }

  Widget _buildSocialMediaButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: color,
          size: 30,
        ),
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'สอบถามข้อมูลเพิ่มเติม',
      },
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openLiveChat(BuildContext context) {
    // ในแอปจริง ควรเปิดหน้าแชทกับเจ้าหน้าที่
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('กำลังเชื่อมต่อกับเจ้าหน้าที่...'),
        backgroundColor: Colors.green,
      ),
    );
  }
} 