import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'focus_insights_screen.dart';

class FocusHistoryScreen extends StatelessWidget {
  const FocusHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ประวัติการนั่งสมาธิ'),
        backgroundColor: AppColors.darkSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filtering
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.black87,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
                ),
                builder: (context) => _buildFilterSheet(context),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 10, // Mock data count
        itemBuilder: (context, index) {
          return _buildHistoryItem(context, index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to focus session screen
          Navigator.pushNamed(context, '/focus/session');
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, int index) {
    // Mock data
    final date = DateTime.now().subtract(Duration(days: index));
    final formattedDate = '${date.day}/${date.month}/${date.year}';
    final duration = [5, 10, 15, 20, 30][index % 5];
    final soundscapes = ['cosmic_harmony', 'star_whispers', 'cosmic_energy', 'lunar_breeze', 'silent'];
    final soundscape = soundscapes[index % soundscapes.length];
    final completed = index % 3 != 0; // Some sessions are incomplete
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          if (completed) {
            // Navigate to insights screen for completed sessions
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FocusInsightsScreen(
                  sessionDurationMinutes: duration,
                  sessionDate: formattedDate,
                  soundscape: soundscape,
                ),
              ),
            );
          } else {
            // Show dialog for incomplete sessions
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('การนั่งสมาธิไม่สมบูรณ์'),
                content: const Text('การนั่งสมาธินี้ถูกยกเลิกก่อนเสร็จสิ้น ไม่มีข้อมูลเชิงลึกสำหรับการนั่งสมาธินี้'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('เข้าใจแล้ว'),
                  ),
                ],
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'การนั่งสมาธิ ${index + 1}',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.timer,
                    label: '$duration นาที',
                  ),
                  const SizedBox(width: 8.0),
                  _buildInfoChip(
                    icon: Icons.music_note,
                    label: _getThaiSoundscapeName(soundscape),
                  ),
                  const SizedBox(width: 8.0),
                  _buildStatusChip(completed),
                ],
              ),
              if (completed) ...[
                const SizedBox(height: 12.0),
                const Text(
                  'ข้อมูลเชิงลึก',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'การนั่งสมาธิครั้งนี้ช่วยให้คุณได้เชื่อมต่อกับตัวเองมากขึ้น ทำให้เกิดความสงบภายในและความชัดเจนในความคิด',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.0,
            color: AppColors.primary,
          ),
          const SizedBox(width: 4.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.0,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(bool completed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: completed ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.cancel,
            size: 16.0,
            color: completed ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4.0),
          Text(
            completed ? 'สมบูรณ์' : 'ไม่สมบูรณ์',
            style: TextStyle(
              fontSize: 12.0,
              color: completed ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSheet(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'กรองประวัติการนั่งสมาธิ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24.0),
          const Text(
            'ระยะเวลา',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              _buildFilterChip('ทั้งหมด', true),
              _buildFilterChip('5 นาที', false),
              _buildFilterChip('10 นาที', false),
              _buildFilterChip('15+ นาที', false),
            ],
          ),
          const SizedBox(height: 16.0),
          const Text(
            'สถานะ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              _buildFilterChip('ทั้งหมด', true),
              _buildFilterChip('สมบูรณ์', false),
              _buildFilterChip('ไม่สมบูรณ์', false),
            ],
          ),
          const SizedBox(height: 16.0),
          const Text(
            'เสียงพื้นหลัง',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              _buildFilterChip('ทั้งหมด', true),
              _buildFilterChip('จักรวาลกลมกลืน', false),
              _buildFilterChip('ดวงดาวกระซิบ', false),
              _buildFilterChip('พลังจักรวาล', false),
              _buildFilterChip('สายลมจันทรา', false),
            ],
          ),
          const SizedBox(height: 24.0),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                  ),
                  child: const Text('ยกเลิก'),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Apply filters
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                  ),
                  child: const Text('นำไปใช้'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (value) {
        // TODO: Implement filter selection
      },
      backgroundColor: Colors.black45,
      selectedColor: AppColors.primary.withOpacity(0.3),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.white70,
      ),
    );
  }

  String _getThaiSoundscapeName(String soundscape) {
    switch (soundscape) {
      case 'cosmic_harmony':
        return 'จักรวาลกลมกลืน';
      case 'star_whispers':
        return 'ดวงดาวกระซิบ';
      case 'cosmic_energy':
        return 'พลังจักรวาล';
      case 'lunar_breeze':
        return 'สายลมจันทรา';
      case 'silent':
        return 'เสียงเงียบสงบ';
      default:
        return soundscape;
    }
  }
} 