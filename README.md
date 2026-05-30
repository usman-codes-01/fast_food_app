# Campus Bites

A campus canteen ordering app built with Flutter, GetX, and Firebase.

## Features

- Splash → Onboarding → Login/Register flow
- Student: browse menu (categories + search), cart with quantity, place order, view live order status, profile + dark mode
- 4-digit pickup OTP shown to student, verified by kitchen at handoff
- Admin: live kitchen display (Pending / Cooking / Ready), multi-item orders, OTP verification, full menu CRUD (add/edit/delete, toggle stock)

## One-time Firebase Setup

The repo intentionally ships **without** Firebase keys. On first launch the app will show a "Firebase not configured" screen. To wire it up:

```bash
# 1. Install CLIs (one-time)
dart pub global activate flutterfire_cli
npm install -g firebase-tools

# 2. Log into Firebase
firebase login

# 3. From the project root: pick / create a Firebase project
flutterfire configure
```

`flutterfire configure` will:

- Generate the real `lib/firebase_options.dart` (overwriting the stub)
- Place `android/app/google-services.json`
- Place `ios/Runner/GoogleService-Info.plist` (if iOS selected)

After running it, in the Firebase Console enable:

- **Authentication → Email/Password**
- **Cloud Firestore** (start in test mode)

Then:

```bash
flutter pub get
flutter run
```

## Default Admin Account

Register a new account with the email `admin@canteen.com` to land on the admin dashboard. Any other email is treated as a student.
