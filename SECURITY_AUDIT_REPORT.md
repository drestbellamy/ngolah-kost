# 🔒 Security Audit Report - Ngolah Kost App
**Date:** May 6, 2026  
**Status:** Pre-Production Review  
**Auditor:** Kiro AI

---

## 🚨 CRITICAL ISSUES (Must Fix Before Production)

### 1. **Hardcoded Supabase Credentials in Source Code**
**Severity:** 🔴 CRITICAL  
**Location:** `lib/main.dart` lines 31-34

```dart
await Supabase.initialize(
  url: 'https://dajiymvbdpmeijvrqdus.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
);
```

**Risk:**
- API keys exposed in source code
- Anyone with access to APK can extract credentials
- Potential unauthorized access to database

**Recommendation:**
```dart
// Create lib/config/env.dart (add to .gitignore)
class Environment {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key',
  );
}

// In main.dart
await Supabase.initialize(
  url: Environment.supabaseUrl,
  anonKey: Environment.supabaseAnonKey,
);
```

**Build command:**
```bash
flutter build apk --dart-define=SUPABASE_URL=https://... --dart-define=SUPABASE_ANON_KEY=...
```

---

### 2. **Debug Print Statements Leaking Sensitive Data**
**Severity:** 🟠 HIGH  
**Locations:** Multiple files

**Found in:**
- `lib/repositories/pengaduan_repository.dart` - 15+ print statements
- `lib/app/modules/user_tagihan/controllers/user_tagihan_controller.dart` - 8+ print statements

**Examples:**
```dart
print('Penghuni ID: $penghuniId');  // Line 48
print('Current User: ${authController.currentUser?.username}');  // Line 74
print('JSON data: $jsonData');  // Line 168
print('Photo URLs: $imageUrls');  // Line 167
```

**Risk:**
- Sensitive user data logged in production
- Can be extracted via logcat on rooted devices
- Compliance issues (GDPR, privacy laws)

**Recommendation:**
```dart
// Replace all print() with conditional logging
import 'package:flutter/foundation.dart';

if (kDebugMode) {
  debugPrint('Debug info: $data');
}

// Or use the existing logger service
logDebug('Operation', {'data': data});
```

**Action Required:**
- Remove ALL print() statements from production code
- Use `debugPrint()` or logger service instead
- Add lint rule to prevent future print() usage

---

### 3. **Missing Release Signing Configuration**
**Severity:** 🟠 HIGH  
**Location:** `android/app/build.gradle.kts` line 38

```kotlin
release {
    signingConfig = signingConfigs.getByName("debug")  // ❌ Using debug key!
}
```

**Risk:**
- App signed with debug certificate
- Cannot publish to Play Store
- Security warnings for users

**Recommendation:**
```kotlin
// Create android/key.properties (add to .gitignore)
storePassword=your-store-password
keyPassword=your-key-password
keyAlias=your-key-alias
storeFile=../keystore.jks

// In build.gradle.kts
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"] as String
        keyPassword = keystoreProperties["keyPassword"] as String
        storeFile = file(keystoreProperties["storeFile"] as String)
        storePassword = keystoreProperties["storePassword"] as String
    }
}

buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}
```

---

## ⚠️ HIGH PRIORITY ISSUES

### 4. **No Session Timeout Implementation**
**Severity:** 🟡 MEDIUM  
**Location:** `lib/app/core/controllers/auth_controller.dart`

**Current State:**
- Session guard timer removed (as requested)
- Users stay logged in indefinitely
- No validation after login

**Risk:**
- Stolen/lost devices remain authenticated
- Deactivated users can continue using app until re-login

**Recommendation:**
```dart
// Add validation on critical operations
Future<bool> validateSessionBeforeAction() async {
  final user = currentUser;
  if (user == null) return false;
  
  try {
    final latest = await _authRepo.getUserById(user.id);
    final isStillActive = latest?['is_active'] == true;
    
    if (!isStillActive) {
      await clearUser();
      Get.offAllNamed(Routes.login);
      ToastHelper.showWarning('Akun tidak aktif');
      return false;
    }
    return true;
  } catch (_) {
    return true; // Allow if check fails
  }
}

// Call before sensitive operations:
// - Submit pengaduan
// - Payment operations
// - Profile updates
```

---

### 5. **Excessive Location Permissions**
**Severity:** 🟡 MEDIUM  
**Location:** `android/app/src/main/AndroidManifest.xml` lines 2-3

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

**Risk:**
- Privacy concerns for users
- Play Store may require justification
- Users may deny installation

**Recommendation:**
- If location is only for map viewing (not tracking), use coarse only
- Add permission rationale in app
- Consider making location optional

