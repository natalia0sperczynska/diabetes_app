# Diabeto (diabetes_app)
<p align="center">
  <img src="https://github.com/user-attachments/assets/72c3c127-eb3e-4259-af28-e38b5fb0529d" width="250" alt="Diabeto Logo" />
</p>

A specialized cross-platform diabetes management application designed with a pixel-art aesthetic. The app provides comprehensive tools for monitoring glucose, nutrition, physical activity, biological rhythms, and includes AI-assisted analysis and a doctor panel for clinician workflows.

## Key Features (Implemented)

* **Glucose Monitoring & Dexcom and Libre Integration:**
    * Real-time glucose data fetching from Dexcom and Libre sensors via Cloud Functions.
    * Visual trend analysis and glucose measurement tracking.
* **Nutrition Log & Diet Management:**
    * Comprehensive meal logging with breakdown of calories, proteins, fats, and carbohydrates.
    * Automatic calculation of **Carb Units (BE)** and **Glycemic Load**.
    * Barcode scanning using Google ML Kit for quick food entry.
    * Local food database powered by Hive for offline access.
* **Activity Tracking (Health Connect):**
    * Native Android integration with **Health Connect** to monitor steps and physical activity.
    * Native Android integration with **Mi Fitness** to monitor steps, oxygenation and sleep (values gathered by a compatible smartwatch.
* **Bio-Rhythm (Menstrual Cycle) Tracker:**
    * Dedicated "Bio-Rhythm" screen to log cycles.
    * **Insulin Insight:** Provides automated warnings about high insulin resistance or sensitivity based on the current cycle phase.
* **AI Diagnostics & Reporting:**
    * AI-powered data analysis to identify trends and "Best Days".
    * Automated PDF report generation for medical consultations, including metrics tables and AI summaries.
* **Doctor Panel:**
    * Dedicated view for medical professionals, with a patient list management.
    * Ability for clinitians to view aggregated patient analysis and daily charts of blood glucose levels.
* **Customization & Vibe:**
    * Dynamic theme switching (Light/Dark).
    * Retro CRT overlay and glitch effects for a unique "Cyber" user experience.

## Architecture

This application follows the **MVVM (Model-View-ViewModel)** pattern for clean separation of concerns.

* **State Management:** `provider` used for global state and business logic.
* **View Models:** Dedicated VMs for Auth, Home, Meals, Theme, Statistics, Health Connect, Analysis, Menstrual Cycle, and Doctor Workflow.
* **Data Persistence:**
    * **Firebase:** Authentication, Firestore for cloud data
    * **Cloud Functions:** Python-based 2nd-gen functions for sensor APIs, and backend tasks related to that.
    * **Hive:** High-performance local NoSQL database for food items.
    * **Secure Storage:** `flutter_secure_storage` for protecting Dexcom and Libre credentials.

## Tech Stack

* **Language:** Dart (Flutter SDK >=3.2.0).
* **UI Components:** `fl_chart` (Analytics), `table_calendar` (Bio-rhythms), `google_fonts` (Typography).
* **Hardware/Native:** `camera` (Scanning), `health` (Health Connect API).
* **AI:** `firebase_ai` for diagnostic processing.

## Getting Started

1.  **Environment:** Ensure you have Flutter 3.2.0 or higher.
2.  **Firebase Setup:** The app requires a configured `google-services.json` (Android) or `GoogleService-Info.plist` (iOS). As well as deployment of Cloud Functions, so navigate to `/functions`, intall dependencies from `requirements.txt`, and run `firebase deploy --only functions`.
3.  **Local Database:** Run `flutter pub run build_runner build` to generate Hive adapters after every modification.
4.  **Health Connect:** On Android, ensure the Health Connect app is installed and permissions are granted.
