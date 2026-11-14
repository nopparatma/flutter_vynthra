# Vynthra (Flutter app)

แอปดูไพ่ ข้อมูลไพ่และคำทำนาย AI มาจาก backend `vynthra_service`
(repo แยก อยู่ที่ `../vynthra_service` มี CLAUDE.md ของตัวเอง)
แอปไม่ต่อ MongoDB หรือ Gemini ตรง และต้องไม่มี credential ใด ๆ ในโค้ด

## คำสั่งพื้นฐาน

- ใช้ `fvm flutter ...` เสมอ เวอร์ชันกำหนดใน `.fvmrc` (`flutter` ตัวหลักของเครื่องเป็นเวอร์ชันเก่า build ไม่ผ่าน)
- รันกับ backend ในเครื่อง (`http://localhost:8787`): `fvm flutter run`
- รันกับ API dev: `fvm flutter run --dart-define-from-file=config/dev.json`
- รันบน web: `fvm flutter run -d web-server --web-port 8080`
- ตรวจโค้ด: `fvm flutter analyze` (มีแต่ info ไม่ควรมี error/warning)
- `test/widget_test.dart` เป็นเทสต์จาก template ที่ fail มาแต่เดิม ไม่เกี่ยวกับแอป

## Environment

ค่าต่อ environment อยู่ใน `config/<env>.json` อ่านผ่าน `lib/app/env.dart`
ด้วย `--dart-define-from-file`

| Environment | ไฟล์ | API | Web |
|---|---|---|---|
| local (ไม่ใส่ flag) | - | `http://localhost:8787` | - |
| dev | `config/dev.json` | https://vynthra-service-dev.vercel.app | https://vynthra-web-dev.vercel.app |
| prod | `config/prod.json` | https://vynthra-service.vercel.app | https://vynthra-web.vercel.app |

เพิ่ม environment ใหม่ (เช่น staging) = เพิ่มไฟล์ใน `config/` แล้วแก้ค่า `APP_ENV`
และ project id ของ web ใน `.github/workflows/main.yml`

## เวอร์ชัน

รูปแบบ `major.minor.patch (build)` เช่น `1.1.3 (43)` เลข patch และ build number
มาจาก CI ไม่ต้องแก้มือ ตรรกะอยู่ที่ `.github/scripts/resolve-version.mjs`

- `pubspec.yaml` เก็บแค่ฐาน `major.minor.0` (เช่น `1.1.0`) CI ใช้แค่ `major.minor`
  build ในเครื่องจึงเห็นเลขฐาน ไม่ใช่เลขจริง
- **push เข้า `rc/**`**: patch +1 จาก tag ล่าสุดของสายนั้น (`v1.1.2` → `1.1.3`)
  และ build number = เลขรอบรันของ workflow เมื่อ android และ web ผ่าน
  CI ติด tag `v1.1.3` (ข้อความ tag จด build number) ที่ commit นั้น
- **push เข้า `main`**: ไม่บวกทั้ง patch และ build number CI อ่าน tag ของ commit
  ที่ merge เข้ามาแล้วใช้เลขนั้น prod จึงได้เลขเดียวกับตัวที่ tester ทดสอบ
  ถ้า commit นั้นไม่มี tag CI จะ fail ที่ job "Resolve version"
- ขึ้น minor/major ใหม่: แก้ฐานใน `pubspec.yaml` (เช่น `1.2.0`) patch เริ่มที่ 0 ใหม่
  ส่วน build number นับต่อ ไม่ reset (store บังคับให้เพิ่มขึ้นเสมอ) เช่น `1.1.42 (42)` → `1.2.0 (43)`
- อย่าติด tag `v*` ด้วยมือ และอย่าลบ tag เพราะ CI ใช้นับเลขถัดไป
- build dev กับ prod ของ commit เดียวกันมีเลขเดียวกัน แยกด้วย `(dev)` / `(prod)`
  ใน release notes และบนหน้า splash

## ขั้นตอน release

1. ทำงานบน `rc/x.y.0` (ขึ้นรอบใหม่: แตกจาก `main` แล้วแก้ฐานเวอร์ชันใน `pubspec.yaml`)
2. push เข้า `rc/**` → CI build ด้วย `config/dev.json` ส่ง Firebase App Distribution
   ให้กลุ่ม `internal-testers` และอัปเดต web dev
3. แก้ bug บน branch เดิมจนผ่าน ทุก push ได้เลขใหม่
4. **รอให้ CI ของ commit ล่าสุดบน rc ผ่านและติด tag ก่อน** แล้ว merge commit นั้นเข้า `main`
   (fast-forward หรือ merge commit ก็ได้) → CI build ด้วย `config/prod.json` ด้วยเลขเดิม
5. hotfix ทำแบบเดียวกัน: แก้บน `rc/x.y.0` → push → ทดสอบ → merge เข้า `main`

ถ้า release รอบนั้นแก้ backend ด้วย ให้ใช้ชื่อ branch `rc/x.y.0` เดียวกันใน
`vynthra_service` และ merge เข้า `main` ของ backend ก่อนหรือพร้อมกับแอป
เลข patch ของแอปกับ backend นับแยกกัน ตรงกันแค่ `major.minor`

## CI (`.github/workflows/main.yml`)

- ทำงานเมื่อ push เข้า `main` หรือ `rc/**` เท่านั้น
- มี 2 job รันขนานกัน ไม่รอกัน:
  - `android`: build APK ส่ง Firebase App Distribution (ราว 4-5 นาที)
    lane อยู่ที่ `android/fastlane/Fastfile` รับ `APP_ENV` และ `BUILD_NUMBER`
  - `web`: `flutter build web` แล้ว deploy โฟลเดอร์ `build/web` ขึ้น Vercel
    (`vynthra-web-dev` สำหรับ `rc/**`, `vynthra-web` สำหรับ `main`)
- ทุก push เข้า `rc/**` ส่ง build ให้ tester และอัปเดต web dev ทันที
  อย่า push งานที่ยังไม่พร้อมให้ทดสอบ
- web ใช้ secret `VERCEL_TOKEN` และ variables `VERCEL_ORG_ID`,
  `VERCEL_PROJECT_ID_DEV`, `VERCEL_PROJECT_ID_PROD` project web บน Vercel ไม่ได้ผูก
  กับ Git จึง deploy ได้ทาง workflow เท่านั้น
- ดูผล: `gh run list --branch <branch>` และ `gh run view <id> --log-failed`

## ข้อควรระวัง

- **ห้ามใส่ credential ในโค้ด** repo นี้เป็น public และเคยมี credential หลุดใน git
  history มาแล้ว secret ทั้งหมดต้องอยู่ที่ backend
- **Web**: ใช้ได้เพราะแอปเรียก HTTP อย่างเดียว ห้ามเพิ่ม package ที่ใช้ `dart:io`
  socket รูปไพ่มาจาก S3 bucket `vynthra` ซึ่งไม่ได้เปิด CORS ทุก `Image.network`
  จึงต้องใส่ `webHtmlElementStrategy: WebHtmlElementStrategy.fallback` ไม่งั้นรูปไม่ขึ้นบน web
- **การทำนายใช้เวลาราว 35 วินาที** timeout ฝั่งแอปตั้งไว้ 150 วินาทีใน
  `lib/services/api_client.dart`
- Flutter/IDE มักแก้ไฟล์ใน `ios/`, `analysis_options.yaml`, `flutter_vynthra.iml`
  เองตอน build อย่ารวมเข้า commit โดยไม่ได้ตั้งใจ
- dev กับ prod ใช้ package id เดียวกัน ติดตั้งทับกันบนเครื่อง
