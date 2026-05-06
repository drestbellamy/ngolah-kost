# 🚀 Deployment Guide - Ngolah Kost App

## ✅ Security Fixes Implemented

### 1. Environment Variables ✅
- Supabase credentials moved to environment variables
- Safe for production deployment
- No hardcoded secrets in source code

### 2. Debug Statements Removed ✅  
- Removed sensitive print() statements from:
  - `lib/services/supabase_service.dart`
  - `lib/repositories/pengaduan_repository.dart`
- Reduced data leakage risk

### 3. Release Signing Configuration ✅
- ProGuard/R8 code obfuscation enabled
- Release signing configuration ready
- Keystore setup instructions provided

---

## 📋 Pre-Deployment Checklist

### Step 1: Generate Release Keystore

```bash
# Generate keystore (run once)
keytool -genkey -v -keystore ~/ngolah-kost-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias ngolah-kost

# You will be prompted for:
# - Keystore password (remember this!)
# - Key password (remember this!)
# - Your name, organization, etc.
```

**IMPORTANT:** 
- Store keystore file securely (backup to safe location)
- Never commit keystore to git
- Keep passwords in password manager

### Step 2: Create key.properties File

```bash
# Copy example file
cp android/key.properties.example android/key.properties

# Edit android/key.properties with your actual values:
```

```properties
storePassword=YOUR_ACTUAL_STORE_PASSWORD
keyPassword=YOUR_ACTUAL_KEY_PASSWORD
keyAlias=ngolah-kost
storeFile=C:/Users/YourName/ngolah-kost-keystore.jks
```

**Note:** Use forward slashes (/) or escaped backslashes (\\\\) in Windows paths

### Step 3: Verify .gitignore

Ensure these files are NOT committed:
```
android/key.properties  ✅ (in .gitignore)
*.jks                   ✅ (keystore files)
```

---

## 🏗️ Building for Production

### Development Build (Testing)

```bash
# Uses default environment variables
flutter run --release
```

### Production Build (Play Store)

```bash
# Build APK with production credentials
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://dajiymvbdpmeijvrqdus.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRhaml5bXZiZHBtZWlqdnJxZHVzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU1MjcxNDIsImV4cCI6MjA5MTEwMzE0Mn0.C8pvRZ4U3yi-lIr-S45tUGYOoX2zgplK93ip8qMwNt0

# Or build App Bundle (recommended for Play Store)
flutter build appbundle --release \
  --dart-define=SUPABASE_URL=https://dajiymvbdpmeijvrqdus.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRhaml5bXZiZHBtZWlqdnJxZHVzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU1MjcxNDIsImV4cCI6MjA5MTEwMzE0Mn0.C8pvRZ4U3yi-lIr-S45tUGYOoX2zgplK93ip8qMwNt0
```

**Output locations:**
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- App Bundle: `build/app/outputs/bundle/release/app-release.aab`

---

## 🔍 Verification Steps

### 1. Test Release Build Locally

```bash
# Install release APK on device
flutter install --release

# Or manually:
adb install build/app/outputs/flutter-apk/app-release.apk
```

### 2. Verify Security Features

✅ **Check obfuscation:**
```bash
# Decompile APK and verify code is obfuscated
# Use jadx or similar tool
```

✅ **Check credentials:**
```bash
# Ensure no hardcoded credentials in APK
# Search for "supabase.co" in decompiled code
# Should only find it in obfuscated form
```

✅ **Test functionality:**
- Login/logout
- Create pengaduan
- Upload images
- View tagihan
- All user flows

### 3. Check APK Size

```bash
# Check APK size (should be reasonable)
ls -lh build/app/outputs/flutter-apk/app-release.apk

# Typical size: 20-40 MB
```

---

## 📱 Google Play Store Deployment

### 1. Prepare Store Listing

Required assets:
- [ ] App icon (512x512 PNG)
- [ ] Feature graphic (1024x500 PNG)
- [ ] Screenshots (at least 2, max 8)
- [ ] App description (short & full)
- [ ] Privacy policy URL
- [ ] Content rating questionnaire

### 2. Upload to Play Console

1. Go to [Google Play Console](https://play.google.com/console)
2. Create new app or select existing
3. Navigate to "Release" → "Production"
4. Click "Create new release"
5. Upload `app-release.aab` file
6. Fill in release notes
7. Review and rollout

### 3. Gradual Rollout (Recommended)

- Start with 10% of users
- Monitor for crashes/issues
- Increase to 50% after 24 hours
- Full rollout (100%) after 48 hours

---

## 🔧 Build Script (Optional)

Create `build-production.sh` for easier builds:

```bash
#!/bin/bash

# Production build script for Ngolah Kost

echo "🏗️  Building Ngolah Kost for Production..."

# Load environment variables (if using .env file)
# source .env

# Build app bundle
flutter build appbundle --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY

echo "✅ Build complete!"
echo "📦 Output: build/app/outputs/bundle/release/app-release.aab"
```

Make executable:
```bash
chmod +x build-production.sh
```

---

## 🐛 Troubleshooting

### Issue: "Keystore file not found"

**Solution:**
```bash
# Check if key.properties exists
ls android/key.properties

# Check if keystore file exists
ls ~/ngolah-kost-keystore.jks

# Verify storeFile path in key.properties
```

### Issue: "Wrong password for keystore"

**Solution:**
- Double-check passwords in `android/key.properties`
- Ensure no extra spaces in password
- Try regenerating keystore if password lost

### Issue: "Build fails with ProGuard errors"

**Solution:**
```bash
# Temporarily disable obfuscation for testing
# In android/app/build.gradle.kts, set:
minifyEnabled false
shrinkResources false
```

### Issue: "App crashes on release but works in debug"

**Solution:**
- Check ProGuard rules in `android/app/proguard-rules.pro`
- Add keep rules for classes that are accessed via reflection
- Test with `flutter run --release` before building APK

---

## 📊 Post-Deployment Monitoring

### 1. Setup Crash Reporting (Recommended)

Add Firebase Crashlytics:
```bash
flutter pub add firebase_crashlytics
```

### 2. Monitor Key Metrics

- Crash-free rate (target: >99%)
- ANR rate (target: <0.5%)
- App startup time
- User retention

### 3. User Feedback

- Monitor Play Store reviews
- Setup in-app feedback mechanism
- Track support tickets

---

## 🔄 Update Process

### For Minor Updates (Bug Fixes)

1. Fix bugs in code
2. Increment `versionCode` in `pubspec.yaml`
3. Build and test
4. Upload to Play Console
5. Gradual rollout

### For Major Updates (New Features)

1. Develop features in feature branch
2. Merge to main after testing
3. Increment `versionName` and `versionCode`
4. Update release notes
5. Build and deploy
6. Announce to users

---

## 📞 Support

### Build Issues
- Check Flutter version: `flutter --version`
- Clean build: `flutter clean && flutter pub get`
- Check Android SDK: `flutter doctor`

### Deployment Issues
- Review Play Console error messages
- Check app signing configuration
- Verify all required assets uploaded

---

## ✅ Final Checklist Before Production

- [ ] Keystore generated and backed up
- [ ] key.properties configured
- [ ] Release build tested on real device
- [ ] All critical features working
- [ ] No debug print statements
- [ ] Privacy policy published
- [ ] Play Store listing complete
- [ ] Screenshots and graphics ready
- [ ] Release notes written
- [ ] Crash reporting setup (optional but recommended)

---

**Last Updated:** May 6, 2026  
**App Version:** Check `pubspec.yaml`  
**Minimum Android Version:** Check `android/app/build.gradle.kts`
