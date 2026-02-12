import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/theme.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'เกี่ยวกับแอป',
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildAppLogo(),
                const SizedBox(height: 24),
                _buildAppInfo(),
                const SizedBox(height: 32),
                _buildDivider(),
                const SizedBox(height: 24),
                _buildSectionTitle('เกี่ยวกับเรา'),
                const SizedBox(height: 16),
                _buildAboutUs(),
                const SizedBox(height: 24),
                _buildDivider(),
                const SizedBox(height: 24),
                _buildSectionTitle('นโยบายและข้อตกลง'),
                const SizedBox(height: 16),
                _buildPolicyItem(
                  'นโยบายความเป็นส่วนตัว',
                  () => _launchURL('https://horora.app/privacy-policy'),
                ),
                _buildPolicyItem(
                  'ข้อตกลงการใช้งาน',
                  () => _launchURL('https://horora.app/terms-of-service'),
                ),
                _buildPolicyItem(
                  'นโยบายการคืนเงิน',
                  () => _launchURL('https://horora.app/refund-policy'),
                ),
                const SizedBox(height: 24),
                _buildDivider(),
                const SizedBox(height: 24),
                _buildSectionTitle('ติดต่อเรา'),
                const SizedBox(height: 16),
                _buildContactInfo(),
                const SizedBox(height: 32),
                _buildCopyright(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppLogo() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.auto_awesome,
            color: AppColors.primary,
            size: 60,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Horora',
          style: TextStyle(
            color: AppColors.lightText,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'เวอร์ชัน 1.0.0',
          style: TextStyle(
            color: AppColors.lightText.withValues(alpha: 0.7),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildAppInfo() {
    return Text(
      'แอปพลิเคชันฝากมูออนไลน์ที่ครบวงจร บริการรับฝากทำบุญ ไหว้พระ สักการะสิ่งศักดิ์สิทธิ์ ณ สถานที่มงคลทั่วประเทศ พร้อมดูดวง อ่านไพ่ทาโรต์ และสนทนากับผู้เชี่ยวชาญด้านโหราศาสตร์',
      style: TextStyle(
        color: AppColors.lightText.withValues(alpha: 0.7),
        fontSize: 16,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: AppColors.lightText.withValues(alpha: 0.1),
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

  Widget _buildAboutUs() {
    return Text(
      'Horora คือแพลตฟอร์มฝากมูออนไลน์ที่เชื่อมต่อคุณกับสถานที่ศักดิ์สิทธิ์ทั่วประเทศไทย เราให้บริการรับฝากทำบุญ ไหว้พระ ถวายสังฆทาน บูชาสิ่งศักดิ์สิทธิ์ และพิธีกรรมมงคลต่างๆ ณ วัดและศาลเจ้าที่มีชื่อเสียง\n\nไม่ว่าคุณจะอยู่ที่ไหน ก็สามารถทำบุญเสริมดวงได้อย่างสะดวกสบาย เรามีทีมงานที่พร้อมเดินทางไปทำบุญแทนคุณ พร้อมส่งหลักฐานการทำบุญและรายงานผลให้ทราบทุกขั้นตอน\n\nสถานที่มงคลที่ให้บริการ:\n• ศาลพระพรหม เอราวัณ - ขอพรทุกด้าน\n• วัดระฆังโฆสิตาราม - โชคลาภ การเงิน\n• พระพิฆเนศ เซ็นทรัลเวิลด์ - การศึกษา ศิลปะ\n• วัดโสธรวรารามฯ - สุขภาพ ความปลอดภัย\n• และสถานที่ศักดิ์สิทธิ์อื่นๆ อีกมากมาย',
      style: TextStyle(
        color: AppColors.lightText.withValues(alpha: 0.7),
        fontSize: 14,
        height: 1.5,
      ),
    );
  }

  Widget _buildPolicyItem(String title, VoidCallback onTap) {
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
            Icon(
              Icons.description_outlined,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.lightText,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
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

  Widget _buildContactInfo() {
    return Column(
      children: [
        _buildContactItem(
          icon: Icons.email_outlined,
          title: 'อีเมล',
          value: 'contact@horora.app',
        ),
        _buildContactItem(
          icon: Icons.phone_outlined,
          title: 'โทรศัพท์',
          value: '02-123-4567',
        ),
        _buildContactItem(
          icon: Icons.location_on_outlined,
          title: 'ที่อยู่',
          value: '123 ถนนสุขุมวิท แขวงคลองเตย เขตคลองเตย กรุงเทพฯ 10110',
        ),
      ],
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 24,
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
                  value,
                  style: TextStyle(
                    color: AppColors.lightText.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyright() {
    return Text(
      '© 2025 Horora. All rights reserved.',
      style: TextStyle(
        color: AppColors.lightText.withValues(alpha: 0.5),
        fontSize: 12,
      ),
      textAlign: TextAlign.center,
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
} 