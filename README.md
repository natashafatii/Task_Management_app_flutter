# 📝 Task Management App

A **Flutter-based Task Management App** designed to help users **organize, track, and manage tasks efficiently**.  
This project demonstrates **Firebase integration, state management with Provider, theming (light & dark mode), reusable widgets, and clean architecture** for scalability.

---

## 🚀 Features
- 🔐 **User Authentication** (Signup, Login, Password Reset with Firebase Auth)  
- ✅ **Task CRUD Operations** (Add, Edit, Delete, View)  
- 🎯 **Priority System** (High, Medium, Low)  
- 👤 **User Profiles** (Edit profile, view users, profile picture storage)  
- 🌗 **Light & Dark Theme Support**  
- 📡 **Real-time Updates** with **Firestore**  
- 📦 **Reusable Widgets** (custom app bar, task tile, task dialog, empty state, loading indicator)  
- 🖼️ **Splash Screen** with smooth transition  
- 🛠️ **Form Validation & Utilities** (async, date-time, dialogs, helpers)  
- 🏗️ **Clean Architecture & Folder Structure** for maintainability  

---

## 📂 Folder Structure
'''
lib/
├── constants/ # App constants
│ ├── app_colors.dart
│ ├── app_constants.dart
│ ├── app_strings.dart
│ └── app_style.dart
│
├── controllers/ # Business logic
│ └── signup_controller.dart
│
├── models/ # Data models
│ ├── task_model.dart
│ └── user_model.dart
│
├── providers/ # State management (Provider)
│ ├── auth_provider.dart
│ ├── signup_provider.dart
│ ├── task_provider.dart
│ ├── theme_provider.dart
│ └── user_provider.dart
│
├── repository/ # Data layer
│ └── authentication_repository/
│ ├── exception/
│ │ ├── auth_exceptions.dart
│ │ ├── login_exception.dart
│ │ ├── password_reset_exception.dart
│ │ └── signup_exceptions.dart
│ └── authentication_repository.dart
│
├── screens/ # UI Screens
│ ├── splash_screen.dart
│ ├── login_screen.dart
│ ├── sign_up_screen.dart
│ ├── forgot_password_screen.dart
│ ├── home_screen.dart
│ ├── add_task_screen.dart
│ ├── edit_task_screen.dart
│ ├── task_detail_screen.dart
│ ├── profile_screen.dart
│ ├── edit_profile_screen.dart
│ ├── user_list_screen.dart
│ └── user_profile_screen.dart
│
├── services/ # External services
│ ├── api_service.dart
│ ├── firestore_service.dart
│ ├── storage_service.dart
│ └── task_service.dart
│
├── themes/
│ └── light_dart_theme.dart # Application themes
│
├── utils/
│ ├── async_utils.dart
│ ├── date_time_utils.dart
│ ├── dialog_utils.dart
│ ├── helpers.dart
│ └── validators.dart
│
├── widgets/ # Reusable Widgets
│ ├── custom_app_bar.dart
│ ├── empty_state.dart
│ ├── loading_indicator.dart
│ ├── priority_chip.dart
│ ├── task_dialog.dart
│ ├── task_stats_card.dart
│ └── task_tile.dart
│
├── firebase_options.dart # Firebase config (generated)
└── main.dart # Application entry point
'''
---

## 🛠️ Tech Stack
- **Flutter** (UI framework)  
- **Dart** (Programming language)  
- **Firebase Authentication** (User login/signup/password reset)  
- **Cloud Firestore** (Realtime database)  
- **Firebase Storage** (Profile pictures, file uploads)  
- **Provider** (State management)  

---

## 🎨 UI/UX
- **Modern UI** with gradient backgrounds & smooth transitions  
- **Dark & Light Themes** for better accessibility  
- **Reusable Components** for consistency  
- **Animations** for enhanced user experience  

---

## ▶️ Getting Started

### Prerequisites
- Install [Flutter SDK 3.0+](https://docs.flutter.dev/get-started/install)  
- Install [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/) with Flutter & Dart plugins  
- Firebase project setup (Auth + Firestore + Storage)  

### Run Locally
```bash
# Clone repository
git clone https://github.com/your-username/task_management_app.git

# Navigate to project
cd task_management_app

# Install dependencies
flutter pub get

# Run Firebase configuration (requires FlutterFire CLI)
flutterfire configure

# Run the app
flutter run
