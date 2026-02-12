# แผนการพัฒนาระบบดวงดาวไทย

## Phase 1: Database & Model (1-2 วัน)
### 1.1 Update Database Schema
```sql
-- เพิ่มใน profiles table
ALTER TABLE profiles ADD COLUMN thai_year_zodiac TEXT; -- ปีนักษัตร (ชวด, ฉลู, ขาล...)
ALTER TABLE profiles ADD COLUMN thai_month_zodiac TEXT; -- ราศีเดือน (เดือนอ้าย, ยี่, สาม...)
ALTER TABLE profiles ADD COLUMN chinese_element TEXT; -- ธาตุ (ไม้, ไฟ, ดิน, ทอง, น้ำ)

-- สร้างตาราง Thai Zodiac Reference
CREATE TABLE thai_zodiac_years (
  id SERIAL PRIMARY KEY,
  year_animal TEXT NOT NULL, -- ชวด, ฉลู, ขาล...
  thai_name TEXT NOT NULL,
  english_name TEXT NOT NULL,
  element TEXT NOT NULL,
  characteristics TEXT,
  lucky_colors TEXT[],
  lucky_numbers INTEGER[]
);

CREATE TABLE thai_month_zodiac (
  id SERIAL PRIMARY KEY,
  month_number INTEGER NOT NULL,
  thai_name TEXT NOT NULL, -- เดือนอ้าย, เดือนยี่...
  lunar_month TEXT,
  characteristics TEXT
);
```

### 1.2 Create Models
- `ThaiZodiac` model
- `ThaiMonthZodiac` model
- `ThaiAstrologyResult` model

## Phase 2: Calculation Logic (2-3 วัน)
### 2.1 Thai Zodiac Calculator Service
```dart
class ThaiZodiacService {
  // คำนวณปีนักษัตรจากปีเกิด
  String getYearZodiac(int birthYear) {
    final animals = ['วอก', 'ระกา', 'จอ', 'กุน', 'ชวด', 'ฉลู', 'ขาล', 'เถาะ', 'มะโรง', 'มะเส็ง', 'มะเมีย', 'มะแม'];
    return animals[birthYear % 12];
  }
  
  // คำนวณธาตุ
  String getElement(int birthYear) {
    final elements = ['ทอง', 'น้ำ', 'ไม้', 'ไฟ', 'ดิน'];
    return elements[((birthYear - 4) % 10) ~/ 2];
  }
  
  // แปลงวันเกิดเป็นเดือนจันทรคติไทย
  String getThaiLunarMonth(DateTime birthDate) {
    // Logic การแปลง solar to lunar calendar
  }
}
```

### 2.2 Integration Points
- Update registration flow เพื่อคำนวณราศีไทย
- Update profile service
- Update horoscope service

## Phase 3: UI Updates (2-3 วัน)
### 3.1 Profile Screen
- แสดงปีนักษัตร + icon สัตว์
- แสดงธาตุประจำตัว
- แสดงราศีเดือนเกิด

### 3.2 Horoscope Screen
- Tab สำหรับดูดวงแบบไทย
- การแสดงผลแบบไทยๆ (ดาว, เคราะห์, ราหู-เกตุ)

### 3.3 New Features
- หน้าดูฤกษ์มงคล
- หน้าเลขมงคลประจำวัน
- หน้าสีมงคลประจำวัน

## Phase 4: Content & AI Integration (3-4 วัน)
### 4.1 Thai Astrology Prompts
```dart
String getThaiHoroscopePrompt(String yearZodiac, String element, DateTime date) {
  return '''
  คุณเป็นหมอดูไทยผู้เชี่ยวชาญ ให้ทำนายดวงชะตาแบบไทย
  - ปีนักษัตร: $yearZodiac
  - ธาตุ: $element
  - วันที่: $date
  
  โปรดทำนายใน 5 ด้าน:
  1. ดวงชะตาโดยรวม
  2. การงาน/การเงิน (ดาวพุธ)
  3. ความรัก (ดาวศุกร์)
  4. สุขภาพ (ดาวอังคาร)
  5. ราหู-เกตุ คาบเกี้ยว
  
  พร้อมแนะนำ:
  - เลขมงคล
  - สีมงคล
  - ทิศทางมงคล
  - พระเครื่องที่เหมาะสม
  ''';
}
```

### 4.2 Content Localization
- คำศัพท์โหราศาสตร์ไทย
- การอธิบายแบบไทยๆ
- อ้างอิงตำราพรหมชาติ, ตำราโหราศาสตร์ไทย

## Phase 5: Special Features (Optional)
### 5.1 ฟีเจอร์พิเศษ
- ดูฤกษ์แต่งงาน
- ดูฤกษ์ขึ้นบ้านใหม่
- ดูฤกษ์เปิดกิจการ
- เสริมดวงด้วยพระเครื่อง
- แก้ชง ปะชง สะเดาะเคราะห์

### 5.2 Calendar Integration
- ปฏิทินจันทรคติไทย
- วันพระ วันศีล
- วันสำคัญทางศาสนา

## Implementation Priority:
1. **เร่งด่วน**: คำนวณปีนักษัตร + แสดงใน Profile
2. **สำคัญ**: ดูดวงรายวันแบบไทย
3. **ดี**: ฤกษ์มงคล, เลข/สีมงคล
4. **เสริม**: ฟีเจอร์พิเศษ

## Technical Considerations:
- ใช้ Buddhist calendar library สำหรับแปลงปีพุทธศักราช
- อาจต้องใช้ Thai lunar calendar API
- Cache ข้อมูลดวงดาวเพื่อลด API calls
- Localization สำหรับ UI ภาษาไทย 100%

## Testing:
- Test case สำหรับทุกปีนักษัตร
- Test การแปลงวันที่ solar <-> lunar
- Test การแสดงผลภาษาไทย
- User testing กับกลุ่มเป้าหมายคนไทย