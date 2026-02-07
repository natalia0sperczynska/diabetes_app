# Diabeto (diabetes_app)

A specialized cross-platform diabetes management application designed with a pixel-art aesthetic. The app provides comprehensive tools for monitoring glucose, nutrition, physical activity, and biological rhythms.

## Key Features (Implemented)

* **Glucose Monitoring & Dexcom and Libre Integration:** * Real-time glucose data fetching from Dexcom and Libre sensors via Cloud Functions.
    * Visual trend analysis and glucose measurement tracking.
* **Nutrition Log & Diet Management:**
    * Comprehensive meal logging with breakdown of calories, proteins, fats, and carbohydrates.
    * Automatic calculation of **Carb Units (BE)** and **Glycemic Load**.
    * Barcode scanning using Google ML Kit for quick food entry.
    * Local food database powered by Hive for offline access.
* **Activity Tracking (Health Connect):**
    * Native Android integration with **Health Connect** to monitor steps and physical activity.
* **Bio-Rhythm (Menstrual Cycle) Tracker:**
    * Dedicated "Bio-Rhythm" screen to log cycles.
    * **Insulin Insight:** Provides automated warnings about high insulin resistance or sensitivity based on the current cycle phase.
* **AI Diagnostics & Reporting:**
    * AI-powered data analysis to identify trends and "Best Days".
    * Automated PDF report generation for medical consultations, including metrics tables and AI summaries.
* **Customization & Vibe:**
    * Dynamic theme switching (Light/Dark).
    * Retro CRT overlay and glitch effects for a unique "Cyber" user experience.

## Architecture

This application follows the **MVVM (Model-View-ViewModel)** pattern for clean separation of concerns.

* **State Management:** `provider` used for global state and business logic.
* **View Models:** Dedicated VMs for Auth, Home, Meals, Theme, Statistics, Health Connect, Analysis, and Menstrual Cycle.
* **Data Persistence:** * **Firebase:** Authentication, Firestore for cloud data, and Cloud Functions for sensor APIs.
    * **Hive:** High-performance local NoSQL database for food items.
    * **Secure Storage:** `flutter_secure_storage` for protecting Dexcom and Libre credentials.

## Tech Stack

* **Language:** Dart (Flutter SDK >=3.2.0).
* **UI Components:** `fl_chart` (Analytics), `table_calendar` (Bio-rhythms), `google_fonts` (Typography).
* **Hardware/Native:** `camera` (Scanning), `health` (Health Connect API).
* **AI:** `firebase_ai` for diagnostic processing.

## Getting Started

1.  **Environment:** Ensure you have Flutter 3.2.0 or higher.
2.  **Firebase Setup:** The app requires a configured `google-services.json` (Android) or `GoogleService-Info.plist` (iOS).
3.  **Local Database:** Run `flutter pub run build_runner build` to generate Hive adapters if modified.
4.  **Health Connect:** On Android, ensure the Health Connect app is installed and permissions are granted.
