# 💰 Expense Tracker

A beautiful, production-quality personal expense tracker built with **Flutter**.

## ✨ Features

- ➕ **Add / Edit / Delete** expenses with title, amount, category, date, and notes
- 📊 **Dashboard** with today/week/month spending summaries
- 🥧 **Interactive Pie Charts** with category breakdown
- 📅 **Date Filtering** (week / month / all-time)
- 🏷️ **8 Categories** — Food, Transport, Shopping, Bills, Entertainment, Health, Education, Other
- 💾 **SQLite** local database — works fully offline
- 🎨 **Premium dark theme** with glassmorphism and gradients
- 🔄 **Swipe-to-delete** with undo support
- 📱 **Cross-platform** — Android, iOS, Desktop

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.x (Dart) |
| **State Management** | Provider |
| **Local Database** | SQLite via `sqflite` |
| **Charts** | `fl_chart` |
| **Fonts** | Google Fonts (Inter) |
| **Architecture** | Models → Services → Providers → UI |

## 📁 Project Structure

```
lib/
├── main.dart               # Entry point
├── app.dart                # MaterialApp + theme
├── models/
│   ├── expense.dart        # Expense data model
│   └── category.dart       # Category enum + extensions
├── services/
│   └── database_service.dart  # SQLite CRUD
├── providers/
│   └── expense_provider.dart  # ChangeNotifier state
├── screens/
│   ├── home_screen.dart       # Dashboard + expense list
│   ├── add_expense_screen.dart # Add/Edit form
│   └── stats_screen.dart      # Charts & analytics
├── widgets/
│   ├── expense_tile.dart      # Expense list item
│   ├── category_chip.dart     # Category selector
│   ├── summary_card.dart      # Spending summary card
│   └── pie_chart_widget.dart  # Interactive pie chart
└── utils/
    ├── constants.dart         # Colors, spacing, strings
    ├── date_helpers.dart      # Date formatting
    └── theme.dart             # App theme configuration
```

## 🚀 Getting Started

```bash
cd expense_tracker_app
flutter pub get
flutter run
```

## 📱 Screenshots

| Dashboard | Add Expense | Statistics |
|---|---|---|
| Summary cards + expense list | Category chips + date picker | Pie chart + breakdown |

## 🎯 Architecture

```
User Action → Screen (UI)
                ↓
           Provider (State)
                ↓
         DatabaseService (SQLite)
                ↓
           Local Storage
```
