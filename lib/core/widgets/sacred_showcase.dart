import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showcaseview/showcaseview.dart';

import '../theme/app_colors.dart';

/// สไตล์กลางของ feature tour (showcaseview) ให้เป็นภาษาเดียวกับธีม
/// Sacred Astrology — tooltip พื้น ivory, หัวข้อทองเข้ม, ตัวอักษร Kanit —
/// แทน default ขาว/ดำของ package ที่หลุดธีมแอป
class SacredShowcase {
  SacredShowcase._();

  /// Scope ของ tour หน้า Home (ดวงรายวัน → ทำบุญ → สนทนา → โปรไฟล์)
  static const String homeScope = 'home_tour';

  /// Scope ของ showcase เฉพาะจุดบนหน้าทำบุญ (เลือกวันไหว้)
  static const String meritScope = 'merit_tour';

  static TextStyle get _titleStyle => GoogleFonts.kanit(
        color: AppColors.deepGoldBrown,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get _descStyle => GoogleFonts.kanit(
        color: AppColors.deepText,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
      );

  static TextStyle get _buttonTextStyle => GoogleFonts.kanit(
        color: const Color(0xFF3A2C0E),
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get _skipTextStyle => GoogleFonts.kanit(
        color: AppColors.deepText.withValues(alpha: 0.55),
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
      );

  /// ปุ่ม action มาตรฐานของ tour: ข้าม (ซ้าย, จาง) / ถัดไป (ขวา, ทอง)
  static List<TooltipActionButton> defaultActions() => [
        TooltipActionButton(
          type: TooltipDefaultActionType.skip,
          name: 'ข้าม',
          backgroundColor: Colors.transparent,
          textStyle: _skipTextStyle,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        ),
        TooltipActionButton(
          type: TooltipDefaultActionType.next,
          name: 'ถัดไป',
          backgroundColor: AppColors.candleGold,
          textStyle: _buttonTextStyle,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        ),
      ];

  /// ปุ่มเดียวสำหรับ step สุดท้าย / showcase แบบจุดเดียว — กด next
  /// (ซึ่งเป็น step สุดท้าย package จะจบ tour เอง)
  static List<TooltipActionButton> finishAction(String label) => [
        TooltipActionButton(
          type: TooltipDefaultActionType.next,
          name: label,
          backgroundColor: AppColors.candleGold,
          textStyle: _buttonTextStyle,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        ),
      ];

  static const TooltipActionConfig actionConfig = TooltipActionConfig(
    alignment: MainAxisAlignment.end,
    actionGap: 10,
    gapBetweenContentAndAction: 14,
  );

  /// ห่อ widget เป้าหมายด้วย [Showcase] ที่จัดธีมแล้ว
  ///
  /// [showcaseKey] เป็น registry id ของ step (v5 ไม่ผูกกับ element จริง)
  /// [actions] ใส่เมื่ออยาก override ปุ่ม global เช่น step สุดท้ายใช้
  /// [finishAction] แทนคู่ ข้าม/ถัดไป
  static Widget wrap({
    required GlobalKey showcaseKey,
    required String scope,
    required String title,
    required String description,
    required Widget child,
    ShapeBorder? targetShapeBorder,
    BorderRadius? targetBorderRadius,
    EdgeInsets targetPadding = const EdgeInsets.all(6),
    List<TooltipActionButton>? actions,
  }) {
    return Showcase(
      key: showcaseKey,
      scope: scope,
      title: title,
      description: description,
      titleTextStyle: _titleStyle,
      descTextStyle: _descStyle,
      tooltipBackgroundColor: AppColors.ivorySilk,
      tooltipBorderRadius: BorderRadius.circular(18),
      tooltipPadding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
      overlayColor: AppColors.templeIndigo,
      overlayOpacity: 0.82,
      targetShapeBorder: targetShapeBorder ??
          RoundedRectangleBorder(
            borderRadius: targetBorderRadius ?? BorderRadius.circular(20),
          ),
      targetBorderRadius: targetBorderRadius,
      targetPadding: targetPadding,
      tooltipActions: actions,
      tooltipActionConfig: actions != null ? actionConfig : null,
      child: child,
    );
  }
}
