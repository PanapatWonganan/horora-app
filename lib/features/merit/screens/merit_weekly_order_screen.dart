import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../../config/constants.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/guest_session_service.dart';
import '../../../core/services/local_reminder_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/merit_colors.dart';
import '../../../core/theme/sacred_ui.dart';
import '../../../core/utils/app_icons.dart';
import '../../../core/widgets/sacred_showcase.dart';
import '../../onboarding/models/onboarding_models.dart';
import '../models/merit_models.dart';
import '../../journey/services/faith_points_service.dart';
import '../services/merit_service.dart';
import '../widgets/merit_ui.dart';
import 'merit_order_status_screen.dart';
import 'merit_payment_screen.dart';

/// Cap on คำอธิษฐาน (wish) input length — mirrors [MeritWishInput]'s default
/// `maxLength` so the pure fill/append helper below never produces a string
/// the field itself would reject.
const int kMeritWishMaxLength = 200;

/// Pure helper for the wish suggestion chips (Task 21.B): tapping a chip
/// either replaces an empty wish box or appends the chip's text (space
/// separated) to existing text — always respecting [kMeritWishMaxLength].
///
/// Extracted as a standalone function (no widget/BuildContext dependency) so
/// it's cheaply unit-testable without pumping a widget tree.
String applyWishChip(String currentText, String chipText, {int maxLength = kMeritWishMaxLength}) {
  final trimmedCurrent = currentText.trim();
  final combined = trimmedCurrent.isEmpty ? chipText : '$trimmedCurrent $chipText';
  if (combined.length <= maxLength) return combined;
  return combined.substring(0, maxLength);
}

/// One ready-made wish suggestion chip's label.
class MeritWishSuggestion {
  final String label;
  const MeritWishSuggestion(this.label);
}

