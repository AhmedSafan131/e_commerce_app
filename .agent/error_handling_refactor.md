# Error Handling Architecture Refactoring

## ✅ Completed: Centralized Error Handling at Repository Layer

### Principle Applied
**"Use try-catch on the top level layer, not in each layer"**

All error handling is now centralized at the **Repository Layer** only. Lower layers (datasources, services) throw exceptions, and the repository catches ALL exceptions and converts them to `Either<Failure, Success>`.

---

## 🔄 Changes Made

### 1. Auth Remote Datasource (`auth_remote_datasource.dart`)

**Before:**
```dart
Future<UserModel> login(String email, String password) async {
  try {
    final userCredential = await firebaseAuth.signInWithEmailAndPassword(...);
    return UserModel.fromFirebaseUser(userCredential.user!);
  } on FirebaseAuthException catch (e) {
    throw ServerFailure(e.message ?? 'Authentication failed');
  } catch (e) {
    throw ServerFailure(e.toString());
  }
}
```

**After:**
```dart
Future<UserModel> login(String email, String password) async {
  final userCredential = await firebaseAuth.signInWithEmailAndPassword(...);
  
  if (userCredential.user == null) {
    throw const ServerFailure('User is null');
  }
  
  return UserModel.fromFirebaseUser(userCredential.user!);
}
```

✅ **Removed try-catch** - Datasource now throws exceptions directly  
✅ **Applied to:** `login()`, `register()`, `logout()`

---

### 2. Cart Local Datasource (`cart_local_datasource.dart`)

**Before:**
```dart
Future<List<CartItemModel>> getCart() async {
  try {
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => CartItemModel.fromJson(e)).toList();
  } catch (_) {
    await sharedPreferences.remove(CACHED_CART);
    return [];
  }
}
```

**After:**
```dart
Future<List<CartItemModel>> getCart() async {
  final List<dynamic> jsonList = json.decode(jsonString);
  return jsonList.map((e) => CartItemModel.fromJson(e)).toList();
}
```

✅ **Removed try-catch** - Let JSON decode errors bubble up to repository

---

### 3. Payment Gateway Service (`payment_gateway.dart`)

**Before:**
```dart
Future<PaymentResult> processPayment(...) async {
  try {
    // ... payment logic ...
    return PaymentResult(...);
  } catch (e) {
    AppLogger.error('[Paymob] Payment error: $e');
    if (e is DioException) {
      // Handle DioException
    }
    rethrow;
  }
}
```

**After:**
```dart
Future<PaymentResult> processPayment(...) async {
  AppLogger.info('[Paymob] Starting payment...');
  
  // ... payment logic ...
  
  return PaymentResult(...);
  // Let all exceptions bubble up to repository
}
```

✅ **Removed try-catch** - Service throws exceptions, repository catches them

---

### 4. Auth Repository (`auth_repository_impl.dart`)

**Enhanced to catch all exception types:**

```dart
@override
Future<Either<Failure, UserEntity>> login(String email, String password) async {
  try {
    final user = await remoteDataSource.login(email, password);
    return Right(user);
  } on Failure catch (e) {
    return Left(e);  // Domain failures from datasource
  } on FirebaseAuthException catch (e) {
    return Left(ServerFailure(e.message ?? 'Authentication failed'));  // Firebase errors
  } catch (e) {
    return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));  // All other errors
  }
}
```

✅ **Repository is the ONLY layer with try-catch**  
✅ **Catches all exception types:**
  - Domain `Failure` exceptions  
  - `FirebaseAuthException`
  - Generic exceptions

---

## 🏗️ Final Architecture

```
┌─────────────────────────────────────────────────────┐
│                  Presentation Layer                  │
│  BLoCs use Either.fold() - NO try-catch             │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│                   Domain Layer                       │
│  UseCases pass through Either - NO try-catch        │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│            🎯 Repository Layer (TOP LEVEL)           │
│  ✅ ONLY LAYER WITH TRY-CATCH                       │
│  Catches ALL exceptions → Either<Failure, Success>  │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│              Data Sources & Services                 │
│  Throw exceptions - NO try-catch                    │
│  Let errors bubble up naturally                     │
└─────────────────────────────────────────────────────┘
```

---

## ✅ Benefits

1. **Single Source of Truth** - All error handling in one place (repositories)
2. **Cleaner Code** - Datasources and services are simpler
3. **Consistent Error Handling** - All errors converted to `Either` at repository boundary
4. **Easier Testing** - Mock exceptions in tests, verify repository handling
5. **Better Error Messages** - Repository can provide context-aware error messages
6. **Follows Clean Architecture** - Clear separation of concerns

---

## 📊 Summary

| Layer | Before | After | Status |
|-------|--------|-------|--------|
| **Datasources** | 4 try-catch blocks | 0 try-catch blocks | ✅ Refactored |
| **Services** | 1 try-catch block | 0 try-catch blocks | ✅ Refactored |
| **Repositories** | 18 try-catch blocks | 18+ enhanced try-catch blocks | ✅ Enhanced |
| **BLoCs** | 1 try-catch (removed earlier) | 0 try-catch | ✅ Clean |

**Result:** ✅ 100% compliant with "top-level only" error handling principle!

---

## 🎯 Error Flow

```
Exception thrown in Datasource/Service
           ↓
    Bubbles up to Repository
           ↓
Repository catches with try-catch
           ↓
Converts to Either<Failure, Success>
           ↓
UseCase receives Either
           ↓
BLoC uses Either.fold()
           ↓
UI reacts to state
```

**All error handling centralized at Repository - Clean Architecture achieved! 🎉**
