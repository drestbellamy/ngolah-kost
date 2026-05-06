# 📋 Remaining Print Statements

## Status: Non-Critical (Can be fixed incrementally)

The following files still contain print() statements. These are **not critical** for production deployment but should be cleaned up over time.

---

## Files with Print Statements

### 1. `lib/app/modules/user_tagihan/controllers/user_tagihan_controller.dart`
**Count:** ~26 print statements  
**Risk Level:** 🟡 Medium  
**Contains:** User IDs, payment amounts, tagihan IDs

**Recommendation:** Replace with conditional debug logging:
```dart
import 'package:flutter/foundation.dart';

if (kDebugMode) {
  debugPrint('Debug info: $data');
}
```

---

### 2. `lib/app/modules/user_profil/controllers/user_profil_controller.dart`
**Count:** ~8 print statements  
**Risk Level:** 🟡 Medium  
**Contains:** User IDs, profile data, photo URLs

---

### 3. `lib/app/modules/user_history_pembayaran/controllers/user_history_pembayaran_controller.dart`
**Count:** ~6 print statements  
**Risk Level:** 🟡 Medium  
**Contains:** Payment history, penghuni IDs

---

### 4. `lib/app/modules/user_info/controllers/user_info_controller.dart`
**Count:** ~4 print statements  
**Risk Level:** 🟢 Low  
**Contains:** General error messages

---

### 5. `lib/app/modules/user_pengaduan/controllers/user_pengaduan_controller.dart`
**Count:** ~1 print statement  
**Risk Level:** 🟢 Low  
**Contains:** Error messages

---

### 6. `lib/app/modules/user_home/controllers/user_home_controller.dart`
**Count:** ~2 print statements  
**Risk Level:** 🟢 Low  
**Contains:** Error messages

---

## Quick Fix Script

To remove all print statements at once, you can use this regex find & replace:

**Find:**
```regex
^\s*print\([^)]*\);\s*(?://.*)?$
```

**Replace:**
```
// Debug log removed for production
```

Or to make them conditional:
```dart
if (kDebugMode) debugPrint($1);
```

---

## Why These Are Not Critical

1. **Most are in catch blocks** - Only execute on errors
2. **No sensitive auth tokens** - Mainly IDs and counts
3. **ProGuard obfuscation** - Makes logs harder to read
4. **Production logs** - Usually not accessible to end users

---

## Recommended Action Plan

### Phase 1: Production Deploy (Now)
- ✅ Critical fixes done
- ✅ Major security issues resolved
- ✅ Safe to deploy

### Phase 2: Cleanup (After Deploy)
- Create utility logging class
- Replace all print() with proper logging
- Add log levels (debug, info, warning, error)

### Phase 3: Monitoring (Ongoing)
- Setup Firebase Crashlytics
- Monitor production logs
- Track user-reported issues

---

## Example Logging Utility

Create `lib/app/core/utils/logger.dart`:

```dart
import 'package:flutter/foundation.dart';

class Logger {
  static void debug(String message, [dynamic data]) {
    if (kDebugMode) {
      debugPrint('🐛 DEBUG: $message${data != null ? ' - $data' : ''}');
    }
  }

  static void info(String message, [dynamic data]) {
    if (kDebugMode) {
      debugPrint('ℹ️ INFO: $message${data != null ? ' - $data' : ''}');
    }
  }

  static void warning(String message, [dynamic data]) {
    if (kDebugMode) {
      debugPrint('⚠️ WARNING: $message${data != null ? ' - $data' : ''}');
    }
  }

  static void error(String message, [dynamic error]) {
    if (kDebugMode) {
      debugPrint('❌ ERROR: $message${error != null ? ' - $error' : ''}');
    }
    // In production, send to crash reporting service
  }
}
```

Usage:
```dart
// Instead of:
print('Loading tagihan for userId: $userId');

// Use:
Logger.debug('Loading tagihan', {'userId': userId});
```

---

**Note:** The critical security fixes have been completed. These remaining print statements are a **nice-to-have** cleanup, not a blocker for production deployment.
