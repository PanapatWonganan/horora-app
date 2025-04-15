import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

class ZodiacCompatibilityCard extends StatelessWidget {
  final String title;
  final List<Map<String, String>> zodiacSigns;
  final VoidCallback onTap;

  const ZodiacCompatibilityCard({
    Key? key,
    required this.title,
    required this.zodiacSigns,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppColors.lightText,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < zodiacSigns.length; i++) ...[
                  if (i > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: AppColors.primary,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  _buildZodiacSign(
                      zodiacSigns[i]['name']!, zodiacSigns[i]['imagePath']!),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.lightText.withOpacity(0.5),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'แตะเพื่อดูรายละเอียด',
                  style: TextStyle(
                    color: AppColors.lightText.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZodiacSign(String name, String imagePath) {
    // ดึงชื่อราศีภาษาอังกฤษจากชื่อราศีไทย
    final signName = name.replaceAll('ราศี', '').trim().toLowerCase();
    final IconData iconData = _getZodiacIcon(signName);

    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.darkBackground,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              iconData,
              size: 30,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            color: AppColors.lightText,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // แปลงชื่อราศีเป็นไอคอนที่เหมาะสม
  IconData _getZodiacIcon(String zodiacSign) {
    switch (zodiacSign) {
      case 'เมษ':
        return Icons.local_fire_department; // ราศีเมษ - ธาตุไฟ
      case 'พฤษภ':
        return Icons.landscape; // ราศีพฤษภ - ธาตุดิน
      case 'เมถุน':
        return Icons.air; // ราศีเมถุน - ธาตุลม
      case 'กรกฎ':
        return Icons.water_drop; // ราศีกรกฎ - ธาตุน้ำ
      case 'สิงห์':
        return Icons.local_fire_department; // ราศีสิงห์ - ธาตุไฟ
      case 'กันย์':
        return Icons.landscape; // ราศีกันย์ - ธาตุดิน
      case 'ตุลย์':
        return Icons.air; // ราศีตุลย์ - ธาตุลม
      case 'พิจิก':
        return Icons.water_drop; // ราศีพิจิก - ธาตุน้ำ
      case 'ธนู':
        return Icons.local_fire_department; // ราศีธนู - ธาตุไฟ
      case 'มังกร':
        return Icons.landscape; // ราศีมังกร - ธาตุดิน
      case 'กุมภ์':
        return Icons.air; // ราศีกุมภ์ - ธาตุลม
      case 'มีน':
        return Icons.water_drop; // ราศีมีน - ธาตุน้ำ
      default:
        return Icons.star; // ค่าเริ่มต้น
    }
  }
}