/// Picks up to 4 wish suggestions based on keywords in the schedule's
/// [belief] string, always ending with a generic catch-all. Belief-specific
/// matches are added first (in a fixed priority order) so the most relevant
/// suggestions for this destination show up before the generic one, then the
/// list is capped at 4.
List<MeritWishSuggestion> wishSuggestionsForBelief(String belief) {
  const generic = MeritWishSuggestion('ขอให้ชีวิตราบรื่น สิ่งดี ๆ เข้ามา');
  final matches = <MeritWishSuggestion>[];

  if (belief.contains('โชคลาภ') || belief.contains('การเงิน') || belief.contains('มั่งคั่ง')) {
    matches.add(const MeritWishSuggestion('ขอให้การเงินคล่องตัว มีโชคลาภ'));
  }
  if (belief.contains('ความรัก') || belief.contains('คู่ครอง')) {
    matches.add(const MeritWishSuggestion('ขอให้พบคู่ที่ดี ความรักราบรื่น'));
  }
  if (belief.contains('สุขภาพ')) {
    matches.add(const MeritWishSuggestion('ขอให้สุขภาพแข็งแรง'));
  }
  if (belief.contains('การงาน') || belief.contains('ความสำเร็จ')) {
    matches.add(const MeritWishSuggestion('ขอให้การงานก้าวหน้า'));
  }

  // Cap belief-specific matches at 3 so the generic catch-all always has a
  // slot within the 4-chip limit, then append it.
  final capped = matches.length > 3 ? matches.sublist(0, 3) : matches;
  return [...capped, generic];
}

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

  // Errors only appear after the first submit attempt; before that the form
  // stays calm (prefill would otherwise count as "interaction" and surface
  // the phone error prematurely on a pristine screen).
  bool _hasAttemptedSubmit = false;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _wishController = TextEditingController();
  DateTime? _birthDate;

  // เลือกแพ็คร่วมบุญ — ไม่มีค่าเริ่มต้น (null) บังคับให้ผู้ใช้เลือกเองอย่าง
  // ตั้งใจ แทนที่จะปล่อยให้ ฿499 ถูกเลือกไว้ล่วงหน้าโดยไม่รู้ตัว
  String? _selectedPackage;

  // เลือก Add-ons
  final Set<String> _selectedAddons = {};

  // ชุดแพ็คร่วมบุญ — hoisted ไปที่ merit_models.dart (WeeklyOrderPackage) เพื่อ
  // ให้หน้า landing (ราคาเริ่มต้น) กับหน้านี้อ่านข้อมูลชุดเดียวกัน
  static const List<WeeklyOrderPackage> _packages =
      WeeklyOrderPackage.defaultPackages;

  // สิทธิ์ "มูฟรีครั้งแรก" — โหลดจาก prefs ตอนเปิดหน้า ถ้ายังไม่เคยใช้
  // จะแทรกการ์ดแพ็คฟรีไว้บนสุดของตัวเลือก
  bool _freeTrialEligible = false;
  bool _isSubmittingFree = false;

  List<WeeklyOrderPackage> get _visiblePackages => _freeTrialEligible
      ? const [WeeklyOrderPackage.freeTrial, ...WeeklyOrderPackage.defaultPackages]
      : _packages;

  bool get _isFreeSelected =>
      _selectedPackage == WeeklyOrderPackage.freeTrial.id;

  // Tour หน้านี้ (ครั้งแรกเท่านั้น) 2 step: เลือกชุดร่วมบุญ → กรอกชื่อ
  // ผู้ขอพร — พาผู้ใช้ไล่จากเลือกแพ็คลงไปถึงฟอร์มกรอกข้อมูลเลย
  late final ShowcaseView _showcaseView;
  final GlobalKey _scFirstPackage = GlobalKey();
  final GlobalKey _scNameField = GlobalKey();

  WeeklyOrderPackage? get _selectedPackageData => _selectedPackage == null
      ? null
      : WeeklyOrderPackage.byId(_selectedPackage!);

  double get _basePrice => _selectedPackageData?.price ?? 0;

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
  void initState() {
    super.initState();
    AnalyticsService.instance.log('merit_order_view');
    _prefillContactInfo();
    _loadFreeTrialEligibility();
    // เข้าหน้าเลือกแพ็ค = intent สูง — ตั้งเตือนออเดอร์ค้างอีก 24 ชม.
    // (จะถูก cancel เมื่อสร้างออเดอร์สำเร็จ ทั้ง path ฟรีและจ่ายเงิน)
    LocalReminderService.instance.scheduleAbandonedOrderReminder();

    _showcaseView = ShowcaseView.register(
      scope: SacredShowcase.meritOrderScope,
      enableAutoScroll: true,
      // ปุ่มเท่านั้นที่เลื่อน tour ได้ — barrier tap ไม่ข้าม step
      disableBarrierInteraction: true,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStartShowcase());
  }

  /// Showcase จุดเดียวชี้ชุดร่วมบุญใบแรก — ครั้งแรกที่เข้าหน้านี้เท่านั้น
  /// ให้ผู้ใช้ใหม่เข้าใจว่าต้องเลือกแพ็คก่อน แล้วค่อยเลื่อนลงกรอกข้อมูล
  /// (แนวเดียวกับ tour หน้า Home: บันทึก "เห็นแล้ว" ตั้งแต่ตอนเริ่ม)
  Future<void> _maybeStartShowcase() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(StorageConstants.meritOrderShowcaseSeen) ?? false) {
        return;
      }
      await prefs.setBool(StorageConstants.meritOrderShowcaseSeen, true);
      if (!mounted) return;
      _showcaseView.startShowCase(
        [_scFirstPackage, _scNameField],
        delay: const Duration(milliseconds: 700),
      );
    } catch (e) {
      debugPrint('MeritWeeklyOrderScreen._maybeStartShowcase error: $e');
    }
  }

  /// เช็คสิทธิ์มูฟรีครั้งแรกจากเครื่อง — ผิดพลาดถือว่าไม่มีสิทธิ์ (ปลอดภัย
  /// กว่าแจกสิทธิ์ซ้ำ)
  Future<void> _loadFreeTrialEligibility() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final used = prefs.getBool(StorageConstants.freeMeritUsed) ?? false;
      if (mounted && !used) setState(() => _freeTrialEligible = true);
    } catch (e) {
      debugPrint('MeritWeeklyOrderScreen._loadFreeTrialEligibility error: $e');
    }
  }

  /// เติมชื่อ/วันเกิดล่วงหน้าจาก (a) บัญชีที่ล็อกอินอยู่ ก่อน (b) ข้อมูล
  /// onboarding ของ guest — ตามลำดับเดียวกับที่ home_screen ใช้ทักทายผู้ใช้
  /// เติมเฉพาะตอนฟิลด์ยังว่างเท่านั้น ไม่ทับข้อมูลที่ผู้ใช้พิมพ์เองแล้ว
  Future<void> _prefillContactInfo() async {
    try {
      final user = AuthService.instance.currentUser;
      final hasAccountName = user?.name.isNotEmpty ?? false;
      final hasAccountBirthDate = user?.birthDate != null;

      OnboardingData? guestData;
      if (!hasAccountName || !hasAccountBirthDate) {
        guestData = await GuestSessionService.instance.loadOnboarding();
      }

      if (!mounted) return;

      setState(() {
        if (_nameController.text.isEmpty) {
          final name = hasAccountName ? user!.name : (guestData?.name ?? '');
          if (name.isNotEmpty) _nameController.text = name;
        }
        _birthDate ??=
            hasAccountBirthDate ? user!.birthDate : guestData?.birthDate;
      });
    } catch (e) {
      // โหลด prefill ไม่สำเร็จ — ปล่อยฟอร์มว่างไว้ ให้ผู้ใช้กรอกเองได้ตามปกติ
      debugPrint('MeritWeeklyOrderScreen._prefillContactInfo error: $e');
    }
  }

  @override
  void dispose() {
    _showcaseView.unregister();
    _nameController.dispose();
    _phoneController.dispose();
    _wishController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat('d MMMM yyyy', 'th_TH').format(widget.selectedDate);

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
                    // Before the first submit attempt the form stays calm
                    // (no red borders on a pristine screen). After the first
                    // attempt, onUserInteraction re-validates on every
                    // keystroke so a stale error clears the moment the user
                    // fixes the field.
                    autovalidateMode: _hasAttemptedSubmit
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Destination temple — make the real endpoint of the
                        // merit unmistakable and verified before anything else.
                        MeritDestinationBanner(
                          templeName: widget.schedule.locationName,
                          belief: widget.schedule.belief,
                          subline:
                              '${widget.schedule.day.displayName} · $dateStr',
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

                        // Add-ons — ซ่อนเมื่อเลือกแพ็คฟรี (สิทธิ์ฟรีคือ
                        // ไหว้ + รูป 1 ใบเท่านั้น ไม่มีของถวายเพิ่ม)
                        if (!_isFreeSelected) ...[
                          _buildSectionTitle('✨ เพิ่มของถวายพิเศษ'),
                          const SizedBox(height: 12),
                          _buildAddonsSelector(),
                          const SizedBox(height: 24),
                        ],

                        // Form Fields
                        _buildSectionTitle('🙏 ข้อมูลผู้ร่วมบุญ'),
                        const SizedBox(height: 12),
                        _buildFormFields(),
                        const SizedBox(height: 20),

                        // Dedication / wish — premium temple-paper input.
                        _buildWishSuggestionChips(),
                        const SizedBox(height: 12),
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
            icon: const SvgIcon(AppIcons.arrowBack,
                size: 20, color: AppColors.onBackdrop),
            tooltip: 'ย้อนกลับ',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SacredOverline('Merit · ร่วมบุญ',
                    color: AppColors.onBackdropMuted,
                    fontSize: 12,
                    letterSpacing: 2.8),
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
      children: _visiblePackages.map((package) {
        final isSelected = _selectedPackage == package.id;
        // "ยอดนิยม" — เดิม ฿499 (standard) ถูกเลือกไว้ล่วงหน้าโดยอัตโนมัติ
        // ตอนนี้ไม่มีการเลือกล่วงหน้าแล้ว แต่ยังอยากให้แพ็คนี้ได้รับความสนใจ
        // อย่างตรงไปตรงมาด้วย badge แทน
        final isPopular = package.id == 'standard';
        final isFree = package.id == WeeklyOrderPackage.freeTrial.id;

        final card = GestureDetector(
          onTap: () {
            AnalyticsService.instance
                .log('merit_package_selected', {'package_id': package.id});
            setState(() {
              _selectedPackage = package.id;
              // แพ็คฟรีไม่รวม add-on (ของถวายมีต้นทุน) — ล้างที่เลือกไว้
              if (isFree) _selectedAddons.clear();
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isSelected ? AppColors.ricePaper : MeritColors.cardBackground,
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
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? MeritColors.accent
                                          .withValues(alpha: 0.16)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? MeritColors.accentDark
                                        : AppColors.mutedText,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check,
                                        size: 16, color: AppColors.deepText)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  package.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.deepText,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // Badge "ครั้งแรกเท่านั้น" ของแพ็คฟรี —
                              // สไตล์เดียวกับ ยอดนิยม แต่โทนเขียวไว้วางใจ
                              if (isFree) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4C7A5A),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'ครั้งแรกเท่านั้น',
                                    style: GoogleFonts.kanit(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                              // "ยอดนิยม" sits inline next to the name — an
                              // overlay at the card corner covered the price.
                              if (isPopular) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: MeritColors.accentGradient,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'ยอดนิยม',
                                    style: GoogleFonts.kanit(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Text(
                          isFree ? 'ฟรี' : package.priceFormatted,
                          style: TextStyle(
                            color: isFree
                                ? const Color(0xFF4C7A5A)
                                : (isSelected
                                    ? AppColors.deepText
                                    : MeritColors.accentDark),
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
                      children: package.features.map((f) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? MeritColors.accent.withValues(alpha: 0.12)
                                : AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            f,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.deepText
                                  : AppColors.mutedText,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );

        // การ์ดใบแรกที่มองเห็นเป็นเป้าของ step 1 "เลือกชุดร่วมบุญ"
        // (ครั้งแรกเท่านั้น — ถ้ามีสิทธิ์มูฟรี การ์ดฟรีคือใบแรก)
        if (package.id != _visiblePackages.first.id) return card;
        return SacredShowcase.wrap(
          showcaseKey: _scFirstPackage,
          scope: SacredShowcase.meritOrderScope,
          title: 'เลือกชุดร่วมบุญ',
          description: 'แต่ละชุดต่างกันที่จำนวนรูปถ่าย วิดีโอ และใบรับรอง '
              'แตะเลือกชุดที่ใช่สำหรับคุณได้เลย',
          targetBorderRadius: BorderRadius.circular(16),
          actions: SacredShowcase.defaultActions(),
          child: card,
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
    if (lower.contains('ดอกไม้') ||
        lower.contains('มาลัย') ||
        lower.contains('พวง')) {
      return '💐';
    }
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
                color: isSelected ? MeritColors.accentDark : AppColors.divider,
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
                        MeritColors.accent
                            .withValues(alpha: isSelected ? 0.4 : 0.25),
                        AppColors.secondary
                            .withValues(alpha: isSelected ? 0.4 : 0.25),
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
                    color: isSelected
                        ? MeritColors.accentDark
                        : AppColors.mutedText,
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
          // Name — step 2 ของ tour หน้านี้: auto-scroll ลงมาชี้ช่องชื่อ
          // ให้ผู้ใช้รู้ว่าต้องกรอกชื่อคนทำบุญตรงนี้ (เอ่ยชื่อตอนไหว้ให้)
          SacredShowcase.wrap(
            showcaseKey: _scNameField,
            scope: SacredShowcase.meritOrderScope,
            title: 'กรอกชื่อคนทำบุญ',
            description: 'ใส่ชื่อ-นามสกุลของผู้ขอพร ทีมงานจะเอ่ยชื่อนี้'
                'ตอนไหว้ให้ที่วัด พร้อมวันเกิดและคำอธิษฐานด้านล่าง',
            targetBorderRadius: BorderRadius.circular(12),
            actions: SacredShowcase.finishAction('เข้าใจแล้ว'),
            child: TextFormField(
              controller: _nameController,
              style: const TextStyle(color: AppColors.deepText),
              decoration: _inputDecoration('👤 ชื่อ-นามสกุล ผู้ขอพร'),
              validator: (v) => (v?.isEmpty ?? true) ? 'กรุณาระบุชื่อ' : null,
            ),
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
                  const SvgIcon(AppIcons.calendar,
                      size: 20, color: AppColors.mutedText),
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
            validator: (v) => (v?.isEmpty ?? true) ? 'กรุณาระบุเบอร์โทร' : null,
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              'ใช้ติดต่อแจ้งผลบุญของคุณเท่านั้น',
              style: GoogleFonts.kanit(
                color: AppColors.mutedText,
                fontSize: 12,
              ),
            ),
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

  /// Ready-made wish chips, tuned to this schedule's `belief` keywords.
  /// Tapping a chip fills the (empty) wish box or appends to existing text —
  /// see [applyWishChip]. Styled like the app's existing ivory pill chips
  /// ([MeritTrustChip]) with a gold hairline; no selected state since each
  /// tap is a one-shot filler, not a persistent choice.
  Widget _buildWishSuggestionChips() {
    final suggestions = wishSuggestionsForBelief(widget.schedule.belief);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: suggestions.map((s) {
        return GestureDetector(
          onTap: () => _onWishChipTap(s.label),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              color: MeritColors.cardBackground.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: MeritColors.accent.withValues(alpha: 0.35)),
            ),
            child: Text(
              s.label,
              style: GoogleFonts.kanit(
                color: AppColors.deepText,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _onWishChipTap(String chipText) {
    setState(() {
      _wishController.text = applyWishChip(_wishController.text, chipText);
      _wishController.selection = TextSelection.collapsed(
        offset: _wishController.text.length,
      );
    });
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
          if (_selectedPackageData != null) ...[
            _buildPriceRow('แพ็คเกจ ${_selectedPackageData!.name}', _basePrice),
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
          ] else
            Row(
              children: [
                const SvgIcon(AppIcons.info,
                    size: 16, color: AppColors.mutedText),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ยังไม่ได้เลือกแพ็ค — เลือกด้านบนได้เลย',
                    style: GoogleFonts.kanit(
                      color: AppColors.mutedText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
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
    final hasPackage = _selectedPackageData != null;
    return Opacity(
      opacity: hasPackage ? 1 : 0.5,
      child: GestureDetector(
        onTap: hasPackage ? _submitOrder : null,
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
              const SvgIcon(AppIcons.heart,
                  size: 22, color: AppColors.deepText),
              const SizedBox(width: 10),
              Text(
                hasPackage
                    ? (_isFreeSelected
                        ? (_isSubmittingFree
                            ? 'กำลังส่งคำขอ...'
                            : 'รับสิทธิ์มูฟรีครั้งแรก')
                        : 'ร่วมบุญ ฿${_totalPrice.toStringAsFixed(0)}')
                    : 'เลือกแพ็คก่อนร่วมบุญ',
                style: const TextStyle(
                  color: AppColors.deepText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ส่งคำสั่ง "มูฟรีครั้งแรก": สร้างออเดอร์ ฿0 ทันที (ไม่ผ่านหน้าชำระเงิน)
  /// สำเร็จแล้ว mark สิทธิ์ว่าใช้แล้ว + พาไปหน้าสถานะคำสั่งบุญ
  Future<void> _submitFreeOrder(MeritOrder order) async {
    if (_isSubmittingFree) return;
    setState(() => _isSubmittingFree = true);
    try {
      final created = await MeritService.instance.createWeeklyOrder(order);
      if (created == null) {
        throw Exception('ไม่ได้รับข้อมูลคำสั่งบุญจากระบบ');
      }
      // ออเดอร์มูฟรีสร้างสำเร็จ — จุดปิด funnel ฝั่ง path ฟรี
      AnalyticsService.instance.log('merit_order_created', {
        'type': 'free',
        'amount': order.price.toInt(),
      });
      // mark สิทธิ์หลังสร้างสำเร็จเท่านั้น — สร้างพลาดยังกลับมาใช้สิทธิ์ได้
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(StorageConstants.freeMeritUsed, true);
      // พลังศรัทธา: ฝากมูสำเร็จ +50 (รวมมูฟรีครั้งแรก)
      await FaithPointsService.instance.awardMeritOrder();
      // ออเดอร์สำเร็จแล้ว — ไม่ต้องเตือนออเดอร์ค้างอีก
      LocalReminderService.instance.cancelAbandonedOrderReminder();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'รับสิทธิ์มูฟรีแล้ว 🙏 ทีมงานจะไหว้ให้และส่งรูปยืนยันถึงคุณ'),
        ),
      );
      // แสดงวัด/แพ็ค/ราคา "ตามที่ผู้ใช้เลือกจริง" — backend ยังไม่รู้จัก
      // locationId/packageId ของ flow รายสัปดาห์ เลยคืนค่า default กลับมา
      // (คงเลขที่ออเดอร์/สถานะ/เวลาจากเซิร์ฟเวอร์ไว้)
      final displayOrder = created.copyWith(
        location: order.location,
        package: order.package,
        price: order.price,
        prayerName: order.prayerName,
        prayerWish: order.prayerWish,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MeritOrderStatusScreen(order: displayOrder),
        ),
      );
    } catch (e) {
      debugPrint('MeritWeeklyOrderScreen._submitFreeOrder error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ส่งคำขอไม่สำเร็จ ลองใหม่อีกครั้งนะคะ ($e)'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmittingFree = false);
    }
  }

  void _submitOrder() {
    final selectedPackage = _selectedPackageData;
    if (selectedPackage == null) return;
    if (!_hasAttemptedSubmit) {
      setState(() => _hasAttemptedSubmit = true);
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // สร้าง MeritOrder และนำไปหน้าชำระเงิน
    final order = MeritOrder(
      id: null,
      orderNumber: null,
      locationId:
          widget.schedule.day.name, // ใช้ day name เป็น location ID ชั่วคราว
      packageId: selectedPackage.id,
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
        id: selectedPackage.id,
        nameTh: selectedPackage.name,
        nameEn: null,
        description: null,
        items: selectedPackage.features,
        price: selectedPackage.price,
        photoCount: switch (selectedPackage.id) {
          'free_trial' => 1,
          'basic' => 3,
          'standard' => 5,
          _ => 10,
        },
        hasVideo: selectedPackage.id == 'standard' ||
            selectedPackage.id == 'premium',
        hasLive: selectedPackage.id == 'premium',
        isActive: true,
        sortOrder: 0,
      ),
    );

    // แพ็คฟรี: ไม่มีอะไรต้องจ่าย — สร้างคำสั่งบุญเลยแล้วพาไปหน้าสถานะ
    // (ข้ามหน้าชำระเงิน/แนบสลิปทั้งหมด)
    if (_isFreeSelected) {
      _submitFreeOrder(order);
      return;
    }

    // Display-only breakdown data for the payment screen's สรุปคำสั่งบุญ —
    // MeritOrder itself carries only the final `price` total, so the
    // package/add-on detail is passed alongside it via constructor params
    // rather than widening the model.
    final selectedAddonObjects = widget.schedule.addons
        .where((a) => _selectedAddons.contains(a.id))
        .toList();

    // ไปหน้าชำระเงิน
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeritPaymentScreen(
          order: order,
          packageName: selectedPackage.name,
          packagePrice: selectedPackage.price,
          selectedAddons: selectedAddonObjects,
          scheduledDate: widget.selectedDate,
          scheduledDayLabel: widget.schedule.day.displayName,
        ),
      ),
    );
  }
}
