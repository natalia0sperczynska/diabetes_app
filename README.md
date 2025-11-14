# diabetes_app

A cross-platform diabetes management app.

## Key Features (Planned)

* **Glucose Monitoring:** Integration with a glucose sensor.
* **Activity Tracking:** Integration with Health APIs (Apple Health / Google Fit) to monitor physical activity.
* **Meal Log:** Logging meals and carbohydrate intake.
* **Statistics:** Charts and analytics to help with diabetes management.

## Architecture

This application uses **MVVM (Model-View-ViewModel)** pattern

* **State Management:** `provider`
* **UI-Logic Binding:** `ChangeNotifier`
* **Dependency Injection (DI):** `MultiProvider` to provide ViewModels throughout the widget tree.
* **Backend / Database:** `Firebase` (for authentication, storing user data, meals, etc.)

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
