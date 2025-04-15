import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ChatMessageItem extends StatelessWidget {
  final String message;
  final bool isUser;
  final bool isTyping;
  final bool isSystemMessage;

  const ChatMessageItem({
    Key? key,
    required this.message,
    required this.isUser,
    required this.isTyping,
    this.isSystemMessage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ถ้าเป็นข้อความระบบ ให้แสดงแบบพิเศษ
    if (isSystemMessage) {
      return _buildSystemMessage(context);
    }
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser 
              ? AppColors.primary.withOpacity(0.2) 
              : AppColors.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUser 
                ? AppColors.primary.withOpacity(0.3) 
                : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      child: Icon(
                        Icons.auto_awesome,
                        color: AppColors.primary,
                        size: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'นักพยากรณ์',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              isTyping
                  ? _buildTypingIndicator()
                  : Text(
                      message,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.white,
                        fontSize: 14,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Widget สำหรับแสดงข้อความระบบ
  Widget _buildSystemMessage(BuildContext context) {
    // ตรวจสอบว่าข้อความเกี่ยวกับราศีหรือไม่
    final bool isZodiacMessage = message.contains('ราศี');
    
    // หาว่าเป็นราศีอะไร
    String? zodiacSign;
    if (isZodiacMessage) {
      for (final sign in [
        'เมษ', 'พฤษภ', 'เมถุน', 'กรกฎ', 'สิงห์', 'กันย์',
        'ตุลย์', 'พิจิก', 'ธนู', 'มังกร', 'กุมภ์', 'มีน'
      ]) {
        if (message.contains('ราศี$sign')) {
          zodiacSign = sign;
          break;
        }
      }
    }
    
    // หาไอคอนที่เหมาะสมกับราศี
    IconData zodiacIcon = Icons.auto_awesome;
    
    // หาธาตุของราศี
    String? element;
    Color elementColor = AppColors.primary;
    
    if (zodiacSign != null) {
      // กำหนดธาตุตามราศี
      if (['เมษ', 'สิงห์', 'ธนู'].contains(zodiacSign)) {
        element = 'ไฟ';
        elementColor = Colors.orange;
        zodiacIcon = Icons.local_fire_department;
      } else if (['พฤษภ', 'กันย์', 'มังกร'].contains(zodiacSign)) {
        element = 'ดิน';
        elementColor = Colors.brown;
        zodiacIcon = Icons.landscape;
      } else if (['เมถุน', 'ตุลย์', 'กุมภ์'].contains(zodiacSign)) {
        element = 'ลม';
        elementColor = Colors.lightBlue;
        zodiacIcon = Icons.air;
      } else if (['กรกฎ', 'พิจิก', 'มีน'].contains(zodiacSign)) {
        element = 'น้ำ';
        elementColor = Colors.blue;
        zodiacIcon = Icons.water_drop;
      }
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isZodiacMessage 
            ? (element != null ? elementColor.withOpacity(0.15) : AppColors.primary.withOpacity(0.15))
            : AppColors.darkSurface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isZodiacMessage 
              ? (element != null ? elementColor.withOpacity(0.3) : AppColors.primary.withOpacity(0.3))
              : AppColors.primary.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: isZodiacMessage ? [
          BoxShadow(
            color: element != null ? elementColor.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          )
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isZodiacMessage ? zodiacIcon : Icons.info_outline,
                size: 18,
                color: isZodiacMessage 
                    ? (element != null ? elementColor : AppColors.primary)
                    : AppColors.lightText.withOpacity(0.7),
              ),
              const SizedBox(width: 8),
              Text(
                isZodiacMessage ? 'ข้อมูลดวงดาวของคุณ' : 'ข้อความจากระบบ',
                style: TextStyle(
                  color: isZodiacMessage 
                      ? (element != null ? elementColor : AppColors.primary)
                      : AppColors.lightText,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (element != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: elementColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'ธาตุ$element',
                    style: TextStyle(
                      color: elementColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: AppColors.lightText.withOpacity(0.9),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDot(1),
        _buildDot(2),
        _buildDot(3),
      ],
    );
  }

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: AnimatedBuilder(
        animation: const AlwaysStoppedAnimation(0),
        builder: (context, child) {
          return Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
          );
        },
      ),
    );
  }
} 