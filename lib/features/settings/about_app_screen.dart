import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/theme.dart';
import '../../core/theme/sacred_ui.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SacredScaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SacredHeader(
              title: 'เกี่ยวกับแอป',
              overline: 'ABOUT',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
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
          ],
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
            color: AppColors.candleGold.withValues(alpha: 0.16),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.candleGold.withValues(alpha: 0.45),
              width: 1.2,
            ),
          ),
          child: const Icon(
            Icons.auto_awesome,
            color: AppColors.deepGoldBrown,
            size: 60,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Mootaewall',
          style: SacredText.display(
            color: AppColors.onBackdrop,
            fontSize: 26,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'เวอร์ชัน 1.0.0',
          style: SacredText.kanit(
            color: AppColors.onBackdropMuted,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildAppInfo() {
    return Text(
      'แอปพลิเคชันฝากมูออนไลน์ที่ครบวงจร บริการรับฝากทำบุญ ไหว้พระ สักการะสิ่งศักดิ์สิทธิ์ ณ สถานที่มงคลทั่วประเทศ พร้อมดูดวง อ่านไพ่ทาโรต์ และสนทนากับผู้เชี่ยวชาญด้านโหราศาสตร์',
      style: SacredText.kanit(
        color: AppColors.onBackdropMuted,
        fontSize: 15,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: AppColors.onBackdrop.withValues(alpha: 0.12),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SacredSectionTitle(title),
    );
  }

  Widget _buildAboutUs() {
    return SacredCard(
      radius: 18,
      child: Text(
        'Mootaewall คือแพลตฟอร์มฝากมูออนไลน์ที่เชื่อมต่อคุณกับสถานที่ศักดิ์สิทธิ์ทั่วประเทศไทย เราให้บริการรับฝากทำบุญ ไหว้พระ ถวายสังฆทาน บูชาสิ่งศักดิ์สิทธิ์ และพิธีกรรมมงคลต่างๆ ณ วัดและศาลเจ้าที่มีชื่อเสียง\n\nไม่ว่าคุณจะอยู่ที่ไหน ก็สามารถทำบุญเสริมดวงได้อย่างสะดวกสบาย เรามีทีมงานที่พร้อมเดินทางไปทำบุญแทนคุณ พร้อมส่งหลักฐานการทำบุญและรายงานผลให้ทราบทุกขั้นตอน\n\nสถานที่มงคลที่ให้บริการ:\n• ศาลพระพรหม เอราวัณ - ขอพรทุกด้าน\n• วัดระฆังโฆสิตาราม - โชคลาภ การเงิน\n• พระพิฆเนศ เซ็นทรัลเวิลด์ - การศึกษา ศิลปะ\n• วัดโสธรวรารามฯ - สุขภาพ ความปลอดภัย\n• และสถานที่ศักดิ์สิทธิ์อื่นๆ อีกมากมาย',
        style: SacredText.kanit(
          color: AppColors.mutedText,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildPolicyItem(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SacredCard(
        onTap: onTap,
        radius: 16,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(
              Icons.description_outlined,
              color: AppColors.deepGoldBrown,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: SacredText.kanit(
                  color: AppColors.deepText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
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
            color: AppColors.candleGold,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: SacredText.kanit(
                    color: AppColors.onBackdrop,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: SacredText.kanit(
                    color: AppColors.onBackdropMuted,
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
      '© 2025 Mootaewall. All rights reserved.',
      style: SacredText.kanit(
        color: AppColors.onBackdropMuted,
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