import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/api_client.dart';
import '../../config/constants.dart';
import '../../core/repositories/horoscope_repository.dart';
import '../../core/utils/thai_zodiac_emoji.dart';
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
    final apiClient = ApiClient(baseUrl: ApiConstants.baseUrl);
    return HoroscopeRepository(apiClient: apiClient, prefs: prefs);
  }

  Widget _buildZodiacSelectionGrid(
      BuildContext context, HoroscopeRepository repository) {
    final List<Map<String, String>> thaiAnimals = [
      {'name': 'ปีชวด', 'key': 'ชวด'},
      {'name': 'ปีฉลู', 'key': 'ฉลู'},
      {'name': 'ปีขาล', 'key': 'ขาล'},
      {'name': 'ปีเถาะ', 'key': 'เถาะ'},
      {'name': 'ปีมะโรง', 'key': 'มะโรง'},
      {'name': 'ปีมะเส็ง', 'key': 'มะเส็ง'},
      {'name': 'ปีมะเมีย', 'key': 'มะเมีย'},
      {'name': 'ปีมะแม', 'key': 'มะแม'},
      {'name': 'ปีวอก', 'key': 'วอก'},
      {'name': 'ปีระกา', 'key': 'ระกา'},
      {'name': 'ปีจอ', 'key': 'จอ'},
      {'name': 'ปีกุน', 'key': 'กุน'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'เลือกปีนักษัตรที่ต้องการดูดวง',
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
            itemCount: thaiAnimals.length,
            itemBuilder: (context, index) {
              final animal = thaiAnimals[index];
              return _buildAnimalCard(context, animal, repository);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalCard(BuildContext context, Map<String, String> animal,
      HoroscopeRepository repository) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Provider.value(
              value: repository,
              child: DailyHoroscopeScreen(thaiAnimal: animal['key']),
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
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  ThaiZodiacEmoji.getEmoji(animal['key']!),
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              animal['name']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
