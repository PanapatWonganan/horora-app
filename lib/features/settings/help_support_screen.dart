import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/theme.dart';
import '../../core/theme/sacred_ui.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SacredScaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SacredHeader(
              title: 'ช่วยเหลือและสนับสนุน',
              overline: 'SUPPORT',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
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
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return SacredSectionTitle(title);
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SacredCard(
        radius: 16,
        padding: EdgeInsets.zero,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            shape: const Border(),
            collapsedShape: const Border(),
            title: Text(
              question,
              style: SacredText.kanit(
                color: AppColors.deepText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            iconColor: AppColors.deepGoldBrown,
            collapsedIconColor: AppColors.mutedText,
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              Text(
                answer,
                style: SacredText.kanit(
                  color: AppColors.mutedText,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SacredCard(
        onTap: onTap,
        radius: 16,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.candleGold.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.deepGoldBrown,
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
                    style: SacredText.kanit(
                      color: AppColors.deepText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: SacredText.kanit(
                      color: AppColors.mutedText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.mutedText.withValues(alpha: 0.6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialMediaLinks() {
    return SacredCard(
      radius: 18,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSocialMediaButton(
            icon: Icons.facebook,
            color: const Color(0xFF1877F2),
            onTap: () => _launchURL('https://facebook.com'),
            label: 'เปิด Facebook',
          ),
          _buildSocialMediaButton(
            icon: Icons.camera_alt_outlined,
            color: const Color(0xFFE1306C),
            onTap: () => _launchURL('https://instagram.com'),
            label: 'เปิด Instagram',
          ),
          _buildSocialMediaButton(
            icon: Icons.chat_bubble_outline,
            color: const Color(0xFF00B900),
            onTap: () => _launchURL('https://line.me'),
            label: 'เปิด LINE',
          ),
          _buildSocialMediaButton(
            icon: Icons.language,
            color: AppColors.deepGoldBrown,
            onTap: () => _launchURL('https://astrologyapp.com'),
            label: 'เปิดเว็บไซต์',
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String label,
  }) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
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
        backgroundColor: AppColors.success,
      ),
    );
  }
} 