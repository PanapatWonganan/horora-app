import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/app_icons.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavigation({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  // ── Sacred Astrology nav palette ──────────────────────────────────────────
  // A muted plum/indigo translucent bar (the dusk-temple surface) with candle-
  // gold for the active tab and muted lilac-grey for inactive ones.
  static const Color _navActive = AppColors.candleGold; // active icon/text
  static const Color _navInactive = AppColors.onBackdropMuted; // muted lilac

  @override
  Widget build(BuildContext context) {
    // Frosted plum surface: translucent night-plum with a blur so the indigo
    // backdrop reads through it, plus a subtle candle-gold top hairline. No loud
    // glow — only a soft deep-indigo lift below.
    // Keep the frosted bar clipped, but draw the raised merit CTA in an
    // unclipped Stack above it. The old top-level ClipRect was cutting the gold
    // circle, so the button looked sliced instead of floating.
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.nightPlum.withValues(alpha: 0.88),
                border: Border(
                  top: BorderSide(
                    color: AppColors.candleGold.withValues(alpha: 0.22),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.templeIndigo.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: const SafeArea(
                child: SizedBox(height: 56),
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildNavItem(
                  context: context,
                  index: 0,
                  iconPath: AppIcons.home,
                  activeIconPath: AppIcons.homeFilled,
                  label: 'หน้าหลัก',
                ),
                _buildNavItem(
                  context: context,
                  index: 1,
                  iconPath: AppIcons.horoscopeWheel,
                  activeIconPath: AppIcons.horoscopeWheelFilled,
                  label: 'ดูดวง',
                ),
                // ทำบุญ — core revenue feature, always visually prominent as a
                // floating CTA. The active state is still communicated separately
                // by the label/indicator so it does not steal selection from Home.
                _MeritCtaTab(
                  isSelected: currentIndex == 2,
                  onTap: () => _handleNavigation(context, 2),
                ),
                _buildNavItem(
                  context: context,
                  index: 3,
                  iconPath: AppIcons.chat,
                  activeIconPath: AppIcons.chatFilled,
                  label: 'สนทนา',
                ),
                _buildNavItem(
                  context: context,
                  index: 4,
                  iconPath: AppIcons.person,
                  activeIconPath: AppIcons.personFilled,
                  label: 'โปรไฟล์',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required String iconPath,
    required String activeIconPath,
    required String label,
  }) {
    final isSelected = currentIndex == index;
    // On the dark plum bar: active = candle gold, inactive = muted lilac-grey.
    final color = isSelected ? _navActive : _navInactive;

    return GestureDetector(
      onTap: () => _handleNavigation(context, index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Active items sit on a soft candle-gold wash pill — calm and
            // clearly-active, no loud glow.
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.candleGold.withValues(alpha: 0.16)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: SvgIcon(
                isSelected ? activeIconPath : iconPath,
                size: 25,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    // ไม่ต้องนำทางถ้าอยู่ที่แท็บเดียวกันแล้ว
    if (index == currentIndex) return;

    // ใช้เส้นทางที่เหมาะสมกับแต่ละแท็บ (ทำบุญ = core, ตรงกลาง index 2)
    String route;
    switch (index) {
      case 0:
        route = AppRoutes.home;
        break;
      case 1:
        route = AppRoutes.horoscope;
        break;
      case 2:
        route = AppRoutes.merit;
        break;
      case 3:
        route = AppRoutes.chat;
        break;
      case 4:
        route = AppRoutes.profile;
        break;
      default:
        route = AppRoutes.home;
    }

    // นำทางไปยังเส้นทางที่กำหนด พร้อม interstitial ad (70% probability)
    Navigator.pushReplacementNamed(context, route);
  }
}

/// Revenue CTA animation for the center merit button.
///
/// - A slow, soft gold halo keeps the donation entry visually alive.
/// - A quick press bounce gives tactile feedback before navigation.
/// - Active selection is still shown by the label/underline so Home can remain
///   clearly selected while the CTA stays prominent.
class _MeritCtaTab extends StatefulWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _MeritCtaTab({
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_MeritCtaTab> createState() => _MeritCtaTabState();
}

class _MeritCtaTabState extends State<_MeritCtaTab>
    with TickerProviderStateMixin {
  late final AnimationController _haloController;
  late final AnimationController _bounceController;
  late final Animation<double> _haloScale;
  late final Animation<double> _haloOpacity;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _haloController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _haloScale = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _haloController, curve: Curves.easeInOutCubic),
    );
    _haloOpacity = Tween<double>(begin: 0.10, end: 0.22).animate(
      CurvedAnimation(parent: _haloController, curve: Curves.easeInOutCubic),
    );
    _pressScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.92)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 42,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.92, end: 1.07)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 34,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.07, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 24,
      ),
    ]).animate(_bounceController);
  }

  @override
  void dispose() {
    _haloController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_bounceController.isAnimating) return;
    await _bounceController.forward(from: 0);
    if (!mounted) return;
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.translate(
            offset: const Offset(0, -22),
            child: AnimatedBuilder(
              animation: Listenable.merge([_haloController, _bounceController]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _pressScale.value,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Transform.scale(
                        scale: _haloScale.value,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.candleGold
                                  .withValues(alpha: _haloOpacity.value),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.candleGold.withValues(
                                  alpha: _haloOpacity.value * 0.8,
                                ),
                                blurRadius: 20,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                      child!,
                    ],
                  ),
                );
              },
              child: Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.candleGold, AppColors.deepGoldBrown],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.onBackdrop
                        : AppColors.onBackdrop.withValues(alpha: 0.34),
                    width: isSelected ? 3 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.deepGoldBrown
                          .withValues(alpha: isSelected ? 0.42 : 0.24),
                      blurRadius: isSelected ? 20 : 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: SvgIcon(
                    AppIcons.temple,
                    size: 34,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -16),
            child: Text(
              'ทำบุญ',
              style: TextStyle(
                color: isSelected
                    ? AppBottomNavigation._navActive
                    : AppColors.onBackdrop,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -6),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: isSelected ? 24 : 0,
              height: 2,
              decoration: BoxDecoration(
                color: AppColors.candleGold,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
