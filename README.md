# MRZ OCR Reader (Flutter Web + Firebase)
Free, on-device Passport and Bahraini CPR ID card OCR reader.

## Tech Stack (100% Free, No Credit Card)
- **Flutter Web** (runs in browser)
- **Firebase Spark Plan** (free tier: Auth + Firestore + Hosting)
- **Tesseract.js** (browser-based OCR, free, runs locally)
- **mrz_parser** (open-source MRZ decoding)

## Architecture (Web)
```
[Image Upload] -> [Tesseract.js OCR (raw text)] -> [MRZ Filter (Regex)] -> [MRZ Parser] -> [Structured JSON]
```

## Setup Steps

### 1. Create Firebase Project (Free Spark Plan)
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create project named **OCR-MRZ**
3. Select **Spark Plan** (free, no credit card)

### 2. Enable Firebase Services
In Firebase Console for project **OCR-MRZ**:
- **Authentication** → Sign-in method → Enable **Anonymous**
- **Firestore Database** → Create database → Start in **Test mode**
- **Hosting** → Get started (install Firebase CLI)

### 3. Get Firebase Web Config
1. In Firebase Console → **Project Settings** → **Add app** → **Web**
2. Copy the `firebaseConfig` object values:
   - `apiKey`
   - `authDomain` (should be `OCR-MRZ.firebaseapp.com`)
   - `projectId` (should be `OCR-MRZ`)
   - `storageBucket`
   - `messagingSenderId`
   - `appId`

### 4. Update Config Files

#### Update `lib/firebase_options.dart`:
Replace the `web` section with your actual values:
```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR-ACTUAL-API-KEY',
  appId: 'YOUR-ACTUAL-APP-ID',
  messagingSenderId: 'YOUR-ACTUAL-SENDER-ID',
  projectId: 'OCR-MRZ',
  authDomain: 'OCR-MRZ.firebaseapp.com',
  storageBucket: 'OCR-MRZ.appspot.com',
);
```

#### Update `web/index.html`:
Replace the Firebase config in the script with your actual values.

### 5. Install Dependencies
```powershell
cd C:\antigravity\OCR-MRZ
flutter pub get
```

### 6. Build & Deploy to Firebase Hosting
```powershell
# Install Firebase CLI if not already installed
npm install -g firebase-tools

# Login to Firebase
firebase login

# Build Flutter web app
flutter build web

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

Your app will be live at: `https://OCR-MRZ.web.app` or `https://OCR-MRZ.firebaseapp.com`

## How to Use (Web)
1. Open the deployed URL in a browser
2. Click **"Select Image"** to upload a photo of:
   - **Passport MRZ**: Bottom 2 lines (44 chars each)
   - **Bahraini CPR ID**: Bottom 3 lines (30 chars each)
3. Tesseract.js processes the image locally in your browser
4. Parsed data is displayed and saved to Firestore

## Project Structure
```
lib/
  main.dart                    # App entry with Firebase init
  firebase_options.dart        # Firebase config (update with your values)
  models/
    scan_result.dart           # Scan result model
  services/
    firebase_service.dart      # Auth + Firestore
    ocr_service.dart           # Tesseract.js wrapper + MRZ filter
    mrz_parser_service.dart    # Passport + CPR MRZ decoding
  screens/
    scan_screen.dart           # Image upload screen
    results_screen.dart        # Parsed data + Firestore save
web/
  index.html                   # Firebase + Tesseract.js CDN
  flutter_bootstrap.js         # Web bootstrap
firebase.json                  # Firebase Hosting config
```

## Free Tier Limits (Firebase Spark)
- **Auth**: Unlimited anonymous sign-ins
- **Firestore**: 50,000 reads/day, 20,000 writes/day, 1 GiB storage
- **Hosting**: 10 GB storage, 10 GB/month transfer
- **Tesseract.js**: 100% free, browser-based, no API limits

## Cost Breakdown
| Component | Cost |
|-----------|------|
| Firebase Auth | $0 |
| Firestore (Spark) | $0 |
| Firebase Hosting (Spark) | $0 |
| Tesseract.js OCR | $0 |
| **Total** | **$0/month** |

## Supported Documents
- **Passports**: ICAO 9303 (2 lines × 44 chars)
- **Bahraini CPR ID Cards**: 3 lines × 30 chars

## Troubleshooting
- **Tesseract OCR not working**: Ensure image has good lighting and MRZ is clear
- **Firebase config error**: Double-check `firebase_options.dart` web values
- **Hosting deployment fails**: Run `firebase login` and ensure you selected the right project
