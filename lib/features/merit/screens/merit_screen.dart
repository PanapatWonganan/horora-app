import 'package:flutter/material.dart';
import '../../../core/theme/merit_colors.dart';
import '../widgets/merit_ui.dart';
import 'weekly_schedule_screen.dart';

/// หน้าหลักบริการทำบุญออนไลน์ - redirect ไปหน้าตารางประจำสัปดาห์
class MeritScreen extends StatefulWidget {
  const MeritScreen({Key? key}) : super(key: key);

  @override
  State<MeritScreen> createState() => _MeritScreenState();
}

class _MeritScreenState extends State<MeritScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate to weekly schedule immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const WeeklyScheduleScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading on the deep celestial backdrop while redirecting, so the
    // transition into the merit hero never flashes a bright screen.
    return const Scaffold(
      body: SilkCandleBackdrop(
        child: Center(
          child: CircularProgressIndicator(color: MeritColors.accent),
        ),
      ),
    );
  }
}
