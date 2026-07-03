import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/merit_colors.dart';
import '../../../core/theme/sacred_ui.dart';
import '../../../core/utils/app_icons.dart';
import '../models/merit_models.dart';
import '../widgets/merit_ui.dart';
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
    'basic': '🙏 แพ็คมงคล',
    'standard': '⭐ แพ็คเสริมดวง',
    'premium': '👑 แพ็คพรีเมียม',
  };

  final Map<String, List<String>> _packageFeatures = {
    'basic': [
      '🪷 ชุดไหว้พื้นฐาน',
      '📸 รูปถ่าย 3 รูป',
      '💬 รายงานผล LINE',
    ],
    'standard': [
      '🪷 ชุดไหว้พื้นฐาน',
      '📸 รูปถ่าย 5 รูป',
      '🎬 วิดีโอสั้น 30 วินาที',
      '💬 รายงานผล LINE',
      '📜 ใบรับรองทำบุญ',
    ],
    'premium': [
      '🪷 ชุดไหว้พื้นฐาน',
      '📸 รูปถ่าย 10 รูป',
      '🎬 วิดีโอเต็ม 3 นาที',
      '📡 Live สด (ถ้าพร้อม)',
      '💬 รายงานผล LINE',
      '📜 ใบรับรองทำบุญ',
      '🎁 ของที่ระลึก',
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
      body: SilkCandleBackdrop(
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
                        // Destination temple — make the real endpoint of the
                        // merit unmistakable and verified before anything else.
                        MeritDestinationBanner(
                          templeName: widget.schedule.locationName,
                          belief: widget.schedule.belief,
                          subline: '${widget.schedule.day.displayName} · $dateStr',
                        ),
                        const SizedBox(height: 16),

                        // Faith-service trust signals (หลักฐาน / ปลายทาง / อนุโมทนา).
                        const MeritTrustStrip(),
                        const SizedBox(height: 24),

                        // Package Selection
                        _buildSectionTitle('🤍 เลือกชุดร่วมบุญ'),
                        const SizedBox(height: 12),
                        _buildPackageSelector(),
                        const SizedBox(height: 24),

                        // Add-ons
                        _buildSectionTitle('✨ เพิ่มของถวายพิเศษ'),
                        const SizedBox(height: 12),
                        _buildAddonsSelector(),
                        const SizedBox(height: 24),

                        // Form Fields
                        _buildSectionTitle('🙏 ข้อมูลผู้ร่วมบุญ'),
                        const SizedBox(height: 12),
                        _buildFormFields(),
                        const SizedBox(height: 20),

                        // Dedication / wish — premium temple-paper input.
                        MeritWishInput(controller: _wishController),
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
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const SvgIcon(AppIcons.arrowBack, size: 20, color: AppColors.onBackdrop),
            tooltip: 'ย้อนกลับ',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SacredOverline('Merit · ร่วมบุญ', color: AppColors.onBackdropMuted, fontSize: 12, letterSpacing: 2.8),
                const SizedBox(height: 2),
                Text(
                  'รายละเอียดคำสั่งบุญ',
                  style: GoogleFonts.kanit(
                    color: AppColors.onBackdrop,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
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
    // Section titles here sit directly on the deep celestial backdrop, so they
    // use the light on-backdrop ink (not dark deepText, which is for ivory cards).
    return Text(
      title,
      style: GoogleFonts.kanit(
        color: AppColors.onBackdrop,
        fontSize: 18,
        fontWeight: FontWeight.w700,
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
              color: isSelected ? AppColors.ricePaper : MeritColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? MeritColors.accent.withValues(alpha: 0.55)
                    : AppColors.divider,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isSelected ? MeritColors.accent : AppColors.primary)
                      .withValues(alpha: isSelected ? 0.14 : 0.06),
                  blurRadius: isSelected ? 12 : 8,
                  offset: const Offset(0, 6),
                ),
              ],
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
                                ? MeritColors.accent.withValues(alpha: 0.16)
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? MeritColors.accentDark
                                  : AppColors.mutedText,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 16, color: AppColors.deepText)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          name,
                          style: const TextStyle(
                            color: AppColors.deepText,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '฿${price.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: isSelected ? AppColors.deepText : MeritColors.accentDark,
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
                            ? MeritColors.accent.withValues(alpha: 0.12)
                            : AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          color: isSelected ? AppColors.deepText : AppColors.mutedText,
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

  String _getAddonEmoji(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('กระดาษ') || lower.contains('ไหว้เจ้า')) return '📜';
    if (lower.contains('ส้ม') || lower.contains('ผลไม้')) return '🍊';
    if (lower.contains('ธูป') || lower.contains('หอม')) return '🪔';
    if (lower.contains('เทียน')) return '🕯️';
    if (lower.contains('ดอกไม้') || lower.contains('มาลัย') || lower.contains('พวง')) return '💐';
    if (lower.contains('น้ำ')) return '💧';
    if (lower.contains('ข้าว')) return '🍚';
    if (lower.contains('ขนม')) return '🍡';
    return '🙏';
  }

  Widget _buildAddonsSelector() {
    if (widget.schedule.addons.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: MeritColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Center(
          child: Text(
            'ไม่มีของไหว้เพิ่มเติมสำหรับสถานที่นี้',
            style: TextStyle(
              color: AppColors.mutedText,
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
              color: MeritColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? MeritColors.accentDark
                    : AppColors.divider,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        MeritColors.accent.withValues(alpha: isSelected ? 0.4 : 0.25),
                        AppColors.secondary.withValues(alpha: isSelected ? 0.4 : 0.25),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: MeritColors.accent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _getAddonEmoji(addon.name),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        addon.name,
                        style: const TextStyle(
                          color: AppColors.deepText,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (addon.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          addon.description!,
                          style: const TextStyle(
                            color: AppColors.mutedText,
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
                    color: isSelected ? MeritColors.accentDark : AppColors.mutedText,
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
        color: MeritColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Name
          TextFormField(
            controller: _nameController,
            style: const TextStyle(color: AppColors.deepText),
            decoration: _inputDecoration('👤 ชื่อ-นามสกุล ผู้ขอพร'),
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
                color: MeritColors.inputBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _birthDate != null
                        ? DateFormat('d MMMM yyyy', 'th_TH').format(_birthDate!)
                        : '📅 วันเกิด (ไม่บังคับ)',
                    style: TextStyle(
                      color: _birthDate != null
                          ? AppColors.deepText
                          : AppColors.mutedText,
                      fontSize: 16,
                    ),
                  ),
                  const SvgIcon(AppIcons.calendar, size: 20, color: AppColors.mutedText),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Phone
          TextFormField(
            controller: _phoneController,
            style: const TextStyle(color: AppColors.deepText),
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration('📞 เบอร์โทรศัพท์'),
            validator: (v) => v?.isEmpty ?? true ? 'กรุณาระบุเบอร์โทร' : null,
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.mutedText),
      filled: true,
      fillColor: MeritColors.inputBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: MeritColors.accentDark),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MeritColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MeritColors.accent.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: MeritColors.accent.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPriceRow('แพ็คเกจ ${_packageNames[_selectedPackage]}', _basePrice),
          if (_addonsPrice > 0) ...[
            const SizedBox(height: 8),
            _buildPriceRow('ของไหว้เพิ่มเติม', _addonsPrice),
          ],
          const SizedBox(height: 12),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ยอดร่วมบุญ',
                style: TextStyle(
                  color: AppColors.deepText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '฿${_totalPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: MeritColors.accentDark,
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
          style: const TextStyle(
            color: AppColors.mutedText,
            fontSize: 14,
          ),
        ),
        Text(
          '฿${price.toStringAsFixed(0)}',
          style: const TextStyle(
            color: AppColors.deepText,
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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: MeritColors.accentGradient,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: MeritColors.accent.withValues(alpha: 0.45),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SvgIcon(AppIcons.heart, size: 22, color: AppColors.deepText),
            const SizedBox(width: 10),
            Text(
              'ร่วมบุญ ฿${_totalPrice.toStringAsFixed(0)}',
              style: const TextStyle(
                color: AppColors.deepText,
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
}
