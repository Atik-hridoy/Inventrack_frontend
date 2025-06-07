# Inventrack Frontend

A modern, responsive Flutter web and mobile frontend for inventory management, featuring categorized product feeds, search, and beautiful UI.

---

## 🚀 Features

- **Product Feed:**  
  Displays products grouped by category (e.g., Lifestyle, Electronics, Tech, Fashion) in a modern, e-commerce style feed.

- **Category Mapping:**  
  Product categories are mapped from backend codes to user-friendly display names.

- **Animated Search Bar:**  
  Elegant, animated search bar for instant product filtering.

- **Responsive Design:**  
  Product cards and grids adapt to all screen sizes, from mobile to large desktop.

- **Blurry Gradient Background:**  
  Attractive, modern background for a premium look.

- **Product Details:**  
  Each product card shows image, name, description, SKU, price, and quantity.

---

## 🛠️ Tech Stack

- **Flutter** (Web & Mobile)
- **Dart**
- **Django** (Backend, see [Inventrack Backend](https://github.com/Atik-hridoy/Inventrack_backend))
- **Provider** (State management)
- **REST API** (JSON)

---

## 🗂️ Project Structure

```
inventrack_frontend/
├── lib/
│   ├── features/
│   │   ├── auth/
│   │   └── product/
│   │       └── screens/
│   │           └── product_feed_screen.dart
│   ├── data/
│   │   ├── data_providers/
│   │   │   └── product_api.dart
│   │   └── models/
│   │       └── product.dart
│   └── main.dart
└── ...
```

---

## 🧑‍💻 How to Run

1. **Clone the repo:**
   ```sh
   git clone https://github.com/Atik-hridoy/Inventrack_frontend.git
   cd Inventrack_frontend
   ```

2. **Install dependencies:**
   ```sh
   flutter pub get
   ```

3. **Run the app:**
   - For web:
     ```sh
     flutter run -d chrome
     ```
   - For mobile:
     ```sh
     flutter run
     ```

---

## 🗃️ Category Mapping

Make sure your backend product categories use codes like:

- `lifestyle`
- `electronics`
- `tech`
- `fashion`

And that your Dart map matches:

```dart
const Map<String, String> categoryDisplayNames = {
  'lifestyle': 'Lifestyle',
  'electronics': 'Electronics',
  'tech': 'Tech',
  'fashion': 'Fashion',
  'other': 'Other',
};
```

If you have more categories in your Django model, add them here as well.

---

## 📝 Contributing

1. Create a new branch:
   ```sh
   git checkout -b add-category
   ```
2. Make your changes.
3. Commit and push:
   ```sh
   git add .
   git commit -m "Add category mapping and group products by category in feed screen"
   git push origin add-category
   ```
4. Open a Pull Request on GitHub.

---

## 📄 License

MIT License

---

## 🙋‍♂️ Questions?

Open an issue or contact [@Atik-hridoy](https://github.com/Atik-hridoy) on GitHub.

---

**Happy Inventracking!**
