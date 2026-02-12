# วิธีแก้ปัญหา Email Confirmation

## ปัญหาที่พบ
- Email confirmation link redirect ไปยัง localhost:3000 ซึ่งไม่ถูกต้องสำหรับ Flutter app
- Error: `otp_expired` - Email link is invalid or has expired

## วิธีแก้ไข

### 1. ตั้งค่า Redirect URL ใน Supabase Dashboard

1. เข้าไปที่ Supabase Dashboard: https://app.supabase.com
2. ไปที่ **Authentication** > **URL Configuration**
3. ใน **Redirect URLs** ให้เพิ่ม URL ต่อไปนี้:
   - `io.supabase.astrology://login-callback` (สำหรับ mobile app)
   - `https://YOUR_DOMAIN.com/auth/callback` (ถ้ามี web version)

4. ใน **Site URL** ให้ตั้งเป็น:
   - `io.supabase.astrology://login-callback`

### 2. อัปเดต Email Templates ใน Supabase

1. ไปที่ **Authentication** > **Email Templates**
2. เลือก **Confirm signup**
3. แก้ไข URL ใน template จาก:
   ```
   {{ .SiteURL }}/auth/confirm?token_hash={{ .TokenHash }}&type=signup
   ```
   เป็น:
   ```
   io.supabase.astrology://login-callback?token_hash={{ .TokenHash }}&type=signup
   ```

### 3. ตั้งค่า Deep Link ใน Android (เสร็จแล้ว)
- ไฟล์ `AndroidManifest.xml` ได้ถูกอัปเดตเพื่อรองรับ deep link แล้ว
- **สำคัญ**: ต้องแทนที่ `YOUR_SUPABASE_PROJECT_ID` ด้วย Supabase project ID จริงของคุณ

### 4. ตั้งค่า Deep Link ใน iOS (ถ้าต้องการ)

แก้ไขไฟล์ `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>io.supabase.astrology</string>
        </array>
    </dict>
</array>
```

### 5. อัปเดต Supabase Initialization (ถ้าจำเป็น)

ในไฟล์ `lib/main.dart`:

```dart
await Supabase.initialize(
  url: dotenv.env['SUPABASE_URL'] ?? '',
  anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  authCallbackUrlHostname: 'login-callback', // เพิ่มบรรทัดนี้
);
```

### 6. ทดสอบ

1. Build APK ใหม่:
   ```bash
   flutter build apk --release
   ```

2. ติดตั้ง APK บนอุปกรณ์
3. ลงทะเบียนด้วยอีเมลใหม่
4. ตรวจสอบอีเมลและคลิก confirm link
5. แอปควรเปิดขึ้นและยืนยันอีเมลสำเร็จ

## หมายเหตุ
- ตรวจสอบให้แน่ใจว่า Supabase project URL และ anon key ใน `.env` ถูกต้อง
- Email confirmation token มีอายุ 24 ชั่วโมง
- หากยังพบปัญหา ให้ตรวจสอบ logs ใน Supabase Dashboard > Authentication > Logs