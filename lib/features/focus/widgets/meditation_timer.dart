import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../focus_session_screen.dart';

class MeditationTimer extends StatelessWidget {
  final String remainingTime;
  final AnimationController animationController;
  final BreathingPhase breathingPhase;

  const MeditationTimer({
    Key? key,
    required this.remainingTime,
    required this.animationController,
    required this.breathingPhase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Breathing circle animation
        AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            double size;
            if (breathingPhase == BreathingPhase.inhale) {
              size = 200 + (animationController.value * 50);
            } else if (breathingPhase == BreathingPhase.hold) {
              size = 250;
            } else {
              size = 250 - ((1 - animationController.value) * 50);
            }

            Color circleColor;
            if (breathingPhase == BreathingPhase.inhale) {
              circleColor = AppColors.primary
                  .withOpacity(0.5 + (animationController.value * 0.3));
            } else if (breathingPhase == BreathingPhase.hold) {
              circleColor = AppColors.primary.withOpacity(0.8);
            } else {
              circleColor = AppColors.primary
                  .withOpacity(0.8 - ((1 - animationController.value) * 0.3));
            }

            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                border: Border.all(
                  color: circleColor,
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: circleColor.withOpacity(0.6),
                    blurRadius: 20.0,
                    spreadRadius: 5.0 +
                        (breathingPhase == BreathingPhase.hold
                            ? 10.0
                            : animationController.value * 10.0),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  remainingTime,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48.0,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32.0),
        // Breathing guidance text
        AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            String mainInstruction;
            String detailedInstruction;

            if (breathingPhase == BreathingPhase.inhale) {
              mainInstruction = 'หายใจเข้า (4 วินาที)';

              final breathProgress = animationController.value;
              if (breathProgress < 0.25) {
                detailedInstruction = 'หายใจเข้าช้าๆ ทางจมูก...';
              } else if (breathProgress < 0.5) {
                detailedInstruction = 'นำลมหายใจลงสู่ท้องน้อย...';
              } else if (breathProgress < 0.75) {
                detailedInstruction = 'ให้ท้องพองออก...';
              } else {
                detailedInstruction = 'สังเกตความรู้สึกเติมเต็ม...';
              }
            } else if (breathingPhase == BreathingPhase.hold) {
              mainInstruction = 'กลั้นหายใจ (7 วินาที)';
              detailedInstruction =
                  'นับในใจช้าๆ... ผ่อนคลาย... กักเก็บพลังงาน...';
            } else {
              mainInstruction = 'หายใจออก (8 วินาที)';

              final breathProgress = animationController.value;
              if (breathProgress < 0.25) {
                detailedInstruction = 'ค่อยๆ ปล่อยลมหายใจออกทางปาก...';
              } else if (breathProgress < 0.5) {
                detailedInstruction = 'ให้ท้องแฟบลง...';
              } else if (breathProgress < 0.75) {
                detailedInstruction = 'ปล่อยความตึงเครียดออกไป...';
              } else {
                detailedInstruction = 'รู้สึกถึงความผ่อนคลายลึกๆ...';
              }
            }

            return Column(
              children: [
                Text(
                  mainInstruction,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  detailedInstruction,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16.0,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24.0),
        // Meditation guidance
        Text(
          'ปล่อยวางความคิด และโฟกัสที่ลมหายใจของคุณ',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 14.0,
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8.0),
        Text(
          'เทคนิค 4-7-8: หายใจเข้า 4 วินาที, กลั้นหายใจ 7 วินาที, หายใจออก 8 วินาที',
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 12.0,
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
