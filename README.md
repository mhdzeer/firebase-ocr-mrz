# MRZ OCR Reader (Flutter + Firebase + ML Kit)
Free, on-device Passport and Bahraini CPR ID card OCR reader.

## Tech Stack (100% Free, No Credit Card)
- **Flutter** (cross-platform mobile app)
- **Firebase Spark Plan** (free tier: Auth + Firestore)
- **Google ML Kit Text Recognition** (on-device, free, unlimited)
- **mrz_parser** (open-source MRZ decoding)

## Architecture
```
[Camera / Gallery] -> [ML Kit OCR (raw text)] -> [MRZ Filter (Regex)] -> [MRZ Parser] -> [Structured JSON]
```

## Setup Steps

### 1. Create a Flutter Project
```bash
cd C:\path\to\workspace
flutter create ocr_mrz
cd ocr_mrz
```

### 2. Add Firebase (Free Spark Plan)
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a project (no billing needed, select "Spark Plan")
3. Add both Android and iOS apps in project settings:
   - **Android**: package name `com.example.ocr_mrz`
   - **iOS**: bundle ID `com.example.ocrM`

### 3. Get Firebase Config Files
```bash
flutter pub global activate flutterfire_cli
flutterfire configure
```
This generates `lib/firebase_options.dart` with your project credentials.

### 4. Place Native Config Files
- Download `google-services.json` from Firebase Console and place it in `android/app/`
- Download `GoogleService-Info.plist` from Firebase Console and place it in `ios/Runner/`

### 5. Add Dependencies
```bash
flutter pub get
```

### 6. Run the App
```bash
flutter run
```

## Android Specific Setup
- Add camera permission in `AndroidManifest.xml` (already included in this repo)
- Make sure `minSdkVersion` is at least 21 (set in `android/app/build.gradle`)

## iOS Specific Setup
- Add camera usage descriptions in `Info.plist` (already included)
- Run on a physical device (ML Kit Camera doesn't work on simulator)

## How It Works
1. **Scan**: User takes a photo of Passport MRZ (bottom 2 lines) or Bahraini CPR ID (bottom 3 lines)
2. **OCR**: ML Kit extracts raw text on-device (no internet, no billing)
3. **Filter**: Regex filters lines that are 44 chars (Passport) or 30 chars (CPR)
4. **Parse**: MRZ parser decodes fields and validates checksums
5. **Save**: Data is saved to Firestore under the user's anonymous UID

## Free Tier Limits (Firebase Spark)
- **Auth**: Unlimited anonymous sign-ins
- **Firestore**: 50,000 reads/day, 20,000 writes/day, 1 GiB storage
- **ML Kit**: Unlimited on-device text recognition

## Cost Breakdown
| Component | Cost |
|-----------|------|
| Firebase Auth | $0 |
| Firestore (Spark) | $0 |
| ML Kit Text Recognition | $0 |
| Third-party ID SDKs (Microblink, etc.) | $0 |
| **Total** | **$0/month** |

## Supported Document Types
- **Passports**: ICAO 9303 standard, 2 lines × 44 chars
- **Bahraini CPR (ID Cards)**: 3 lines × 30 chars, custom parser

## Project Structure
```
lib/
  main.dart                    # App entry + Firebase init
  models/
    scan_result.dart           # Scan data model
  services/
    firebase_service.dart      # Auth + Firestore
    ocr_service.dart           # ML Kit wrapper + MRZ regex filter
    mrz_parser_service.dart    # Passport + CPR MRZ decoding
  screens/
    scan_screen.dart           # Camera / Gallery capture
    results_screen.dart        # Parsed data display + Firestore save
```

## Troubleshooting
- **ML Kit not detecting text**: Ensure image is well-lit and MRZ is in focus
- **Firebase auth fails**: Check `google-services.json` / `GoogleService-Info.plist` are correct
- **iOS simulator error**: ML Kit Camera requires a physical iOS device
