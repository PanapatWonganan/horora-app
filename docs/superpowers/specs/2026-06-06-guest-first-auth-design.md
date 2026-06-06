# Guest-First Auth Flow — Design Spec

**Date:** 2026-06-06
**Project:** Astrology App (Horora) — Flutter frontend
**Goal:** เปลี่ยนจาก "บังคับ register/login ก่อนใช้งาน" เป็น **guest-first** — เข้า app และใช้ free features ได้โดยไม่ต้อง login แล้วค่อยเด้งหน้าสมัครเมื่อจะใช้ feature ที่ต้อง persist data

---

## 1. ปัญหา & เป้าหมาย

ปัจจุบัน `AuthWrapper` เป็น **hard gate** ที่ root — ไม่มี token = เห็นแค่ Welcome → Onboarding → Register (บังคับ) ทำให้ user drop-off ก่อนเข้าใช้แอป

เป้าหมาย: ให้ guest
- เข้า app ได้เลย ทำ onboarding (ความสนใจ + วันเกิด + สไตล์) แบบไม่ต้องสมัคร
- ใช้ free features: **Horoscope, Tarot (ดู), Merit (ดู)** ได้ทันที
- เมื่อกด action ที่ต้อง login (save reading / chat AI / สั่ง merit order / affiliate / profile / history) → เด้งหน้าสมัคร พร้อม **resume action เดิม** หลังสมัครเสร็จ
- วันเกิด/ความสนใจที่กรอกตอน guest → เก็บ local → **sync ขึ้น server ตอนสมัคร** (pre-fill register form)

## 2. หลักการความปลอดภัย (ยึดเข้มงวด)

- **ห้ามย้าย secret/API key ไป frontend เพิ่ม** จากที่มีอยู่ปัจจุบัน
- OpenAI key อยู่ใน `assets/.env` ฝั่ง client อยู่แล้ว (ของเดิม) — **ไม่ขยาย** การ expose เพิ่ม
- **ไม่เปิด backend endpoint ที่ sensitive ให้ guest** โดยไม่ตรวจสอบ — gate ที่ action ที่ต้อง persist (save/order/chat) ผ่าน Sanctum token เหมือนเดิม
- Guest data เก็บ local เท่านั้น (SharedPreferences) ไม่ส่ง PII ไป server จนกว่าจะสมัคร

## 3. ผลตรวจ backend (ยืนยันแล้ว)

Backend อยู่ที่ `../backend/horora-api/`, routes (`routes/api.php`):

| Feature | Guest accessible | หมายเหตุ |
|---|---|---|
| Horoscope (daily) | ✅ | สร้างฝั่ง client ผ่าน OpenAI (`smart_horoscope_service.dart` / `openai_client.dart`) — ไม่พึ่ง token |
| Horoscope history | 🔒 | `/horoscope/history` ต้อง `auth:sanctum` |
| Tarot cards / random | ✅ | มี local fallback (`LocalTarotData`) |
| Tarot save reading | 🔒 | `POST /tarot/readings` ต้อง token |
| Merit browse (locations/packages/schedule) | ✅ | public routes |
| Merit order | 🔒 | `POST /merit/orders` ต้อง token |
| Chat AI | 🔒 | ทุก `/chat/*` ต้อง token |
| Affiliate | 🔒 | ต้อง token |

**ข้อสรุป:** gate จริงอยู่ที่ **action ที่ persist** ไม่ใช่ทั้ง feature → ตรงกับ Feature-Level Auth Gating พอดี **ไม่ต้องแก้ backend** (guest support มีพออยู่แล้วอย่างปลอดภัย)

## 4. สถาปัตยกรรม (แนวทาง A — Feature-Level Auth Gating)

```
Launch → AuthWrapper → [onboardingCompleted?]
                          ├─ ยัง  → Welcome → Onboarding(guest) → Home
                          └─ เสร็จ → Home (guest หรือ logged-in)

ที่ Home/Feature:
  guest ใช้ฟรี (Horoscope / Tarot ดู / Merit ดู)
  กด gated action → AuthGuard.requireAuth(context, intent:)
      ├─ logged-in → return true → ทำ action ต่อ
      └─ guest     → push Register (prefill onboarding local + จำ intent)
                        → สมัคร/sync สำเร็จ → return true → resume action เดิม
```

### องค์ประกอบใหม่

**4.1 `GuestSessionService` (singleton)** — `lib/core/services/guest_session_service.dart`
- เก็บ/อ่าน onboarding data ใน SharedPreferences: `birth_date`, `birth_time`, `primary_interest`, `spiritual_style`, `name`
- flag `onboarding_completed` (bool)
- `Future<void> saveOnboarding(OnboardingData data)`
- `Future<OnboardingData?> loadOnboarding()`
- `Future<bool> isOnboardingCompleted()`
- `Future<void> markOnboardingCompleted()`
- `Future<void> clear()` (เรียกหลัง sync สำเร็จ เพื่อไม่ให้ข้อมูล guest ค้าง)
- Storage keys เพิ่มใน `StorageConstants`: `guestOnboarding`, `onboardingCompleted`