```xml
<!-- Only if you need precise location -->
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

---

### 6. **No Code Obfuscation Enabled**
**Severity:** 🟡 MEDIUM  
**Location:** `android/app/build.gradle.kts`

**Current State:**
- No ProGuard/R8 configuration
- Code easily decompilable
- Business logic exposed

**Recommendation:**
```kotlin
buildTypes {
    release {
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}
```

Create `android/app/proguard-rules.pro`:
```proguard
# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Supabase
-keep class io.supabase.** { *; }
```

---

## ✅ GOOD SECURITY PRACTICES FOUND

### 1. **Row Level Security (RLS) with RPC Functions**
✅ Using secure RPC functions for sensitive operations:
- `login_user_secure`
- `create_user_secure`
- `verify_user_password`
- `update_user_password`

### 2. **Role-Based Access Control**
✅ Proper middleware implementation:
- `AdminMiddleware` - Protects admin routes
- `UserMiddleware` - Protects user routes
- Role validation in `AuthController`

### 3. **No SQL Injection Vulnerabilities**
✅ Using Supabase query builder (parameterized queries)
✅ No raw SQL concatenation found

### 4. **Password Handling**
✅ Passwords handled server-side via RPC
✅ No plaintext password storage in app
✅ Password validation (min 6 characters)

### 5. **Proper .gitignore Configuration**
✅ Excludes sensitive files:
- Build artifacts
- Local properties
- `.kiro/` folder

---

## 📋 ADDITIONAL RECOMMENDATIONS

### 7. **Add Network Security Configuration**
Create `android/app/src/main/res/xml/network_security_config.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>
    <domain-config cleartextTrafficPermitted="false">
        <domain includeSubdomains="true">supabase.co</domain>
    </domain-config>
</network-security-config>
```

Add to `AndroidManifest.xml`:
```xml
<application
    android:networkSecurityConfig="@xml/network_security_config"
    ...>
```

---

### 8. **Add Certificate Pinning (Optional but Recommended)**
For high-security requirements, pin Supabase SSL certificate.

---

### 9. **Implement Biometric Authentication**
For sensitive operations (payments, profile changes):
```dart
import 'package:local_auth/local_auth.dart';

Future<bool> authenticateWithBiometrics() async {
  final auth = LocalAuthentication();
  try {
    return await auth.authenticate(
      localizedReason: 'Verifikasi identitas Anda',
      options: const AuthenticationOptions(
        stickyAuth: true,
        biometricOnly: true,
      ),
    );
  } catch (e) {
    return false;
  }
}
```

---

### 10. **Add Rate Limiting on Login**
Prevent brute force attacks:
```dart
// In LoginController
int _loginAttempts = 0;
DateTime? _lastFailedAttempt;

Future<void> login() async {
  // Check rate limit
  if (_loginAttempts >= 5) {
    final timeSinceLastAttempt = DateTime.now()
        .difference(_lastFailedAttempt ?? DateTime.now());
    
    if (timeSinceLastAttempt.inMinutes < 5) {
      ToastHelper.showError(
        'Terlalu banyak percobaan. Coba lagi dalam 5 menit.'
      );
      return;
    }
    _loginAttempts = 0;
  }
  
  // ... existing login logic
  
  if (loginFailed) {
    _loginAttempts++;
    _lastFailedAttempt = DateTime.now();
  } else {
    _loginAttempts = 0;
  }
}
```

---

## 🎯 PRE-PRODUCTION CHECKLIST

### Must Do (Critical):
- [ ] Move Supabase credentials to environment variables
- [ ] Remove ALL print() statements
- [ ] Setup release signing configuration
- [ ] Generate release keystore
- [ ] Test release build

### Should Do (High Priority):
- [ ] Add session validation on critical operations
- [ ] Enable code obfuscation (ProGuard/R8)
- [ ] Review location permissions necessity
- [ ] Add network security config
- [ ] Test on multiple devices

### Nice to Have:
- [ ] Implement biometric authentication
- [ ] Add certificate pinning
- [ ] Add rate limiting on login
- [ ] Setup crash reporting (Firebase Crashlytics)
- [ ] Add analytics (privacy-compliant)

---

## 📊 SECURITY SCORE

**Overall Security Rating:** 6.5/10

**Breakdown:**
- Authentication & Authorization: 8/10 ✅
- Data Protection: 5/10 ⚠️
- Code Security: 4/10 ⚠️
- Network Security: 6/10 ⚠️
- Privacy: 5/10 ⚠️

**After Implementing Critical Fixes:** 8.5/10 ✅

---

## 🚀 DEPLOYMENT STEPS

1. **Fix Critical Issues** (1-2 days)
   - Environment variables
   - Remove debug prints
   - Release signing

2. **Test Release Build** (1 day)
   ```bash
   flutter build apk --release --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
   ```

3. **Security Testing** (1 day)
   - Test on real devices
   - Check for crashes
   - Verify authentication flows
   - Test role-based access

4. **Deploy to Internal Testing** (Google Play Internal Testing)
   - Limited user group
   - Monitor for issues

5. **Production Release**
   - Gradual rollout (10% → 50% → 100%)
   - Monitor crash reports
   - Monitor user feedback

---

## 📞 SUPPORT

If you need help implementing these fixes, prioritize:
1. Environment variables (Critical)
2. Remove print statements (Critical)
3. Release signing (Critical)

The rest can be implemented incrementally after initial release.

---

**Report Generated:** May 6, 2026  
**Next Review:** After implementing critical fixes
