import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_icons.dart';
import '../models/merit_models.dart';
import 'merit_payment_screen.dart';

/// หน้าสั่งจองฝากมูตามตารางสัปดาห์
class MeritWeeklyOrderScreen extends StatefulWidget {
  final WeeklyMeritSchedule schedule;
  final DateTime selectedDate;

  const MeritWeeklyOrderScreen({
    Key? key,
    required this.schedule,
    required this.selectedDate,
  }) : super(key: key);

  @override
  State<MeritWeeklyOrderScreen> createState() => _MeritWeeklyOrderScreenState();
}

class _MeritWeeklyOrderScreenState extends State<MeritWeeklyOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _wishController = TextEditingController();
  DateTime? _birthDate;

  // เลือก Package
  String _selectedPackage = 'standard';

  // เลือก Add-ons
  final Set<String> _selectedAddons = {};

  // ราคาพื้นฐานตาม Package
  final Map<String, double> _packagePrices = {
    'basic': 299,
    'standard': 499,
    'premium': 799,
  };

  final Map<String, String> _packageNames = {
    'basic': 'แพ็คมงคล',
    'standard': 'แพ็คเสริมดวง',
    'premium': 'แพ็คพรีเมียม',
  };

  final Map<String, List<String>> _packageFeatures = {
    'basic': [
      'ชุดไหว้พื้นฐาน',
      'รูปถ่าย 3 รูป',
      'รายงานผล LINE',
    ],
    'standard': [
      'ชุดไหว้พื้นฐาน',
      'รูปถ่าย 5 รูป',
      'วิดีโอสั้น 30 วินาที',
      'รายงานผล LINE',
      'ใบรับรองทำบุญ',
    ],
    'premium': [
      'ชุดไหว้พื้นฐาน',
      'รูปถ่าย 10 รูป',
      'วิดีโอเต็ม 3 นาที',
      'Live สด (ถ้าพร้อม)',
      'รายงานผล LINE',
      'ใบรับรองทำบุญ',
      'ของที่ระลึก',
    ],
  };

  double get _basePrice => _packagePrices[_selectedPackage] ?? 499;

  double get _addonsPrice {
    double total = 0;
    for (var addonId in _selectedAddons) {
      final addon = widget.schedule.addons.firstWhere(
        (a) => a.id == addonId,
        orElse: () => const MeritAddon(id: '', name: '', price: 0),
      );
      total += addon.price;
    }
    return total;
  }

  double get _totalPrice => _basePrice + _addonsPrice;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _wishController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMMM yyyy', 'th_TH').format(widget.selectedDate);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.darkBackground,
              const Color(0xFF1A1A2E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Location & Date Info
                        _buildInfoCard(dateStr),
                        const SizedBox(height: 24),

                        // Package Selection
                        _buildSectionTitle('เลือกแพ็คเกจ'),
                        const SizedBox(height: 12),
                        _buildPackageSelector(),
                        const SizedBox(height: 24),

                        // Add-ons
                        _buildSectionTitle('เพิ่มของไหว้พิเศษ'),
                        const SizedBox(height: 12),
                        _buildAddonsSelector(),
                        const SizedBox(height: 24),

                        // Form Fields
                        _buildSectionTitle('ข้อมูลผู้ขอพร'),
                        const SizedBox(height: 12),
                        _buildFormFields(),
                        const SizedBox(height: 24),

                        // Price Summary
                        _buildPriceSummary(),
                        const SizedBox(height: 24),

                        // Submit Button
                        _buildSubmitButton(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: SvgIcon(AppIcons.arrowBack, size: 20, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              'สั่งจองฝากมู',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String dateStr) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFD700).withValues(alpha: 0.2),
            const Color(0xFFFF8C00).withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SvgIcon(AppIcons.temple, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.schedule.locationName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.schedule.day.displayName} - $dateStr',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPackageSelector() {
    return Column(
      children: _packagePrices.keys.map((packageId) {
        final isSelected = _selectedPackage == packageId;
        final price = _packagePrices[packageId]!;
        final name = _packageNames[packageId]!;
        final features = _packageFeatures[packageId]!;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPackage = packageId;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                    )
                  : null,
              color: isSelected ? null : const Color(0xFF2D2D44),
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? null
                  : Border.all(color: Colors.white24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? Colors.white
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.white54,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 16, color: Color(0xFFFF8C00))
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '฿${price.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFFFFD700),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: features.map((f) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddonsSelector() {
    if (widget.schedule.addons.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D44),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'ไม่มีของไหว้เพิ่มเติมสำหรับสถานที่นี้',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    return Column(
      children: widget.schedule.addons.map((addon) {
        final isSelected = _selectedAddons.contains(addon.id);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedAddons.remove(addon.id);
              } else {
                _selectedAddons.add(addon.id);
              }
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D44),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFFFD700)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: isSelected
                        ? const Color(0xFFFFD700)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFFD700)
                          : Colors.white54,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.black)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        addon.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (addon.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          addon.description!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '+${addon.priceFormatted}',
                  style: TextStyle(
                    color: isSelected ? const Color(0xFFFFD700) : Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFormFields() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D44),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Name
          TextFormField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('ชื่อ-นามสกุล ผู้ขอพร'),
            validator: (v) => v?.isEmpty ?? true ? 'กรุณาระบุชื่อ' : null,
          ),
          const SizedBox(height: 16),

          // Birth Date
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _birthDate ?? DateTime(1990),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() {
                  _birthDate = date;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _birthDate != null
                        ? DateFormat('d MMMM yyyy', 'th_TH').format(_birthDate!)
                        : 'วันเกิด (ไม่บังคับ)',
                    style: TextStyle(
                      color: _birthDate != null
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      fontSize: 16,
                    ),
                  ),
                  SvgIcon(AppIcons.calendar, size: 20, color: Colors.white54),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Phone
          TextFormField(
            controller: _phoneController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration('เบอร์โทรศัพท์'),
            validator: (v) => v?.isEmpty ?? true ? 'กรุณาระบุเบอร์โทร' : null,
          ),
          const SizedBox(height: 16),

          // Wish
          TextFormField(
            controller: _wishController,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: _inputDecoration('คำอธิษฐาน / สิ่งที่ต้องการขอ'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D44),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          _buildPriceRow('แพ็คเกจ ${_packageNames[_selectedPackage]}', _basePrice),
          if (_addonsPrice > 0) ...[
            const SizedBox(height: 8),
            _buildPriceRow('ของไหว้เพิ่มเติม', _addonsPrice),
          ],
          const SizedBox(height: 12),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'รวมทั้งหมด',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '฿${_totalPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
        Text(
          '฿${price.toStringAsFixed(0)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _submitOrder,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgIcon(AppIcons.heart, size: 22, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              'ยืนยันสั่งจอง ฿${_totalPrice.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitOrder() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // สร้าง MeritOrder และนำไปหน้าชำระเงิน
    final order = MeritOrder(
      id: null,
      orderNumber: null,
      locationId: widget.schedule.day.name, // ใช้ day name เป็น location ID ชั่วคราว
      packageId: _selectedPackage,
      prayerName: _nameController.text,
      prayerBirthdate: _birthDate,
      prayerWish: _wishController.text.isEmpty ? null : _wishController.text,
      prayerPhone: _phoneController.text,
      price: _totalPrice,
      slipUrl: null,
      paidAt: null,
      status: MeritOrderStatus.pending,
      proofUrls: null,
      proofVideoUrl: null,
      completedAt: null,
      adminNote: null,
      createdAt: DateTime.now(),
      location: MeritLocation(
        id: widget.schedule.day.name,
        nameTh: widget.schedule.locationName,
        nameEn: null,
        description: null,
        belief: widget.schedule.belief,
        address: null,
        imageUrl: null,
        isActive: true,
        sortOrder: 0,
      ),
      package: MeritPackage(
        id: _selectedPackage,
        nameTh: _packageNames[_selectedPackage] ?? 'แพ็คเกจ',
        nameEn: null,
        description: null,
        items: _packageFeatures[_selectedPackage] ?? [],
        price: _basePrice,
        photoCount: _selectedPackage == 'basic' ? 3 : (_selectedPackage == 'standard' ? 5 : 10),
        hasVideo: _selectedPackage != 'basic',
        hasLive: _selectedPackage == 'premium',
        isActive: true,
        sortOrder: 0,
      ),
    );

    // ไปหน้าชำระเงิน
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeritPaymentScreen(order: order),
      ),
    );
  }

  void _showSuccessDialog(Map<String, dynamic> orderData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFFFD700),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'บันทึกคำสั่งสำเร็จ!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'ยอดชำระ ฿${_totalPrice.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'กรุณาชำระเงินผ่าน LINE\nเพื่อยืนยันการจอง',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Back to schedule
                Navigator.pop(context); // Back to merit screen
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'ตกลง',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
