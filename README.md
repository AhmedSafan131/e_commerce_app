# 🛍️ E-Commerce Mobile App

A full-stack **Flutter e-commerce application** with integrated **Paymob payment gateway**, **Firebase backend**, and **Clean Architecture** design pattern.

## 📱 Features

✅ User Authentication (Email/Password)  
✅ Product Catalog with Categories  
✅ Shopping Cart (Local Storage)  
✅ Checkout & Payment Processing  
✅ Paymob Payment Gateway Integration  
✅ Order History & Management  
✅ Real-time Database (Cloud Firestore)  

## 🏗️ Architecture

- **Pattern**: Clean Architecture + BLoC
- **State Management**: flutter_bloc
- **Dependency Injection**: get_it
- **Navigation**: go_router
- **Backend**: Firebase (Auth, Firestore, Cloud Functions)
- **Payment**: Paymob Accept

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.10.7+)
- Dart SDK (3.10.7+)
- Node.js (18+) for Firebase Functions
- Firebase CLI: `npm install -g firebase-tools`

### Installation

```bash
# 1. Install Flutter dependencies
flutter pub get

# 2. Install Firebase Functions dependencies
cd functions
npm install

# 3. Configure Paymob credentials
# Edit functions/.env with your Paymob API keys

# 4. Run local payment server (for testing)
node local-server.js

# 5. Run the app
flutter run
```

## 📚 Documentation

### 🎯 For Interviews & Understanding

1. **[PROJECT_TECHNICAL_OVERVIEW.md](PROJECT_TECHNICAL_OVERVIEW.md)** (21KB)
   - Complete technical documentation
   - All technologies explained
   - Payment flow details
   - Webhook implementation
   - Architecture patterns
   - **READ THIS FIRST!**

2. **[INTERVIEW_CHEAT_SHEET.md](INTERVIEW_CHEAT_SHEET.md)** (8KB)
   - Quick reference guide
   - Common interview questions & answers
   - Key concepts summary
   - Technical terms glossary
   - **PERFECT FOR LAST-MINUTE REVIEW!**

3. **[ARCHITECTURE_DIAGRAMS.md](ARCHITECTURE_DIAGRAMS.md)** (39KB)
   - Visual system architecture
   - Payment flow sequence diagrams
   - BLoC pattern visualization
   - Data structure diagrams
   - **GREAT FOR VISUAL LEARNERS!**

### 🛠️ For Development & Setup

4. **[PAYMOB_SETUP.md](PAYMOB_SETUP.md)** (4KB)
   - How to get Paymob credentials
   - Configuration steps
   - Testing guide

5. **[LOCAL_SERVER_GUIDE.md](LOCAL_SERVER_GUIDE.md)** (2KB)
   - Running local payment server
   - Testing without Firebase deployment
   - Network configuration

6. **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** (2KB)
   - Deploy Firebase Functions
   - Build Flutter app for production
   - Environment configuration

7. **[ENABLE_APIS_GUIDE.md](ENABLE_APIS_GUIDE.md)** (2KB)
   - Firebase API setup
   - Required services

8. **[EMULATOR_TESTING_GUIDE.md](EMULATOR_TESTING_GUIDE.md)** (3KB)
   - Testing with Firebase emulators
   - Local development setup

9. **[PAYMENT_ERRORS_GUIDE.md](PAYMENT_ERRORS_GUIDE.md)** (3KB)
   - Common payment errors
   - Troubleshooting solutions

## 🎓 Recommended Reading Order

### For Interview Preparation:
1. **INTERVIEW_CHEAT_SHEET.md** - Quick overview
2. **PROJECT_TECHNICAL_OVERVIEW.md** - Deep dive
3. **ARCHITECTURE_DIAGRAMS.md** - Visual understanding

### For Development:
1. **PAYMOB_SETUP.md** - Get credentials
2. **LOCAL_SERVER_GUIDE.md** - Start testing
3. **DEPLOYMENT_GUIDE.md** - Go to production

## 💳 Payment System

### Current Setup: Local Development Server
- **Server**: `functions/local-server.js`
- **URL**: `http://192.168.1.14:3000`
- **Start**: `node local-server.js`
- **Use**: Testing without Firebase deployment

### Production Setup: Firebase Cloud Functions
- **Server**: `functions/index.js`
- **URL**: `https://us-central1-e-commerce-app-2dc94.cloudfunctions.net/paymob`
- **Deploy**: `firebase deploy --only functions`
- **Use**: Production environment

## 🔧 Tech Stack

### Frontend (Flutter)
- **flutter_bloc** - State management
- **get_it** - Dependency injection
- **go_router** - Navigation
- **dio** - HTTP client
- **cached_network_image** - Image caching
- **shared_preferences** - Local storage

### Backend (Firebase)
- **Firebase Authentication** - User management
- **Cloud Firestore** - NoSQL database
- **Cloud Functions** - Serverless backend

### Payment
- **Paymob Accept** - Payment gateway
- **HMAC Verification** - Webhook security

## 📂 Project Structure

```
lib/
├── core/              # Shared utilities
├── features/          # Feature modules
│   ├── auth/          # Authentication
│   ├── products/      # Product catalog
│   ├── cart/          # Shopping cart
│   ├── checkout/      # Payment processing
│   └── orders/        # Order management
├── shared/            # Shared widgets
└── main.dart          # App entry point

functions/
├── index.js           # Firebase Cloud Functions
├── local-server.js    # Local development server
└── .env               # Paymob credentials
```

## 🧪 Testing

### Test Payment Flow
1. Start local server: `cd functions && node local-server.js`
2. Run app: `flutter run`
3. Add items to cart
4. Go to checkout and click "Pay"
5. Use Paymob test card: `4987654321098769`

### Monitor Logs
- **Flutter Console**: App-side logs
- **Server Terminal**: Payment processing logs
- **Firebase Console**: Production logs

## 🚀 Deployment

### Build Flutter App
```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS (requires Mac)
flutter build ios --release
```

### Deploy Firebase Functions
```bash
firebase login
firebase deploy --only functions
```

## 📞 Support & Troubleshooting

See **[PAYMENT_ERRORS_GUIDE.md](PAYMENT_ERRORS_GUIDE.md)** for common issues and solutions.

## 👨‍💻 Author

**Ahmed Safan**  
Email: ahmedsafan131@gmail.com

## 📄 License

This project is for educational and portfolio purposes.

---

**Version**: 1.0.0  
**Last Updated**: February 7, 2026  
**Flutter Version**: 3.10.7+  
**Dart Version**: 3.10.7+
