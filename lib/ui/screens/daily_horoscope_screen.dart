import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/models.dart';
import '../../core/repositories/horoscope_repository.dart';
import '../constants/app_colors.dart';

class DailyHoroscopeScreen extends StatefulWidget {
  final String? zodiacSign;

  const DailyHoroscopeScreen({Key? key, this.zodiacSign}) : super(key: key);

  @override
  State<DailyHoroscopeScreen> createState() => _DailyHoroscopeScreenState();
}

class _DailyHoroscopeScreenState extends State<DailyHoroscopeScreen> {
  late Future<DailyHoroscope> _horoscopeFuture;
  late final HoroscopeRepository _horoscopeRepository;

  @override
  void initState() {
    super.initState();
    _horoscopeRepository =
        Provider.of<HoroscopeRepository>(context, listen: false);
    _loadHoroscope();
  }

  void _loadHoroscope() {
    final String sign = widget.zodiacSign ?? 'aries';
    _horoscopeFuture = _horoscopeRepository.getDailyHoroscope(sign);
  }

  void _refreshHoroscope() {
    setState(() {
      _loadHoroscope();
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ดวงประจำวัน'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshHoroscope,
          ),
        ],
      ),
      body: FutureBuilder<DailyHoroscope>(
        future: _horoscopeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ไม่สามารถโหลดดวงประจำวันได้',
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _refreshHoroscope,
                    icon: const Icon(Icons.refresh),
                    label: const Text('ลองใหม่อีกครั้ง'),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final horoscope = snapshot.data!;
            return _buildHoroscopeContent(context, horoscope, textTheme);
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.search_off,
                    color: Colors.orange,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ไม่พบข้อมูลดวงประจำวัน',
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _refreshHoroscope,
                    icon: const Icon(Icons.refresh),
                    label: const Text('ลองใหม่อีกครั้ง'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildHoroscopeContent(
      BuildContext context, DailyHoroscope horoscope, TextTheme textTheme) {
    const bool isThaiContent = true; // ควรมาจาก settings หรือ locale

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ส่วนหัว
          _buildHeaderSection(horoscope, textTheme),

          const SizedBox(height: 24),

          // เนื้อหาดวงชะตา
          Text(
            'คำทำนาย',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isThaiContent ? horoscope.contentTh : horoscope.content,
            style: textTheme.bodyLarge,
          ),

          const SizedBox(height: 24),

          // คะแนนในแต่ละด้าน
          Text(
            'คะแนนดวงชะตาในแต่ละด้าน',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildRatingsSection(horoscope, textTheme),

          const SizedBox(height: 24),

          // เลขนำโชคและสีนำโชค
          Text(
            'สิ่งนำโชค',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildLuckySection(horoscope, textTheme),

          const SizedBox(height: 32),

          // คำเตือน
          Center(
            child: Text(
              'คำทำนายนี้เป็นเพียงแนวทางเท่านั้น โปรดใช้วิจารณญาณในการรับชม',
              style: textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(DailyHoroscope horoscope, TextTheme textTheme) {
    // แปลงชื่อราศีภาษาอังกฤษเป็นภาษาไทย
    final String zodiacThaiName = _getThaiZodiacName(horoscope.zodiacSign);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // รูปภาพราศี
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.secondaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Center(
            child: Image.asset(
              'assets/images/zodiac/${horoscope.zodiacSign}.png',
              width: 60,
              height: 60,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.stars,
                size: 40,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // ข้อมูลราศีและวันที่
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                zodiacThaiName,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '(${horoscope.zodiacSign.toUpperCase()})',
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'วันที่ ${_formatDate(horoscope.date)}',
                style: textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingsSection(DailyHoroscope horoscope, TextTheme textTheme) {
    return Column(
      children: [
        _buildRatingBar('ความรัก', horoscope.loveRating, Colors.red[400]!),
        const SizedBox(height: 12),
        _buildRatingBar('การงาน', horoscope.careerRating, Colors.blue[600]!),
        const SizedBox(height: 12),
        _buildRatingBar('สุขภาพ', horoscope.healthRating, Colors.green[600]!),
      ],
    );
  }

  Widget _buildRatingBar(String label, int rating, Color color) {
    const int maxRating = 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 8),
            Text(
              '$rating/$maxRating',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    // Background (unfilled)
                    Container(
                      height: 12,
                      color: Colors.grey[300],
                    ),
                    // Filled rating
                    FractionallySizedBox(
                      widthFactor: rating / maxRating,
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLuckySection(DailyHoroscope horoscope, TextTheme textTheme) {
    return Row(
      children: [
        Expanded(
          child: _buildLuckyItem(
            context,
            'เลขนำโชค',
            horoscope.luckyNumber,
            Icons.confirmation_number_outlined,
            Colors.purple[400]!,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildLuckyItem(
            context,
            'สีนำโชค',
            horoscope.luckyColor,
            Icons.color_lens_outlined,
            Colors.orange[400]!,
          ),
        ),
      ],
    );
  }

  Widget _buildLuckyItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // แปลงชื่อราศีภาษาอังกฤษเป็นภาษาไทย
  String _getThaiZodiacName(String englishName) {
    final Map<String, String> zodiacNames = {
      'aries': 'ราศีเมษ',
      'taurus': 'ราศีพฤษภ',
      'gemini': 'ราศีเมถุน',
      'cancer': 'ราศีกรกฎ',
      'leo': 'ราศีสิงห์',
      'virgo': 'ราศีกันย์',
      'libra': 'ราศีตุลย์',
      'scorpio': 'ราศีพิจิก',
      'sagittarius': 'ราศีธนู',
      'capricorn': 'ราศีมังกร',
      'aquarius': 'ราศีกุมภ์',
      'pisces': 'ราศีมีน',
    };

    return zodiacNames[englishName.toLowerCase()] ?? englishName;
  }

  // จัดรูปแบบวันที่
  String _formatDate(DateTime date) {
    final List<String> thaiMonths = [
      'มกราคม',
      'กุมภาพันธ์',
      'มีนาคม',
      'เมษายน',
      'พฤษภาคม',
      'มิถุนายน',
      'กรกฎาคม',
      'สิงหาคม',
      'กันยายน',
      'ตุลาคม',
      'พฤศจิกายน',
      'ธันวาคม'
    ];

    return '${date.day} ${thaiMonths[date.month - 1]} ${date.year + 543}';
  }
}
