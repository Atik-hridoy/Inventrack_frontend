# Inventrack Frontend

**Inventrack** is a Flutter-based ERP-style application frontend designed to manage inventory, users, and roles with an organized modular structure.

This repository contains the **frontend** for the Inventrack system, built using Flutter with a scalable and maintainable architecture.

---

## ✨ Features Implemented So Far

- ✅ **Modular folder structure** (`features/`, `routes/`, `config/`)
- ✅ Centralized routing using named routes (`AppRoutes`)
- ✅ Theme configuration with `AppTheme`
- ✅ Responsive Login and Registration screens
- ✅ Dashboard screen with logout functionality
- ✅ Navigation setup for login → dashboard → logout → login
- ✅ Clean navigation stack using `pushReplacementNamed` and `pushNamedAndRemoveUntil`

---

## 📁 Directory Structure

```bash
lib/ ├── config/ │ └── app_theme.dart │ ├── features/ │ ├── auth/ │ │ └── screens/ │ │ ├── login_screen.dart │ │ └── register_screen.dart │ │ │ └── dashboard/ │ └── screens/ │ └── dashboard_screen.dart │ ├── routes/ │ └── app_routes.dart │ ├── app.dart └── main.dart
```








---

## 🚀 Getting Started

Make sure Flutter is installed and your environment is set up. Then:

```bash
git clone https://github.com/Atik-hridoy/Inventrack_frontend.git
cd inventrack_frontend
flutter pub get
flutter run
