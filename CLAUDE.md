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

| Environment | ไฟล์ | API |
|---|---|---|
| local (ไม่ใส่ flag) | - | `http://localhost:8787` |
| dev | `config/dev.json` | https://vynthra-service-dev.vercel.app |
| prod | `config/prod.json` | https://vynthra-service.vercel.app |

เพิ่ม environment ใหม่ (เช่น staging) = เพิ่มไฟล์ใน `config/` แล้วเพิ่มเงื่อนไขใน
step "Select environment" ของ `.github/workflows/main.yml`

## เวอร์ชัน

- รูปแบบ `major.minor.patch` ใน `pubspec.yaml` แก้ด้วยมือ ไม่ใส่ `+build`
  - minor ขยับเมื่อเริ่มรอบ release ใหม่ (แตก `rc/x.y.0`)
  - patch ขยับเฉพาะ hotfix ของเวอร์ชันที่ปล่อย prod ไปแล้ว
  - แก้ bug ระหว่างทดสอบ RC ไม่ต้องขยับเลขเวอร์ชัน
- build number มาจาก CI (`github.run_number`) อย่าใส่เอง

## ขั้นตอน release

1. แตก `rc/x.y.0` จาก `main` แล้วแก้ `version` ใน `pubspec.yaml`
2. push เข้า `rc/**` → CI build ด้วย `config/dev.json` ส่ง Firebase App Distribution
   ให้กลุ่ม `internal-testers`
3. แก้ bug บน branch `rc/x.y.0` จนผ่าน
4. merge เข้า `main` → CI build ด้วย `config/prod.json`
5. ติด tag `vx.y.z` ที่ `main`
6. hotfix: แตก `hotfix/x.y.z` จาก `main` ขยับ patch แล้ว merge กลับ `main`

ถ้า release รอบนั้นแก้ backend ด้วย ให้ใช้ชื่อ branch `rc/x.y.0` เดียวกันใน
`vynthra_service` และ merge เข้า `main` ของ backend ก่อนหรือพร้อมกับแอป

## CI (`.github/workflows/main.yml`)

- ทำงานเมื่อ push เข้า `main` หรือ `rc/**` เท่านั้น build เฉพาะ Android
- ทุก push เข้า `rc/**` ส่ง build ให้ tester ทันที อย่า push งานที่ยังไม่พร้อมให้ทดสอบ
- lane อยู่ที่ `android/fastlane/Fastfile` รับ `APP_ENV` และ `BUILD_NUMBER`
- ดูผล: `gh run list --branch <branch>` และ `gh run view <id> --log-failed`

## ข้อควรระวัง

- **ห้ามใส่ credential ในโค้ด** repo นี้เป็น public และเคยมี credential หลุดใน git
  history มาแล้ว secret ทั้งหมดต้องอยู่ที่ backend
- **Web**: ใช้ได้เพราะแอปเรียก HTTP อย่างเดียว ห้ามเพิ่ม package ที่ใช้ `dart:io`
  socket รูปไพ่มาจาก S3 bucket `vynthra` ซึ่งยังไม่ได้เปิด CORS รูปจึงไม่ขึ้นบน web
- **การทำนายใช้เวลาราว 35 วินาที** timeout ฝั่งแอปตั้งไว้ 150 วินาทีใน
  `lib/services/api_client.dart`
- Flutter/IDE มักแก้ไฟล์ใน `ios/`, `analysis_options.yaml`, `flutter_vynthra.iml`
  เองตอน build อย่ารวมเข้า commit โดยไม่ได้ตั้งใจ
- dev กับ prod ใช้ package id เดียวกัน ติดตั้งทับกันบนเครื่อง
