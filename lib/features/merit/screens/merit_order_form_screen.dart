import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/merit_colors.dart';
import '../../../core/theme/sacred_ui.dart';
import '../../../core/utils/app_icons.dart';
import '../models/merit_models.dart';
import '../services/merit_service.dart';
import '../widgets/merit_ui.dart';
import 'merit_payment_screen.dart';

/// หน้ากรอกข้อมูลสั่งซื้อ
class MeritOrderFormScreen extends StatefulWidget {
  final MeritLocation location;

  const MeritOrderFormScreen({
    Key? key,
    required this.location,
  }) : super(key: key);

  @override
  State<MeritOrderFormScreen> createState() => _MeritOrderFormScreenState();
}

class _MeritOrderFormScreenState extends State<MeritOrderFormScreen> {
  final MeritService _meritService = MeritService.instance;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _wishController = TextEditingController();

  List<MeritPackage> _packages = [];
  MeritPackage? _selectedPackage;
  DateTime? _selectedBirthdate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _wishController.dispose();
    super.dispose();
  }

  Future<void> _loadPackages() async {
    setState(() => _isLoading = true);
    try {
      final packages = await _meritService.getPackages();
      setState(() {
        _packages = packages;
        if (packages.isNotEmpty) {
          _selectedPackage = packages.first;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _packages = MeritPackage.defaultPackages;
        _selectedPackage = _packages.first;
        _isLoading = false;
      });
    }
  }

  Future<void> _selectBirthdate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthdate ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: MeritColors.accentDark,
              onPrimary: Colors.white,
              surface: MeritColors.cardBackground,
              onSurface: AppColors.deepText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedBirthdate = picked;
      });
    }
  }

  void _proceedToPayment() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPackage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกชุดร่วมบุญ')),
      );
      return;
    }

    final order = MeritOrder(
      locationId: widget.location.id,
      packageId: _selectedPackage!.id,
      prayerName: _nameController.text.trim(),
      prayerBirthdate: _selectedBirthdate,
      prayerWish: _wishController.text.trim(),
      prayerPhone: _phoneController.text.trim(),
      price: _selectedPackage!.price,
      location: widget.location,
      package: _selectedPackage,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeritPaymentScreen(order: order),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SilkCandleBackdrop(
        warmHero: false,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoading
                    ? const SacredLoader.large()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLocationInfo(),
                              const SizedBox(height: 24),
                              _buildPackageSelection(),
                              const SizedBox(height: 24),
                              _buildPrayerForm(),
                              const SizedBox(height: 32),
                              _buildProceedButton(),
                              const SizedBox(height: 20),
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
                  'กรอกข้อมูลร่วมบุญ',
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

  Widget _buildLocationInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MeritColors.accent.withValues(alpha: 0.2),
            MeritColors.accentDark.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MeritColors.accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: MeritColors.accent.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.temple_buddhist,
              color: MeritColors.accent,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.location.nameTh,
                  style: GoogleFonts.kanit(
                    color: AppColors.deepText,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (widget.location.belief != null)
                  Text(
                    widget.location.belief!,
                    style: GoogleFonts.kanit(
                      color: MeritColors.accentDark,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MeritSectionTitle(
          'เลือกชุดร่วมบุญ',
          overline: 'Choose package',
          icon: AppIcons.star,
        ),
        const SizedBox(height: 16),
        ..._packages.map((package) => _buildPackageCard(package)),
      ],
    );
  }

  Widget _buildPackageCard(MeritPackage package) {
    final isSelected = _selectedPackage?.id == package.id;

    return GestureDetector(
      onTap: () => setState(() => _selectedPackage = package),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? MeritColors.accent.withValues(alpha: 0.18)
              : MeritColors.inputBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? MeritColors.accentDark : AppColors.divider,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  package.nameTh,
                  style: GoogleFonts.kanit(
                    color: isSelected ? MeritColors.accentDark : AppColors.deepText,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(colors: MeritColors.accentGradient)
                        : null,
                    color: isSelected ? null : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    package.priceFormatted,
                    style: GoogleFonts.fraunces(
                      color: isSelected ? AppColors.deepText : MeritColors.accentDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (package.description != null)
              Text(
                package.description!,
                style: const TextStyle(
                  color: AppColors.mutedText,
                  fontSize: 12,
                ),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: package.items.map((item) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item,
                  style: const TextStyle(
                    color: AppColors.deepText,
                    fontSize: 12,
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.photo_camera, size: 14, color: AppColors.mutedText),
                const SizedBox(width: 4),
                Text(
                  '${package.photoCount} รูป',
                  style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
                ),
                if (package.hasVideo) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.videocam, size: 14, color: AppColors.mutedText),
                  const SizedBox(width: 4),
                  const Text(
                    'วิดีโอ',
                    style: TextStyle(color: AppColors.mutedText, fontSize: 12),
                  ),
                ],
                if (package.hasLive) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.live_tv, size: 14, color: AppColors.error.withValues(alpha: 0.9)),
                  const SizedBox(width: 4),
                  Text(
                    'Live',
                    style: TextStyle(color: AppColors.error.withValues(alpha: 0.9), fontSize: 12),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MeritSectionTitle(
          'ข้อมูลผู้ร่วมบุญ',
          overline: 'Your details',
          icon: AppIcons.heart,
        ),
        const SizedBox(height: 16),

        // Name
        _buildTextField(
          controller: _nameController,
          label: 'ชื่อ-นามสกุล *',
          hint: 'กรอกชื่อ-นามสกุล',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'กรุณากรอกชื่อ-นามสกุล';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Birthdate
        GestureDetector(
          onTap: _selectBirthdate,
          child: AbsorbPointer(
            child: _buildTextField(
              label: 'วัน/เดือน/ปีเกิด',
              hint: _selectedBirthdate != null
                  ? DateFormat('d MMMM yyyy', 'th').format(_selectedBirthdate!)
                  : 'เลือกวันเกิด',
              suffixIcon: Icons.calendar_today,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Phone
        _buildTextField(
          controller: _phoneController,
          label: 'เบอร์โทรศัพท์',
          hint: '08X-XXX-XXXX',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),

        // Wish
        _buildTextField(
          controller: _wishController,
          label: 'สิ่งที่ต้องการขอพร',
          hint: 'เขียนคำขอพรของคุณ...',
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    IconData? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.kanit(
            color: AppColors.deepText,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.kanit(color: AppColors.deepText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.kanit(color: AppColors.mutedText),
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: AppColors.mutedText)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildProceedButton() {
    return SacredPrimaryButton(
      label: _selectedPackage != null
          ? 'ร่วมบุญ ${_selectedPackage!.priceFormatted}'
          : 'เลือกชุดร่วมบุญก่อน',
      onTap: _proceedToPayment,
      filled: true,
    );
  }
}
