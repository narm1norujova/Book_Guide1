# 📚 Book Explorer App

A Flutter application for browsing, exploring, and favoriting a curated library of books. Built with an interactive UI, persistent storage, and rich theming, this app allows users to filter by genre, search by title/author, toggle between view modes, and dive into detailed book pages.

---

## 👩‍💻 Students
- Orujova Narmin  
- Abbasova Hurnisa  
- Hajiyeva Nurlana  

---

## 📁 Project Overview

**Project Title:** `Book_Explorer_Project_Guide`  
**Package Name:** `flutter_application_1`  
**Version:** `1.0.0+1`

The project is a mobile-friendly Flutter app that showcases a collection of books loaded from local assets. Key features include:

- Grid/List view toggling
- Genre-based filtering
- Text-based search
- Favorites page with persistent storage
- Detailed book pages with preview links

---

## 📂 File Descriptions

### 1. `pubspec.yaml`
Defines:
- App metadata, environment constraints
- Core dependencies:
  - `shared_preferences` – local storage
  - `url_launcher` – open links
  - `palette_generator` – color extraction
  - `logger`, `flutter_lints`, etc.
- Assets: book data JSON and cover images

### 2. `main.dart`
- Entry point of the app.
- Configures:
  - Theme (green primarySwatch)
  - App-wide font, card styles, AppBar styles
  - Home screen set to `HomePage`
  - Removes debug banner

### 3. `book_card.dart`
- Reusable `BookCard` widget
- Grid or list layout toggle
- Favorite toggling with `shared_preferences`
- Animations and responsive design

### 4. `book_data_loader.dart`
- Utility to load books from `assets/books.json`
- Includes:
  - `loadBooks()` – fetches & parses JSON
  - `getUniqueGenres()` – extracts genre filters

### 5. `home_page.dart`
- Main screen with:
  - Genre filter (ChoiceChips)
  - Search bar
  - View toggle button
  - Navigation to Favorites & Detail screens
- Book data loaded and filtered dynamically

### 6. `favorites_page.dart`
- Displays all favorite books
- Loads favorites from `shared_preferences`
- Grid view with BookCards
- Navigation to detail page on tap

### 7. `book_detail_page.dart`
- Shows detailed book information:
  - Cover, title, author, year, genre
  - Tagline and preview link
  - Favorite toggle with snackbar feedback
- Consistent theme and structured layout

### 8. `book.dart`
- `Book` data model with:
  - Fields: `id`, `title`, `author`, `year`, `genre`, `coverImageUrl`, `tagline`, `previewLink`
  - JSON serialization methods for storage and parsing

---

## ▶️ How to Run

Open terminal and follow the steps below:

```bash
# Check if Flutter is set up
flutter doctor

# Connect your device or emulator
flutter devices

# Run the app
flutter run