**4.2 `AuthGuard` (helper)** — `lib/core/services/auth_guard.dart`
- `static Future<bool> requireAuth(BuildContext context, {String? intentLabel})`
  - ถ้า `AuthService.instance.isLoggedIn()` (ใช้ in-memory token ก่อน เพื่อไม่ block UI) → return true
  - ถ้าไม่ → push `RegisterScreen` (หรือ login) แบบ modal/route, ส่ง onboarding prefill
  - รอผล: ถ้าสมัครสำเร็จ → return true, ถ้า user ยกเลิก → return false
- ไม่ทำ navigation ของ action เอง — แค่ตอบ true/false ให้ caller ตัดสินใจ resume

**4.3 `AuthWrapper` ใหม่**
- เปลี่ยนเงื่อนไข: เช็ค `isLoggedIn` **หรือ** `isOnboardingCompleted`
  - logged-in → Home
  - ไม่ logged-in แต่ onboarding เสร็จ (guest) → Home
  - ยังไม่เสร็จ → Welcome
- ยังคง `isLoggedIn()` validate token เดิมไว้ (สำหรับ resume session ของ user จริง)

### ของเดิมที่แก้

| ไฟล์ | การแก้ |
|---|---|
| `lib/features/auth/auth_wrapper.dart` | เพิ่มเช็ค onboardingCompleted → guest เข้า Home ได้ |
| `lib/features/onboarding/.../onboarding_quiz_screen.dart` | หน้า register CTA → guest กด "ข้ามไปก่อน / เริ่มใช้งาน" → save local + markOnboardingCompleted → ไป Home (แทนบังคับ register) |
| `lib/features/auth/register/register_screen.dart` | รับ onboarding prefill, หลังสมัครสำเร็จ sync + clear guest data + `Navigator.pop(true)` (รองรับ resume) |
| Gated actions: Tarot save, Merit order, Chat entry, Affiliate, Profile/History | ห่อด้วย `if (await AuthGuard.requireAuth(context)) { ...action... }` |
| `lib/config/constants.dart` | เพิ่ม storage keys |

## 5. Data flow: guest → สมัคร (sync)

1. Guest ทำ onboarding → `GuestSessionService.saveOnboarding()` เก็บ local
2. Guest กด gated action → `AuthGuard` push Register พร้อม prefill (`loadOnboarding()`)
3. Register สำเร็จ → `signUp(birthDate, name, ...)` ส่งข้อมูลที่มีไป server (เหมือน flow เดิม)
4. หลังสำเร็จ → `GuestSessionService.clear()` (ลบ guest data local)
5. `Navigator.pop(true)` → AuthGuard return true → caller resume action

## 6. Error handling

- โหลด/save local ล้มเหลว → fallback เป็นค่า null/ guest ปกติ ไม่ crash
- `requireAuth`: ถ้า user ยกเลิก register → return false, caller ไม่ทำ action (แสดง snackbar เบาๆ ได้)
- Token validate ล้มเหลว (หมดอายุ) → treat เป็น guest ที่ onboarding เสร็จ → เข้า Home ได้ ไม่เด้งออก

## 7. Testing

- **Unit**: `GuestSessionService` (save/load/clear roundtrip, completed flag) — mock SharedPreferences
- **Unit/Widget**: `AuthGuard.requireAuth` — logged-in → true ทันที; guest → push register
- **Widget**: `AuthWrapper` — 3 states (logged-in / guest-onboarded / fresh)
- **Verify**: `flutter analyze` (lint) + `flutter test` (unit/widget) + `flutter build apk --debug` (build จริง)

## 8. แบ่งงาน 3 agents

- **Agent 1 — Core auth plumbing**: `GuestSessionService`, `AuthGuard`, storage keys, `AuthWrapper` ใหม่ + unit tests
- **Agent 2 — Onboarding & Register**: guest path ใน onboarding (skip→home), register รับ prefill + sync + pop(true) + widget tests
- **Agent 3 — Feature gating**: ใส่ `AuthGuard.requireAuth` ที่ gated actions (Tarot save, Merit order, Chat, Affiliate, Profile/History)

ตัวหลัก (orchestrator) คุม integration, แก้ conflict, run analyze/test/build รวม

## 9. Non-goals

- ไม่แก้ backend (guest support พออยู่แล้ว)
- ไม่ทำ social login (Apple/Google/LINE)
- ไม่ย้าย secret ไป client เพิ่ม
- ไม่ทำ A/B test ใหม่ (ใช้ของเดิม)
