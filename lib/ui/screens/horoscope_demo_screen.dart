import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/api_client.dart';
import '../../core/repositories/horoscope_repository.dart';
import 'daily_horoscope_screen.dart';

class HoroscopeDemoScreen extends StatelessWidget {
  const HoroscopeDemoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ทดสอบระบบดูดวง'),
      ),
      body: Center(
        child: FutureBuilder<HoroscopeRepository>(
          future: _setupHoroscopeRepository(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('เกิดข้อผิดพลาด: ${snapshot.error}');
            } else if (snapshot.hasData) {
              return _buildZodiacSelectionGrid(context, snapshot.data!);
            } else {
              return const Text('ไม่สามารถเริ่มต้นระบบดูดวงได้');
            }
          },
        ),
      ),
    );
  }

  Future<HoroscopeRepository> _setupHoroscopeRepository() async {
    final prefs = await SharedPreferences.getInstance();
    final apiClient = ApiClient(baseUrl: 'https://api.astrology-app.com/api');
    return HoroscopeRepository(apiClient: apiClient, prefs: prefs);
  }

  Widget _buildZodiacSelectionGrid(
      BuildContext context, HoroscopeRepository repository) {
    final List<Map<String, String>> zodiacSigns = [
      {'name': 'ราศีเมษ', 'key': 'aries'},
      {'name': 'ราศีพฤษภ', 'key': 'taurus'},
      {'name': 'ราศีเมถุน', 'key': 'gemini'},
      {'name': 'ราศีกรกฎ', 'key': 'cancer'},
      {'name': 'ราศีสิงห์', 'key': 'leo'},
      {'name': 'ราศีกันย์', 'key': 'virgo'},
      {'name': 'ราศีตุลย์', 'key': 'libra'},
      {'name': 'ราศีพิจิก', 'key': 'scorpio'},
      {'name': 'ราศีธนู', 'key': 'sagittarius'},
      {'name': 'ราศีมังกร', 'key': 'capricorn'},
      {'name': 'ราศีกุมภ์', 'key': 'aquarius'},
      {'name': 'ราศีมีน', 'key': 'pisces'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'เลือกราศีที่ต้องการดูดวง',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.0,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: zodiacSigns.length,
            itemBuilder: (context, index) {
              final sign = zodiacSigns[index];
              return _buildZodiacCard(context, sign, repository);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildZodiacCard(BuildContext context, Map<String, String> sign,
      HoroscopeRepository repository) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Provider.value(
              value: repository,
              child: DailyHoroscopeScreen(zodiacSign: sign['key']),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/zodiac/${sign['key']}.png',
              width: 48,
              height: 48,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.stars,
                size: 48,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              sign['name']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
