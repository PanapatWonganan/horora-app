import 'package:flutter/material.dart';
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
    // Show loading while redirecting
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
