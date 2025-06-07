# Investrack Frontend

Investrack is a powerful inventory and staff management system designed to streamline product tracking, user registration, and business resource management. This repository contains the **Flutter frontend** of the Investrack application.

---

## 🚀 Features

- 🔐 **User Authentication**
  - Register as user or staff
  - Login with role-based access control
  - Forgot password navigation (future feature)

- 📦 **Inventory Management**
  - Product registration
  - Product listing
  - Edit/update/delete product details
  - Image upload with product

- 👥 **User Management**
  - Fetch user details after login
  - Staff approval system (controlled via backend)

- 🌐 **API Integration**
  - Integrated with Django REST API
  - Uses `http` for all communication with the backend

---

## 🛠️ Project Structure

```
investrack_frontend/
├── lib/
│   ├── core/
│   │   ├── services/        # API service logic
│   │   └── providers/       # User and app-wide providers
│   ├── screens/             # UI screens (login, register, dashboard, etc.)
│   └── main.dart            # Entry point
├── assets/                  # Static assets like images
├── pubspec.yaml             # Flutter dependencies
└── README.md                # This file
```

---

## ⚙️ Installation & Running

### 1. 📦 Prerequisites

- Flutter SDK (3.x recommended)
- Dart SDK
- Android Studio / VSCode
- Connected backend: [Investrack Django Backend](https://github.com/your-org/investrack_backend)

### 2. 🧪 Clone the Repository

```bash
git clone https://github.com/your-org/investrack_frontend.git
cd investrack_frontend
```

### 3. 📥 Install Dependencies

```bash
flutter pub get
```

### 4. 🔧 Configure API URL

Ensure your backend is running, and update the base URL in your API service files:

```dart
const String baseUrl = 'http://10.0.2.2:8000/api'; // Android emulator
```

For physical device or web, replace with your machine IP (e.g. `192.168.x.x`).

### 5. ▶️ Run the App

```bash
flutter run
```

---

## 🧪 Backend API Expectations

Ensure your backend returns consistent JSON structure, e.g., for login:

```json
{
  "success": true,
  "message": "Login successful.",
  "data": {
    "user": {
      "email": "user@example.com",
      "first_name": "John",
      "username": "john123",
      "role": "user"
    }
  }
}
```

---

## 📸 Screenshots

> (Add screenshots of Login, Dashboard, and Inventory screens here)

---

## 🙋‍♂️ Contributing

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/login`)
3. Commit your changes (`git commit -m 'Add login screen'`)
4. Push to the branch (`git push origin feature/login`)
5. Create a Pull Request

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

## 👨‍💻 Maintainers

- [Hridoy](https://[github.com/Atik-hridoy])


---
```
